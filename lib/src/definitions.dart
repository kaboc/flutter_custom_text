import 'package:flutter/widgets.dart'
    show InlineSpan, SystemMouseCursors, WidgetSpan;

import 'builder.dart';
import 'definition_base.dart';
import 'gesture_details.dart';
import 'text.dart';
import 'text_editing_controller.dart';

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
