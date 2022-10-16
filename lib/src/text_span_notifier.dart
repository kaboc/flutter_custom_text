import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';

import 'package:text_parser/text_parser.dart' show TextElement;

import 'definition_base.dart';
import 'definitions.dart';
import 'transient_elements_builder.dart';

const _kLongPressDuration = Duration(milliseconds: 600);

class CustomTextSpanNotifier extends ValueNotifier<TextSpan> {
  CustomTextSpanNotifier({
    required this.text,
    required List<Definition> definitions,
    this.matchStyle,
    this.tapStyle,
    this.hoverStyle,
    this.onTap,
    this.onLongPress,
    Duration? longPressDuration,
  })  : _definitions = {
          for (final def in definitions) def.matcher.runtimeType: def,
        },
        _longPressDuration = longPressDuration ?? _kLongPressDuration,
        super(TextSpan(text: text));

  final String text;
  final Map<Type, Definition> _definitions;
  final TextStyle? matchStyle;
  final TextStyle? tapStyle;
  final TextStyle? hoverStyle;
  final void Function(Type, String)? onTap;
  final void Function(Type, String)? onLongPress;
  final Duration _longPressDuration;

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
  void dispose() {
    _longPressTimer?.cancel();
    _tapRecognizers
      ..forEach((_, recognizer) => recognizer.dispose())
      ..clear();
    _disposed = true;

    super.dispose();
  }

