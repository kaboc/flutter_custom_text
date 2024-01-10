// ignore_for_file: public_member_api_docs

import 'dart:async' show Timer;

import 'package:flutter/gestures.dart' show PointerEvent;
import 'package:flutter/painting.dart' show InlineSpan, TextStyle;

import 'package:text_parser/text_parser.dart' show TextElement;

import '../definition_base.dart';
import '../gesture_details.dart';

const kLongPressDuration = Duration(milliseconds: 600);

class SpanData {
  SpanData({
    required this.index,
    required this.element,
    required this.children,
    required this.definition,
    required this.shownText,
    required this.actionText,
    required this.onTapDown,
    required this.onTapCancel,
    required this.onMouseEnter,
    required this.onMouseExit,
  });

  final int index;
  final TextElement element;
  final List<InlineSpan>? children;
  final Definition definition;
  final String? shownText;
  final String? actionText;
  final void Function(SpanData)? onTapDown;
  final void Function(SpanData)? onTapCancel;
  final void Function(PointerEvent, SpanData)? onMouseEnter;
  final void Function(PointerEvent, SpanData)? onMouseExit;
}

class SpansBuilderSettings {
  SpansBuilderSettings({
    required List<Definition> definitions,
    this.spans,
    this.style,
    this.matchStyle,
    this.tapStyle,
    this.hoverStyle,
    this.onTap,
    this.onLongPress,
    this.onGesture,
    Duration? longPressDuration,
  })  : definitions = {},
        longPressDuration = longPressDuration ?? kLongPressDuration {
    // `i` is the index of a matcher (which is also the index of
    // a definition) that is necessary to identify which matcher
    // was used for a certain element when there are more than one
    // matchers of the same type.
    for (var i = 0; i < definitions.length; i++) {
      final def = definitions[i];
      this.definitions.update(
            def.matcher.runtimeType,
            (list) => list..[i] = def,
            ifAbsent: () => {i: def},
          );
    }
  }

  final Map<Type, Map<int, Definition>> definitions;
  final List<InlineSpan>? spans;
  final TextStyle? style;
  final TextStyle? matchStyle;
  final TextStyle? tapStyle;
  final TextStyle? hoverStyle;
  final GestureCallback? onTap;
  final GestureCallback? onLongPress;
  final GestureCallback? onGesture;
  final Duration longPressDuration;
}

/// A class to hold some values used for a workaround to skip
/// unwanted hover events in GestureHandler.
class HoverState {
  int? index;
  GestureKind? gestureKind;
  Map<int, Timer> debounceTimers = {};

  void reset() {
    index = null;
    gestureKind = null;
    debounceTimers
      ..forEach((_, t) => t.cancel())
      ..clear();
  }
}
