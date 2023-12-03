import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';

import 'package:text_parser/text_parser.dart' show TextParser;

import 'definitions.dart';
import 'definition_base.dart';
import 'gesture_details.dart';
import 'parser_options.dart';
import 'text_span/data.dart';
import 'text_span/span_utils.dart';
import 'text_span/text_span_notifier.dart';

const _kTextScaleFactorDeprecation =
    'Use `MediaQuery` instead or ignore this warning depending on the '
    'Flutter SDK version you are currently using, until `textScaler` '
    'is added at a future version of custom_text. This was deprecated '
    'at custom_text 1.3.0.\n'
    '* < Flutter 3.16: Ignore this warning for now.\n'
    '* >= Flutter 3.16: Wrap `CustomText` / `CustomText.spans` with '
    '`MediaQuery`, `MediaQuery.withNoTextScaling` or '
    '`MediaQuery.withClampedTextScaling` to override the existing '
    'TextScaler.';

/// A text widget that decorates partial strings in it, and enables tap,
/// long-press and/or hover gestures based on flexible definitions.
///
/// {@template customText.CustomText}
/// This widget is useful for making certain portions of text such as URLs,
/// email addresses or phone numbers clickable, or for only highlighting
/// some parts of text with colors and different font settings depending
/// on the types of text elements.
///
/// ```dart
/// CustomText(
///   'URL: https://example.com/\n'
///   'Email: foo@example.com\n'
///   'Tel: +1-012-3456-7890',
///   definitions: const [
///     TextDefinition(matcher: UrlMatcher()),
///     TextDefinition(matcher: EmailMatcher()),
///     TextDefinition(matcher: TelMatcher()),
///   ],
///   matchStyle: const TextStyle(color: Colors.indigo),
///   hoverStyle: const TextStyle(color: Colors.lightBlue),
///   onTap: (details) => launchUrlString(details.actionText),
/// )
/// ```
/// {@endtemplate}
///
/// This widget also has the `CustomText.spans` constructor,
/// which targets a list of [InlineSpan]s instead of text.
class CustomText extends StatefulWidget {
  /// Creates a text widget that decorates partial strings in it,
  /// and enables tap, long-press and/or hover gestures based on
  /// flexible definitions.
  ///
  /// {@macro customText.CustomText}
  const CustomText(
    String this.text, {
    super.key,
    required this.definitions,
    this.parserOptions = const ParserOptions(),
    this.style,
    this.matchStyle,
    this.tapStyle,
    this.hoverStyle,
    this.onTap,
    this.onLongPress,
    this.onGesture,
    this.longPressDuration,
    this.preventBlocking = false,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    @Deprecated(_kTextScaleFactorDeprecation) this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
  }) : spans = null;

