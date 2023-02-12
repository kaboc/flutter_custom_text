import 'package:flutter/widgets.dart';

import 'definition_base.dart';
import 'gesture_details.dart';
import 'text.dart';
import 'text_editing_controller.dart';

/// A class that defines rules for parsing, appearance and actions
/// for [CustomText] and [CustomTextEditingController].
class TextDefinition extends Definition {
  /// Creates a [TextDefinition] that defines rules for parsing,
  /// appearance and actions for [CustomText] and [CustomTextEditingController].
  ///
  /// {@template customText.definition.matcherAndStyle}
  /// The strings that have matched the pattern defined in [matcher] are
  /// styled according to the styles specified by [matchStyle], [tapStyle]
  /// and [hoverStyle], which are applied to a TextSpan while it is not
  /// pressed, being pressed, and being hovered, respectively.
  /// {@endtemplate}
  ///
  /// [onTap] and [onLongPress] are handler functions called when a
  /// TextSpan is tapped and long-pressed respectively. A [GestureDetails]
  /// object that has details on the element and press (type, text, tap
  /// position, etc) is passed in to the functions.
  ///
  /// {@template customText.definition.mouseCursor}
  /// [mouseCursor] is a mouse cursor type used while the mouse hovers
  /// over a matching text element. Note that even if this is omitted,
  /// [SystemMouseCursors.click] is automatically used if [onTap] or
  /// [onLongPress] is specified.
  /// {@endtemplate}
  const TextDefinition({
    required super.matcher,
    super.matchStyle,
    super.tapStyle,
    super.hoverStyle,
    super.onTap,
    super.onLongPress,
    super.mouseCursor,
  });
}

/// A class that defines rules for parsing, appearance and actions
/// for [CustomText] and [CustomTextEditingController].
///
/// This is similar to [TextDefinition] but different in that
/// it configures separately the string to be displayed and the
/// one to be passed to the tap and long-press callbacks.
class SelectiveDefinition extends Definition {
  /// Creates a [SelectiveDefinition] that defines rules for parsing,
  /// appearance and actions similarly to [TextDefinition] but allows
  /// a little more flexible settings.
  ///
  /// {@macro customText.definition.matcherAndStyle}
  ///
  /// [onTap] and [onLongPress] are handler functions called when a
  /// TextSpan is tapped and long-pressed respectively.
  ///
  /// [labelSelector] and [tapSelector] are functions for selecting
  /// a string. It receives a list of strings that have matched the
  /// fragments enclosed in parentheses within the match pattern.
  /// The string returned by [labelSelector] is displayed, and the one
  /// returned by [tapSelector] is included in the [GestureDetails]
  /// object passed to [onTap] and [onLongPress].
  ///
  /// {@macro customText.definition.mouseCursor}
  const SelectiveDefinition({
    required super.matcher,
    required LabelSelector super.labelSelector,
    super.tapSelector,
    super.matchStyle,
    super.tapStyle,
    super.hoverStyle,
    super.onTap,
    super.onLongPress,
    super.mouseCursor,
  });
}

/// A class that defines rules for parsing, appearance and widget
/// to be displayed inside [CustomText].
class SpanDefinition extends Definition {
  /// A [SpanDefinition] that defines parsing rules and the widget
  /// to be displayed inside [CustomText].
  ///
  /// The [builder] function receives the entire matched string and
  /// a list of strings that have matched the fragments enclosed in
  /// parentheses within the match pattern. Use the function to return
  /// an object of [InlineSpan] or its subtype (e.g. [WidgetSpan]) to
  /// display it instead of the matched string.
  const SpanDefinition({
    required super.matcher,
    required SpanBuilder super.builder,
  });
}
