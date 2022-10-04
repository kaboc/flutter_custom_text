import 'dart:async';
import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';

import 'package:text_parser/text_parser.dart';

import 'definition_base.dart';
import 'parser_options.dart';
import 'text_span_notifier.dart';

/// A widget that decorates parts of text and/or enables taps/long-presses
/// on them according to specified definitions.
///
/// This widget is useful for making strings in selectable/non-selectable
/// text such as URLs, email addresses or phone numbers clickable, or for
/// only highlighting some parts of text with colors and different font
/// settings depending on the types of string elements.
class CustomText extends StatefulWidget {
  /// Creates a text widget that decorates strings in it and/or enables
  /// clicks on them according to specified definitions.
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
  /// and/or enables clicks on them according to specified definitions.
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

  // For SelectableText
  final FocusNode? focusNode;
  final bool showCursor;
  final bool autofocus;
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

  @override
  void initState() {
    super.initState();

    _textSpanNotifier = _initSpanNotifier();
    _parse();
  }

  @override
  void didUpdateWidget(CustomText oldWidget) {
    super.didUpdateWidget(oldWidget);

    final isMatcherUpdated = _hasNewMatchers(oldWidget);
    final isDefinitionUpdated =
        isMatcherUpdated || _hasNewDefinitions(oldWidget);

    final shouldParse = isMatcherUpdated ||
        widget.text != oldWidget.text ||
        widget.parserOptions != oldWidget.parserOptions ||
        widget.preventBlocking != oldWidget.preventBlocking;

    final shouldUpdateSpan = isDefinitionUpdated ||
        widget.style != oldWidget.style ||
        widget.matchStyle != oldWidget.matchStyle ||
        widget.tapStyle != oldWidget.tapStyle ||
        widget.hoverStyle != oldWidget.hoverStyle ||
        widget.longPressDuration != oldWidget.longPressDuration;

    if (shouldParse) {
      _parse(shouldUpdateSpan: shouldUpdateSpan);
    } else if (shouldUpdateSpan) {
      _textSpanNotifier = _updateSpanNotifier();
    }
  }

  @override
  void dispose() {
    _textSpanNotifier.dispose();
    super.dispose();
  }

  CustomTextSpanNotifier _initSpanNotifier() {
    return CustomTextSpanNotifier(
      text: widget.text,
      definitions: widget.definitions,
      matchStyle: widget.matchStyle,
      tapStyle: widget.tapStyle,
      hoverStyle: widget.hoverStyle,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      longPressDuration: widget.longPressDuration,
    );
  }

  CustomTextSpanNotifier _updateSpanNotifier() {
    final oldNotifier = _textSpanNotifier;
    final notifier = _initSpanNotifier();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifier
        ..elements = oldNotifier.elements
        ..buildSpan(style: widget.style);
      oldNotifier.dispose();
    });

    return notifier;
  }

  Future<void> _parse({bool shouldUpdateSpan = false}) async {
    _textSpanNotifier.elements = await TextParser(
      matchers: widget.definitions.map((def) => def.matcher).toList(),
      multiLine: widget.parserOptions.multiLine,
      caseSensitive: widget.parserOptions.caseSensitive,
      unicode: widget.parserOptions.unicode,
      dotAll: widget.parserOptions.dotAll,
    ).parse(
      widget.text,
      useIsolate: widget.preventBlocking,
    );

    if (shouldUpdateSpan) {
      _textSpanNotifier = _updateSpanNotifier();
    } else {
      _textSpanNotifier.buildSpan(style: widget.style);
    }
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