  /// Creates a text widget that decorates certain portions of
  /// [InlineSpan]s, and enables tap, long-press and/or hover
  /// gestures based on flexible definitions.
  ///
  /// This constructor is useful if you already have styled spans
  /// and want to decorate them additionally.
  ///
  /// ```dart
  /// CustomText.spans(
  ///   style: const TextStyle(fontSize: 50.0),
  ///   definitions: const [
  ///     TextDefinition(
  ///       // WidgetSpan is matched by `\uFFFC` or `.` in a match pattern.
  ///       matcher: PatternMatcher('Flutter devs\uFFFC'),
  ///       matchStyle: const TextStyle(color: Colors.blue),
  ///       hoverStyle: TextStyle(color: Colors.blue.shade300),
  ///       mouseCursor: SystemMouseCursors.forbidden,
  ///     ),
  ///   ],
  ///   spans: [
  ///     const TextSpan(text: 'Hi, '),
  ///     const TextSpan(
  ///       text: 'Flutter',
  ///       style: TextStyle(fontWeight: FontWeight.bold),
  ///     ),
  ///     const TextSpan(text: ' devs'),
  ///     WidgetSpan(
  ///       alignment: PlaceholderAlignment.middle,
  ///       child: Builder(
  ///         builder: (context) {
  ///           // Text style is available also in WidgetSpan
  ///           // via DefaultTextStyle.
  ///           final style = DefaultTextStyle.of(context).style;
  ///           return Icon(
  ///             Icons.emoji_emotions,
  ///             size: style.fontSize,
  ///             color: style.color,
  ///           );
  ///         },
  ///       ),
  ///     ),
  ///   ],
  /// )
  /// ```
  ///
  /// This example shows "Hi, Flutter devs" with an emoji at the end.
  /// The text consists of a list of [InlineSpan]s, where "Flutter"
  /// is styled as bold and the emoji is defined by a [WidgetSpan].
  /// CustomText used via the `spans` constructor cleverly handles
  /// `InlineSpan`s like the above instead of plain text. This results
  /// in displaying "Flutter devs" and the emoji in blue, without
  /// losing the bold style of "Flutter" defined in the original span.
  ///
  /// However, note that the style is lost in the string corresponding
  /// to definitions other than [TextDefinition]; the string returned
  /// by the `shownText` callback of [SelectiveDefinition] and the
  /// `InlineSpan` created by the `builder` function of [SpanDefinition]
  /// do not inherit the original style.
  ///
  /// Also note that attributes except for `style` in the original
  /// `TextSpan`s are removed.
  const CustomText.spans({
    super.key,
    required List<InlineSpan> this.spans,
    required this.definitions,
    this.parserOptions = const ParserOptions(),
    this.style,
    this.matchStyle,
    this.tapStyle,
    this.hoverStyle,
    this.onTap,
    this.onLongPress,
    this.onGesture,
    this.longPressDuration,
    this.preventBlocking = false,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    @Deprecated(_kTextScaleFactorDeprecation) this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
  }) : text = null;

  /// The text to which styles and gesture actions are applied.
  final String? text;

  /// The list of InlineSpans to which styles and gesture actions
  /// are applied.
  final List<InlineSpan>? spans;

  /// Definitions that specify rules for parsing, appearance and actions.
  final List<Definition> definitions;

  /// The options for [RegExp] that configure how regular expressions
  /// are treated.
  final ParserOptions parserOptions;

  /// The text style for strings that did not match any match patterns.
  ///
  /// This is also used for matched strings if neither [CustomText.matchStyle]
  /// nor `matchStyle` in the relevant definition is specified.
  ///
  /// If no style is specified, [DefaultTextStyle] is used instead.
  final TextStyle? style;

  /// {@template customText.matchStyle}
  /// The default text style for matched strings.
  ///
  /// The argument with the same name in the relevant definition takes
  /// precedence over this.
  /// {@endtemplate}
  final TextStyle? matchStyle;

  /// {@template customText.tapStyle}
  /// The default text style used for tappable strings while they are
  /// being pressed.
  ///
  /// This is used only if a tap or long-press is enabled on the string
  /// by [onTap] or [onLongPress].
  ///
  /// If this is not specified, [hoverStyle] or [matchStyle] is used
  /// instead if specified.
  ///
  /// The argument with the same name in the relevant definition takes
  /// precedence over this.
  /// {@endtemplate}
  final TextStyle? tapStyle;

  /// {@template customText.hoverStyle}
  /// The default text style used for matched strings while they are
  /// under the mouse pointer.
  ///
  /// The argument with the same name in the relevant definition takes
  /// precedence over this.
  /// {@endtemplate}
  final TextStyle? hoverStyle;

  /// {@template customText.onTap}
  /// The callback function called when a tappable element is tapped.
  ///
  /// The argument with the same name in the relevant definition takes
  /// precedence over this.
  /// {@endtemplate}
  final GestureCallback? onTap;

  /// {@template customText.onLongPress}
  /// The callback function called when a tappable element is long-pressed.
  ///
  /// The argument with the same name in the relevant definition takes
  /// precedence over this.
  /// {@endtemplate}
  final GestureCallback? onLongPress;

