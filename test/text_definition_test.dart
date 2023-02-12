import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'utils.dart';
import 'widgets.dart';

void main() {
  setUp(reset);

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
      'matchStyle specified in definition takes precedence',
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
      'if tap callbacks are not specified',
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
      'tapStyle specified in definition takes precedence',
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
      'if onTap is specified in definition',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com https://example.com/',
            style: TextStyle(color: Color(0xFF111111)),
            matchStyle: TextStyle(color: Color(0xFF222222)),
            tapStyle: TextStyle(color: Color(0xFF333333)),
            onTapInDef: onTap,
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
      'if onLongPress is specified in definition',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com https://example.com/',
            style: TextStyle(color: Color(0xFF111111)),
            matchStyle: TextStyle(color: Color(0xFF222222)),
            tapStyle: TextStyle(color: Color(0xFF333333)),
            onLongPressInDef: onLongPress,
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
      'if onTap is specified in CustomText',
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
      'if onLongPress is specified in CustomText',
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
      'if onTap is specified in definition',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: TextStyle(color: Color(0xFF111111)),
            tapStyleInDef: TextStyle(color: Color(0xFF222222)),
            onTapInDef: onTap,
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
      'if onLongPress is specified in definition',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: TextStyle(color: Color(0xFF111111)),
            tapStyleInDef: TextStyle(color: Color(0xFF222222)),
            onLongPressInDef: onLongPress,
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
      'Correct info is passed to onTap specified in definition',
      (tester) async {
        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: const CustomTextWidget(
              'aaa bbb@example.com',
              onTapInDef: onTap,
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);
        await tester.tapAt(center);

        expect(gestureType, equals(GestureType.tap));
        expect(matcherType, equals(EmailMatcher));
        expect(labelText, equals('bbb@example.com'));
        expect(tappedText, equals('bbb@example.com'));
        expect(globalPosition, equals(center));
        expect(localPosition, equals(center - const Offset(10.0, 10.0)));
      },
    );

    testWidgets(
      'Correct info is passed to onLongPress specified in definition',
      (tester) async {
        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: const CustomTextWidget(
              'aaa bbb@example.com',
              onLongPressInDef: onLongPress,
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);
        final gesture = await tester.startGesture(center);
        await tester.pump(const Duration(milliseconds: 610));
        await gesture.up();

        expect(gestureType, equals(GestureType.longPress));
        expect(matcherType, equals(EmailMatcher));
        expect(labelText, equals('bbb@example.com'));
        expect(tappedText, equals('bbb@example.com'));
        expect(globalPosition, equals(center));
        expect(localPosition, equals(center - const Offset(10.0, 10.0)));
      },
    );

    testWidgets(
      'Only onTap specified in definition is called on short tap',
      (tester) async {
        var tap = false;
        var long = false;

        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            onTapInDef: (_) => tap = true,
            onLongPressInDef: (_) => long = true,
          ),
        );
        await tester.pump();

        const email = 'bbb@example.com';
        final span = findSpan(email);

        tapDownSpan(span);
        await tester.pump();
        tapUpSpan(span);
        await tester.pump();

        expect(tap, isTrue);
        expect(long, isFalse);
      },
    );

    testWidgets(
      'Only onLongPress specified in definition is called on long-press',
      (tester) async {
        var tap = false;
        var long = false;

        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            onTapInDef: (_) => tap = true,
            onLongPressInDef: (_) => long = true,
          ),
        );
        await tester.pump();

        const email = 'bbb@example.com';
        final span = findSpan(email);

        tapDownSpan(span);
        await tester.pump(const Duration(milliseconds: 610));
        tapUpSpan(span);
        await tester.pump();

        expect(tap, isFalse);
        expect(long, isTrue);
      },
    );

    testWidgets(
      'onTap specified in definition takes precedence',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            onTap: (details) => onTap(
              GestureDetails(
                gestureType: details.gestureType,
                matcherType: details.matcherType,
                text: 'tap1',
                label: 'tap1',
              ),
            ),
            onTapInDef: (details) => onTap(
              GestureDetails(
                gestureType: details.gestureType,
                matcherType: details.matcherType,
                text: 'tap2',
                label: 'tap2',
              ),
            ),
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
      },
    );

    testWidgets(
      'onLongPress specified in definition takes precedence',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            onLongPress: (details) => onLongPress(
              GestureDetails(
                gestureType: details.gestureType,
                matcherType: details.matcherType,
                text: 'long1',
                label: 'long1',
              ),
            ),
            onLongPressInDef: (details) => onLongPress(
              GestureDetails(
                gestureType: details.gestureType,
                matcherType: details.matcherType,
                text: 'long2',
                label: 'long2',
              ),
            ),
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

        expect(tappedText, 'long2');
      },
    );

    testWidgets(
      'default mouse cursor is used for element with/without tap callback',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            onTap: (_) {},
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
    testWidgets('specified mouse cursor is used', (tester) async {
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
    });

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
            onTap: (_) {},
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
      'tapStyle is used while being tapped even if hoverStyle is specified',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            style: const TextStyle(color: Color(0xFF111111)),
            tapStyle: const TextStyle(color: Color(0xFF222222)),
            hoverStyle: const TextStyle(color: Color(0xFF333333)),
            onTap: (_) {},
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
      'hoverStyle is used while being tapped if tapStyle is not specified',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            style: const TextStyle(color: Color(0xFF111111)),
            hoverStyle: const TextStyle(color: Color(0xFF222222)),
            onTap: (_) {},
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
