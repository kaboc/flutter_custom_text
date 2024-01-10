// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter/painting.dart' show TextSpan, TextStyle;

import 'package:text_parser/text_parser.dart' show TextElement;

import 'data.dart';
import 'gesture_handler.dart';
import 'spans_builder.dart';
import 'transient_elements_builder.dart';

class CustomTextSpanNotifier extends ValueNotifier<TextSpan> {
  CustomTextSpanNotifier({
    required String? initialText,
    required TextStyle? initialStyle,
    required SpansBuilderSettings settings,
  }) : super(
          initialText == null || initialText.isEmpty
              ? const TextSpan()
              : TextSpan(text: initialText, style: initialStyle),
        ) {
    _spansBuilder = SpansBuilder(
      settings: settings,
      gestureHandlers: GestureHandlers(),
      onSpanUpdateNeeded: _onSpanUpdateNeeded,
    );
  }

  late final SpansBuilder _spansBuilder;
  bool _disposed = false;

  List<TextElement> get elements => _spansBuilder.elements;

  @override
  set value(TextSpan span) {
    if (!_disposed) {
      super.value = span;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _spansBuilder.gestureHandlers?.dispose();
    super.dispose();
  }

  // ignore: use_setters_to_change_properties
  void updateSettings(SpansBuilderSettings settings) {
    _spansBuilder.settings = settings;
  }

  // ignore: use_setters_to_change_properties
  void updateElements(List<TextElement> elements) {
    _spansBuilder.elements = elements;
  }

  void buildSpan({
    required TextStyle? style,
    required List<int> updatedDefinitionIndexes,
  }) {
    value = TextSpan(
      children: _spansBuilder.buildSpans(
        style: style,
        currentSpans: value.children ?? [],
        updatedDefinitionIndexes: updatedDefinitionIndexes,
      ),
    );
  }

  void buildTransientSpan({
    required TextStyle? style,
    required Range replaceRange,
    required Range spanRange,
  }) {
    final spans = _spansBuilder.buildTransientSpans(
      style: style,
      spanRange: spanRange,
    );

    value = TextSpan(
      children: List.of(value.children!)
        ..replaceRange(replaceRange.start, replaceRange.end + 1, spans),
    );
  }

  void _onSpanUpdateNeeded(int index, TextElement element, TextSpan span) {
    // Span must not be updated in the following cases:
    //
    // * When the notifier is no longer available. (issue #6)
    // * When the number of spans has been reduced while one of them
    //   is still hovered on, in which case an update will lead to
    //   a range error.
    // * When the text at the index has changed, which indicates that
    //   this method has been triggered by the hover handler of the
    //   old span and it will cause the new span to get wrong text.
    if (!_disposed &&
        index < value.children!.length &&
        elements[index].text == element.text) {
      value = TextSpan(
        children: List.of(value.children!)..[index] = span,
      );
    }
  }
}
