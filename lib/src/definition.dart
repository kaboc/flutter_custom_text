part of 'text.dart';

abstract class _Definition {
  const _Definition({
    required this.matcher,
    this.labelSelector,
    this.tapSelector,
    this.builder,
    this.matchStyle,
    this.tapStyle,
    this.onTap,
    this.onLongPress,
  });

  final TextMatcher matcher;
  final String Function(List<String?>)? labelSelector;
  final String Function(List<String?>)? tapSelector;
  final InlineSpan Function(String, List<String?>)? builder;
  final TextStyle? matchStyle;
  final TextStyle? tapStyle;
  final void Function(String)? onTap;
  final void Function(String)? onLongPress;
}

/// A class that defines the parsing rule, text styles and actions for
/// tap/long-press events.
class TextDefinition extends _Definition {
  /// Creates a [TextDefinition] that defines parsing rules, text styles,
  /// and actions for tap/long-press events.
  ///
  /// If strings match the pattern set in [matcher], the strings are styled
  /// according to the styles specified by [matchStyle] and [tapStyle],
  /// which are used while a parsed element is not pressed and pressed
  /// respectively.
  ///
  /// [onTap] / [onLongPress] are callback functions called when the element
  /// is tapped/long-pressed. The matched string is passed in to the functions.
  const TextDefinition({
    required TextMatcher matcher,
    TextStyle? matchStyle,
    TextStyle? tapStyle,
    void Function(String)? onTap,
    @Deprecated(
      '[onLongTap] is being deprecated in favor of [onLongPress]. '
      '[onLongTap] will be removed on or after the 1.0.0 release.',
    )
        void Function(String)? onLongTap,
    void Function(String)? onLongPress,
  }) : super(
          matcher: matcher,
          matchStyle: matchStyle,
          tapStyle: tapStyle,
          onTap: onTap,
          onLongPress: onLongPress ?? onLongTap,
        );
}

/// A class that is similar to [TextDefinition] but different in that this
/// enables to choose the string to be displayed and the one passed to the
/// tap/long-press callbacks.
class SelectiveDefinition extends _Definition {
  /// Creates a [SelectiveDefinition] that is similar to [TextDefinition] but
  /// allows more flexible settings.,
  ///
  /// If strings match the pattern set in [matcher], the strings are styled
  /// according to the styles specified by [matchStyle] and [tapStyle],
  /// which are used while the string element is not pressed and pressed
  /// respectively.
  ///
  /// [labelSelector] and [tapSelector] are functions provided with groups
  /// (an array of strings) that have matched the fragments enclosed with
  /// parentheses within the match pattern. The string returned by
  /// [labelSelector] is displayed, and the one returned by [tapSelector]
  /// is passed to [onTap] and [onLongPress].
  ///
  /// [onTap] / [onLongPress] are callback functions called when the element
  /// is tapped/long-pressed. The string set by [tapSelector] is passed
  /// in to the functions.
  const SelectiveDefinition({
    required TextMatcher matcher,
    required String Function(List<String?>) labelSelector,
    String Function(List<String?>)? tapSelector,
    TextStyle? matchStyle,
    TextStyle? tapStyle,
    void Function(String)? onTap,
    @Deprecated(
      '[onLongTap] is being deprecated in favor of [onLongPress]. '
      '[onLongTap] will be removed on or after the 1.0.0 release.',
    )
        void Function(String)? onLongTap,
    void Function(String)? onLongPress,
  }) : super(
          matcher: matcher,
          labelSelector: labelSelector,
          tapSelector: tapSelector,
          matchStyle: matchStyle,
          tapStyle: tapStyle,
          onTap: onTap,
          onLongPress: onLongPress ?? onLongTap,
        );
}

/// A class that defines parsing rules and the string or widget to be
/// displayed inside [CustomText].
class SpanDefinition extends _Definition {
  /// A [SpanDefinition] that defines parsing rules and the widget to
  /// be displayed inside [CustomText].
  ///
  /// The whole matched string and the string that has matched the pattern
  /// specified in matcher are passed in to the [builder] function. Use the
  /// function to return an object of a type derived from [InlineSpan],
  /// like [WidgetSpan], to display it instead of the matched string.
  const SpanDefinition({
    required TextMatcher matcher,
    required InlineSpan Function(String, List<String?>) builder,
  }) : super(
          matcher: matcher,
          builder: builder,
        );
}
