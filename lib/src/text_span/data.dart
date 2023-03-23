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
  })  : definitions = {
          for (final def in definitions) def.matcher.runtimeType: def,
        },
        longPressDuration = longPressDuration ?? kLongPressDuration;

  final Map<Type, Definition> definitions;
  final TextStyle? matchStyle;
  final TextStyle? tapStyle;
  final TextStyle? hoverStyle;
  final GestureCallback? onTap;
  final GestureCallback? onLongPress;
  final GestureCallback? onGesture;
  final Duration longPressDuration;
}
