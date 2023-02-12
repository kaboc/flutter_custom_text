import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';

import 'package:text_parser/text_parser.dart' show TextElement;

import 'definition_base.dart';
import 'definitions.dart';
import 'gesture_details.dart';
import 'transient_elements_builder.dart';

const kLongPressDuration = Duration(milliseconds: 600);

class SpanData {
  SpanData({
    required this.index,
    required this.text,
    required this.label,
    required this.link,
    required this.definition,
    required this.tappable,
  });

  final int index;
  final String text;
  final String label;
  final String link;
  final Definition definition;
  final bool tappable;
}

class NotifierSettings {
  NotifierSettings({
    required List<Definition> definitions,
    this.matchStyle,
    this.tapStyle,
    this.hoverStyle,
    this.onTap,
    this.onLongPress,
    Duration? longPressDuration,
  })  : definitions = {
          for (final def in definitions) def.matcher.runtimeType: def,
        },
        longPressDuration = longPressDuration ?? kLongPressDuration;

  final Map<Type, Definition> definitions;
  final TextStyle? matchStyle;
  final TextStyle? tapStyle;
  final TextStyle? hoverStyle;
  final void Function(GestureDetails)? onTap;
  final void Function(GestureDetails)? onLongPress;
  final Duration longPressDuration;
}

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

  @override
  set value(TextSpan span) {
    if (!_disposed) {
      super.value = span;
    }
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
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

    final isTappable = def.onTap != null ||
        def.onLongPress != null ||
        _settings.onTap != null ||
        _settings.onLongPress != null;

    final label = def.labelSelector == null
        ? element.text
        : def.labelSelector!(element.groups);

    final spanData = SpanData(
      index: index,
      text: element.text,
      label: label,
      link: def.tapSelector == null
          ? element.text
          : def.tapSelector!(element.groups),
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
    _style = style;

    final spans = [
      for (var i = spanRange.start; i < spanRange.end; i++)
        _span(i, elements[i]),
    ];

    value = TextSpan(
      children: List.of(value.children!)
        ..replaceRange(replaceRange.start, replaceRange.end + 1, spans),
    );
  }

  TextSpan _nonTappableTextSpan({required SpanData spanData}) {
    var matchStyle = spanData.definition.matchStyle ?? _settings.matchStyle;
    var hoverStyle = spanData.definition.hoverStyle ?? _settings.hoverStyle;
    final hasHoverStyle = hoverStyle != null;

    if (_style != null) {
      matchStyle = _style!.merge(matchStyle);
      hoverStyle = _style!.merge(hoverStyle);
    }

    _tapRecognizers[spanData.index]?.dispose();
    _tapRecognizers.remove(spanData.index);

    return TextSpan(
      text: spanData.label,
      // hoverStyle must be cancelled when text spans are built.
      // Otherwise, if a span with hoverStyle is being hovered on
      // during a build and then gets a different index in new spans, the
      // style is mistakenly applied to a new span at the original index.
      style: _hoverIndex == spanData.index && !_isBuilding
          ? hoverStyle
          : matchStyle,
      mouseCursor: spanData.definition.mouseCursor,
      onEnter: hasHoverStyle
          ? (event) => _updateHoverIndex(
                spanData: spanData,
                globalPosition: event.position,
                localPosition: event.localPosition,
                hovered: true,
              )
          : null,
      onExit: hasHoverStyle
          ? (event) => _updateHoverIndex(
                spanData: spanData,
                globalPosition: event.position,
                localPosition: event.localPosition,
                hovered: false,
              )
          : null,
    );
  }

  TextSpan _tappableTextSpan({required SpanData spanData}) {
    var matchStyle = spanData.definition.matchStyle ?? _settings.matchStyle;
    var hoverStyle = spanData.definition.hoverStyle ?? _settings.hoverStyle;
    var tapStyle = spanData.definition.tapStyle ?? _settings.tapStyle;
    tapStyle ??= hoverStyle ?? matchStyle;
    final hasHoverStyle = hoverStyle != null;

    if (_style != null) {
      matchStyle = _style!.merge(matchStyle);
      tapStyle = _style!.merge(tapStyle);
      hoverStyle = _style!.merge(hoverStyle);
    }

    _configureRecognizer(
      spanData: spanData,
      style: _style,
    );

    return TextSpan(
      text: spanData.label,
      // tapStyle and hoverStyle must be cancelled when text spans are built.
      // Otherwise, if a span with such a style is being tapped or hovered
      // on during a build and then gets a different index in new spans,
      // the style is mistakenly applied to a new span at the original index.
      style: _isBuilding
          ? matchStyle
          : _tapIndex == spanData.index
              ? tapStyle
              : (_hoverIndex == spanData.index ? hoverStyle : matchStyle),
      recognizer: _tapRecognizers[spanData.index],
      mouseCursor: spanData.definition.mouseCursor,
      onEnter: hasHoverStyle
          ? (event) => _updateHoverIndex(
                spanData: spanData,
                globalPosition: event.position,
                localPosition: event.localPosition,
                hovered: true,
              )
          : null,
      onExit: hasHoverStyle
          ? (event) => _updateHoverIndex(
                spanData: spanData,
                globalPosition: event.position,
                localPosition: event.localPosition,
                hovered: false,
              )
          : null,
    );
  }

  void _configureRecognizer({
    required SpanData spanData,
    required TextStyle? style,
  }) {
    // Reuses the tap recognizer instead of discarding
    // the previous one and creating a new one.
    _tapRecognizers[spanData.index] ??= TapGestureRecognizer();

    _tapRecognizers[spanData.index]
      ?..onTapDown = (d) {
        final details = GestureDetails(
          gestureType: GestureType.longPress,
          matcherType: spanData.definition.matcher.runtimeType,
          text: spanData.link,
          label: spanData.label,
          globalPosition: d.globalPosition,
          localPosition: d.localPosition,
        );

        if (spanData.definition.onLongPress != null) {
          _longPressTimer = Timer(
            _settings.longPressDuration,
            () => spanData.definition.onLongPress!(details),
          );
        } else if (_settings.onLongPress != null) {
          _longPressTimer = Timer(
            _settings.longPressDuration,
            () => _settings.onLongPress?.call(details),
          );
        }

        _updateTapIndex(
          spanData: spanData,
          tapped: true,
        );
      }
      ..onTapUp = (d) {
        // A tap is valid if long presses are not enabled
        // or if the press was shorter than a long press and
        // therefore the timer is still active.
        final timer = _longPressTimer;
        if (timer == null || timer.isActive) {
          final details = GestureDetails(
            gestureType: GestureType.tap,
            matcherType: spanData.definition.matcher.runtimeType,
            text: spanData.link,
            label: spanData.label,
            globalPosition: d.globalPosition,
            localPosition: d.localPosition,
          );

          if (spanData.definition.onTap != null) {
            spanData.definition.onTap!(details);
          } else if (_settings.onTap != null) {
            _settings.onTap?.call(details);
          }
        }
        _tapRecognizers[spanData.index]?.onTapCancel!();
      }
      ..onTapCancel = () {
        _longPressTimer?.cancel();
        _longPressTimer = null;

        _updateTapIndex(
          spanData: spanData,
          tapped: false,
        );
      };
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
    required Offset globalPosition,
    required Offset localPosition,
    required bool hovered,
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