  /// {@template customText.onGesture}
  /// The callback function called when a gesture happens on a text element.
  ///
  /// The function is called on the following events:
  /// * A press of the secondary button
  /// * A press of the tertiary button
  /// * An enter of the mouse pointer
  /// * An exit of the mouse pointer
  ///
  /// The `gestureKind` contained in the [GestureDetails] object
  /// indicates which of the above events has triggered the function;
  /// respectively [GestureKind.secondaryTap], [GestureKind.tertiaryTap],
  /// [GestureKind.enter] and [GestureKind.exit].
  ///
  /// The argument with the same name in the relevant definition takes
  /// precedence over this.
  ///
  /// Note that unlike [onTap] and [onLongPress], it does not affect
  /// text styling whether this argument is specified or not.
  ///
  /// For a press event of the primary button, use [onTap] and [onLongPress].
  /// {@endtemplate}
  final GestureCallback? onGesture;

  /// {@template customText.longPressDuration}
  /// The duration before a tap is regarded as a long-press and the
  /// [onLongPress] function is called.
  /// {@endtemplate}
  final Duration? longPressDuration;

  /// Whether to use an isolate for parsing to avoid blocking of the UI.
  ///
  /// If set to true, parsing with the default parser is executed in
  /// an isolate to prevent blocking of the main thread and the UI.
  ///
  /// This option does not work for the web where isolates are not
  /// supported. Also, this does not affect an external parser.
  ///
  /// Note that using an isolate adds an overhead, resulting in a
  /// slightly longer execution time. As a result, the raw text is
  /// shown without decorations while parsing takes a little longer,
  /// during which CustomText is yet to know which definition should
  /// be used for which portion of text.
  ///
  /// How long parsing takes depends on the text length, the number
  /// and complexity of match patterns, the device performance, etc.
  /// Try both `true` and `false` to see which is suitable if you
  /// are unsure.
  final bool preventBlocking;

  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  @Deprecated(_kTextScaleFactorDeprecation)
  final double? textScaleFactor;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  @override
  State<CustomText> createState() => _CustomTextState();
}

class _CustomTextState extends State<CustomText> {
  late CustomTextSpanNotifier _textSpanNotifier;

  NotifierSettings _createNotifierSettings() {
    return NotifierSettings(
      definitions: widget.definitions,
      spans: widget.spans,
      style: widget.style,
      matchStyle: widget.matchStyle,
      tapStyle: widget.tapStyle,
      hoverStyle: widget.hoverStyle,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onGesture: widget.onGesture,
      longPressDuration: widget.longPressDuration,
    );
  }

  /// Whether to keep the content transparent during initial parsing
  /// to prevent the strings and widgets that should not be shown
  /// (e.g. symbols for LinkMatcher `[]()`) from being visible for
  /// an instant.
  ///
  /// However, the following cases are excluded:
  ///
  /// * When `preventBlocking` is enabled, which means the user has
  ///   chosen to show the raw content without it blocked by parsing.
  /// * When the default constructor is used and `definitions`
  ///   contains only TextDefinition, in which case the shown text
  ///   remains unchanged before and after parsing.
  ///   As an exception, this does not apply to the case where
  ///   `CustomText.spans` is used because the given spans can contain
  ///   widgets that cannot be hidden by just making the text colour
  ///   transparent.
  bool _shouldBeInvisibleDuringParsing() {
    return !widget.preventBlocking &&
        (widget.spans != null ||
            widget.definitions.any((def) => !def.isTextDefinition));
  }

  @override
  void initState() {
    super.initState();

    final spanText = widget.spans.toPlainText();

    _textSpanNotifier = _shouldBeInvisibleDuringParsing()
        ? CustomTextSpanNotifier(
            // Shows plain text even in the case of `CustomText.spans`.
            // Otherwise, widgets contained in spans become visible
            // because the transparent colour only works for text.
            // (Using empty string instead of making text transparent
            // is wrong here because the widget should have the space
            // for the content at this point to avoid it changing later.)
            initialText: widget.text ?? spanText,
            initialStyle:
                widget.style?.copyWith(color: const Color(0x00000000)) ??
                    const TextStyle(color: Color(0x00000000)),
            settings: _createNotifierSettings(),
          )
        : CustomTextSpanNotifier(
            initialText: widget.text,
            initialStyle: widget.style,
            settings: _createNotifierSettings(),
          );

    _parse(widget.text ?? spanText);
  }

