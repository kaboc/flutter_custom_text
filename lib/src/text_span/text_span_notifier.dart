import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/painting.dart'
    show InlineSpan, Offset, TextSpan, TextStyle;

import 'package:text_parser/text_parser.dart' show TextElement;

import '../definitions.dart';
import 'data.dart';
import 'gesture_handler.dart';
import 'span_utils.dart';
import 'split_spans.dart';
import 'transient_elements_builder.dart';

class CustomTextSpanNotifier extends ValueNotifier<TextSpan> {
  CustomTextSpanNotifier({
    required String? initialText,
    required TextStyle? initialStyle,
    required this.settings,
  }) : super(
          initialText == null || initialText.isEmpty
              ? const TextSpan()
              : TextSpan(
                  text: initialText,
                  style: initialStyle,
                ),
        );

  NotifierSettings settings;
  List<TextElement> elements = [];
  final GestureHandlers _gestureHandlers = GestureHandlers();

  bool _disposed = false;
  bool _isBuilding = false;

  TextStyle? _style;
  bool _tapped = false;
  bool _hovered = false;
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
    _disposed = true;
    _gestureHandlers.dispose();
    super.dispose();
  }

  void buildSpan({required TextStyle? style, required int oldElementsLength}) {
    _isBuilding = true;
    _style = style;
    final spans = settings.spans?.splitSpans(elements: elements);

    value = TextSpan(
      children: elements.isEmpty
          ? null
          : [
              if (spans == null)
                for (var i = 0; i < elements.length; i++) _span(i, elements[i])
              else
                for (final i in spans.keys)
                  _span(i, elements[i], spans: spans[i]),
            ],
    );

    // If the number of new elements has become smaller than before,
    // the elements after the current max index are no longer necessary.
    for (var i = elements.length; i < oldElementsLength; i++) {
      _gestureHandlers.removeHandler(index: i);
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

  InlineSpan _span(int index, TextElement element, {List<InlineSpan>? spans}) {
    final defs = settings.definitions[element.matcherType];
    if (defs == null || defs.isEmpty) {
      return spans == null
          ? TextSpan(text: element.text, style: _style)
          : applyPropsToChildren(
              TextSpan(children: spans, style: _style),
            );
    }

    final def = defs[element.matcherIndex] ?? defs[defs.keys.first]!;

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
      spans: spans,
      shownText: def.shownText?.call(element.groups),
      actionText: def.actionText?.call(element.groups),
      definition: def,
      onTapDown: isTappable
          ? (spanData) => _updateTapIndex(
                spanData: spanData,
                tapped: true,
              )
          : null,
      onTapCancel: isTappable
          ? (spanData) => _updateTapIndex(
                spanData: spanData,
                tapped: false,
              )
          : null,
      onMouseEnter: (event, spanData) => _updateHoverIndex(
        spanData: spanData,
        hovered: true,
        globalPosition: event.position,
      ),
      onMouseExit: (event, spanData) => _updateHoverIndex(
        spanData: spanData,
        hovered: false,
        globalPosition: event.position,
      ),
    );

    return isTappable
        ? _tappableTextSpan(spanData: spanData)
        : _nonTappableTextSpan(spanData: spanData);
  }

  TextSpan _nonTappableTextSpan({required SpanData spanData}) {
    final def = spanData.definition;
    var matchStyle = def.matchStyle ?? settings.matchStyle;
    var hoverStyle = def.hoverStyle ?? settings.hoverStyle;

    var style = _style;
    if (style != null) {
      matchStyle = style.merge(matchStyle);
      hoverStyle = hoverStyle == null ? null : style.merge(hoverStyle);
    }

    final gestureHandler = _gestureHandlers.prepareHandler(
      settings: settings,
      spanData: spanData,
    );

    // hoverStyle must be removed when text spans are built.
    // Otherwise, if a span with hoverStyle is being hovered on during
    // a build and then gets a different index in new spans, the style
    // is mistakenly applied to the new span at the original index.
    style = _hovered && _hoverIndex == spanData.index && !_isBuilding
        ? hoverStyle
        : matchStyle;

    final newSpan = def is SpanDefinition
        ? TextSpan(
            style: style,
            mouseCursor: spanData.definition.mouseCursor,
            onEnter: gestureHandler.onEnter,
            onExit: gestureHandler.onExit,
            children: [
              def.builder(spanData.element.text, spanData.element.groups),
            ],
          )
        : TextSpan(
            text: spanData.shownText ??
                (spanData.spans == null ? spanData.text : null),
            style: style,
            mouseCursor: spanData.definition.mouseCursor,
            onEnter: gestureHandler.onEnter,
            onExit: gestureHandler.onExit,
            children: spanData.shownText == null ? spanData.spans : null,
          );

    return newSpan.children == null ? newSpan : applyPropsToChildren(newSpan);
  }

  TextSpan _tappableTextSpan({required SpanData spanData}) {
    final def = spanData.definition;
    var matchStyle = def.matchStyle ?? settings.matchStyle;
    var hoverStyle = def.hoverStyle ?? settings.hoverStyle;
    var tapStyle = def.tapStyle ?? settings.tapStyle;
    tapStyle ??= hoverStyle ?? matchStyle;

    var style = _style;
    if (style != null) {
      matchStyle = style.merge(matchStyle);
      hoverStyle = hoverStyle == null ? null : style.merge(hoverStyle);
      tapStyle = style.merge(tapStyle);
    }

    final gestureHandler = _gestureHandlers.prepareHandler(
      settings: settings,
      spanData: spanData,
    );
    final recognizer = gestureHandler.recognizer;

    // tapStyle and hoverStyle must be cancelled when text spans are built.
    // Otherwise, if a span with such a style is being pressed or hovered
    // on during a build and then gets a different index in new spans,
    // the style is mistakenly applied to a new span at the original index.
    style = _isBuilding
        ? matchStyle
        : _tapped && _tapIndex == spanData.index
            ? tapStyle
            : _hovered && _hoverIndex == spanData.index
                ? hoverStyle
                : matchStyle;

    final newSpan = def is SpanDefinition
        ? TextSpan(
            style: style,
            recognizer: recognizer,
            mouseCursor: spanData.definition.mouseCursor,
            onEnter: gestureHandler.onEnter,
            onExit: gestureHandler.onExit,
            children: [
              def.builder(spanData.element.text, spanData.element.groups),
            ],
          )
        : TextSpan(
            text: spanData.shownText ??
                (spanData.spans == null ? spanData.text : null),
            style: style,
            recognizer: recognizer,
            mouseCursor: spanData.definition.mouseCursor,
            onEnter: gestureHandler.onEnter,
            onExit: gestureHandler.onExit,
            children: spanData.shownText == null ? spanData.spans : null,
          );

    return newSpan.children == null ? newSpan : applyPropsToChildren(newSpan);
  }

  void _updateNonTappableSpan({required SpanData spanData}) {
    // Avoids the range error that occurs when text spans are
    // reduced while one of them is still hovered on.
    //
    // Also suppresses an update of the span if the text at the
    // index has changed because it indicates this method has been
    // triggered by the hover handler of the old span.
    // If it is not suppressed, the new span will get a wrong text.
    if (spanData.index >= value.children!.length ||
        elements[spanData.index].text != spanData.text) {
      return;
    }

    // Copying the children is necessary to cause a redraw.
    // It is not enough to only replace an element.
    value = TextSpan(
      children: List.of(value.children!)
        ..[spanData.index] = _nonTappableTextSpan(spanData: spanData),
    );
  }

  void _updateTappableSpan({required SpanData spanData}) {
    // Avoids the range error that occurs if text spans are
    // reduced while one of them is still hovered on.
    //
    // Also suppresses an update of the span if the text at the
    // index has changed because it indicates this method has been
    // triggered by the hover handler of the old span.
    // If it is not suppressed, the new span will get a wrong text.
    if (spanData.index >= value.children!.length ||
        elements[spanData.index].text != spanData.text) {
      return;
    }

    // Prevents the issue #6 by avoiding updating the value
    // when the notifier is no longer available.
    if (!_disposed) {
      // Copying the children is necessary to cause a redraw.
      // It is not enough to only replace an element.
      value = TextSpan(
        children: List.of(value.children!)
          ..[spanData.index] = _tappableTextSpan(spanData: spanData),
      );
    }
  }

  void _updateTapIndex({required SpanData spanData, required bool tapped}) {
    if (tapped == _tapped && spanData.index == _tapIndex) {
      return;
    }

    _tapped = tapped;
    _tapIndex = tapped ? spanData.index : null;

    _updateTappableSpan(spanData: spanData);
  }

  void _updateHoverIndex({
    required SpanData spanData,
    required bool hovered,
    required Offset globalPosition,
  }) {
    if (hovered == _hovered && spanData.index == _hoverIndex) {
      return;
    }

    _hovered = hovered;
    _hoverIndex = hovered ? spanData.index : null;

    // Updates only if the span is not being pressed.
    // The previous and current hovering positions are checked
    // to prevent repetitive rebuilds that can happen when
    // CustomTextEditingController is used.
    if (!_tapped && globalPosition != _hoverPosition) {
      _hoverPosition = hovered ? globalPosition : null;

      spanData.onTapDown == null
          ? _updateNonTappableSpan(spanData: spanData)
          : _updateTappableSpan(spanData: spanData);
    }
  }
}
