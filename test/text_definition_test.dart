import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';
import 'widgets.dart';

void main() {
  setUp(() {
    isTap = isLongPress = false;
    matcherType = tappedText = null;
  });

  group('Styles for TextDefinition', () {
    testWidgets(
      'matchStyle specified in definition is used even if without onTap',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: TextStyle(color: Color(0xFF111111)),
            matchStyleInDef: TextStyle(color: Color(0xFF222222)),
          ),
        );
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2 = findSpan('bbb@example.com');
        expect(span1?.style?.color, const Color(0xFF111111));
        expect(span2?.style?.color, const Color(0xFF222222));
      },
    );

    testWidgets(
      'matchStyle specified in definition is only applied to relevant element',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com https://example.com/',
            style: TextStyle(color: Color(0xFF111111)),
            matchStyleInDef: TextStyle(color: Color(0xFF222222)),
          ),
        );
        await tester.pump();

        final span1 = findSpan('bbb@example.com');
        final span2 = findSpan('https://example.com/');
        expect(span1?.style?.color, const Color(0xFF222222));
        expect(span2?.style?.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'matchStyle specified in definition takes priority',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            matchStyle: TextStyle(color: Color(0xFF111111)),
            matchStyleInDef: TextStyle(color: Color(0xFF222222)),
          ),
        );
        await tester.pump();

        final span = findSpan('bbb@example.com');
        expect(span?.style?.color, const Color(0xFF222222));
      },
    );

    testWidgets(
      'tapStyle specified in definition is not applied '
      'if tap callbacks are not set',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: TextStyle(color: Color(0xFF111111)),
            tapStyleInDef: TextStyle(color: Color(0xFF222222)),
          ),
        );
        await tester.pump();

        final spanA = findSpan('bbb@example.com');
        tapDownSpan(spanA);
        await tester.pump();

        final spanB = findSpan('bbb@example.com');
        expect(spanB?.style?.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'tapStyle specified in definition is only applied to relevant element',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com https://example.com/',
            style: TextStyle(color: Color(0xFF111111)),
            tapStyleInDef: TextStyle(color: Color(0xFF222222)),
            onTap: onTap,
          ),
        );
        await tester.pump();

        final span2A = findSpan('bbb@example.com');
        tapDownSpan(span2A);
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2B = findSpan('bbb@example.com');
        final span3 = findSpan('https://example.com/');
        expect(span1?.style?.color, const Color(0xFF111111));
        expect(span2B?.style?.color, const Color(0xFF222222));
        expect(span3?.style?.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'tapStyle specified in definition takes priority',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            tapStyle: TextStyle(color: Color(0xFF111111)),
            tapStyleInDef: TextStyle(color: Color(0xFF222222)),
            onTap: onTap,
          ),
        );
        await tester.pump();

        final spanA = findSpan('bbb@example.com');
        tapDownSpan(spanA);
        await tester.pump();

        final spanB = findSpan('bbb@example.com');
        expect(spanB?.style?.color, const Color(0xFF222222));
      },
    );

    testWidgets(
      'tapStyle specified in CustomText is applied '
      'if onTap is set in definition',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com https://example.com/',
            style: const TextStyle(color: Color(0xFF111111)),
            matchStyle: const TextStyle(color: Color(0xFF222222)),
            tapStyle: const TextStyle(color: Color(0xFF333333)),
            onTapInDef: (text) => onTap(null, text),
          ),
        );
        await tester.pump();

        final span2A = findSpan('bbb@example.com');
        tapDownSpan(span2A);
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2B = findSpan('bbb@example.com');
        final span3 = findSpan('https://example.com/');
        expect(span1?.style?.color, const Color(0xFF111111));
        expect(span2B?.style?.color, const Color(0xFF333333));
        expect(span3?.style?.color, const Color(0xFF222222));

        tapUpSpan(span2B);
        await tester.pump();

        final span2C = findSpan('bbb@example.com');
        expect(span2C?.style?.color, const Color(0xFF222222));
      },
    );

    testWidgets(
      'tapStyle specified in CustomText is applied '
      'if onLongPress is set in definition',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com https://example.com/',
            style: const TextStyle(color: Color(0xFF111111)),
            matchStyle: const TextStyle(color: Color(0xFF222222)),
            tapStyle: const TextStyle(color: Color(0xFF333333)),
            onLongPressInDef: (text) => onLongPress(null, text),
          ),
        );
        await tester.pump();

        final span2A = findSpan('bbb@example.com');
        tapDownSpan(span2A);
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2B = findSpan('bbb@example.com');
        final span3 = findSpan('https://example.com/');
        expect(span1?.style?.color, const Color(0xFF111111));
        expect(span2B?.style?.color, const Color(0xFF333333));
        expect(span3?.style?.color, const Color(0xFF222222));

        tapUpSpan(span2B);
        await tester.pump();

        final span2C = findSpan('bbb@example.com');
        expect(span2C?.style?.color, const Color(0xFF222222));
      },
    );

    testWidgets(
      'tapStyle specified in definition is applied '
      'if onTap is set in CustomText',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: TextStyle(color: Color(0xFF111111)),
            tapStyleInDef: TextStyle(color: Color(0xFF222222)),
            onTap: onTap,
          ),
        );
        await tester.pump();

        final span2A = findSpan('bbb@example.com');
        tapDownSpan(span2A);
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2B = findSpan('bbb@example.com');
        expect(span1?.style?.color, const Color(0xFF111111));
        expect(span2B?.style?.color, const Color(0xFF222222));

        tapUpSpan(span2B);
        await tester.pump();

        final span2C = findSpan('bbb@example.com');
        expect(span2C?.style?.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'tapStyle specified in definition is applied '
      'if onLongPress is set in CustomText',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: TextStyle(color: Color(0xFF111111)),
            tapStyleInDef: TextStyle(color: Color(0xFF222222)),
            onLongPress: onLongPress,
          ),
        );
        await tester.pump();

        final span2A = findSpan('bbb@example.com');
        tapDownSpan(span2A);
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2B = findSpan('bbb@example.com');
        expect(span1?.style?.color, const Color(0xFF111111));
        expect(span2B?.style?.color, const Color(0xFF222222));

        tapUpSpan(span2B);
        await tester.pump();

        final span2C = findSpan('bbb@example.com');
        expect(span2C?.style?.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'tapStyle specified in definition is applied '
      'if onTap is set in definition',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            style: const TextStyle(color: Color(0xFF111111)),
            tapStyleInDef: const TextStyle(color: Color(0xFF222222)),
            onTapInDef: (text) => onTap(null, text),
          ),
        );
        await tester.pump();

        final span2A = findSpan('bbb@example.com');
        tapDownSpan(span2A);
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2B = findSpan('bbb@example.com');
        expect(span1?.style?.color, const Color(0xFF111111));
        expect(span2B?.style?.color, const Color(0xFF222222));

        tapUpSpan(span2B);
        await tester.pump();

        final span2C = findSpan('bbb@example.com');
        expect(span2C?.style?.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'tapStyle specified in definition is applied '
      'if onLongPress is set in definition',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            style: const TextStyle(color: Color(0xFF111111)),
            tapStyleInDef: const TextStyle(color: Color(0xFF222222)),
            onLongPressInDef: (text) => onLongPress(null, text),
          ),
        );
        await tester.pump();

        final span2A = findSpan('bbb@example.com');
        tapDownSpan(span2A);
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2B = findSpan('bbb@example.com');
        expect(span1?.style?.color, const Color(0xFF111111));
        expect(span2B?.style?.color, const Color(0xFF222222));

        tapUpSpan(span2B);
        await tester.pump();

        final span2C = findSpan('bbb@example.com');
        expect(span2C?.style?.color, const Color(0xFF111111));
      },
    );
  });

  group('Tap callbacks of TextDefinition', () {
    testWidgets(
      'Correct string is passed to onTap specified in definition',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            onTapInDef: (text) => onTap(null, text),
          ),
        );
        await tester.pump();

        const email = 'bbb@example.com';
        final span = findSpan(email);

        tapDownSpan(span);
        await tester.pump();
        tapUpSpan(span);
        await tester.pump();

        expect(isTap, isTrue);
        expect(tappedText, equals(email));
      },
    );

    testWidgets(
      'Correct string is passed to onLongPress specified in definition',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            onLongPressInDef: (text) => onLongPress(null, text),
          ),
        );
        await tester.pump();

        const email = 'bbb@example.com';
        final span = findSpan(email);

        tapDownSpan(span);
        await tester.pump(const Duration(milliseconds: 610));
        tapUpSpan(span);
        await tester.pump();

        expect(isLongPress, isTrue);
        expect(tappedText, equals(email));
      },
    );

    testWidgets(
      'Only onTap specified in definition is called on short tap',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            onTapInDef: (text) => onTap(null, text),
            onLongPressInDef: (text) => onLongPress(null, text),
          ),
        );
        await tester.pump();

        const email = 'bbb@example.com';
        final span = findSpan(email);

        tapDownSpan(span);
        await tester.pump();
        tapUpSpan(span);
        await tester.pump();

        expect(isTap, isTrue);
        expect(isLongPress, isFalse);
      },
    );

    testWidgets(
      'Only onLongPress specified in definition is called on long-press',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            onTapInDef: (text) => onTap(null, text),
            onLongPressInDef: (text) => onLongPress(null, text),
          ),
        );
        await tester.pump();

        const email = 'bbb@example.com';
        final span = findSpan(email);

        tapDownSpan(span);
        await tester.pump(const Duration(milliseconds: 610));
        tapUpSpan(span);
        await tester.pump();

        expect(isTap, isFalse);
        expect(isLongPress, isTrue);
      },
    );

    testWidgets('onTap specified in definition takes priority', (tester) async {
      await tester.pumpWidget(
        CustomTextWidget(
          'aaa bbb@example.com',
          onTap: (_, __) => onTap(null, 'tap1'),
          onTapInDef: (_) => onTap(null, 'tap2'),
        ),
      );
      await tester.pump();

      const email = 'bbb@example.com';
      final span = findSpan(email);

      tapDownSpan(span);
      await tester.pump();
      tapUpSpan(span);
      await tester.pump();

      expect(tappedText, 'tap2');
    });

    testWidgets(
      'onLongPress specified in definition takes priority',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            onLongPress: (_, __) => onLongPress(null, 'longPress1'),
            onLongPressInDef: (_) => onLongPress(null, 'longPress2'),
          ),
        );
        await tester.pump();

        const email = 'bbb@example.com';
        final span = findSpan(email);

        tapDownSpan(span);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 610));
        tapUpSpan(span);
        await tester.pump();

        expect(tappedText, 'longPress2');
      },
    );

    testWidgets(
      'default mouse cursors for TextSpan with/without tap callbacks',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            onTap: (_, __) {},
          ),
        );
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2 = findSpan('bbb@example.com');
        expect((span1 as TextSpan?)?.mouseCursor, MouseCursor.defer);
        expect((span2 as TextSpan?)?.mouseCursor, SystemMouseCursors.click);
      },
    );
  });

  group('mouse hover', () {
    testWidgets(
      'mouse cursor for TextSpan with mouseCursor set',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            mouseCursor: SystemMouseCursors.grab,
          ),
        );
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2 = findSpan('bbb@example.com');
        expect((span1 as TextSpan?)?.mouseCursor, MouseCursor.defer);
        expect((span2 as TextSpan?)?.mouseCursor, SystemMouseCursors.grab);
      },
    );

    testWidgets('hoverStyle', (tester) async {
      await tester.pumpWidget(
        const CustomTextWidget(
          'aaa bbb@example.com https://example.com/',
          style: TextStyle(color: Color(0xFF111111)),
          matchStyle: TextStyle(color: Color(0xFF222222)),
          hoverStyle: TextStyle(color: Color(0xFF333333)),
          hoverStyleInDef: TextStyle(color: Color(0xFF444444)),
        ),
      );
      await tester.pump();

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);

      await gesture.addPointer(location: Offset.zero);
      final center = tester.getCenter(find.byType(RichText).first);

      await gesture.moveTo(Offset(center.dx / 2, center.dy));
      await tester.pump();

      final span1A = findSpan('aaa ');
      final span2A = findSpan('bbb@example.com');
      final span3A = findSpan('https://example.com/');
      expect(span1A?.style?.color, const Color(0xFF111111));
      expect(span2A?.style?.color, const Color(0xFF444444));
      expect(span3A?.style?.color, const Color(0xFF222222));

      await gesture.moveTo(Offset(center.dx / 2 * 3, center.dy));
      await tester.pump();

      final span1B = findSpan('aaa ');
      final span2B = findSpan('bbb@example.com');
      final span3B = findSpan('https://example.com/');
      expect(span1B?.style?.color, const Color(0xFF111111));
      expect(span2B?.style?.color, const Color(0xFF222222));
      expect(span3B?.style?.color, const Color(0xFF333333));
    });

    testWidgets(
      'Styling on hover is not enabled w/o hoverStyle and matchStyle is used.',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            style: const TextStyle(color: Color(0xFF111111)),
            onTap: (_, __) {},
          ),
        );
        await tester.pump();

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        await gesture.addPointer(location: Offset.zero);
        await gesture.moveTo(tester.getCenter(find.byType(RichText).first));
        await tester.pump();

        final spanA = findSpan('bbb@example.com');
        expect(spanA?.style?.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'tapStyle is used while being tapped even if hoverStyle is set',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            style: const TextStyle(color: Color(0xFF111111)),
            tapStyle: const TextStyle(color: Color(0xFF222222)),
            hoverStyle: const TextStyle(color: Color(0xFF333333)),
            onTap: (_, __) {},
          ),
        );
        await tester.pump();

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        await gesture.addPointer(location: Offset.zero);
        await gesture.moveTo(tester.getCenter(find.byType(RichText).first));
        await tester.pump();

        final spanA = findSpan('bbb@example.com');
        expect(spanA?.style?.color, const Color(0xFF333333));

        tapDownSpan(spanA);
        await tester.pump();

        final spanB = findSpan('bbb@example.com');
        expect(spanB?.style?.color, const Color(0xFF222222));
      },
    );

    testWidgets(
      'hoverStyle is used while being tapped if tapStyle is not set',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            style: const TextStyle(color: Color(0xFF111111)),
            hoverStyle: const TextStyle(color: Color(0xFF222222)),
            onTap: (_, __) {},
          ),
        );
        await tester.pump();

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        await gesture.addPointer(location: Offset.zero);
        await gesture.moveTo(tester.getCenter(find.byType(RichText).first));
        await tester.pump();

        final spanA = findSpan('bbb@example.com');
        expect(spanA?.style?.color, const Color(0xFF222222));

        tapDownSpan(spanA);
        await tester.pump();

        final spanB = findSpan('bbb@example.com');
        expect(spanB?.style?.color, const Color(0xFF222222));
      },
    );
  });
}
