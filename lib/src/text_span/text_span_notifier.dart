import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'package:text_parser/text_parser.dart' show TextElement;

import '../definitions.dart';
import 'data.dart';
import 'gesture_handler.dart';
import 'transient_elements_builder.dart';

class CustomTextSpanNotifier extends ValueNotifier<TextSpan> {
  CustomTextSpanNotifier({
    required String? text,
    required TextStyle? style,
    required this.settings,
  }) : super(TextSpan(text: text, style: style));

  NotifierSettings settings;
  List<TextElement> elements = [];

  final Map<int, GestureHandler> _gestureHandlers = {};
  bool _disposed = false;
  bool _isBuilding = false;

  TextStyle? _style;
  int? _tapIndex;
  int? _hoverIndex;
  Offset? _hoverPosition;

  @override
  set value(TextSpan span) {
    if (!_disposed) {
      super.value = span;
    }
  }

  @override
  void dispose() {
    _gestureHandlers
      ..forEach((_, handler) => handler.dispose())
      ..clear();
    _disposed = true;

    super.dispose();
  }

  void buildSpan({required TextStyle? style, required int oldElementsLength}) {
    _isBuilding = true;
    _style = style;

    value = TextSpan(
      children: [
        for (var i = 0; i < elements.length; i++) _span(i, elements[i]),
      ],
    );

    // If the number of new elements is smaller than that of
    // the previous ones, the elements after the current max index
    // are no longer necessary.
    for (var i = elements.length; i < oldElementsLength; i++) {
      _gestureHandlers[i]?.dispose();
      _gestureHandlers.remove(i);
    }

    _isBuilding = false;
  }

  void buildTransientSpan({
    required TextStyle? style,
    required Range replaceRange,
    required Range spanRange,
  }) {
    _isBuilding = true;
    _style = style;

    final spans = [
      for (var i = spanRange.start; i < spanRange.end; i++)
        _span(i, elements[i]),
    ];

    value = TextSpan(
      children: List.of(value.children!)
        ..replaceRange(replaceRange.start, replaceRange.end + 1, spans),
    );

    _isBuilding = false;
  }

  InlineSpan _span(int index, TextElement element) {
    final defs = settings.definitions[element.matcherType];
    if (defs == null || defs.isEmpty) {
      return TextSpan(text: element.text, style: _style);
    }

    final def = defs[element.matcherIndex] ?? defs[defs.keys.first]!;
    if (def is SpanDefinition) {
      return def.builder!(element.text, element.groups);
    }

    final isTappable = settings.onTap != null ||
        settings.onLongPress != null ||
        settings.onGesture != null ||
        def.onTap != null ||
        def.onLongPress != null ||
        def.onGesture != null;

    final spanData = SpanData(
      index: index,
      element: element,
      text: element.text,
      shownText: def.shownText?.call(element.groups),
      actionText: def.actionText?.call(element.groups),
      definition: def,
      tappable: isTappable,
    );

    return isTappable
        ? _tappableTextSpan(spanData: spanData)
        : _nonTappableTextSpan(spanData: spanData);
  }

  TextSpan _nonTappableTextSpan({required SpanData spanData}) {
    var matchStyle = spanData.definition.matchStyle ?? settings.matchStyle;
    var hoverStyle = spanData.definition.hoverStyle ?? settings.hoverStyle;

    final style = _style;
    if (style != null) {
      matchStyle = style.merge(matchStyle);
      hoverStyle = hoverStyle == null ? null : style.merge(hoverStyle);
    }

    // This method is called frequently, so the existing handler
    // should be reused instead of created every time.
    _gestureHandlers[spanData.index] ??= GestureHandler();

    final gestureHandler = _gestureHandlers[spanData.index]
      ?..updateSettings(
        settings: settings,
        spanData: spanData,
        hoverStyle: hoverStyle,
        onMouseEnter: (event) => _updateHoverIndex(
          spanData: spanData,
          hovered: true,
          globalPosition: event.position,
        ),
        onMouseExit: (event) => _updateHoverIndex(
          spanData: spanData,
          hovered: false,
          globalPosition: event.position,
        ),
      );

    return TextSpan(
      text: spanData.shownText ?? spanData.text,
      // hoverStyle must be removed when text spans are built.
      // Otherwise, if a span with hoverStyle is being hovered on during
      // a build and then gets a different index in new spans, the style
      // is mistakenly applied to the new span at the original index.
      style: _hoverIndex == spanData.index && !_isBuilding
          ? hoverStyle
          : matchStyle,
      mouseCursor: spanData.definition.mouseCursor,
      onEnter: gestureHandler?.onEnter,
      onExit: gestureHandler?.onExit,
    );
  }

