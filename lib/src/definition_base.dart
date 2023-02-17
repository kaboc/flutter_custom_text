import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import 'package:meta/meta.dart';
import 'package:text_parser/text_parser.dart' show TextMatcher;

import 'gesture_details.dart';
import 'text.dart';
import 'text_editing_controller.dart';

/// The signature for a callback to select a string to display.
typedef LabelSelector = String Function(List<String?>);

/// The signature for a callback to select a string to be passed
/// to gesture callbacks.
typedef TapSelector = String Function(List<String?>);

/// The signature for a callback to return an [InlineSpan] to
/// be used as part of the text to display.
typedef SpanBuilder = InlineSpan Function(String, List<String?>);

/// The base class for definitions of rules for parsing, appearance
/// and actions for [CustomText] and [CustomTextEditingController].
@immutable
@sealed
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
