import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';

import 'package:text_parser/text_parser.dart';

import 'definition_base.dart';
import 'definitions.dart';

const _kLongPressDuration = Duration(milliseconds: 600);

@immutable
class _SpanState {
  const _SpanState({this.tapIndex, this.hoverIndex});

  final int? tapIndex;
  final int? hoverIndex;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SpanState &&
          tapIndex == other.tapIndex &&
          hoverIndex == other.hoverIndex;

  @override
  int get hashCode => tapIndex.hashCode ^ hoverIndex.hashCode;
}

class CustomTextSpanNotifier extends ValueNotifier<_SpanState> {
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
        super(const _SpanState());

  final String text;
  final Map<Type, Definition> _definitions;
  final TextStyle? matchStyle;
  final TextStyle? tapStyle;
  final TextStyle? hoverStyle;
  void Function(Type, String)? onTap;
  void Function(Type, String)? onLongPress;
  final Duration _longPressDuration;

  final Map<int, TapGestureRecognizer> _tapRecognizers = {};
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _tapRecognizers
      ..forEach((_, recognizer) => recognizer.dispose())
      ..clear();

    super.dispose();
  }

  TextSpan span({
    required List<TextElement> elements,
    TextStyle? style,
  }) {
    // Replacing only inner TextSpan when parsing is done causes
    // the issue #5, so this outer TextSpan is replaced instead.
    return elements.isEmpty
        ? TextSpan(text: text)
        : TextSpan(
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
                      style: style,
                      onTap: onTap,
                      onLongPress: onLongPress,
                    )
                  : _nonTappableTextSpan(
                      index: index,
                      text: spanText,
                      definition: def,
                      style: style,
                    );
            }).toList(),
          );
  }

  TextSpan _nonTappableTextSpan({
    required int index,
    required String text,
    required Definition definition,
    required TextStyle? style,
  }) {
    var matchStyle = definition.matchStyle ?? this.matchStyle;
    var hoverStyle = definition.hoverStyle ?? this.hoverStyle;
    final hasHoverStyle = hoverStyle != null;

    if (style != null) {
      matchStyle = style.merge(matchStyle);
      hoverStyle = style.merge(hoverStyle);
    }

    return TextSpan(
      text: text,
      style: value.hoverIndex == index ? hoverStyle : matchStyle,
      mouseCursor: definition.mouseCursor,
      onEnter: hasHoverStyle ? (_) => _updateHoverIndex(index) : null,
      onExit: hasHoverStyle ? (_) => _updateHoverIndex() : null,
    );
  }

  TextSpan _tappableTextSpan({
    required int index,
    required String text,
    required String link,
    required Definition definition,
    required TextStyle? style,
    required void Function(Type, String)? onTap,
    required void Function(Type, String)? onLongPress,
  }) {
    var matchStyle = definition.matchStyle ?? this.matchStyle;
    var tapStyle = definition.tapStyle ?? this.tapStyle ?? matchStyle;
    var hoverStyle = definition.hoverStyle ?? this.hoverStyle;
    final hasHoverStyle = hoverStyle != null;

    if (style != null) {
      matchStyle = style.merge(matchStyle);
      tapStyle = style.merge(tapStyle);
      hoverStyle = style.merge(hoverStyle);
    }

    return TextSpan(
      text: text,
      style: value.tapIndex == index
          ? tapStyle
          : (value.hoverIndex == index ? hoverStyle : matchStyle),
      recognizer: _tapRecognizers[index] ??= _recognizer(
        index: index,
        link: link,
        definition: definition,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
      mouseCursor: definition.mouseCursor,
      onEnter: hasHoverStyle ? (_) => _updateHoverIndex(index) : null,
      onExit: hasHoverStyle ? (_) => _updateHoverIndex() : null,
    );
  }

  TapGestureRecognizer _recognizer({
    required int index,
    required String link,
    required Definition definition,
    required void Function(Type, String)? onTap,
    required void Function(Type, String)? onLongPress,
  }) {
    return TapGestureRecognizer()
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

        _updateTapIndex(index);
      }
      ..onTapUp = (_) {
        if (_timer?.isActive ?? true) {
          if (definition.onTap != null) {
            definition.onTap!(link);
          } else if (onTap != null) {
            onTap(definition.matcher.runtimeType, link);
          }
        }
        _timer?.cancel();
        _timer = null;

        _updateTapIndex();
      }
      ..onTapCancel = () {
        _timer?.cancel();
        _timer = null;

        _updateTapIndex();
      };
  }

  void _updateTapIndex([int? index]) {
    value = _SpanState(tapIndex: index);
  }

  void _updateHoverIndex([int? index]) {
    // Should update only if the span is not being pressed.
    if (value.tapIndex == null) {
      value = _SpanState(hoverIndex: index);
    }
  }
}
