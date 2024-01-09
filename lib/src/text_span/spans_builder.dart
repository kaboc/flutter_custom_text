// ignore_for_file: public_member_api_docs

import 'package:flutter/painting.dart'
    show InlineSpan, Offset, TextSpan, TextStyle;

import 'package:text_parser/text_parser.dart' show TextElement;

import '../definitions.dart';
import 'data.dart';
import 'gesture_handler.dart';
import 'span_utils.dart';
import 'split_spans.dart';
import 'transient_elements_builder.dart';

class SpansBuilder {
  SpansBuilder({
    required this.settings,
    this.gestureHandlers,
    this.onSpanUpdateNeeded,
  });

  SpansBuilderSettings settings;
  final GestureHandlers? gestureHandlers;
  final void Function(int, TextElement, TextSpan)? onSpanUpdateNeeded;

  List<TextElement> elements = [];
  bool _isBuilding = false;
  TextStyle? _style;
  bool _tapped = false;
  bool _hovered = false;
  int? _tapIndex;
  int? _hoverIndex;
  Offset? _hoverPosition;

  List<InlineSpan>? buildSpans({
    required TextStyle? style,
    required List<InlineSpan> currentSpans,
    // If this is not empty when rebuilding existing spans,
    // only the spans relevant to the definitions at the
    // specified indexes in the `definitions` list are rebuilt.
    required List<int> updatedDefinitionIndexes,
  }) {
    _isBuilding = true;
    _style = style;

    // A map containing a list of InlineSpans as a result of splitting
    // the spans specified in the `CustomText.spans` constructor.
    final splitSpans = settings.spans?.splitSpans(elements: elements);

    final newSpans = elements.isEmpty
        ? null
        : [
            if (splitSpans == null)
              for (var i = 0; i < elements.length; i++)
                _span(
                  elementIndex: i,
                  element: elements[i],
                  children: null,
                  currentSpans: currentSpans,
                  updatedDefinitionIndexes: updatedDefinitionIndexes,
                )
            else
              for (final i in splitSpans.keys)
                _span(
                  elementIndex: i,
                  element: elements[i],
                  children: splitSpans[i],
                  currentSpans: currentSpans,
                  updatedDefinitionIndexes: updatedDefinitionIndexes,
                ),
          ];

    if (gestureHandlers != null) {
      // If the number of new elements has become smaller than before,
      // the elements after the current max index are no longer necessary.
      for (var i = elements.length; i < currentSpans.length; i++) {
        gestureHandlers?.removeHandler(index: i);
      }
    }

    _isBuilding = false;

    return newSpans;
  }

  List<InlineSpan> buildTransientSpans({
    required TextStyle? style,
    required Range spanRange,
  }) {
    _isBuilding = true;
    _style = style;

    final newSpans = [
      for (var i = spanRange.start; i < spanRange.end; i++)
        _span(
          elementIndex: i,
          element: elements[i],
          children: null,
          currentSpans: [],
          updatedDefinitionIndexes: [],
        ),
    ];

    _isBuilding = false;

    return newSpans;
  }

  InlineSpan _span({
    required int elementIndex,
    required TextElement element,
    required List<InlineSpan>? children,
    required List<InlineSpan> currentSpans,
    required List<int> updatedDefinitionIndexes,
  }) {
    if (elementIndex < currentSpans.length &&
        updatedDefinitionIndexes.isNotEmpty &&
        !updatedDefinitionIndexes.contains(element.matcherIndex)) {
      // Returns the existing span quickly for good performance
      // if the ongoing build is due to changes in definitions only
      // and the target index is irrelevant to the changes.
      return currentSpans[elementIndex];
    }

    final defs = settings.definitions[element.matcherType];
    if (defs == null || defs.isEmpty) {
      return children == null
          ? TextSpan(text: element.text, style: _style)
          : applyPropsToChildren(
              TextSpan(children: children, style: _style),
            );
    }

    final def = defs[element.matcherIndex] ?? defs[defs.keys.first]!;

    final isTappable = settings.onTap != null ||
        settings.onLongPress != null ||
        settings.onGesture != null ||
        def.onTap != null ||
        def.onLongPress != null ||
        def.onGesture != null;

    final hasTapStyle = settings.tapStyle != null || def.tapStyle != null;
    final hasHoverStyle = settings.hoverStyle != null || def.hoverStyle != null;

    final spanData = SpanData(
      index: elementIndex,
      element: element,
      children: children,
      definition: def,
      shownText: def.shownText?.call(element.groups),
      actionText: def.actionText?.call(element.groups),
      onTapDown: hasTapStyle || hasHoverStyle
          ? (spanData) => _updateTapIndex(
                spanData: spanData,
                tapped: true,
              )
          : null,
      onTapCancel: hasTapStyle || hasHoverStyle
          ? (spanData) => _updateTapIndex(
                spanData: spanData,
                tapped: false,
              )
          : null,
      onMouseEnter: hasHoverStyle
          ? (event, spanData) => _updateHoverIndex(
                spanData: spanData,
                hovered: true,
                globalPosition: event.position,
              )
          : null,
      onMouseExit: hasHoverStyle
          ? (event, spanData) => _updateHoverIndex(
                spanData: spanData,
                hovered: false,
                globalPosition: event.position,
              )
          : null,
    );

    return isTappable && gestureHandlers != null
        ? _tappableTextSpan(spanData: spanData)
        : _nonTappableTextSpan(spanData: spanData);
  }

