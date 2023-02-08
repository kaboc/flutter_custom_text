import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:meta/meta.dart';
import 'package:text_parser/text_parser.dart';

import 'definitions.dart';
import 'parser_options.dart';
import 'text_span_notifier.dart';
import 'transient_elements_builder.dart';

/// A variant of [TextEditingController] that decorates strings in
/// an editable text field and enables tap, long-press and/or hover
/// gestures based on flexible definitions.
///
/// {@template customText.TextEditingController}
/// This controller is useful for making partial strings in text such
/// as URLs, email addresses or phone numbers clickable, or for only
/// highlighting some parts of text with colors and different font
/// settings depending on the types of text elements.
/// {@endtemplate}
class CustomTextEditingController extends TextEditingController {
  /// Creates a controller for an editable text field.
  ///
  /// {@macro customText.TextEditingController}
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
    this.debounceDuration,
  }) {
    _init();
  }

  /// Creates a controller for an editable text field from an initial
  /// [TextEditingValue].
  ///
  /// {@macro customText.TextEditingController}
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
    this.debounceDuration,
  }) : super.fromValue() {
    _init();
  }

  /// [TextDefinition]s that specify rules for parsing, appearance and
  /// actions.
  final List<TextDefinition> definitions;

  /// The options for [RegExp] that configure how regular expressions
  /// are treated.
  final ParserOptions parserOptions;

  /// The text style for strings that did not match any match patterns.
  ///
  /// This is also used for matched strings if neither
  /// [CustomTextEditingController.matchStyle] nor `matchStyle` in the
  /// relevant definition is specified.
  ///
  /// If no style is specified, the `style` of the editable text field that
  /// this controller is associated with is used instead.
  final TextStyle? style;

  /// {@macro customText.matchStyle}
  final TextStyle? matchStyle;

  /// {@macro customText.tapStyle}
  final TextStyle? tapStyle;

  /// {@macro customText.hoverStyle}
  final TextStyle? hoverStyle;

  /// {@macro customText.onTap}
  final void Function(Type, String)? onTap;

  /// {@macro customText.onLongPress}
  final void Function(Type, String)? onLongPress;

  /// {@macro customText.longPressDuration}
  final Duration? longPressDuration;

  /// The debouncing duration after every text input action.
  ///
  /// **This is experimental for now. Use it at your own risk.**
  ///
  /// This is not perfect but somewhat effective in long text.
  /// Parsing is scheduled to be performed after the specified duration,
  /// but it is rescheduled if any event happens, such as a text change
  /// and a cursor move. It reduces the frequency of text parsing and
  /// thus making text updates a little more performant.
  ///
  /// The default value is `null`, meaning debouncing is disabled.
  /// The initial parsing is not debounced even if a duration above
  /// zero is given.
  ///
  /// A new value can be assigned to change the duration span
  /// or turn debouncing on/off.
  @experimental
  Duration? debounceDuration;

  late TextParser _parser;
  late CustomTextSpanNotifier _textSpanNotifier;
  String _oldText = '';
  TextStyle? _style;
  Future<void> Function()? _delayedParse;
  Timer? _debounceTimer;

  Duration? get _correctedDebounceDuration => debounceDuration == null ||
          debounceDuration == Duration.zero ||
          debounceDuration!.isNegative
      ? null
      : debounceDuration;

  /// The list of [TextElement]s as a result of parsing.
  List<TextElement> get elements =>
      List.unmodifiable(_textSpanNotifier.elements);

  @override
  void dispose() {
    _debounceTimer?.cancel();
    removeListener(_onTextChanged);

    _textSpanNotifier
      ..removeListener(notifyListeners)
      ..dispose();

    super.dispose();
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
      settings: NotifierSettings(
        definitions: definitions,
        matchStyle: matchStyle,
        tapStyle: tapStyle,
        hoverStyle: hoverStyle,
        onTap: onTap,
        onLongPress: onLongPress,
        longPressDuration: longPressDuration,
      ),
    )..addListener(notifyListeners);

    if (text.isNotEmpty) {
      _onTextChanged();
    }
  }

  Future<void> _onTextChanged() async {
    _debounceTimer?.cancel();

    final debounceDuration = _correctedDebounceDuration;

    final oldText = _oldText;
    final newText = text;
    _oldText = text;

    if (newText != oldText) {
      final oldElementsLength = _textSpanNotifier.elements.length;

      if (debounceDuration == null || oldElementsLength == 0) {
        _textSpanNotifier
          ..elements = await _parser.parse(newText, useIsolate: false)
          ..buildSpan(
            style: style ?? _style,
            oldElementsLength: 0,
          );
      } else {
        final elements = _textSpanNotifier.elements;
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: oldText,
          newText: newText,
        );
        final changeRange = builder.findUpdatedElementsRange();
        if (changeRange.isInvalid) {
          return;
        }

        final result = builder.build(changeRange: changeRange);

        _textSpanNotifier
          ..elements = result.elements
          ..buildTransientSpan(
            style: style ?? _style,
            replaceRange: result.replaceRange,
            spanRange: result.spanRange,
          );

        _delayedParse = () async {
          _textSpanNotifier
            ..elements = await _parser.parse(newText, useIsolate: false)
            ..buildSpan(
              style: style ?? _style,
              oldElementsLength: oldElementsLength,
            );
        };
      }
    }

    final timer = _debounceTimer;
    final needDebounce =
        _delayedParse != null && (timer == null || !timer.isActive);

    if (needDebounce) {
      _debounceTimer = Timer(debounceDuration!, () async {
        await _delayedParse?.call();
        _delayedParse = null;
      });
    }
  }
}
