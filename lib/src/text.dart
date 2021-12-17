import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:text_parser/text_parser.dart';

import 'parser_options.dart';

part 'definition.dart';

const _kLongPressDuration = Duration(milliseconds: 600);

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
  final List<_Definition> definitions;

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
  late Map<Type, _Definition> _definitions;
  late List<TextMatcher> _matchers;
  late Future<List<TextElement>> _futureElements;

  final Map<int, TapGestureRecognizer> _tapRecognizers = {};
  Timer? _timer;
  int? _tapIndex;
  int? _hoverIndex;

  @override
  void initState() {
    super.initState();
    _init();
    _reset();
  }

  @override
  void didUpdateWidget(CustomText oldWidget) {
    super.didUpdateWidget(oldWidget);

    _init();

    final isUpdated = widget.text != oldWidget.text ||
        widget.preventBlocking != oldWidget.preventBlocking ||
        _hasNewDefinitions(oldWidget);

    if (isUpdated) {
      _reset();
    }
  }

  @override
  void dispose() {
    _disposeTapRecognizers();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    // Makes sure that the state object is still mounted
    // to prevent the issues #6 and #9.
    if (mounted) {
      super.setState(fn);
    }
  }

  void _init() {
    _definitions = {
      for (final def in widget.definitions) def.matcher.runtimeType: def,
    };
  }

  void _reset() {
    _disposeTapRecognizers();

    _matchers = widget.definitions.map((def) => def.matcher).toList();

    _futureElements = TextParser(
      matchers: _matchers,
      multiLine: widget.parserOptions.multiLine,
      caseSensitive: widget.parserOptions.caseSensitive,
      unicode: widget.parserOptions.unicode,
      dotAll: widget.parserOptions.dotAll,
    ).parse(
      widget.text,
      useIsolate: widget.preventBlocking,
    );
  }

  void _disposeTapRecognizers() {
    _timer?.cancel();
    _tapRecognizers
      ..forEach((_, recognizer) => recognizer.dispose())
      ..clear();
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
      _textSpan(elements),
      style: widget.style,
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

  TextSpan _textSpan(List<TextElement> elements) {
    // Replacing only inner TextSpan when parsing is done causes
    // the issue #5, so this outer TextSpan is replaced instead.
    return elements.isEmpty
        ? TextSpan(text: widget.text)
        : TextSpan(
            children: elements.asMap().entries.map((entry) {
              final index = entry.key;
              final elm = entry.value;

              final def = _definitions[elm.matcherType];
              if (def == null) {
                return TextSpan(text: elm.text, style: widget.style);
              }

              if (def.builder != null) {
                return def.builder!(elm.text, elm.groups);
              }

              final isTappable = def.onTap != null ||
                  def.onLongPress != null ||
                  widget.onTap != null ||
                  widget.onLongPress != null;

              final text = def.labelSelector == null
                  ? elm.text
                  : def.labelSelector!(elm.groups);

              return isTappable
                  ? _tappableTextSpan(
                      index: index,
                      text: text,
                      link: def.tapSelector == null
                          ? elm.text
                          : def.tapSelector!(elm.groups),
                      definition: def,
                      longPressDuration:
                          widget.longPressDuration ?? _kLongPressDuration,
                    )
                  : _nonTappableTextSpan(
                      index: index,
                      text: text,
                      definition: def,
                    );
            }).toList(),
          );
  }

  TextSpan _nonTappableTextSpan({
    required int index,
    required String text,
    required _Definition definition,
  }) {
    final matchStyle =
        definition.matchStyle ?? widget.matchStyle ?? widget.style;
    final hoverStyle = definition.hoverStyle ?? widget.hoverStyle;

    return TextSpan(
      text: text,
      style: _hoverIndex == index ? hoverStyle : matchStyle,
      mouseCursor: definition.mouseCursor,
      onEnter: hoverStyle == null
          ? null
          : (_) {
              setState(() => _hoverIndex = index);
            },
      onExit: hoverStyle == null
          ? null
          : (_) {
              setState(() => _hoverIndex = null);
            },
    );
  }

  TextSpan _tappableTextSpan({
    required int index,
    required String text,
    required String link,
    required _Definition definition,
    required Duration longPressDuration,
  }) {
    final matchStyle =
        definition.matchStyle ?? widget.matchStyle ?? widget.style;
    final tapStyle = definition.tapStyle ?? widget.tapStyle ?? matchStyle;
    final hoverStyle = definition.hoverStyle ?? widget.hoverStyle;

    return TextSpan(
      text: text,
      style: _tapIndex == index
          ? tapStyle
          : (_hoverIndex == index ? hoverStyle : matchStyle),
      recognizer: _tapRecognizers[index] ??= _recognizer(
        index: index,
        link: link,
        definition: definition,
        longPressDuration: longPressDuration,
      ),
      mouseCursor: definition.mouseCursor,
      onEnter: hoverStyle == null
          ? null
          : (_) {
              setState(() => _hoverIndex = index);
            },
      onExit: hoverStyle == null
          ? null
          : (_) {
              setState(() => _hoverIndex = null);
            },
    );
  }

  TapGestureRecognizer _recognizer({
    required int index,
    required String link,
    required _Definition definition,
    required Duration longPressDuration,
  }) {
    return TapGestureRecognizer()
      ..onTapDown = (_) {
        setState(() => _tapIndex = index);
        if (definition.onLongPress != null) {
          _timer = Timer(
            longPressDuration,
            () => definition.onLongPress!(link),
          );
        } else if (widget.onLongPress != null) {
          _timer = Timer(
            longPressDuration,
            () => widget.onLongPress!(definition.matcher.runtimeType, link),
          );
        }
      }
      ..onTapUp = (_) {
        setState(() => _tapIndex = null);
        if (_timer?.isActive ?? true) {
          if (definition.onTap != null) {
            definition.onTap!(link);
          } else if (widget.onTap != null) {
            widget.onTap!(definition.matcher.runtimeType, link);
          }
        }
        _timer?.cancel();
        _timer = null;
      }
      ..onTapCancel = () {
        setState(() => _tapIndex = null);
        _timer?.cancel();
        _timer = null;
      };
  }
}
