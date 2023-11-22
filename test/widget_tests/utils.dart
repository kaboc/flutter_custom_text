import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';
import 'package:custom_text/src/text_span/data.dart';

final kTestLongPressDuration =
    kLongPressDuration + const Duration(milliseconds: 10);

GestureKind? gestureKind;
PointerDeviceKind? pointerDeviceKind;
TextElement? element;
String? shownText;
String? actionText;
Offset? globalPosition;
Offset? localPosition;

void reset() {
  gestureKind = null;
  pointerDeviceKind = null;
  element = null;
  shownText = null;
  actionText = null;
  globalPosition = null;
  localPosition = null;
}

void onTap(GestureDetails details) {
  gestureKind = details.gestureKind;
  pointerDeviceKind = details.pointerDeviceKind;
  element = details.element;
  shownText = details.shownText;
  actionText = details.actionText;
  globalPosition = details.globalPosition;
  localPosition = details.localPosition;
}

void onLongPress(GestureDetails details) {
  gestureKind = details.gestureKind;
  pointerDeviceKind = details.pointerDeviceKind;
  element = details.element;
  shownText = details.shownText;
  actionText = details.actionText;
  globalPosition = details.globalPosition;
  localPosition = details.localPosition;
}

void onGesture(GestureDetails details) {
  gestureKind = details.gestureKind;
  pointerDeviceKind = details.pointerDeviceKind;
  element = details.element;
  shownText = details.shownText;
  actionText = details.actionText;
  globalPosition = details.globalPosition;
  localPosition = details.localPosition;
}

Text findText() {
  final finder = find.byType(Text);
  return finder.evaluate().first.widget as Text;
}

List<InlineSpan> findInlineSpans({bool onlyDirectChildren = false}) {
  if (onlyDirectChildren) {
    return (findText().textSpan as TextSpan?)?.children ?? [];
  }

  final spans = <InlineSpan>[];
  findText().textSpan?.visitChildren((span) {
    spans.add(span);
    return true;
  });
  return spans;
}

TextSpan? findTextSpan(String text) {
  TextSpan? span;
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

extension SpanRecognizer on TextSpan? {
  void tapDown() {
    final recognizer = this?.recognizer as TapGestureRecognizer?;
    recognizer!.onTapDown!(TapDownDetails());
  }

  void maybeTapDown() {
    final recognizer = this?.recognizer as TapGestureRecognizer?;
    recognizer?.onTapDown?.call(TapDownDetails());
  }

  void tapUp() {
    final recognizer = this?.recognizer as TapGestureRecognizer?;
    recognizer!.onTapUp!(TapUpDetails(kind: PointerDeviceKind.touch));
  }

  void maybeTapUp() {
    final recognizer = this?.recognizer as TapGestureRecognizer?;
    recognizer?.onTapUp?.call(TapUpDetails(kind: PointerDeviceKind.touch));
  }
}

extension WidgetTesterExtension on WidgetTester {
  Future<void> tapButton() async {
    final finder = find.byType(ElevatedButton);
    await tap(finder);
  }

  Iterable<T> findWidgetsByType<T>() {
    return widgetList(find.byType(T)).map((v) => v as T);
  }

  Iterable<T> findDescendantWidgetsByType<T>({required Type of}) {
    final finder = find.descendant(
      of: find.byType(of),
      matching: find.byType(T),
    );
    return widgetList(finder).map((v) => v as T);
  }
}
