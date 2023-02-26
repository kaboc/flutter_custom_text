import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';

import 'package:text_parser/text_parser.dart' show TextElement;

import '../definitions.dart';
import '../gesture_details.dart';
import 'data.dart';
import 'transient_elements_builder.dart';

part 'gestures.dart';

class CustomTextSpanNotifier extends ValueNotifier<TextSpan> {
  CustomTextSpanNotifier({
    required this.text,
    required NotifierSettings settings,
  })  : _settings = settings,
        super(TextSpan(text: text));

  final String text;
  NotifierSettings _settings;

  List<TextElement> elements = [];
  final Map<int, TapGestureRecognizer> _tapRecognizers = {};
  bool _disposed = false;
  bool _isBuilding = false;

  TextStyle? _style;
  Timer? _longPressTimer;
  int? _tapIndex;
  int? _hoverIndex;
  Offset? _hoverPosition;

  // For workaround to skip unwanted events in _onHover()
  Timer? _hoverHandlerDebounceTimer;
  int? _enterOrExitIndex;
  GestureKind? _lastHoverGestureKind;

  @override
  set value(TextSpan span) {
    if (!_disposed) {
      super.value = span;
    }
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _hoverHandlerDebounceTimer?.cancel();
    _tapRecognizers
      ..forEach((_, recognizer) => recognizer.dispose())
      ..clear();
    _disposed = true;

    super.dispose();
  }

  // ignore: use_setters_to_change_properties
  void updateSettings(NotifierSettings settings) {
    _settings = settings;
  }

  InlineSpan _span(int index, TextElement element) {
    final def = _settings.definitions[element.matcherType];
    if (def == null) {
      return TextSpan(text: element.text, style: _style);
    }
    if (def is SpanDefinition) {
      return def.builder!(element.text, element.groups);
    }

    final isTappable = _settings.onTap != null ||
        _settings.onLongPress != null ||
        _settings.onGesture != null ||
        def.onTap != null ||
        def.onLongPress != null ||
        def.onGesture != null;

    final spanData = SpanData(
      index: index,
      element: element,
      text: element.text,
      shownText:
          def.shownText == null ? element.text : def.shownText!(element.groups),
      actionText: def.actionText == null
          ? element.text
          : def.actionText!(element.groups),
      definition: def,
      tappable: isTappable,
    );

    return isTappable
        ? _tappableTextSpan(spanData: spanData)
        : _nonTappableTextSpan(spanData: spanData);
  }

  void buildSpan({required TextStyle? style, required int oldElementsLength}) {
    _isBuilding = true;
    _style = style;

    value = TextSpan(
      children: elements.asMap().entries.map((entry) {
        final index = entry.key;
        final element = entry.value;
        return _span(index, element);
      }).toList(),
    );

    // If the number of new elements is smaller than that of
    // the previous ones, the elements after the current max index
    // are no longer necessary.
    for (var i = elements.length; i < oldElementsLength; i++) {
      _tapRecognizers[i]?.dispose();
      _tapRecognizers.remove(i);
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

  TextSpan _nonTappableTextSpan({required SpanData spanData}) {
    var matchStyle = spanData.definition.matchStyle ?? _settings.matchStyle;
    var hoverStyle = spanData.definition.hoverStyle ?? _settings.hoverStyle;

    final style = _style;
    if (style != null) {
      matchStyle = style.merge(matchStyle);
      hoverStyle = hoverStyle == null ? null : style.merge(hoverStyle);
    }

    _tapRecognizers[spanData.index]?.dispose();
    _tapRecognizers.remove(spanData.index);

    final hoverEnabled = hoverStyle != null ||
        _settings.onGesture != null ||
        spanData.definition.onGesture != null;

    return TextSpan(
      text: spanData.shownText,
      // hoverStyle must be removed when text spans are built.
      // Otherwise, if a span with hoverStyle is being hovered on during
      // a build and then gets a different index in new spans, the style
      // is mistakenly applied to the new span at the original index.
      style: _hoverIndex == spanData.index && !_isBuilding
          ? hoverStyle
          : matchStyle,
      mouseCursor: spanData.definition.mouseCursor,
      onEnter: hoverEnabled
          ? (event) => _onHover(
                spanData: spanData,
                gestureKind: GestureKind.enter,
                pointerDeviceKind: event.kind,
                globalPosition: event.position,
                localPosition: event.localPosition,
                styling: hoverStyle != null,
              )
          : null,
      onExit: hoverEnabled
          ? (event) => _onHover(
                spanData: spanData,
                gestureKind: GestureKind.exit,
                pointerDeviceKind: event.kind,
                globalPosition: event.position,
                localPosition: event.localPosition,
                styling: hoverStyle != null,
              )
          : null,
    );
  }

  TextSpan _tappableTextSpan({required SpanData spanData}) {
    var matchStyle = spanData.definition.matchStyle ?? _settings.matchStyle;
    var hoverStyle = spanData.definition.hoverStyle ?? _settings.hoverStyle;
    var tapStyle = spanData.definition.tapStyle ?? _settings.tapStyle;
    tapStyle ??= hoverStyle ?? matchStyle;

    final style = _style;
    if (style != null) {
      matchStyle = style.merge(matchStyle);
      hoverStyle = hoverStyle == null ? null : style.merge(hoverStyle);
      tapStyle = style.merge(tapStyle);
    }

    _configureRecognizer(
      spanData: spanData,
      style: style,
    );

    final hoverEnabled = hoverStyle != null ||
        _settings.onGesture != null ||
        spanData.definition.onGesture != null;

    return TextSpan(
      text: spanData.shownText,
      // tapStyle and hoverStyle must be cancelled when text spans are built.
      // Otherwise, if a span with such a style is being pressed or hovered
      // on during a build and then gets a different index in new spans,
      // the style is mistakenly applied to a new span at the original index.
      style: _isBuilding
          ? matchStyle
          : _tapIndex == spanData.index
              ? tapStyle
              : (_hoverIndex == spanData.index ? hoverStyle : matchStyle),
      recognizer: _tapRecognizers[spanData.index],
      mouseCursor: spanData.definition.mouseCursor,
      onEnter: hoverEnabled
          ? (event) => _onHover(
                spanData: spanData,
                gestureKind: GestureKind.enter,
                pointerDeviceKind: event.kind,
                globalPosition: event.position,
                localPosition: event.localPosition,
                styling: hoverStyle != null,
              )
          : null,
      onExit: hoverEnabled
          ? (event) => _onHover(
                spanData: spanData,
                gestureKind: GestureKind.exit,
                pointerDeviceKind: event.kind,
                globalPosition: event.position,
                localPosition: event.localPosition,
                styling: hoverStyle != null,
              )
          : null,
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
