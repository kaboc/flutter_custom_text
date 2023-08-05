import 'package:flutter/painting.dart';

import 'package:text_parser/text_parser.dart' show TextElement;

import '../definition_base.dart';

const kLongPressDuration = Duration(milliseconds: 600);

class SpanData {
  SpanData({
    required this.index,
    required this.element,
    required this.text,
    required this.shownText,
    required this.actionText,
    required this.definition,
    required this.tappable,
  });

  final int index;
  final TextElement element;
  final String text;
  final String shownText;
  final String actionText;
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
  final TextStyle? matchStyle;
  final TextStyle? tapStyle;
  final TextStyle? hoverStyle;
  final GestureCallback? onTap;
  final GestureCallback? onLongPress;
  final GestureCallback? onGesture;
  final Duration longPressDuration;
}
