import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';

import 'package:text_parser/text_parser.dart' show TextParser;

import 'builder.dart';
import 'definitions.dart';
import 'gesture_details.dart';
import 'parser_options.dart';
import 'utils.dart';
import 'span/data.dart';
import 'span/span_utils.dart';
import 'span/text_span_notifier.dart';

/// A text widget that decorates substrings and enables tap, long-press
/// and/or hover gestures on them based on flexible definitions.
///
/// {@template customText.CustomText}
/// This is useful for making certain portions of text such as URLs,
/// email addresses or phone numbers clickable, or for only highlighting
/// substrings with colours and different font settings.
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
/// which targets a list of [InlineSpan]s instead of plain text.
class CustomText extends StatefulWidget {
  /// Creates a text widget that decorates substrings and enables tap,
  /// long-press and/or hover gestures on them based on flexible definitions.
  ///
  /// {@macro customText.CustomText}
  const CustomText(
    String this.text, {
    super.key,
    required this.definitions,
    this.preBuilder,
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
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  }) : spans = null;

  /// Creates a text widget that decorates part of the provided
  /// [InlineSpan]s and enables tap, long-press and/or hover
  /// gestures on them based on flexible definitions.
  ///
  /// This constructor is useful if you already have styled spans
  /// and want to decorate them additionally.
  ///
  /// ```dart
  /// CustomText.spans(
  ///   style: const TextStyle(fontSize: 50.0),
  ///   definitions: [
  ///     TextDefinition(
  ///       // WidgetSpan is matched by `\uFFFC` or `.` in a match pattern.
  ///       matcher: ExactMatcher(const ['Flutter devs\uFFFC']),
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
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  })  : text = null,
        preBuilder = null;

  /// The text to which styles and gesture actions are applied.
  final String? text;

  /// The list of InlineSpans to which styles and gesture actions
  /// are applied.
  final List<InlineSpan>? spans;

  /// A builder function to build a [TextSpan] to which styles and
  /// gesture actions are applied.
  ///
  /// The example below displays "KISS" and "Keep It Simple, Stupid!"
  /// in bold, and additionally applies a colour to capital letters
  /// contained in them.
  ///
  /// ```dart
  /// CustomText(
  ///   'KISS is an acronym for "Keep It Simple, Stupid!".',
  ///   definitions: const [
  ///     TextDefinition(
  ///       matcher: PatternMatcher('[A-Z]'),
  ///       matchStyle: TextStyle(color: Colors.red),
  ///     ),
  ///   ],
  ///   preBuilder: CustomSpanBuilder(
  ///     definitions: [
  ///       const TextDefinition(
  ///         matcher: PatternMatcher('KISS|Keep.+Stupid!'),
  ///         matchStyle: TextStyle(fontWeight: FontWeight.bold),
  ///       ),
  ///     ],
  ///   ),
  /// )
  /// ```
  ///
  /// This is optional. If specified, the function is called first to build
  /// a [TextSpan], and then another parsing is performed in `CustomText`
  /// itself against the plain text converted from the built span, followed
  /// by a rebuild. Check how much it affects the performance of your app
  /// if you choose to use this.
  ///
  /// Note that [CustomSpanBuilder] ignores values passed to most
  /// parameters of definitions. See its document for details.
  final CustomSpanBuilder? preBuilder;

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
  /// If no style is specified, [DefaultTextStyle.style] is used instead.
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
  /// This is used only if a tap or long-press is enabled with [onTap]
  /// or [onLongPress].
  ///
  /// If this is not specified, [hoverStyle] or [matchStyle] is used
  /// instead if existing.
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
  /// The callback function called when a matched string is tapped.
  ///
  /// The argument with the same name in the relevant definition takes
  /// precedence over this.
  /// {@endtemplate}
  final GestureCallback? onTap;

  /// {@template customText.onLongPress}
  /// The callback function called when a matched string is long-pressed.
  ///
  /// The argument with the same name in the relevant definition takes
  /// precedence over this.
  /// {@endtemplate}
  final GestureCallback? onLongPress;

  /// {@template customText.onGesture}
  /// The callback function called when a gesture happens on a string.
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
  /// slightly longer execution time, during which the raw text is
  /// shown without decorations since CustomText is yet to know which
  /// definition should be used for which portion of text.
  ///
  /// How long parsing takes depends on the text length, the number
  /// and complexity of match patterns, the device performance, etc.
  /// Try both `true` and `false` to see which is suitable if you
  /// are unsure.
  final bool preventBlocking;

  /// The strut style to use.
  ///
  /// See [Text.strutStyle] for more details.
  final StrutStyle? strutStyle;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The directionality of the text.
  ///
  /// See [Text.textDirection] for more details.
  final TextDirection? textDirection;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale.
  ///
  /// See [Text.locale] for more details.
  final Locale? locale;

  /// Whether the text should break at soft line breaks.
  ///
  /// See [Text.softWrap] for more details.
  final bool? softWrap;

  /// How visual overflow should be handled.
  ///
  /// See [Text.overflow] for more details.
  final TextOverflow? overflow;

  /// The font scaling strategy to use when laying out and
  /// rendering the text.
  ///
  /// See [Text.textScaler] for more details.
  final TextScaler? textScaler;

  /// An optional maximum number of lines for the text to span,
  /// wrapping if necessary.
  ///
  /// See [Text.maxLines] for more details.
  final int? maxLines;

  /// An alternative semantics label for this text.
  ///
  /// See [Text.semanticsLabel] for more details.
  final String? semanticsLabel;

  /// Defines how to measure the width of the rendered text.
  final TextWidthBasis? textWidthBasis;

  /// Defines how to apply TextStyle.height over and under text.
  ///
  /// See [Text.textHeightBehavior] for more details.
  final TextHeightBehavior? textHeightBehavior;

  /// The color to use when painting the selection.
  final Color? selectionColor;

  @override
  State<CustomText> createState() => _CustomTextState();
}

