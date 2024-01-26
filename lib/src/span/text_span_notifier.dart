// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart' show ChangeNotifier, ValueListenable;
import 'package:flutter/painting.dart' show TextSpan, TextStyle;

import 'package:text_parser/text_parser.dart' show TextElement;

import 'data.dart';
import 'gesture_handler.dart';
import 'spans_builder.dart';
import 'transient_elements_builder.dart';

/// ValueNotifier with the ability to forcefully reassign a new value
/// regardless of whether it is equal to the previous.
class _ValueNotifier extends ChangeNotifier
    implements ValueListenable<TextSpan> {
  _ValueNotifier(this._value);

  TextSpan _value;
  bool _disposed = false;

  @override
  TextSpan get value => _value;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void updateValue(TextSpan newValue, {bool force = false}) {
    if (!_disposed && (_value != newValue || force)) {
      _value = newValue;
      notifyListeners();
    }
  }
}

class CustomTextSpanNotifier extends _ValueNotifier {
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

  List<TextElement> get elements => _spansBuilder.elements;

  @override
  void dispose() {
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
    updateValue(
      force: true,
      TextSpan(
        children: _spansBuilder.buildSpans(
          style: style,
          currentSpans: value.children ?? [],
          updatedDefinitionIndexes: updatedDefinitionIndexes,
        ),
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

    updateValue(
      TextSpan(
        children: List.of(value.children!)
          ..replaceRange(replaceRange.start, replaceRange.end + 1, spans),
      ),
    );
  }

  void _onSpanUpdateNeeded(int index, TextElement element, TextSpan span) {
    // Span must not be updated in the following cases:
    //
    // * When the number of spans has been reduced while one of them
    //   is still hovered on, in which case an update will lead to
    //   a range error.
    // * When the text at the index has changed, which indicates that
    //   this method has been triggered by the hover handler of the
    //   old span and it will cause the new span to get wrong text.
    if (index < value.children!.length &&
        elements[index].text == element.text) {
      updateValue(
        TextSpan(
          children: List.of(value.children!)..[index] = span,
        ),
      );
    }
  }
}