  TextSpan _tappableTextSpan({required SpanData spanData}) {
    var matchStyle = spanData.definition.matchStyle ?? settings.matchStyle;
    var hoverStyle = spanData.definition.hoverStyle ?? settings.hoverStyle;
    var tapStyle = spanData.definition.tapStyle ?? settings.tapStyle;
    tapStyle ??= hoverStyle ?? matchStyle;

    final style = _style;
    if (style != null) {
      matchStyle = style.merge(matchStyle);
      hoverStyle = hoverStyle == null ? null : style.merge(hoverStyle);
      tapStyle = style.merge(tapStyle);
    }

    // This method is called frequently, so the existing handler
    // should be reused instead of created every time.
    _gestureHandlers[spanData.index] ??= GestureHandler();

    final gestureHandler = _gestureHandlers[spanData.index]
      ?..updateSettings(
        settings: settings,
        spanData: spanData,
        hoverStyle: hoverStyle,
        onTapDown: () {
          _updateTapIndex(
            spanData: spanData,
            tapped: true,
          );
        },
        onTapCancel: () => _updateTapIndex(
          spanData: spanData,
          tapped: false,
        ),
        onMouseEnter: (event) => _updateHoverIndex(
          spanData: spanData,
          hovered: true,
          globalPosition: event.position,
        ),
        onMouseExit: (event) => _updateHoverIndex(
          spanData: spanData,
          hovered: false,
          globalPosition: event.position,
        ),
      );

    return TextSpan(
      text: spanData.shownText ?? spanData.text,
      // tapStyle and hoverStyle must be cancelled when text spans are built.
      // Otherwise, if a span with such a style is being pressed or hovered
      // on during a build and then gets a different index in new spans,
      // the style is mistakenly applied to a new span at the original index.
      style: _isBuilding
          ? matchStyle
          : _tapIndex == spanData.index
              ? tapStyle
              : (_hoverIndex == spanData.index ? hoverStyle : matchStyle),
      recognizer: gestureHandler?.recognizer,
      mouseCursor: spanData.definition.mouseCursor,
      onEnter: gestureHandler?.onEnter,
      onExit: gestureHandler?.onExit,
    );
  }

  void _updateNonTappableSpan({required SpanData spanData}) {
    // Avoids the range error that occurs if text spans are
    // reduced while one of them is still hovered on.
    //
    // Also suppresses an update of the span if the text at the index
    // has changed because it means this method has been triggered by
    // the hover handler of the old span.
    // If it is not suppressed, the new span will get a wrong text.
    if (spanData.index >= value.children!.length ||
        elements[spanData.index].text != spanData.text) {
      return;
    }

    // For causing a redraw, it is necessary to replace
    // the whole TextSpan as well as update a child.
    value = TextSpan(
      children: List.of(value.children!)
        ..[spanData.index] = _nonTappableTextSpan(spanData: spanData),
    );
  }

  void _updateTappableSpan({required SpanData spanData}) {
    // Avoids the range error that occurs if text spans are
    // reduced while one of them is still hovered on.
    //
    // Also suppresses an update of the span if the text at the index
    // has changed because it means this method has been triggered by
    // the hover handler of the old span.
    // If it is not suppressed, the new span will get a wrong text.
    if (spanData.index >= value.children!.length ||
        elements[spanData.index].text != spanData.text) {
      return;
    }

    // Prevents the issue #6 by avoiding updating the value
    // when the notifier is no longer available.
    if (!_disposed) {
      // For causing a redraw, it is necessary to replace
      // the whole TextSpan as well as update a child.
      value = TextSpan(
        children: List.of(value.children!)
          ..[spanData.index] = _tappableTextSpan(spanData: spanData),
      );
    }
  }

  void _updateTapIndex({required SpanData spanData, required bool tapped}) {
    _tapIndex = tapped ? spanData.index : null;

    // Resetting hover values is necessary here.
    // Otherwise, the hover style remains if a press is
    // cancelled after the pointer leaves the text.
    _hoverIndex = null;
    _hoverPosition = null;

    _updateTappableSpan(spanData: spanData);
  }

  void _updateHoverIndex({
    required SpanData spanData,
    required bool hovered,
    required Offset globalPosition,
  }) {
    // Updates only if the span is not being pressed.
    // The previous and current hovering positions are checked for
    // preventing repetitive rebuilds that can happen when
    // CustomTextEditingController is used.
    if (_tapIndex == null && globalPosition != _hoverPosition) {
      _hoverIndex = hovered ? spanData.index : null;
      _hoverPosition = hovered ? globalPosition : null;

      spanData.tappable
          ? _updateTappableSpan(spanData: spanData)
          : _updateNonTappableSpan(spanData: spanData);
    }
  }
}
