import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';
import 'widgets.dart';

void main() {
  setUp(() {
    isTap = isLongPress = false;
    matcherType = tappedText = null;
  });

  group('selection', () {
    testWidgets(
      'tapStyle is cancelled if pointer moves while text is pressed',
      (tester) async {
        TextSelection? selection;
        const email = 'bbb@example.com';
        const text = 'aaa $email https//example.com/';
        final emailStartIndex = text.indexOf(email);
        final emailEndIndex = emailStartIndex + email.length;

        await tester.pumpWidget(
          SelectableCustomTextWidget(
            text,
            withNavigator: true,
            hoverStyleInDef: const TextStyle(color: Color(0xFF111111)),
            tapStyleInDef: const TextStyle(color: Color(0xFF222222)),
            onTapInDef: (_) {},
            onSelectionChanged: (sel) => selection = sel,
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(EditableText).first);
        final gesture = await tester.startGesture(
          Offset(center.dx / 2, center.dy),
          kind: PointerDeviceKind.mouse,
        );
        addTearDown(gesture.removePointer);
        await tester.pumpAndSettle();

        final spanA = findSelectableSpan(email);
        expect(spanA?.style?.color, const Color(0xFF222222));

        await gesture.moveBy(const Offset(30.0, 0.0));
        await tester.pumpAndSettle();

        final spanB = findSelectableSpan(email);
        expect(selection?.extentOffset, greaterThan(emailStartIndex));
        expect(selection?.extentOffset, greaterThanOrEqualTo(emailStartIndex));
        expect(selection?.extentOffset, lessThan(emailEndIndex));
        expect(spanB?.style?.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'selection is not cancelled by rebuild when selection ranges '
      'from span with hoverStyle to span without hoverStyle',
      (tester) async {
        TextSelection? selection;
        const email = 'bbb@example.com';
        const text = 'aaa $email https//example.com/';
        final emailStartIndex = text.indexOf(email);
        final emailEndIndex = emailStartIndex + email.length;

        await tester.pumpWidget(
          SelectableCustomTextWidget(
            'aaa $email https://example.com/',
            withNavigator: true,
            matchStyle: const TextStyle(color: Color(0xFF111111)),
            hoverStyle: const TextStyle(color: Color(0xFF444444)),
            hoverStyleInDef: const TextStyle(color: Color(0xFF222222)),
            tapStyleInDef: const TextStyle(color: Color(0xFF333333)),
            onTapInDef: (_) {},
            onSelectionChanged: (sel) => selection = sel,
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(EditableText).first);
        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);

        await gesture.addPointer(location: Offset(center.dx / 2, center.dy));
        await tester.pump();

        final spanA = findSelectableSpan(email);
        expect(spanA?.style?.color, const Color(0xFF222222));

        await gesture.down(Offset(center.dx / 2, center.dy));
        await tester.pumpAndSettle();

        final spanB = findSelectableSpan(email);
        expect(spanB?.style?.color, const Color(0xFF333333));

        await gesture.moveBy(const Offset(250.0, 0.0));
        await gesture.up();
        await gesture.removePointer();
        await tester.pumpAndSettle();

        final spanC = findSelectableSpan(email);
        expect(spanC?.style?.color, const Color(0xFF111111));
        expect(selection?.baseOffset, greaterThanOrEqualTo(emailStartIndex));
        expect(selection?.baseOffset, lessThan(emailEndIndex));
        expect(selection?.extentOffset, greaterThan(emailEndIndex));
        expect(selection?.extentOffset, lessThan(text.length));
      },
    );
  });
}
