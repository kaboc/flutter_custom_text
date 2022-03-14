import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

bool? isTap;
bool? isLongPress;
Type? matcherType;
String? tappedText;

void onTap(Type? type, String text) {
  isTap = true;
  matcherType = type;
  tappedText = text;
}

void onLongPress(Type? type, String text) {
  isLongPress = true;
  matcherType = type;
  tappedText = text;
}

Text findText() {
  final finder = find.byType(Text);
  return finder.evaluate().first.widget as Text;
}

SelectableText findSelectableText() {
  final finder = find.byType(SelectableText);
  return finder.evaluate().first.widget as SelectableText;
}

RichText findRichText() {
  final finder = find.byType(RichText);
  return finder.evaluate().first.widget as RichText;
}

EditableText findEditableText() {
  final finder = find.byType(EditableText);
  return finder.evaluate().first.widget as EditableText;
}

List<InlineSpan> getSpans() {
  final spans = <InlineSpan>[];
  findText().textSpan?.visitChildren((span) {
    spans.add(span);
    return true;
  });
  return spans;
}

List<InlineSpan> getSelectableSpans() {
  final spans = <InlineSpan>[];
  findSelectableText().textSpan?.visitChildren((span) {
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

InlineSpan? findSelectableSpan(String text) {
  InlineSpan? span;
  findSelectableText().textSpan?.visitChildren(
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
