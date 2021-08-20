import 'dart:async';

import 'package:flutter/material.dart';

import 'package:text_parser/text_parser.dart';

import 'definition_base.dart';
import 'parser_options.dart';
import 'text_span_notifier.dart';

/// A widget that decorates parts of text and/or enables taps/long-presses
/// on them according to specified definitions.
///
/// This widget is useful for making strings such as URLs, email addresses
/// or phone numbers clickable, or for only highlighting some parts of
/// text with colors and different font settings depending on the types
/// of string elements.
class CustomText extends StatefulWidget {
  /// Creates a widget that decorates parts of text and/or enables clicks
  /// on them according to specified definitions.
  const CustomText(
    this.text, {
    Key? key,
    required this.definitions,
    this.parserOptions = const ParserOptions(),
    this.style,
    this.matchStyle,
    this.tapStyle,
    this.hoverStyle,
    this.onTap,
    this.onLongPress,
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
  }) : super(key: key);

  /// The text to parse and show.
  final String text;

  /// Definitions that specify parsing rules, text styles and actions
  /// for tap/long-press events.
  final List<Definition> definitions;

  /// The options for [RegExp] that configures how a regular expression
  /// is treated.
  final ParserOptions parserOptions;

  /// The text style for strings that did not match any match patterns.
  ///
  /// This is also used for matched strings if neither [CustomText.matchStyle]
  /// nor `matchStyle` in the relative definition is set.
  ///
  /// If no style is set, [DefaultTextStyle] is used instead.
  final TextStyle? style;

  /// The default text style for matched strings.
  ///
  /// This is used only if `matchStyle` is not set in the relative
  /// definition.
  final TextStyle? matchStyle;

  /// The default text style used for matched strings while they are
  /// pressed.
  ///
  /// This is used only if neither `matchStyle` nor `tapStyle` is set
  /// in the relative definition,
  final TextStyle? tapStyle;

  /// The default text style used for matched strings while they are
  /// under the mouse pointer.
  ///
  /// This is used only if `hoverStyle` is not set in the relative
  /// definition.
  final TextStyle? hoverStyle;

  /// The callback function called when tappable elements are tapped.
  final void Function(Type, String)? onTap;

  /// The callback function called when tappable elements are long-pressed.
  final void Function(Type, String)? onLongPress;

  /// The duration before a tap is regarded as a long-press and the
  /// [onLongPress] function is called.
  final Duration? longPressDuration;

  /// Parsing is executed in an isolate to prevent blocking of the UI
  /// if set to `true`, except on the web where isolates are not supported,
  ///
  /// Using an isolate has the adverse effect of adding an overhead,
  /// resulting in a slightly longer execution, but it is sometimes better
  /// than the main thread getting blocked.
  ///
  /// How long parsing takes depends on the text length, the number and
  /// complexity of match patterns, the device performance, etc.
  /// Try both `true` and `false` to see which is suitable if you are
  /// unsure of it.
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
  _CustomTextState createState() => _CustomTextState();
}

class _CustomTextState extends State<CustomText> {
  late Future<List<TextElement>> _futureElements;

  late CustomTextSpanNotifier _textSpanNotifier;

  @override
  void initState() {
    super.initState();

    _parse();
    _initSpanNotifier();
  }

  @override
  void didUpdateWidget(CustomText oldWidget) {
    super.didUpdateWidget(oldWidget);

    final isUpdated = widget.text != oldWidget.text ||
        widget.preventBlocking != oldWidget.preventBlocking ||
        _hasNewDefinitions(oldWidget);

    if (isUpdated) {
      _disposeSpanNotifier();
      _initSpanNotifier();
    }
  }

  @override
  void dispose() {
    _disposeSpanNotifier();
    super.dispose();
  }

  void _parse() {
    _futureElements = TextParser(
      matchers: widget.definitions.map((def) => def.matcher).toList(),
      multiLine: widget.parserOptions.multiLine,
      caseSensitive: widget.parserOptions.caseSensitive,
      unicode: widget.parserOptions.unicode,
      dotAll: widget.parserOptions.dotAll,
    ).parse(
      widget.text,
      useIsolate: widget.preventBlocking,
    );

    _initSpanNotifier();
  }

  void _initSpanNotifier() {
    _textSpanNotifier = CustomTextSpanNotifier(
      text: widget.text,
      definitions: widget.definitions,
      matchStyle: widget.matchStyle,
      tapStyle: widget.tapStyle,
      hoverStyle: widget.hoverStyle,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      longPressDuration: widget.longPressDuration,
    );

    // Causes a rebuild when notified of a change
    // in the value of SpanState.
    _textSpanNotifier.addListener(_rebuild);
  }

  void _disposeSpanNotifier() {
    _textSpanNotifier.removeListener(_rebuild);
    _textSpanNotifier.dispose();
  }

  void _rebuild() {
    // Makes sure that the state object is still mounted
    // to prevent the issues #6 and #9.
    if (mounted) {
      setState(() {});
    }
  }

  bool _hasNewDefinitions(CustomText oldWidget) {
    if (widget.definitions.length == oldWidget.definitions.length) {
      return true;
    }

    for (var i = 0; i < widget.definitions.length; i++) {
      if (widget.definitions[i].matcher != oldWidget.definitions[i].matcher) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TextElement>>(
      future: _futureElements,
      initialData: const [],
      builder: (_, snapshot) => _richText(snapshot.data!),
    );
  }

  Text _richText(List<TextElement> elements) {
    return Text.rich(
      _textSpanNotifier.span(
        elements: elements,
        style: widget.style,
      ),
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
    );
  }
}
