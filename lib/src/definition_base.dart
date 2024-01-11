import 'package:flutter/foundation.dart' show Key;
import 'package:flutter/painting.dart' show InlineSpan, TextStyle;
import 'package:flutter/services.dart' show MouseCursor;

import 'package:meta/meta.dart' show immutable, sealed;
import 'package:text_parser/text_parser.dart' show TextElement, TextMatcher;

import 'gesture_details.dart';
import 'text.dart';
import 'text_editing_controller.dart';

/// The signature for a callback to select a string to display.
typedef ShownTextSelector = String Function(TextElement);

/// The signature for a callback to select a string to be passed
/// to gesture callbacks.
typedef ActionTextSelector = String Function(TextElement);

/// The signature for a callback to return an [InlineSpan] to
/// be used as part of the text to display.
typedef SpanBuilder = InlineSpan Function(TextElement);

/// The signature for a callback to return a [GestureDetails].
typedef GestureCallback = void Function(GestureDetails);

/// The base class for definitions of rules for parsing, appearance
/// and actions for [CustomText] and [CustomTextEditingController].
@immutable
@sealed
abstract class Definition {
  // ignore: public_member_api_docs
  const Definition({
    required this.matcher,
    this.rebuildKey,
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

  /// The matcher used to parse text for this definition.
  final TextMatcher matcher;

  /// A key that is used to decide whether to rebuild the [InlineSpan]s
  /// relevant to this definition.
  ///
  /// [CustomText] rebuilds [InlineSpan]s when configurations in definitions
  /// are updated, but changes in callbacks do not trigger rebuilds because
  /// CustomText cannot evaluate the differences of callbacks.
  /// In such cases, it is possible to cause a rebuild by changing this key.
  final Key? rebuildKey;

  /// The function to choose a string to be shown.
  final ShownTextSelector? shownText;

  /// The function to choose a string to be passed to gesture callbacks.
  final ActionTextSelector? actionText;

  /// The builder function that builds an [InlineSpan] to replace
  /// matched strings with.
  final SpanBuilder? builder;

  /// The text style for matched strings.
  final TextStyle? matchStyle;

  /// The text style used for matched strings while they are being pressed.
  ///
  /// This is used only if a tap or long-press is enabled with [onTap]
  /// or [onLongPress].
  final TextStyle? tapStyle;

  /// The text style used for matched strings while they are under
  /// the mouse pointer.
  final TextStyle? hoverStyle;

  /// The callback function called when a matched string is tapped.
  final GestureCallback? onTap;

  /// The callback function called when a matched string is long-pressed.
  final GestureCallback? onLongPress;

  /// The callback function called when a gesture happens on a matched string.
  final GestureCallback? onGesture;

  /// The mouse cursor shown on a matched string while it is being hovered.
  final MouseCursor? mouseCursor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Definition &&
          runtimeType == other.runtimeType &&
          matcher == other.matcher &&
          rebuildKey == other.rebuildKey &&
          matchStyle == other.matchStyle &&
          tapStyle == other.tapStyle &&
          hoverStyle == other.hoverStyle &&
          mouseCursor == other.mouseCursor;

  @override
  int get hashCode => Object.hash(
        runtimeType,
        matcher,
        rebuildKey,
        matchStyle,
        tapStyle,
        hoverStyle,
        mouseCursor,
      );

  /// Whether the definition is TextDefinition.
  bool get isTextDefinition => shownText == null && builder == null;
}
