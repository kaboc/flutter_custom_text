import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:text_parser/text_parser.dart';

part 'definition.dart';

const _kLongPressDuration = Duration(milliseconds: 600);

/// A widget that adds styles to partial strings in text and/or enables
/// taps/long-presses on them according to specified definitions.
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
    Key? key,
    required this.definitions,
    this.style,
    this.matchStyle,
    this.tapStyle,
    this.onTap,
    @Deprecated(
      '[onLongTap] is being deprecated in favor of [onLongPress]. '
      '[onLongTap] will be removed on or after the 1.0.0 release.',
    )
        this.onLongTap,
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
  })  : assert(
          maxLines == null || maxLines > 0,
          '`maxLines` must be greater than zero if it is not null.',
        ),
        super(key: key);

  /// The text to parse and show.
  final String text;

  /// Definitions that specify how to parse text, what to show and how to
  /// show them, and what to do on taps/long-presses.
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
  final TextStyle? style;

  /// The default text style for matched strings. This is used only if
  /// `matchStyle` is not set in the relative definition.
  ///
  /// If no style is set to this parameter either, [DefaultTextStyle] is
  /// used instead.
  final TextStyle? matchStyle;

  /// The default text style used for matched strings while they are
  /// pressed.
  ///
  /// This is used only if neither `matchStyle` nor `tapStyle` is set
  /// in the relative definition,
  ///
  /// If no style is set to this parameter either, [DefaultTextStyle]
  /// is used instead.
  final TextStyle? tapStyle;

  /// The callback function called when tappable elements are tapped.
  final void Function(Type, String)? onTap;

  /// The callback function called when tappable elements are long-pressed.
  final void Function(Type, String)? onLongTap;

  /// The callback function called when tappable elements are long-pressed.
  final void Function(Type, String)? onLongPress;

  /// The duration before a tap is regarded as a long-press and the
  /// [onLongPress] function is called.
  final Duration? longPressDuration;

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

  final _tapRecognizers = <int, TapGestureRecognizer>{};
  int? _tapIndex;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(CustomText oldWidget) {
    super.didUpdateWidget(oldWidget);
    _disposeTapRecognizers();
    _init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _disposeTapRecognizers();
    super.dispose();
  }

  void _init() {
    _definitions = {
      for (final e in widget.definitions) e.matcher.runtimeType: e,
    };
    _matchers = widget.definitions.map((def) => def.matcher).toList();
    _futureElements = TextParser(matchers: _matchers).parse(
      widget.text,
      useIsolate: widget.preventBlocking,
    );
  }

  void _disposeTapRecognizers() {
    _tapRecognizers
      ..forEach((_, recognizer) => recognizer.dispose())
      ..clear();
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
      TextSpan(
        children: elements.isEmpty
            ? [TextSpan(text: widget.text)]
            : elements.asMap().entries.map((entry) {
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
                    widget.onLongPress != null ||
                    // ignore: deprecated_member_use_from_same_package
                    widget.onLongTap != null;

                return isTappable
                    ? _tappableTextSpan(
                        index: index,
                        text: def.labelSelector == null
                            ? elm.text
                            : def.labelSelector!(elm.groups),
                        link: def.tapSelector == null
                            ? elm.text
                            : def.tapSelector!(elm.groups),
                        definition: def,
                        longPressDuration:
                            widget.longPressDuration ?? _kLongPressDuration,
                      )
                    : TextSpan(
                        text: def.labelSelector == null
                            ? elm.text
                            : def.labelSelector!(elm.groups),
                        style:
                            def.matchStyle ?? widget.matchStyle ?? widget.style,
                        mouseCursor: def.mouseCursor,
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
    required int index,
    required String text,
    required String link,
    required _Definition definition,
    required Duration longPressDuration,
  }) {
    final matchStyle =
        definition.matchStyle ?? widget.matchStyle ?? widget.style;
    final tapStyle = definition.tapStyle ?? widget.tapStyle ?? matchStyle;

    return TextSpan(
      text: text,
      style: _tapIndex == index ? tapStyle : matchStyle,
      mouseCursor: definition.mouseCursor,
      recognizer: _tapRecognizers[index] = _recognizer(
        index: index,
        link: link,
        definition: definition,
        longPressDuration: longPressDuration,
      ),
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
          // ignore: deprecated_member_use_from_same_package
        } else if (widget.onLongPress != null || widget.onLongTap != null) {
          // ignore: deprecated_member_use_from_same_package
          final onLongPress = widget.onLongPress ?? widget.onLongTap;
          _timer = Timer(
            longPressDuration,
            () => onLongPress!(definition.matcher.runtimeType, link),
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
