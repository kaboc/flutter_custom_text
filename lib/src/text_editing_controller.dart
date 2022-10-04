import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:text_parser/text_parser.dart';

import 'definitions.dart';
import 'parser_options.dart';
import 'text_span_notifier.dart';

/// A widget that decorates parts of editable text and/or enables
/// taps/long-presses according on them according to specified definitions.
///
/// This widget is useful for making strings in editable text such as
/// URLs, email addresses or phone numbers clickable, or for only
/// highlighting some parts of text with colors and different font
/// settings depending on the types of string elements.
class CustomTextEditingController extends TextEditingController {
  /// Creates a controller for an editable text field.
  ///
  /// Unlike [TextEditingController], this controller has the features
  /// to decorate parts of editable text and/or enable clicks on them
  /// according to specified definitions.
  CustomTextEditingController({
    super.text,
    required this.definitions,
    this.parserOptions = const ParserOptions(),
    this.style,
    this.matchStyle,
    this.tapStyle,
    this.hoverStyle,
    this.onTap,
    this.onLongPress,
    this.longPressDuration,
  }) {
    _init();
  }

  /// Creates a controller for an editable text field from an initial
  /// [TextEditingValue].
  ///
  /// Unlike [TextEditingController], this controller has the features
  /// to decorate parts of editable text and/or enable clicks on them
  /// according to specified definitions.
  CustomTextEditingController.fromValue(
    super.value, {
    required this.definitions,
    this.parserOptions = const ParserOptions(),
    this.style,
    this.matchStyle,
    this.tapStyle,
    this.hoverStyle,
    this.onTap,
    this.onLongPress,
    this.longPressDuration,
  }) : super.fromValue() {
    _init();
  }

  /// Definitions that specify parsing rules, text styles and actions
  /// for tap/long-press events.
  final List<TextDefinition> definitions;

  /// The options for [RegExp] that configures how a regular expression
  /// is treated.
  final ParserOptions parserOptions;

  /// The text style for strings that did not match any match patterns.
  ///
  /// This is also used for matched strings if neither
  /// [CustomTextEditingController.matchStyle] nor `matchStyle` in the
  /// relative definition is set.
  ///
  /// If no style is set, the `style` of the editable text field that
  /// this controller is associated with is used instead.
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

  late TextParser _parser;

  late CustomTextSpanNotifier _textSpanNotifier;

  TextStyle? _style;

  /// The list of [TextElement]s as a result of parsing.
  List<TextElement> get elements =>
      List.unmodifiable(_textSpanNotifier.elements);

  @override
  void dispose() {
    removeListener(_onTextChanged);

    _textSpanNotifier
      ..removeListener(notifyListeners)
      ..dispose();

    super.dispose();
  }

  void _init() {
    addListener(_onTextChanged);

    _parser = TextParser(
      matchers: definitions.map((def) => def.matcher).toList(),
      multiLine: parserOptions.multiLine,
      caseSensitive: parserOptions.caseSensitive,
      unicode: parserOptions.unicode,
      dotAll: parserOptions.dotAll,
    );

    _textSpanNotifier = CustomTextSpanNotifier(
      text: text,
      definitions: definitions,
      matchStyle: matchStyle,
      tapStyle: tapStyle,
      hoverStyle: hoverStyle,
      onTap: onTap,
      onLongPress: onLongPress,
      longPressDuration: longPressDuration,
    )..addListener(notifyListeners);

    if (text.isNotEmpty) {
      _onTextChanged();
    }
  }

  Future<void> _onTextChanged() async {
    final oldText = _textSpanNotifier.elements.map((v) => v.text).join();
    if (text != oldText) {
      _textSpanNotifier
        ..elements = await _parser.parse(text, useIsolate: false)
        ..buildSpan(style: style ?? _style);
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    _style = style;
    return _textSpanNotifier.value;
  }
}