  @override
  void didUpdateWidget(CustomText oldWidget) {
    super.didUpdateWidget(oldWidget);

    final spanText = widget.spans.toPlainText();

    final needsParse = _hasNewMatchers(oldWidget) ||
        widget.parserOptions != oldWidget.parserOptions ||
        widget.text != oldWidget.text ||
        spanText != oldWidget.spans.toPlainText();

    if (needsParse) {
      _textSpanNotifier.settings = _createNotifierSettings();
      _parse(widget.text ?? spanText);
      return;
    }

    // This has to be here after checking the necessity of parsing.
    // Don't swap the order.
    if (_textSpanNotifier.elements.isEmpty) {
      // No-op when called before initial parsing completes so that
      // having no element won't cause an empty span to be build.
      // (But this only happens if this widget is rebuilt with some
      // values updated while parsing is taking long.)
      return;
    }

    final needsSpanUpdate = widget.style != oldWidget.style ||
        widget.matchStyle != oldWidget.matchStyle ||
        widget.tapStyle != oldWidget.tapStyle ||
        widget.hoverStyle != oldWidget.hoverStyle ||
        widget.longPressDuration != oldWidget.longPressDuration ||
        _hasNewDefinitions(oldWidget) ||
        !listEquals(widget.spans, oldWidget.spans);

    if (needsSpanUpdate) {
      _textSpanNotifier
        ..settings = _createNotifierSettings()
        ..buildSpan(
          style: widget.style,
          oldElementsLength: _textSpanNotifier.elements.length,
        );
    }
  }

  @override
  void dispose() {
    _textSpanNotifier.dispose();
    super.dispose();
  }

  bool _hasNewMatchers(CustomText oldWidget) {
    if (widget.definitions.length != oldWidget.definitions.length) {
      return true;
    }

    for (var i = 0; i < widget.definitions.length; i++) {
      if (widget.definitions[i].matcher != oldWidget.definitions[i].matcher) {
        return true;
      }
    }
    return false;
  }

  bool _hasNewDefinitions(CustomText oldWidget) {
    if (widget.definitions.length != oldWidget.definitions.length) {
      return true;
    }

    for (var i = 0; i < widget.definitions.length; i++) {
      if (widget.definitions[i] != oldWidget.definitions[i]) {
        return true;
      }
    }
    return false;
  }

  Future<void> _parse(String text) async {
    final externalParser = widget.parserOptions.parser;
    final oldElementsLength = _textSpanNotifier.elements.length;

    final elements = externalParser == null
        ? await TextParser(
            matchers: widget.definitions.map((def) => def.matcher).toList(),
            multiLine: widget.parserOptions.multiLine,
            caseSensitive: widget.parserOptions.caseSensitive,
            unicode: widget.parserOptions.unicode,
            dotAll: widget.parserOptions.dotAll,
          ).parse(
            text,
            useIsolate: widget.preventBlocking,
          )
        : await externalParser(text);

    _textSpanNotifier
      ..elements = elements
      ..buildSpan(
        style: widget.style,
        oldElementsLength: oldElementsLength,
      );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _textSpanNotifier,
      builder: (context, span, _) => Text.rich(
        span,
        strutStyle: widget.strutStyle,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        locale: widget.locale,
        softWrap: widget.softWrap,
        overflow: widget.overflow,
        // ignore: deprecated_member_use_from_same_package
        textScaleFactor: widget.textScaleFactor,
        maxLines: widget.maxLines,
        semanticsLabel: widget.semanticsLabel,
        textWidthBasis: widget.textWidthBasis,
        textHeightBehavior: widget.textHeightBehavior,
      ),
    );
  }
}
