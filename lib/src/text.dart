import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:text_parser/text_parser.dart';

part 'definition.dart';

const _kLongTapDuration = Duration(milliseconds: 600);

/// A widget that adds styles to partial strings in text and/or enables
/// taps on them according to specified definitions.
///
/// This widget may be useful for making strings such as URLs, email
/// addresses or phone numbers clickable, or for only highlighting some
/// parts of text with colors / different font settings depending on the
/// types of string elements.
class CustomText extends StatefulWidget {
  /// Creates a widget that adds styles to string elements in text and/or
  /// enables clicks on them according to specified definitions.
  const CustomText(
    this.text, {
    Key key,
    @required this.definitions,
    this.style,
    this.matchStyle,
    this.tapStyle,
    this.onTap,
    this.onLongTap,
    this.longTapDuration,
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
  })  : assert(
          definitions != null && definitions.length > 0,
          '`definitions` must not be null nor empty.',
        ),
        super(key: key);

  /// The text to parse and show.
  final String text;

  /// Definitions that specify how to parse text, what to show and how to
  /// show them, and what to do on taps.
  final List<_Definition> definitions;

  /// The text style for strings that did not match any match patterns.
  ///
  /// This is also used as the default text style; it is applied to matched
  /// strings too if neither [CustomText.matchStyle] nor `matchStyle` in the
  /// relative definition is set, and similarly, applied while they are
  /// pressed if none of [CustomText.matchStyle], [CustomText.tapStyle], and
  /// `matchStyle` / `tapStyle` in the relative definition is set.
  ///
  /// If no style is set to any of the above and this parameter,
  /// [DefaultTextStyle] is used instead.
  final TextStyle style;

  /// The default text style for matched strings. This is used only if
  /// `matchStyle` is not set in the relative definition.
  ///
  /// If no style is set to this parameter either, [DefaultTextStyle] is
  /// used instead.
  final TextStyle matchStyle;

  /// The default text style used for matched strings while they are
  /// pressed.
  ///
  /// This is used only if neither `matchStyle` nor `tapStyle` is set
  /// in the relative definition,
  ///
  /// If no style is set to this parameter either, [DefaultTextStyle]
  /// is used instead.
  final TextStyle tapStyle;

  /// The callback function called when tappable elements are tapped.
  final void Function(Type, String) onTap;

  /// The callback function called when tappable elements are long-tapped.
  final void Function(Type, String) onLongTap;

  /// The duration before a tap is regarded as a long-tap and the
  /// [onLongTap] function is called..
  final Duration longTapDuration;

  /// Parsing is executed in an isolate to prevent blocking of the UI
  /// if set to `true`, except on the web where isolates are not supported,
  ///
  /// Using an isolate has the adverse effect of adding an overhead,
  /// resulting in a slightly longer execution. If it is enabled. the
  /// widget shows text without styles first and then applies them when
  /// parsing is completed. Generally, leaving it disabled shows styled
  /// text quicker, which probably looks better.
  ///
  /// How long parsing takes depends on the text length, the number and
  /// complexity of match patterns, the device performance, etc.
  /// Try both `true` and `false` to see which is suitable if you are
  /// unsure of it.
  final bool preventBlocking;

  final StrutStyle strutStyle;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Locale locale;
  final bool softWrap;
  final TextOverflow overflow;
  final double textScaleFactor;
  final int maxLines;
  final String semanticsLabel;
  final TextWidthBasis textWidthBasis;
  final TextHeightBehavior textHeightBehavior;

  @override
  _CustomTextState createState() => _CustomTextState();
}

class _CustomTextState extends State<CustomText> {
  Map<Type, _Definition> _definitions;
  List<TextMatcher> _matchers;
  Future<List<TextElement>> _futureElements;
  List<bool> _isTapped;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(CustomText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init();
  }

  @override
  void dispose() {
    if (_timer?.isActive ?? false) {
      _timer.cancel();
    }
    super.dispose();
  }

  void _init() {
    _isTapped = [];
    _definitions = {
      for (final e in widget.definitions) e.matcher.runtimeType: e,
    };
    _matchers = widget.definitions.map((def) => def.matcher).toList();
    _futureElements = TextParser(matchers: _matchers).parse(
      widget.text,
      useIsolate: widget.preventBlocking,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TextElement>>(
      future: _futureElements,
      initialData: const [],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data.length != _isTapped.length) {
          _isTapped = List.generate(snapshot.data.length, (_) => false);
        }
        return _richText(snapshot.data);
      },
    );
  }

  Text _richText(List<TextElement> elements) {
    return Text.rich(
      TextSpan(
        children: elements.isEmpty
            ? [TextSpan(text: widget.text)]
            : elements.asMap().entries.map((entry) {
                final index = entry.key;
                final elm = entry.value;

                if (elm.matcherType == null ||
                    !_definitions.containsKey(elm.matcherType)) {
                  return TextSpan(text: elm.text, style: widget.style);
                }

                final def = _definitions[elm.matcherType];
                if (def.builder != null) {
                  return def.builder(elm.text, elm.groups);
                }

                final isTappable = def.onTap != null ||
                    def.onLongTap != null ||
                    widget.onTap != null ||
                    widget.onLongTap != null;

                return isTappable
                    ? _tappableTextSpan(
                        index: index,
                        text: def.labelSelector == null
                            ? elm.text
                            : def.labelSelector(elm.groups),
                        link: def.tapSelector == null
                            ? elm.text
                            : def.tapSelector(elm.groups),
                        definition: def,
                        longTapDuration: widget.longTapDuration,
                      )
                    : TextSpan(
                        text: def.labelSelector == null
                            ? elm.text
                            : def.labelSelector(elm.groups),
                        style:
                            def.matchStyle ?? widget.matchStyle ?? widget.style,
                      );
              }).toList(),
      ),
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

  TextSpan _tappableTextSpan({
    int index,
    String text,
    String link,
    _Definition definition,
    Duration longTapDuration,
  }) {
    final matchStyle =
        definition.matchStyle ?? widget.matchStyle ?? widget.style;
    final tapStyle = definition.tapStyle ?? widget.tapStyle ?? matchStyle;

    return TextSpan(
      text: text,
      style:
          _isTapped.length > index && _isTapped[index] ? tapStyle : matchStyle,
      recognizer: TapGestureRecognizer()
        ..onTapDown = (_) {
          setState(() => _isTapped[index] = true);
          if (definition.onLongTap != null) {
            _timer = Timer(
              longTapDuration ?? _kLongTapDuration,
              () => definition.onLongTap(link),
            );
          } else if (widget.onLongTap != null) {
            _timer = Timer(
              longTapDuration ?? _kLongTapDuration,
              () => widget.onLongTap(definition.matcher.runtimeType, link),
            );
          }
        }
        ..onTapUp = (_) {
          setState(() => _isTapped[index] = false);
          if (_timer?.isActive ?? true) {
            if (definition.onTap != null) {
              definition.onTap(link);
            } else if (widget.onTap != null) {
              widget.onTap(definition.matcher.runtimeType, link);
            }
          }
          _timer?.cancel();
          _timer = null;
        }
        ..onTapCancel = () {
          setState(() => _isTapped[index] = false);
          _timer?.cancel();
          _timer = null;
        }
        // onTap is necessary until this fix arrives in the stable channel.
        // https://github.com/flutter/flutter/pull/69793
        ..onTap = () {},
    );
  }
}
