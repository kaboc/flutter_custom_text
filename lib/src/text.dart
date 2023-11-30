import 'package:flutter/widgets.dart';

import 'package:text_parser/text_parser.dart' show TextParser;

import 'definition_base.dart';
import 'gesture_details.dart';
import 'parser_options.dart';
import 'text_span/data.dart';
import 'text_span/text_span_notifier.dart';

/// A text widget that decorates strings in it and enables tap,
/// long-press and/or hover gestures based on flexible definitions.
///
/// {@template customText.CustomText}
/// This widget is useful for making partial strings in text such as URLs,
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
class CustomText extends StatefulWidget {
  /// Creates a text widget that decorates strings and enables tap,
  /// long-press and/or hover gestures based on flexible definitions.
  ///
  /// {@macro customText.CustomText}
  const CustomText(
    this.text, {
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
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  /// The text to parse and display.
  final String text;

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
      // Keeps text transparent during initial parsing to prevent the
      // strings that should not be shown (e.g. symbols for LinkMatcher
      // `[]()`) from being visible for an instant.
      // Exceptionally, text is not made invisible in the following cases:
      //
      // * When `preventBlocking` is enabled, which means the user has
      //   chosen to show the raw text without it blocked by parsing.
      // * When `definitions` contains only TextDefinition, in which case
      //   the shown text remains unchanged before and after parsing.
      style: widget.preventBlocking ||
              widget.definitions.every((def) => def.isTextDefinition)
          ? widget.style
          : widget.style?.copyWith(color: const Color(0x00000000)) ??
              const TextStyle(color: Color(0x00000000)),
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
  void initState() {
    super.initState();

    _textSpanNotifier = CustomTextSpanNotifier(
      text: widget.text,
      settings: _createNotifierSettings(),
    );
    _parse(widget.text);
  }

  @override
  void didUpdateWidget(CustomText oldWidget) {
    super.didUpdateWidget(oldWidget);

    final needsParse = _hasNewMatchers(oldWidget) ||
        widget.text != oldWidget.text ||
        widget.parserOptions != oldWidget.parserOptions;

    if (needsParse) {
      _textSpanNotifier.settings = _createNotifierSettings();
      _parse(widget.text);
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
        _hasNewDefinitions(oldWidget);

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
        textScaleFactor: widget.textScaleFactor,
        maxLines: widget.maxLines,
        semanticsLabel: widget.semanticsLabel,
        textWidthBasis: widget.textWidthBasis,
        textHeightBehavior: widget.textHeightBehavior,
      ),
    );
  }
}
