import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

GestureType? gestureType;
Type? matcherType;
String? labelText;
String? tappedText;
Offset? globalPosition;
Offset? localPosition;

void reset() {
  gestureType = null;
  matcherType = null;
  labelText = null;
  tappedText = null;
  globalPosition = null;
  localPosition = null;
}

void onTap(GestureDetails details) {
  gestureType = details.gestureType;
  matcherType = details.matcherType;
  labelText = details.label;
  tappedText = details.text;
  globalPosition = details.globalPosition;
  localPosition = details.localPosition;
}

void onLongPress(GestureDetails details) {
  gestureType = details.gestureType;
  matcherType = details.matcherType;
  labelText = details.label;
  tappedText = details.text;
  globalPosition = details.globalPosition;
  localPosition = details.localPosition;
}

Text findText() {
  final finder = find.byType(Text);
  return finder.evaluate().first.widget as Text;
}

RichText findRichText() {
  final finder = find.byType(RichText);
  return finder.evaluate().first.widget as RichText;
}

List<InlineSpan> getSpans() {
  final spans = <InlineSpan>[];
  findText().textSpan?.visitChildren((span) {
    spans.add(span);
    return true;
  });
  return spans;
}

InlineSpan? findSpan(String text) {
  InlineSpan? span;
  findText().textSpan?.visitChildren(
    (visitor) {
      if (visitor is TextSpan && visitor.text == text) {
        span = visitor;
        return false;
      }
      return true;
    },
  );
  return span;
}

void tapDownSpan(InlineSpan? span) {
  if (span is TextSpan) {
    final onTapDown = (span.recognizer as TapGestureRecognizer?)?.onTapDown;
    onTapDown?.call(TapDownDetails());
  }
}

void tapUpSpan(InlineSpan? span) {
  if (span is TextSpan) {
    final onTapUp = (span.recognizer as TapGestureRecognizer?)?.onTapUp;
    onTapUp?.call(TapUpDetails(kind: PointerDeviceKind.touch));
  }
}

Future<void> tapButton(WidgetTester tester) async {
  final finder = find.byType(ElevatedButton);
  await tester.tap(finder);
}