  InlineSpan _span(int index, TextElement element) {
    final def = _definitions[element.matcherType];
    if (def == null) {
      return TextSpan(text: element.text, style: _style);
    }
    if (def is SpanDefinition) {
      return def.builder!(element.text, element.groups);
    }

    final isTappable = def.onTap != null ||
        def.onLongPress != null ||
        onTap != null ||
        onLongPress != null;

    final label = def.labelSelector == null
        ? element.text
        : def.labelSelector!(element.groups);

    return isTappable
        ? _tappableTextSpan(
            index: index,
            text: element.text,
            label: label,
            link: def.tapSelector == null
                ? element.text
                : def.tapSelector!(element.groups),
            definition: def,
          )
        : _nonTappableTextSpan(
            index: index,
            text: element.text,
            label: label,
            definition: def,
          );
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

  TextSpan _nonTappableTextSpan({
    required int index,
    required String text,
    required String label,
    required Definition definition,
  }) {
    var matchStyle = definition.matchStyle ?? this.matchStyle;
    var hoverStyle = definition.hoverStyle ?? this.hoverStyle;
    final hasHoverStyle = hoverStyle != null;

    if (_style != null) {
      matchStyle = _style!.merge(matchStyle);
      hoverStyle = _style!.merge(hoverStyle);
    }

    _tapRecognizers[index]?.dispose();
    _tapRecognizers.remove(index);

    return TextSpan(
      text: label,
      // hoverStyle is cancelled when text spans are built.
      // Otherwise, if a span with hoverStyle is being hovered on
      // during it and then gets a different index in new spans, the
      // style is mistakenly applied to a new span at the original index.
      style: _hoverIndex == index && !_isBuilding ? hoverStyle : matchStyle,
      mouseCursor: definition.mouseCursor,
      onEnter: hasHoverStyle
          ? (event) => _updateHoverIndex(
                position: event.position,
                index: index,
                hovered: true,
                text: text,
                label: label,
                definition: definition,
              )
          : null,
      onExit: hasHoverStyle
          ? (event) => _updateHoverIndex(
                position: event.position,
                index: index,
                hovered: false,
                text: text,
                label: label,
                definition: definition,
              )
          : null,
    );
  }

  TextSpan _tappableTextSpan({
    required int index,
    required String text,
    required String label,
    required String link,
    required Definition definition,
  }) {
    var matchStyle = definition.matchStyle ?? this.matchStyle;
    var tapStyle = definition.tapStyle ?? this.tapStyle ?? matchStyle;
    var hoverStyle = definition.hoverStyle ?? this.hoverStyle;
    final hasHoverStyle = hoverStyle != null;

    if (_style != null) {
      matchStyle = _style!.merge(matchStyle);
      tapStyle = _style!.merge(tapStyle);
      hoverStyle = _style!.merge(hoverStyle);
    }

    _configureRecognizer(
      index: index,
      text: text,
      label: label,
      link: link,
      definition: definition,
      style: _style,
      onTap: onTap,
      onLongPress: onLongPress,
    );

    return TextSpan(
      text: label,
      // tapStyle and hoverStyle are cancelled when text spans are build.
      // Otherwise, if a span with such a style is being tapped / hovered
      // on during it and then gets a different index in new spans, the
      // style is mistakenly applied to a new span at the original index.
      style: _isBuilding
          ? matchStyle
          : _tapIndex == index
              ? tapStyle
              : (_hoverIndex == index ? hoverStyle : matchStyle),
      recognizer: _tapRecognizers[index],
      mouseCursor: definition.mouseCursor,
      onEnter: hasHoverStyle
          ? (event) => _updateHoverIndex(
                position: event.position,
                index: index,
                hovered: true,
                text: text,
                label: label,
                link: link,
                definition: definition,
              )
          : null,
      onExit: hasHoverStyle
          ? (event) => _updateHoverIndex(
                position: event.position,
                index: index,
                hovered: false,
                text: text,
                label: label,
                link: link,
                definition: definition,
              )
          : null,
    );
  }

  void _configureRecognizer({
    required int index,
    required String text,
    required String label,
    required String link,
    required Definition definition,
    required TextStyle? style,
    required void Function(Type, String)? onTap,
    required void Function(Type, String)? onLongPress,
  }) {
    // Reuses the tap recognizer instead of discarding
    // the previous one and creating a new one.
    _tapRecognizers[index] ??= TapGestureRecognizer();

    _tapRecognizers[index]
      ?..onTapDown = (_) {
        if (definition.onLongPress != null) {
          _longPressTimer = Timer(
            _longPressDuration,
            () => definition.onLongPress!(link),
          );
        } else if (onLongPress != null) {
          _longPressTimer = Timer(
            _longPressDuration,
            () => onLongPress(definition.matcher.runtimeType, link),
          );
        }

        _updateTapIndex(
          index: index,
          tapped: true,
          text: text,
          label: label,
          link: link,
          definition: definition,
        );
      }
      ..onTapUp = (_) {
        // A tap is valid if long presses are not enabled
        // or if the press was shorter than a long press and
        // therefore the timer is still active.
        final timer = _longPressTimer;
        if (timer == null || timer.isActive) {
          if (definition.onTap != null) {
            definition.onTap!(link);
          } else if (onTap != null) {
            onTap(definition.matcher.runtimeType, link);
          }
        }
        _tapRecognizers[index]?.onTapCancel!();
      }
      ..onTapCancel = () {
        _longPressTimer?.cancel();
        _longPressTimer = null;

        _updateTapIndex(
          index: index,
          tapped: false,
          text: text,
          label: label,
          link: link,
          definition: definition,
        );
      };
  }

  void _updateNonTappableSpan({
    required int index,
    required String text,
    required String label,
    required Definition definition,
  }) {
    // Avoids the range error that occurs if text spans are
    // reduced while one of them is still hovered on.
    //
    // Also suppresses an update of the span if the text at the index
    // has changed because it means this method has been triggered by
    // the hover handler of the old span.
    // If it is not suppressed, the new span will get a wrong text.
    if (index >= value.children!.length || elements[index].text != text) {
      return;
    }

    // For causing a redraw, it is necessary to replace
    // the whole TextSpan as well as update a child.
    value = TextSpan(
      children: List.of(value.children!)
        ..[index] = _nonTappableTextSpan(
          index: index,
          text: text,
          label: label,
          definition: definition,
        ),
    );
  }

  void _updateTappableSpan({
    required int index,
    required String text,
    required String label,
    required String link,
    required Definition definition,
  }) {
    // Avoids the range error that occurs if text spans are
    // reduced while one of them is still hovered on.
    //
    // Also suppresses an update of the span if the text at the index
    // has changed because it means this method has been triggered by
    // the hover handler of the old span.
    // If it is not suppressed, the new span will get a wrong text.
    if (index >= value.children!.length || elements[index].text != text) {
      return;
    }

    // Prevents the issue #6 by avoiding updating the value
    // after the notifier is no longer available.
    if (!_disposed) {
      // For causing a redraw, it is necessary to replace
      // the whole TextSpan as well as update a child.
      value = TextSpan(
        children: List.of(value.children!)
          ..[index] = _tappableTextSpan(
            index: index,
            text: text,
            label: label,
            link: link,
            definition: definition,
          ),
      );
    }
  }

  void _updateTapIndex({
    required int index,
    required bool tapped,
    required String text,
    required String label,
    required String link,
    required Definition definition,
  }) {
    _tapIndex = tapped ? index : null;

    // Resetting hover values is necessary here.
    // Otherwise, the hover style remains if a press is
    // cancelled after the pointer leaves the text.
    _hoverIndex = null;
    _hoverPosition = null;

    _updateTappableSpan(
      index: index,
      text: text,
      label: label,
      link: link,
      definition: definition,
    );
  }

  void _updateHoverIndex({
    required Offset position,
    required int index,
    required bool hovered,
    required String text,
    required String label,
    required Definition definition,
    String? link,
  }) {
    // Updates only if the span is not being pressed.
    // The previous and current hovering positions are checked for
    // preventing repetitive rebuilds that can happen when
    // CustomText.selectable or CustomTextEditingController is used.
    if (_tapIndex == null && position != _hoverPosition) {
      _hoverIndex = hovered ? index : null;
      _hoverPosition = hovered ? position : null;

      link == null
          ? _updateNonTappableSpan(
              index: index,
              text: text,
              label: label,
              definition: definition,
            )
          : _updateTappableSpan(
              index: index,
              text: text,
              label: label,
              link: link,
              definition: definition,
            );
    }
  }
}
