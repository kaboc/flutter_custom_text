import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'utils.dart';
import 'widgets.dart';

void main() {
  setUp(reset);

  group('Styles', () {
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

  group('onTap and onLongPress', () {
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
        await tester.pump(kTestLongPressDuration);
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
        await tester.pump(kTestLongPressDuration);
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
        await tester.pump(kTestLongPressDuration);
        tapUpSpan(span);
        await tester.pump();

        expect(tappedText, 'long2');
      },
    );
  });

  group('onGesture', () {
    testWidgets(
      'Correct info is passed to onGesture specified in definition',
      (tester) async {
        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: const CustomTextWidget(
              'aaa bbb@example.com',
              onGesture: onGesture,
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);

        await tester.tapAt(center, buttons: kSecondaryButton);
        expect(gestureType, equals(GestureType.secondaryTap));
        expect(matcherType, equals(EmailMatcher));
        expect(labelText, equals('bbb@example.com'));
        expect(tappedText, equals('bbb@example.com'));
        expect(globalPosition, equals(center));
        expect(localPosition, equals(center - const Offset(10.0, 10.0)));

        tappedText = globalPosition = localPosition = null;
        await tester.tapAt(center, buttons: kTertiaryButton);
        expect(gestureType, equals(GestureType.tertiaryTap));
        expect(tappedText, equals('bbb@example.com'));
        expect(globalPosition, equals(center));
        expect(localPosition, equals(center - const Offset(10.0, 10.0)));

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        tappedText = globalPosition = localPosition = null;
        await gesture.addPointer(location: Offset(center.dx, 9.0));
        await gesture.moveTo(center);
        await tester.pumpAndSettle();
        expect(gestureType, equals(GestureType.enter));
        expect(tappedText, equals('bbb@example.com'));
        expect(globalPosition, equals(center));
        expect(localPosition, equals(center - const Offset(10.0, 10.0)));

        tappedText = globalPosition = localPosition = null;
        await gesture.moveTo(Offset(center.dx, 9.0));
        await tester.pumpAndSettle();
        expect(gestureType, equals(GestureType.exit));
        expect(tappedText, equals('bbb@example.com'));
        expect(globalPosition, equals(Offset(center.dx, 9.0)));
        expect(localPosition, equals(Offset(center.dx - 10.0, -1.0)));
      },
    );

    testWidgets(
      'onGesture specified in definition takes precedence',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            onGesture: (details) => onGesture(
              GestureDetails(
                gestureType: details.gestureType,
                matcherType: details.matcherType,
                text: 'gesture1',
                label: 'gesture1',
              ),
            ),
            onGestureInDef: (details) => onGesture(
              GestureDetails(
                gestureType: details.gestureType,
                matcherType: details.matcherType,
                text: 'gesture2',
                label: 'gesture2',
              ),
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);

        await tester.tapAt(center, buttons: kSecondaryButton);
        expect(gestureType, equals(GestureType.secondaryTap));
        expect(tappedText, equals('gesture2'));

        tappedText = null;
        await tester.tapAt(center, buttons: kTertiaryButton);
        expect(gestureType, equals(GestureType.tertiaryTap));
        expect(tappedText, equals('gesture2'));

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        tappedText = null;
        await gesture.addPointer(location: Offset(center.dx, 0.0));
        await gesture.moveTo(center);
        await tester.pumpAndSettle();
        expect(gestureType, equals(GestureType.enter));
        expect(tappedText, equals('gesture2'));

        tappedText = null;
        await gesture.moveTo(Offset(center.dx, -1.0));
        await tester.pumpAndSettle();
        expect(gestureType, equals(GestureType.exit));
        expect(tappedText, equals('gesture2'));
      },
    );
  });

  group('Mouse hover', () {
    testWidgets(
      'hoverStyle specified in definition takes precedence',
      (tester) async {
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

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        await gesture.addPointer(location: Offset.zero);
        final center = tester.getCenter(find.byType(RichText).first);

        await gesture.moveTo(Offset(center.dx / 2, center.dy));
        await tester.pumpAndSettle();

        final span1A = findSpan('aaa ');
        final span2A = findSpan('bbb@example.com');
        final span3A = findSpan('https://example.com/');
        expect(span1A?.style?.color, const Color(0xFF111111));
        expect(span2A?.style?.color, const Color(0xFF444444));
        expect(span3A?.style?.color, const Color(0xFF222222));

        await gesture.moveTo(Offset(center.dx / 2 * 3, center.dy));
        await tester.pumpAndSettle();

        final span1B = findSpan('aaa ');
        final span2B = findSpan('bbb@example.com');
        final span3B = findSpan('https://example.com/');
        expect(span1B?.style?.color, const Color(0xFF111111));
        expect(span2B?.style?.color, const Color(0xFF222222));
        expect(span3B?.style?.color, const Color(0xFF333333));
      },
    );

    testWidgets(
      'matchStyle in definition is used if hoverStyle is not specified.',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: TextStyle(color: Color(0xFF111111)),
            matchStyleInDef: TextStyle(color: Color(0xFF222222)),
          ),
        );
        await tester.pump();

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        await gesture.addPointer(location: Offset.zero);
        await gesture.moveTo(tester.getCenter(find.byType(RichText).first));
        await tester.pumpAndSettle();

        final spanA = findSpan('bbb@example.com');
        expect(spanA?.style?.color, const Color(0xFF222222));
      },
    );

    testWidgets(
      'hoverStyle in definition is used while being pressed '
      'if tapStyle is not specified',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            style: const TextStyle(color: Color(0xFF111111)),
            hoverStyleInDef: const TextStyle(color: Color(0xFF222222)),
            onTap: (_) {},
          ),
        );
        await tester.pump();

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        await gesture.addPointer(location: Offset.zero);
        await gesture.moveTo(tester.getCenter(find.byType(RichText).first));
        await tester.pumpAndSettle();

        final spanA = findSpan('bbb@example.com');
        expect(spanA?.style?.color, const Color(0xFF222222));

        tapDownSpan(spanA);
        await tester.pumpAndSettle();

        final spanB = findSpan('bbb@example.com');
        expect(spanB?.style?.color, const Color(0xFF222222));
      },
    );
  });
}
