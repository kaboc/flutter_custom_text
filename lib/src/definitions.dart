import 'package:flutter/widgets.dart';

import 'package:text_parser/text_parser.dart' show TextElement, TextMatcher;

import 'builder.dart';
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
sealed class Definition {
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

/// A class that defines parsing rules, appearance and actions for
/// [CustomText], [CustomTextEditingController] and [CustomSpanBuilder].
///
/// {@template customText.textDefinition}
/// The strings that have matched the pattern defined in [matcher]
/// are styled according to [matchStyle], [tapStyle] and [hoverStyle]
/// while not pressed, being pressed, and being hovered, respectively.
///
/// [onTap] and [onLongPress] are handler functions called when a
/// TextSpan is tapped and long-pressed. [onGesture] is a handler
/// function called when other gesture events happen.
/// A [GestureDetails] object containing details on the element
/// and the event (kind, text, tap position, etc) is passed in to
/// the functions.
///
/// [mouseCursor] is a mouse cursor type used while the mouse hovers
/// over a matching text element. Note that even if this is omitted,
/// [SystemMouseCursors.click] is automatically used if [onTap] or
/// [onLongPress] is specified.
///
/// Also note that most properties are ignored in [CustomSpanBuilder].
/// See its document for details.
/// {@endtemplate}
class TextDefinition extends Definition {
  /// Creates a [TextDefinition] that defines rules for parsing, appearance
  /// and actions for [CustomText], [CustomTextEditingController] and
  /// [CustomSpanBuilder].
  ///
  /// {@macro customText.textDefinition}
  const TextDefinition({
    required super.matcher,
    super.rebuildKey,
    super.matchStyle,
    super.tapStyle,
    super.hoverStyle,
    super.onTap,
    super.onLongPress,
    super.onGesture,
    super.mouseCursor,
  });
}

/// A class that defines parsing rules, appearance and actions,
/// and flexibly selects the string to be shown and another string
/// to be passed to callbacks (e.g. onTap, onGesture).
///
/// {@template customText.selectiveDefinition}
/// [shownText] and [actionText] are functions to select a string.
/// The string returned by [shownText] is displayed, and the string
/// returned by [actionText] is included in the [GestureDetails]
/// object passed to [onTap], [onLongPress] and [onGesture].
///
/// When this definition type is used, the text selected by
/// [shownText] is not shown until parsing completes and spots
/// which parts in the original text need to be replaced with
/// the selected text, so that the raw text is not shown as is
/// while waiting. Exceptionally, this behaviour is not applied
/// if [CustomText.preventBlocking] is enabled.
///
/// See also the document of [TextDefinition], which has most of
/// other properties in common.
/// {@endtemplate}
class SelectiveDefinition extends Definition {
  /// Creates a [SelectiveDefinition] that defines parsing rules,
  /// appearance and actions, and flexibly selects the string to
  /// be shown and another string to be passed to callbacks (e.g.
  /// onTap, onGesture).
  ///
  /// {@macro customText.selectiveDefinition}
  const SelectiveDefinition({
    required super.matcher,
    required ShownTextSelector super.shownText,
    super.rebuildKey,
    super.actionText,
    super.matchStyle,
    super.tapStyle,
    super.hoverStyle,
    super.onTap,
    super.onLongPress,
    super.onGesture,
    super.mouseCursor,
  });
}

/// A class that defines parsing rules, appearance and actions, and
/// builds the [InlineSpan] to replace matched strings with.
///
/// {@template customText.spanDefinition}
/// An object of [InlineSpan] or its subtype (e.g. [WidgetSpan])
/// returned from the [builder] function is displayed in place of the
/// string matched by the match pattern specified in this definition.
///
/// When this definition type is used, the [InlineSpan] created by
/// [builder] is not shown until CustomText finds which parts in the
/// original text need to be replaced with the span, so that the raw
/// text is not shown as is while waiting. Exceptionally, this behaviour
/// is not applied if [CustomText.preventBlocking] is enabled.
///
/// See also the document of [TextDefinition], which has most of
/// other properties in common.
/// {@endtemplate}
class SpanDefinition extends Definition {
  /// Creates a [SpanDefinition] that defines parsing rules,
  /// appearance and actions, and builds the [InlineSpan] to replace
  /// certain portions of text with.
  ///
  /// {@macro customText.spanDefinition}
  const SpanDefinition({
    required super.matcher,
    required SpanBuilder super.builder,
    super.rebuildKey,
    super.matchStyle,
    super.tapStyle,
    super.hoverStyle,
    super.onTap,
    super.onLongPress,
    super.onGesture,
    super.mouseCursor,
  });

  @override
  SpanBuilder get builder => super.builder!;
}
