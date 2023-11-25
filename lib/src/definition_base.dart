import 'package:flutter/painting.dart' show InlineSpan, TextStyle;
import 'package:flutter/services.dart' show MouseCursor;

import 'package:meta/meta.dart' show immutable, sealed;
import 'package:text_parser/text_parser.dart' show TextMatcher;

import 'gesture_details.dart';
import 'text.dart';
import 'text_editing_controller.dart';

/// The signature for a callback to select a string to display.
typedef ShownTextSelector = String Function(List<String?>);

/// The signature for a callback to select a string to be passed
/// to gesture callbacks.
typedef ActionTextSelector = String Function(List<String?>);

/// The signature for a callback to return an [InlineSpan] to
/// be used as part of the text to display.
typedef SpanBuilder = InlineSpan Function(String, List<String?>);

/// The signature for a callback to return a [GestureDetails].
typedef GestureCallback = void Function(GestureDetails);

/// The base class for definitions of rules for parsing, appearance
/// and actions for [CustomText] and [CustomTextEditingController].
@immutable
@sealed
abstract class Definition {
  const Definition({
    required this.matcher,
    this.shownText,
    this.actionText,
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
  final ShownTextSelector? shownText;
  final ActionTextSelector? actionText;
  final SpanBuilder? builder;
  final TextStyle? matchStyle;
  final TextStyle? tapStyle;
  final TextStyle? hoverStyle;
  final GestureCallback? onTap;
  final GestureCallback? onLongPress;
  final GestureCallback? onGesture;
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
  int get hashCode => Object.hash(
        runtimeType,
        matcher,
        matchStyle,
        tapStyle,
        hoverStyle,
        mouseCursor,
      );
}