class _CustomTextState extends State<CustomText> {
  late CustomTextSpanNotifier _textSpanNotifier;

  SpansBuilderSettings _createSettings({List<InlineSpan>? spans}) {
    return SpansBuilderSettings(
      definitions: widget.definitions,
      spans: spans ?? widget.spans,
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

  @override
  void dispose() {
    _textSpanNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final spanText = widget.spans.toPlainText();

    _textSpanNotifier = _shouldBeInvisibleDuringParsing()
        ? CustomTextSpanNotifier(
            // Uses plain text instead of spans at this point even when
            // `CustomText.spans` or `preBuilder` is used.
            // Otherwise, widgets contained in spans become visible
            // because the transparent colour only works for text.
            // (Using empty string instead of making text transparent
            // is wrong here because the widget should have the space
            // for the content at this point to avoid it changing later.)
            initialText: widget.text ?? spanText,
            initialStyle:
                widget.style?.copyWith(color: const Color(0x00000000)) ??
                    const TextStyle(color: Color(0x00000000)),
            settings: _createSettings(),
          )
        : CustomTextSpanNotifier(
            initialText: widget.text,
            initialStyle: widget.style,
            settings: _createSettings(),
          );

    _buildSpans(
      spanText: spanText,
      oldWidget: null,
    );
  }

  @override
  void didUpdateWidget(CustomText oldWidget) {
    super.didUpdateWidget(oldWidget);

    _textSpanNotifier.updateSettings(_createSettings());

    _buildSpans(
      spanText: widget.spans.toPlainText(),
      oldWidget: oldWidget,
    );
  }

  Future<void> _buildSpans({
    required String? spanText,
    required CustomText? oldWidget,
  }) async {
    final isInitial = oldWidget == null;
    final hasElements = _textSpanNotifier.elements.isNotEmpty;

    if (!isInitial) {
      final hasText = (widget.text ?? '').isNotEmpty;

      // If the text was empty initially and is provided now,
      // it is the time to show it, except in some cases where
      // it should be hidden until parsing completes.
      if (!hasElements && hasText && !_shouldBeInvisibleDuringParsing()) {
        _textSpanNotifier.updateValue(
          TextSpan(
            text: widget.text,
            style: widget.style,
          ),
        );
      }
    }

    final preBuilder = widget.preBuilder;
    final oldBuilder = oldWidget?.preBuilder;
    final builtSpan = await preBuilder?.build(
      text: widget.text ?? '',
      oldBuilder: oldBuilder,
    );

    if (preBuilder != null && builtSpan != null) {
      _textSpanNotifier.updateSettings(
        _createSettings(spans: builtSpan.children),
      );
    }

    final builtSpanText = builtSpan?.toPlainText();

    final needsParse = isInitial ||
        widget.definitions.hasUpdatedMatchers(oldWidget.definitions) ||
        widget.parserOptions != oldWidget.parserOptions ||
        // Parsing is necessary in the following cases:
        // * Pre-builder is not used and text has changed.
        // * Plain text of the span built by pre-builder has changed.
        // * Plain text of the spans passed to `CustomText.spans` has changed.
        preBuilder == null && widget.text != oldWidget.text ||
        builtSpanText != oldBuilder?.spanText() ||
        spanText != oldWidget.spans.toPlainText();

    if (needsParse) {
      await _parse(
        builtSpanText ?? widget.text ?? spanText ?? '',
      );
      return;
    }

    // This must not be earlier than the necessity of parsing is checked.
    // Don't swap the order.
    if (!hasElements) {
      // No-op when called before initial parsing completes so that
      // having no element won't cause an empty span to be build.
      // (But the issue only happens if this widget is rebuilt with
      // some values updated while parsing is taking long.)
      return;
    }

    final needsEntireBuild = preBuilder != null && preBuilder.built ||
        widget.style != oldWidget.style ||
        widget.matchStyle != oldWidget.matchStyle ||
        widget.tapStyle != oldWidget.tapStyle ||
        widget.hoverStyle != oldWidget.hoverStyle ||
        widget.longPressDuration != oldWidget.longPressDuration ||
        !listEquals(widget.spans, oldWidget.spans);

    final updatedDefIndexes = needsEntireBuild
        ? <int>[]
        : widget.definitions.findUpdatedDefinitions(oldWidget.definitions);

    if (needsEntireBuild || updatedDefIndexes.isNotEmpty) {
      _textSpanNotifier.buildSpan(
        style: widget.style,
        updatedDefinitionIndexes: updatedDefIndexes,
      );
    }
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
            widget.preBuilder != null ||
            widget.definitions.any((def) => !def.isTextDefinition));
  }

  Future<void> _parse(String text) async {
    final externalParser = widget.parserOptions.parser;

    final elements = externalParser == null
        ? await TextParser(
            matchers: widget.definitions.map((def) => def.matcher),
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
      ..updateElements(elements)
      ..buildSpan(
        style: widget.style,
        updatedDefinitionIndexes: [],
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
        textScaler: widget.textScaler,
        maxLines: widget.maxLines,
        semanticsLabel: widget.semanticsLabel,
        textWidthBasis: widget.textWidthBasis,
        textHeightBehavior: widget.textHeightBehavior,
        selectionColor: widget.selectionColor,
      ),
    );
  }
}
