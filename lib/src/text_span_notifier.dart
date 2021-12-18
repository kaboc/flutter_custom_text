import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';

import 'package:text_parser/text_parser.dart';

import 'definition_base.dart';
import 'definitions.dart';

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

  bool _disposed = false;

  TextStyle? _style;
  List<TextElement> elements = [];
  final Map<int, TapGestureRecognizer> _tapRecognizers = {};

  Timer? _timer;
  int? _tapIndex;
  int? _hoverIndex;
  Offset? _hoverPosition;

  @override
  void dispose() {
    _timer?.cancel();
    _tapRecognizers
      ..forEach((_, recognizer) => recognizer.dispose())
      ..clear();
    _disposed = true;

    super.dispose();
  }

  void buildSpan({required TextStyle? style}) {
    _style = style;

    value = TextSpan(
      children: elements.asMap().entries.map((entry) {
        final index = entry.key;
        final elm = entry.value;

        final def = _definitions[elm.matcherType];
        if (def == null) {
          return TextSpan(text: elm.text, style: style);
        }
        if (def is SpanDefinition) {
          return def.builder!(elm.text, elm.groups);
        }

        final isTappable = def.onTap != null ||
            def.onLongPress != null ||
            onTap != null ||
            onLongPress != null;

        final spanText = def.labelSelector == null
            ? elm.text
            : def.labelSelector!(elm.groups);

        return isTappable
            ? _tappableTextSpan(
                index: index,
                text: spanText,
                link: def.tapSelector == null
                    ? elm.text
                    : def.tapSelector!(elm.groups),
                definition: def,
              )
            : _nonTappableTextSpan(
                index: index,
                text: spanText,
                definition: def,
              );
      }).toList(),
    );
  }

  TextSpan _nonTappableTextSpan({
    required int index,
    required String text,
    required Definition definition,
  }) {
    var matchStyle = definition.matchStyle ?? this.matchStyle;
    var hoverStyle = definition.hoverStyle ?? this.hoverStyle;
    final hasHoverStyle = hoverStyle != null;

    if (_style != null) {
      matchStyle = _style!.merge(matchStyle);
      hoverStyle = _style!.merge(hoverStyle);
    }

    return TextSpan(
      text: text,
      style: _hoverIndex == index ? hoverStyle : matchStyle,
      mouseCursor: definition.mouseCursor,
      onEnter: hasHoverStyle
          ? (event) => _updateHoverIndex(
                position: event.position,
                index: index,
                hovered: true,
                text: text,
                definition: definition,
              )
          : null,
      onExit: hasHoverStyle
          ? (event) => _updateHoverIndex(
                position: event.position,
                index: index,
                hovered: false,
                text: text,
                definition: definition,
              )
          : null,
    );
  }

  TextSpan _tappableTextSpan({
    required int index,
    required String text,
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
      link: link,
      definition: definition,
      style: _style,
      onTap: onTap,
      onLongPress: onLongPress,
    );

    return TextSpan(
      text: text,
      style: _tapIndex == index
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
                link: link,
                definition: definition,
              )
          : null,
    );
  }

  void _configureRecognizer({
    required int index,
    required String text,
    required String link,
    required Definition definition,
    required TextStyle? style,
    required void Function(Type, String)? onTap,
    required void Function(Type, String)? onLongPress,
  }) {
    _tapRecognizers[index] ??= TapGestureRecognizer();

    _tapRecognizers[index]!
      ..onTapDown = (_) {
        if (definition.onLongPress != null) {
          _timer = Timer(
            _longPressDuration,
            () => definition.onLongPress!(link),
          );
        } else if (onLongPress != null) {
          _timer = Timer(
            _longPressDuration,
            () => onLongPress(definition.matcher.runtimeType, link),
          );
        }

        _updateTapIndex(
          index: index,
          tapped: true,
          text: text,
          link: link,
          definition: definition,
        );
      }
      ..onTapUp = (_) {
        if (_timer?.isActive ?? true) {
          if (definition.onTap != null) {
            definition.onTap!(link);
          } else if (onTap != null) {
            onTap(definition.matcher.runtimeType, link);
          }
        }
        _tapRecognizers[index]!.onTapCancel!();
      }
      ..onTapCancel = () {
        _timer?.cancel();
        _timer = null;

        _updateTapIndex(
          index: index,
          tapped: false,
          text: text,
          link: link,
          definition: definition,
        );
      };
  }

  void _updateNonTappableSpan({
    required int index,
    required String text,
    required Definition definition,
  }) {
    // For causing a redraw, it is necessary to replace
    // the whole TextSpan as well as update a child.
    value = TextSpan(
      children: List.of(value.children!)
        ..[index] = _nonTappableTextSpan(
          index: index,
          text: text,
          definition: definition,
        ),
    );
  }

  void _updateTappableSpan({
    required int index,
    required String text,
    required String link,
    required Definition definition,
  }) {
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
    required String link,
    required Definition definition,
  }) {
    _tapIndex = tapped ? index : null;

    _updateTappableSpan(
      index: index,
      text: text,
      link: link,
      definition: definition,
    );
  }

  void _updateHoverIndex({
    required Offset position,
    required int index,
    required bool hovered,
    required String text,
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
              definition: definition,
            )
          : _updateTappableSpan(
              index: index,
              text: text,
              link: link,
              definition: definition,
            );
    }
  }
}