  TextSpan _nonTappableTextSpan({required SpanData spanData}) {
    final def = spanData.definition;
    var matchStyle = def.matchStyle ?? settings.matchStyle;
    var hoverStyle = def.hoverStyle ?? settings.hoverStyle;

    var style = _style;
    if (style != null) {
      matchStyle = style.merge(matchStyle);
      hoverStyle = hoverStyle == null ? null : style.merge(hoverStyle);
    }

    final gestureHandler = gestureHandlers?.prepareHandler(
      settings: settings,
      spanData: spanData,
    );

    // hoverStyle must be removed when text spans are built.
    // Otherwise, if a span with hoverStyle is being hovered on during
    // a build and then gets a different index in new spans, the style
    // is mistakenly applied to the new span at the original index.
    style = _hovered && _hoverIndex == spanData.index && !_isBuilding
        ? hoverStyle
        : matchStyle;

    final newSpan = def is SpanDefinition
        ? TextSpan(
            style: style,
            mouseCursor: spanData.definition.mouseCursor,
            onEnter: gestureHandler?.onEnter,
            onExit: gestureHandler?.onExit,
            children: [
              def.builder(spanData.element.text, spanData.element.groups),
            ],
          )
        : TextSpan(
            text: spanData.shownText ??
                (spanData.children == null ? spanData.element.text : null),
            style: style,
            mouseCursor: spanData.definition.mouseCursor,
            onEnter: gestureHandler?.onEnter,
            onExit: gestureHandler?.onExit,
            children: spanData.shownText == null ? spanData.children : null,
          );

    return newSpan.children == null ? newSpan : applyPropsToChildren(newSpan);
  }

  TextSpan _tappableTextSpan({required SpanData spanData}) {
    final def = spanData.definition;
    var matchStyle = def.matchStyle ?? settings.matchStyle;
    var hoverStyle = def.hoverStyle ?? settings.hoverStyle;
    var tapStyle = def.tapStyle ?? settings.tapStyle;
    tapStyle ??= hoverStyle ?? matchStyle;

    var style = _style;
    if (style != null) {
      matchStyle = style.merge(matchStyle);
      hoverStyle = hoverStyle == null ? null : style.merge(hoverStyle);
      tapStyle = style.merge(tapStyle);
    }

    final gestureHandler = gestureHandlers?.prepareHandler(
      settings: settings,
      spanData: spanData,
    );

    // tapStyle and hoverStyle must be cancelled when text spans are built.
    // Otherwise, if a span with such a style is being pressed or hovered
    // on during a build and then gets a different index in new spans,
    // the style is mistakenly applied to a new span at the original index.
    style = _isBuilding
        ? matchStyle
        : _tapped && _tapIndex == spanData.index
            ? tapStyle
            : _hovered && _hoverIndex == spanData.index
                ? hoverStyle
                : matchStyle;

    final newSpan = def is SpanDefinition
        ? TextSpan(
            style: style,
            recognizer: gestureHandler?.recognizer,
            mouseCursor: spanData.definition.mouseCursor,
            onEnter: gestureHandler?.onEnter,
            onExit: gestureHandler?.onExit,
            children: [
              def.builder(spanData.element.text, spanData.element.groups),
            ],
          )
        : TextSpan(
            text: spanData.shownText ??
                (spanData.children == null ? spanData.element.text : null),
            style: style,
            recognizer: gestureHandler?.recognizer,
            mouseCursor: spanData.definition.mouseCursor,
            onEnter: gestureHandler?.onEnter,
            onExit: gestureHandler?.onExit,
            children: spanData.shownText == null ? spanData.children : null,
          );

    return newSpan.children == null ? newSpan : applyPropsToChildren(newSpan);
  }

  void _updateTapIndex({required SpanData spanData, required bool tapped}) {
    if (tapped == _tapped && spanData.index == _tapIndex) {
      return;
    }

    _tapped = tapped;
    _tapIndex = tapped ? spanData.index : null;

    onSpanUpdateNeeded?.call(
      spanData.index,
      spanData.element,
      _tappableTextSpan(spanData: spanData),
    );
  }

  void _updateHoverIndex({
    required SpanData spanData,
    required bool hovered,
    required Offset globalPosition,
  }) {
    if (hovered == _hovered && spanData.index == _hoverIndex) {
      return;
    }

    _hovered = hovered;
    _hoverIndex = hovered ? spanData.index : null;

    // Updates only if the span is not being pressed.
    // The previous and current hovering positions are checked
    // to prevent repetitive rebuilds that can happen when
    // CustomTextEditingController is used.
    if (!_tapped && globalPosition != _hoverPosition) {
      _hoverPosition = hovered ? globalPosition : null;

      onSpanUpdateNeeded?.call(
        spanData.index,
        spanData.element,
        spanData.onTapDown == null
            ? _nonTappableTextSpan(spanData: spanData)
            : _tappableTextSpan(spanData: spanData),
      );
    }
  }
}
