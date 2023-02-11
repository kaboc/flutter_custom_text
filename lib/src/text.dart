import 'dart:async';
import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';

import 'package:text_parser/text_parser.dart';

import 'definition_base.dart';
import 'parser_options.dart';
import 'text_span_notifier.dart';

/// A text widget that decorates strings in it and enables tap,
/// long-press and/or hover gestures based on flexible definitions.
///
/// {@template customText.CustomText}
/// This widget is useful for making partial strings in text such as URLs,
/// email addresses or phone numbers clickable, or for only highlighting
/// some parts of text with colors and different font settings depending
/// on the types of text elements.
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
  })  : _isSelectable = false,
        focusNode = null,
        showCursor = false,
        autofocus = false,
        toolbarOptions = null,
        minLines = null,
        cursorWidth = 0.0,
        cursorHeight = null,
        cursorRadius = null,
        cursorColor = null,
        selectionHeightStyle = null,
        selectionWidthStyle = null,
        dragStartBehavior = null,
        enableInteractiveSelection = false,
        selectionControls = null,
        scrollPhysics = null,
        onSelectionChanged = null;

  /// Creates a selectable text widget that decorates strings in it
  /// and enables tap, long-press and/or hover gestures based on
  /// flexible definitions.
  @Deprecated(
    'Use SelectionArea on Flutter 3.3 and above, or '
    '`TextField.readOnly` with `CustomTextEditingController`',
  )
  const CustomText.selectable(
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
    this.longPressDuration,
    this.preventBlocking = false,
    this.focusNode,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.textScaleFactor,
    this.showCursor = false,
    this.autofocus = false,
    this.toolbarOptions,
    this.minLines,
    this.maxLines,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.selectionHeightStyle,
    this.selectionWidthStyle,
    this.dragStartBehavior,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.scrollPhysics,
    this.semanticsLabel,
    this.textHeightBehavior,
    this.textWidthBasis,
    this.onSelectionChanged,
  })  : _isSelectable = true,
        locale = null,
        softWrap = null,
        overflow = null;

  final bool _isSelectable;

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
  final void Function(Type, String)? onTap;

  /// {@template customText.onLongPress}
  /// The callback function called when a tappable element is long-pressed.
  ///
  /// The argument with the same name in the relevant definition takes
  /// precedence over this.
  /// {@endtemplate}
  final void Function(Type, String)? onLongPress;

  /// {@template customText.longPressDuration}
  /// The duration before a tap is regarded as a long-press and the
  /// [onLongPress] function is called.
  /// {@endtemplate}
  final Duration? longPressDuration;

  /// Parsing is executed in an isolate to prevent blocking of the UI
  /// if set to `true`, except on the web where isolates are not supported.
  ///
  /// Using an isolate has the adverse effect of adding an overhead,
  /// resulting in a slightly longer execution, but it is sometimes better
  /// than the main thread getting blocked.
  ///
  /// How long parsing takes depends on the text length, the number and
  /// complexity of match patterns, the device performance, etc.
  /// Try both `true` and `false` to see which is suitable if you are
  /// unsure.
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

  // For SelectableText
  final FocusNode? focusNode;
  final bool showCursor;
  final bool autofocus;
  // ignore: deprecated_member_use
  final ToolbarOptions? toolbarOptions;
  final int? minLines;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final ui.BoxHeightStyle? selectionHeightStyle;
  final ui.BoxWidthStyle? selectionWidthStyle;
  final DragStartBehavior? dragStartBehavior;
  final bool enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final ScrollPhysics? scrollPhysics;
  final SelectionChangedCallback? onSelectionChanged;

  @override
  State<CustomText> createState() => _CustomTextState();
}

class _CustomTextState extends State<CustomText> {
  late CustomTextSpanNotifier _textSpanNotifier;

  NotifierSettings get _notifierSettings => NotifierSettings(
        definitions: widget.definitions,
        matchStyle: widget.matchStyle,
        tapStyle: widget.tapStyle,
        hoverStyle: widget.hoverStyle,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        longPressDuration: widget.longPressDuration,
      );

  @override
  void initState() {
    super.initState();

    _textSpanNotifier = CustomTextSpanNotifier(
      text: widget.text,
      settings: _notifierSettings,
    );
    _parse();
  }

  @override
  void didUpdateWidget(CustomText oldWidget) {
    super.didUpdateWidget(oldWidget);

    final isMatcherUpdated = _hasNewMatchers(oldWidget);
    final isDefinitionUpdated = _hasNewDefinitions(oldWidget);

    final needsParse = isMatcherUpdated ||
        widget.text != oldWidget.text ||
        widget.parserOptions != oldWidget.parserOptions;

    final needsSpanUpdate = isMatcherUpdated ||
        isDefinitionUpdated ||
        widget.style != oldWidget.style ||
        widget.matchStyle != oldWidget.matchStyle ||
        widget.tapStyle != oldWidget.tapStyle ||
        widget.hoverStyle != oldWidget.hoverStyle ||
        widget.longPressDuration != oldWidget.longPressDuration;

    if (needsSpanUpdate) {
      _textSpanNotifier.updateSettings(_notifierSettings);
    }

    if (needsParse) {
      _parse();
    } else if (needsSpanUpdate) {
      _textSpanNotifier.buildSpan(
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

  Future<void> _parse() async {
    final elements = await TextParser(
      matchers: widget.definitions.map((def) => def.matcher).toList(),
      multiLine: widget.parserOptions.multiLine,
      caseSensitive: widget.parserOptions.caseSensitive,
      unicode: widget.parserOptions.unicode,
      dotAll: widget.parserOptions.dotAll,
    ).parse(
      widget.text,
      useIsolate: widget.preventBlocking,
    );

    _textSpanNotifier
      ..elements = elements
      ..buildSpan(
        style: widget.style,
        oldElementsLength: _textSpanNotifier.elements.length,
      );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextSpan>(
      valueListenable: _textSpanNotifier,
      builder: (context, span, _) =>
          widget._isSelectable ? _richSelectableText(span) : _richText(span),
    );
  }

  Text _richText(TextSpan span) {
    return Text.rich(
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
    );
  }

  SelectableText _richSelectableText(TextSpan span) {
    return SelectableText.rich(
      span,
      focusNode: widget.focusNode,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      textScaleFactor: widget.textScaleFactor,
      showCursor: widget.showCursor,
      autofocus: widget.autofocus,
      // ignore: deprecated_member_use
      toolbarOptions: widget.toolbarOptions,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      cursorWidth: widget.cursorWidth,
      cursorHeight: widget.cursorHeight,
      cursorRadius: widget.cursorRadius,
      cursorColor: widget.cursorColor,
      selectionHeightStyle:
          widget.selectionHeightStyle ?? ui.BoxHeightStyle.tight,
      selectionWidthStyle: widget.selectionWidthStyle ?? ui.BoxWidthStyle.tight,
      dragStartBehavior: widget.dragStartBehavior ?? DragStartBehavior.start,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      selectionControls: widget.selectionControls,
      scrollPhysics: widget.scrollPhysics,
      semanticsLabel: widget.semanticsLabel,
      textHeightBehavior: widget.textHeightBehavior,
      textWidthBasis: widget.textWidthBasis,
      onSelectionChanged: widget.onSelectionChanged,
    );
  }
}
