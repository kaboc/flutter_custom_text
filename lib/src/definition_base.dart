import 'package:meta/meta.dart';

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import 'package:text_parser/text_parser.dart';

import 'gesture_details.dart';

typedef LabelSelector = String Function(List<String?>);
typedef TapSelector = String Function(List<String?>);
typedef SpanBuilder = InlineSpan Function(String, List<String?>);

@immutable
abstract class Definition {
  const Definition({
    required this.matcher,
    this.labelSelector,
    this.tapSelector,
    this.builder,
    this.matchStyle,
    this.tapStyle,
    this.hoverStyle,
    this.onTap,
    this.onLongPress,
    this.onGesture,
    this.mouseCursor,
  });

  final TextMatcher matcher;
  final LabelSelector? labelSelector;
  final TapSelector? tapSelector;
  final SpanBuilder? builder;
  final TextStyle? matchStyle;
  final TextStyle? tapStyle;
  final TextStyle? hoverStyle;
  final void Function(GestureDetails)? onTap;
  final void Function(GestureDetails)? onLongPress;
  final void Function(GestureDetails)? onGesture;
  final MouseCursor? mouseCursor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Definition &&
          runtimeType == other.runtimeType &&
          matcher == other.matcher &&
          matchStyle == other.matchStyle &&
          tapStyle == other.tapStyle &&
          hoverStyle == other.hoverStyle &&
          mouseCursor == other.mouseCursor;

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        matcher,
        matchStyle,
        tapStyle,
        hoverStyle,
        mouseCursor,
      ]);
}
