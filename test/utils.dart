import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
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

RichText findRichText() {
  final finder = find.byType(RichText);
  return finder.evaluate().single.widget as RichText;
}

List<InlineSpan> getSpans() {
  final spans = <InlineSpan>[];
  findRichText().text.visitChildren((span) {
    spans.add(span);
    return true;
  });
  return spans;
}

InlineSpan? findSpan(String text) {
  InlineSpan? span;
  findRichText().text.visitChildren(
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
