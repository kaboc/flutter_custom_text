import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'widget_utils.dart';
import 'widgets.dart';

void main() {
  setUp(reset);

  group('Styles', () {
    testWidgets(
      'matchStyle specified in definition is used even if without onTap',
      (tester) async {
        const style = TextStyle(color: Color(0xFF111111));
        const matchStyle = TextStyle(color: Color(0xFF222222));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: style,
            matchStyleInDef: matchStyle,
          ),
        );
        await tester.pump();

        expect(findTextSpan('aaa ')?.style, style);
        expect(findTextSpan('bbb@example.com')?.style, matchStyle);
      },
    );

    testWidgets(
      'matchStyle specified in definition is only applied to relevant element',
      (tester) async {
        const style = TextStyle(color: Color(0xFF111111));
        const matchStyle = TextStyle(color: Color(0xFF222222));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com https://example.com/',
            style: style,
            matchStyleInDef: matchStyle,
          ),
        );
        await tester.pump();

        expect(findTextSpan('bbb@example.com')?.style, matchStyle);
        expect(findTextSpan('https://example.com/')?.style, style);
      },
    );

    testWidgets(
      'matchStyle specified in definition takes precedence',
      (tester) async {
        const matchStyle = TextStyle(color: Color(0xFF111111));
        const matchStyleInDef = TextStyle(color: Color(0xFF222222));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            matchStyle: matchStyle,
            matchStyleInDef: matchStyleInDef,
          ),
        );
        await tester.pump();

        expect(findTextSpan('bbb@example.com')?.style, matchStyleInDef);
      },
    );

    testWidgets(
      'tapStyle specified in definition is not applied '
      'if tap callbacks are not specified',
      (tester) async {
        const style = TextStyle(color: Color(0xFF111111));
        const tapStyle = TextStyle(color: Color(0xFF222222));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: style,
            tapStyleInDef: tapStyle,
          ),
        );
        await tester.pump();

        findTextSpan('bbb@example.com')?.recognizer?.tapDown();
        await tester.pump();

        expect(findTextSpan('bbb@example.com')?.style, style);
      },
    );

    testWidgets(
      'tapStyle specified in definition is only applied to relevant element',
      (tester) async {
        const style = TextStyle(color: Color(0xFF111111));
        const tapStyle = TextStyle(color: Color(0xFF222222));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com https://example.com/',
            style: style,
            tapStyleInDef: tapStyle,
            onTap: onTap,
          ),
        );
        await tester.pump();

        findTextSpan('bbb@example.com')?.recognizer!.tapDown();
        await tester.pump();

        expect(findTextSpan('aaa ')?.style, style);
        expect(findTextSpan('bbb@example.com')?.style, tapStyle);
        expect(findTextSpan('https://example.com/')?.style, style);
      },
    );

    testWidgets(
      'tapStyle specified in definition takes precedence',
      (tester) async {
        const tapStyle = TextStyle(color: Color(0xFF111111));
        const tapStyleInDef = TextStyle(color: Color(0xFF222222));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            tapStyle: tapStyle,
            tapStyleInDef: tapStyleInDef,
            onTap: onTap,
          ),
        );
        await tester.pump();

        findTextSpan('bbb@example.com')?.recognizer!.tapDown();
        await tester.pump();

        expect(findTextSpan('bbb@example.com')?.style, tapStyleInDef);
      },
    );

    testWidgets(
      'tapStyle specified in CustomText is applied '
      'if onTap is specified in definition',
      (tester) async {
        const style = TextStyle(color: Color(0xFF111111));
        const matchStyle = TextStyle(color: Color(0xFF222222));
        const tapStyle = TextStyle(color: Color(0xFF333333));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com https://example.com/',
            style: style,
            matchStyle: matchStyle,
            tapStyle: tapStyle,
            onTapInDef: onTap,
          ),
        );
        await tester.pump();

        findTextSpan('bbb@example.com')?.recognizer!.tapDown();
        await tester.pump();

        expect(findTextSpan('aaa ')?.style, style);
        expect(findTextSpan('bbb@example.com')?.style, tapStyle);
        expect(findTextSpan('https://example.com/')?.style, matchStyle);

        findTextSpan('bbb@example.com')?.recognizer!.tapUp();
        await tester.pump();

        expect(findTextSpan('bbb@example.com')?.style, matchStyle);
      },
    );

    testWidgets(
      'tapStyle specified in CustomText is applied '
      'if onLongPress is specified in definition',
      (tester) async {
        const style = TextStyle(color: Color(0xFF111111));
        const matchStyle = TextStyle(color: Color(0xFF222222));
        const tapStyle = TextStyle(color: Color(0xFF333333));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com https://example.com/',
            style: style,
            matchStyle: matchStyle,
            tapStyle: tapStyle,
            onLongPressInDef: onLongPress,
          ),
        );
        await tester.pump();

        findTextSpan('bbb@example.com')?.recognizer!.tapDown();
        await tester.pump();

        expect(findTextSpan('aaa ')?.style, style);
        expect(findTextSpan('bbb@example.com')?.style, tapStyle);
        expect(findTextSpan('https://example.com/')?.style, matchStyle);

        findTextSpan('bbb@example.com')?.recognizer!.tapUp();
        await tester.pump();

        expect(findTextSpan('bbb@example.com')?.style, matchStyle);
      },
    );

    testWidgets(
      'tapStyle specified in definition is applied '
      'if onTap is specified in CustomText',
      (tester) async {
        const style = TextStyle(color: Color(0xFF111111));
        const tapStyle = TextStyle(color: Color(0xFF222222));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: style,
            tapStyleInDef: tapStyle,
            onTap: onTap,
          ),
        );
        await tester.pump();

        findTextSpan('bbb@example.com')?.recognizer!.tapDown();
        await tester.pump();

        expect(findTextSpan('aaa ')?.style, style);
        expect(findTextSpan('bbb@example.com')?.style, tapStyle);

        findTextSpan('bbb@example.com')?.recognizer!.tapUp();
        await tester.pump();

        expect(findTextSpan('bbb@example.com')?.style, style);
      },
    );

    testWidgets(
      'tapStyle specified in definition is applied '
      'if onLongPress is specified in CustomText',
      (tester) async {
        const style = TextStyle(color: Color(0xFF111111));
        const tapStyle = TextStyle(color: Color(0xFF222222));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: style,
            tapStyleInDef: tapStyle,
            onLongPress: onLongPress,
          ),
        );
        await tester.pump();

        findTextSpan('bbb@example.com')?.recognizer!.tapDown();
        await tester.pump();

        expect(findTextSpan('aaa ')?.style, style);
        expect(findTextSpan('bbb@example.com')?.style, tapStyle);

        findTextSpan('bbb@example.com')?.recognizer!.tapUp();
        await tester.pump();

        expect(findTextSpan('bbb@example.com')?.style, style);
      },
    );

    testWidgets(
      'tapStyle specified in definition is applied '
      'if onTap is specified in definition',
      (tester) async {
        const style = TextStyle(color: Color(0xFF111111));
        const tapStyle = TextStyle(color: Color(0xFF222222));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: style,
            tapStyleInDef: tapStyle,
            onTapInDef: onTap,
          ),
        );
        await tester.pump();

        findTextSpan('bbb@example.com')?.recognizer!.tapDown();
        await tester.pump();

        expect(findTextSpan('aaa ')?.style, style);
        expect(findTextSpan('bbb@example.com')?.style, tapStyle);

        findTextSpan('bbb@example.com')?.recognizer!.tapUp();
        await tester.pump();

        expect(findTextSpan('bbb@example.com')?.style, style);
      },
    );

    testWidgets(
      'tapStyle specified in definition is applied '
      'if onLongPress is specified in definition',
      (tester) async {
        const style = TextStyle(color: Color(0xFF111111));
        const tapStyle = TextStyle(color: Color(0xFF222222));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: style,
            tapStyleInDef: tapStyle,
            onLongPressInDef: onLongPress,
          ),
        );
        await tester.pump();

        findTextSpan('bbb@example.com')?.recognizer!.tapDown();
        await tester.pump();

        expect(findTextSpan('aaa ')?.style, style);
        expect(findTextSpan('bbb@example.com')?.style, tapStyle);

        findTextSpan('bbb@example.com')?.recognizer!.tapUp();
        await tester.pump();

        expect(findTextSpan('bbb@example.com')?.style, style);
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

        expect(gestureKind, GestureKind.tap);
        expect(pointerDeviceKind, PointerDeviceKind.touch);
        expect(element?.matcherType, EmailMatcher);
        expect(shownText, 'bbb@example.com');
        expect(actionText, 'bbb@example.com');
        expect(globalPosition, center);
        expect(localPosition, center - const Offset(10.0, 10.0));
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

        expect(gestureKind, GestureKind.longPress);
        expect(pointerDeviceKind, PointerDeviceKind.touch);
        expect(element?.matcherType, EmailMatcher);
        expect(shownText, 'bbb@example.com');
        expect(actionText, 'bbb@example.com');
        expect(globalPosition, center);
        expect(localPosition, center - const Offset(10.0, 10.0));
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

        findTextSpan('bbb@example.com')!.recognizer!
          ..tapDown()
          ..tapUp();
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

        final span = findTextSpan('bbb@example.com');
        span?.recognizer!.tapDown();
        await tester.pump(kTestLongPressDuration);
        span?.recognizer!.tapUp();
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
                gestureKind: details.gestureKind,
                pointerDeviceKind: PointerDeviceKind.mouse,
                element: const TextElement(''),
                shownText: 'tap1',
                actionText: 'tap1',
              ),
            ),
            onTapInDef: (details) => onTap(
              GestureDetails(
                gestureKind: details.gestureKind,
                pointerDeviceKind: PointerDeviceKind.mouse,
                element: const TextElement(''),
                shownText: 'tap2',
                actionText: 'tap2',
              ),
            ),
          ),
        );
        await tester.pump();

        findTextSpan('bbb@example.com')!.recognizer!
          ..tapDown()
          ..tapUp();
        await tester.pump();

        expect(actionText, 'tap2');
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
                gestureKind: details.gestureKind,
                pointerDeviceKind: PointerDeviceKind.mouse,
                element: const TextElement(''),
                shownText: 'long1',
                actionText: 'long1',
              ),
            ),
            onLongPressInDef: (details) => onLongPress(
              GestureDetails(
                gestureKind: details.gestureKind,
                pointerDeviceKind: PointerDeviceKind.mouse,
                element: const TextElement(''),
                shownText: 'long2',
                actionText: 'long2',
              ),
            ),
          ),
        );
        await tester.pump();

        final span = findTextSpan('bbb@example.com');
        span?.recognizer!.tapDown();
        await tester.pump(kTestLongPressDuration);
        span?.recognizer!.tapUp();
        await tester.pump();

        expect(actionText, 'long2');
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

        expect(gestureKind, GestureKind.secondaryTap);
        expect(pointerDeviceKind, PointerDeviceKind.touch);
        expect(element?.matcherType, EmailMatcher);
        expect(shownText, 'bbb@example.com');
        expect(actionText, 'bbb@example.com');
        expect(globalPosition, center);
        expect(localPosition, center - const Offset(10.0, 10.0));

        reset();
        await tester.tapAt(center, buttons: kTertiaryButton);

        expect(gestureKind, GestureKind.tertiaryTap);
        expect(pointerDeviceKind, PointerDeviceKind.touch);
        expect(actionText, 'bbb@example.com');
        expect(globalPosition, center);
        expect(localPosition, center - const Offset(10.0, 10.0));

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        reset();
        await gesture.addPointer(location: Offset(center.dx, 9.0));
        await gesture.moveTo(center);
        await tester.pumpAndSettle();

        expect(gestureKind, GestureKind.enter);
        expect(pointerDeviceKind, PointerDeviceKind.mouse);
        expect(actionText, 'bbb@example.com');
        expect(globalPosition, center);
        expect(localPosition, center - const Offset(10.0, 10.0));

        reset();
        await gesture.moveTo(Offset(center.dx, 9.0));
        await tester.pumpAndSettle();

        expect(gestureKind, GestureKind.exit);
        expect(pointerDeviceKind, PointerDeviceKind.mouse);
        expect(actionText, 'bbb@example.com');
        expect(globalPosition, Offset(center.dx, 9.0));
        expect(localPosition, Offset(center.dx - 10.0, -1.0));
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
                gestureKind: details.gestureKind,
                pointerDeviceKind: PointerDeviceKind.mouse,
                element: const TextElement(''),
                shownText: 'gesture1',
                actionText: 'gesture1',
              ),
            ),
            onGestureInDef: (details) => onGesture(
              GestureDetails(
                gestureKind: details.gestureKind,
                pointerDeviceKind: PointerDeviceKind.mouse,
                element: const TextElement(''),
                shownText: 'gesture2',
                actionText: 'gesture2',
              ),
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);

        await tester.tapAt(center, buttons: kSecondaryButton);

        expect(gestureKind, GestureKind.secondaryTap);
        expect(shownText, 'gesture2');
        expect(actionText, 'gesture2');

        reset();
        await tester.tapAt(center, buttons: kTertiaryButton);

        expect(gestureKind, GestureKind.tertiaryTap);
        expect(actionText, 'gesture2');

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        reset();
        await gesture.addPointer(location: Offset(center.dx, 0.0));
        await gesture.moveTo(center);
        await tester.pumpAndSettle();

        expect(gestureKind, GestureKind.enter);
        expect(actionText, 'gesture2');

        reset();
        await gesture.moveTo(Offset(center.dx, -1.0));
        await tester.pumpAndSettle();

        expect(gestureKind, GestureKind.exit);
        expect(actionText, 'gesture2');
      },
    );
  });

  group('Mouse hover', () {
    testWidgets(
      'hoverStyle specified in definition takes precedence',
      (tester) async {
        const style = TextStyle(color: Color(0xFF111111));
        const matchStyle = TextStyle(color: Color(0xFF222222));
        const hoverStyle = TextStyle(color: Color(0xFF333333));
        const hoverStyleInDef = TextStyle(color: Color(0xFF444444));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com https://example.com/',
            style: style,
            matchStyle: matchStyle,
            hoverStyle: hoverStyle,
            hoverStyleInDef: hoverStyleInDef,
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

        expect(findTextSpan('aaa ')?.style, style);
        expect(findTextSpan('bbb@example.com')?.style, hoverStyleInDef);
        expect(findTextSpan('https://example.com/')?.style, matchStyle);

        await gesture.moveTo(Offset(center.dx / 2 * 3, center.dy));
        await tester.pumpAndSettle();

        expect(findTextSpan('aaa ')?.style, style);
        expect(findTextSpan('bbb@example.com')?.style, matchStyle);
        expect(findTextSpan('https://example.com/')?.style, hoverStyle);
      },
    );

    testWidgets(
      'matchStyle in definition is used if hoverStyle is not specified.',
      (tester) async {
        const style = TextStyle(color: Color(0xFF111111));
        const matchStyle = TextStyle(color: Color(0xFF222222));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: style,
            matchStyleInDef: matchStyle,
          ),
        );
        await tester.pump();

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        await gesture.addPointer(location: Offset.zero);
        await gesture.moveTo(tester.getCenter(find.byType(RichText).first));
        await tester.pumpAndSettle();

        expect(findTextSpan('bbb@example.com')?.style, matchStyle);
      },
    );

    testWidgets(
      'hoverStyle in definition is used while being pressed '
      'if tapStyle is not specified',
      (tester) async {
        const style = TextStyle(color: Color(0xFF111111));
        const hoverStyle = TextStyle(color: Color(0xFF222222));

        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            style: style,
            hoverStyleInDef: hoverStyle,
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

        expect(findTextSpan('bbb@example.com')?.style, hoverStyle);

        findTextSpan('bbb@example.com')?.recognizer!.tapDown();
        await tester.pumpAndSettle();

        expect(findTextSpan('bbb@example.com')?.style, hoverStyle);
      },
    );
  });
}
