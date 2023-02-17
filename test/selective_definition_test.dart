import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'utils.dart';
import 'widgets.dart';

void main() {
  setUp(reset);

  group('onTap and onLongPress', () {
    testWidgets(
      'Correct info is passed to onTap specified in CustomText',
      (tester) async {
        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: const SelectiveCustomTextWidget(
              'aaa[bbb](ccc)ddd',
              onTap: onTap,
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);
        await tester.tapAt(center);

        expect(gestureKind, equals(GestureKind.tap));
        expect(pointerDeviceKind, equals(PointerDeviceKind.touch));
        expect(element?.matcherType, equals(LinkMatcher));
        expect(labelText, equals('bbb'));
        expect(tappedText, equals('ccc'));
        expect(globalPosition, equals(center));
        expect(localPosition, equals(center - const Offset(10.0, 10.0)));
      },
    );

    testWidgets(
      'Correct info is passed to onLongPress specified in CustomText',
      (tester) async {
        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: const SelectiveCustomTextWidget(
              'aaa[bbb](ccc)ddd',
              onLongPress: onLongPress,
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);
        final gesture = await tester.startGesture(center);
        await tester.pump(kTestLongPressDuration);
        await gesture.up();

        expect(gestureKind, equals(GestureKind.longPress));
        expect(pointerDeviceKind, equals(PointerDeviceKind.touch));
        expect(element?.matcherType, equals(LinkMatcher));
        expect(labelText, equals('bbb'));
        expect(tappedText, equals('ccc'));
        expect(globalPosition, equals(center));
        expect(localPosition, equals(center - const Offset(10.0, 10.0)));
      },
    );

    testWidgets(
      'Correct info is passed to onTap specified in definition',
      (tester) async {
        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: const SelectiveCustomTextWidget(
              'aaa[bbb](ccc)ddd',
              onTapInDef: onTap,
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);
        await tester.tapAt(center);

        expect(gestureKind, equals(GestureKind.tap));
        expect(pointerDeviceKind, equals(PointerDeviceKind.touch));
        expect(element?.matcherType, equals(LinkMatcher));
        expect(labelText, equals('bbb'));
        expect(tappedText, equals('ccc'));
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
            child: const SelectiveCustomTextWidget(
              'aaa[bbb](ccc)ddd',
              onLongPressInDef: onLongPress,
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);
        final gesture = await tester.startGesture(center);
        await tester.pump(kTestLongPressDuration);
        await gesture.up();

        expect(gestureKind, equals(GestureKind.longPress));
        expect(pointerDeviceKind, equals(PointerDeviceKind.touch));
        expect(element?.matcherType, equals(LinkMatcher));
        expect(labelText, equals('bbb'));
        expect(tappedText, equals('ccc'));
        expect(globalPosition, equals(center));
        expect(localPosition, equals(center - const Offset(10.0, 10.0)));
      },
    );
  });

  group('onGesture', () {
    testWidgets(
      'Correct info is passed to onGesture specified in CustomText',
      (tester) async {
        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: const SelectiveCustomTextWidget(
              'aaa[bbb](ccc)ddd',
              onGesture: onGesture,
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);

        await tester.tapAt(center, buttons: kSecondaryButton);
        expect(gestureKind, equals(GestureKind.secondaryTap));
        expect(pointerDeviceKind, equals(PointerDeviceKind.touch));
        expect(element?.matcherType, equals(LinkMatcher));
        expect(labelText, equals('bbb'));
        expect(tappedText, equals('ccc'));
        expect(globalPosition, equals(center));
        expect(localPosition, equals(center - const Offset(10.0, 10.0)));

        labelText = tappedText = null;
        await tester.tapAt(center, buttons: kTertiaryButton);
        expect(gestureKind, equals(GestureKind.tertiaryTap));
        expect(pointerDeviceKind, equals(PointerDeviceKind.touch));
        expect(labelText, equals('bbb'));
        expect(tappedText, equals('ccc'));

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        labelText = tappedText = null;
        await gesture.addPointer(location: Offset(center.dx, 9.0));
        await gesture.moveTo(center);
        await tester.pumpAndSettle();
        expect(gestureKind, equals(GestureKind.enter));
        expect(pointerDeviceKind, equals(PointerDeviceKind.mouse));
        expect(labelText, equals('bbb'));
        expect(tappedText, equals('ccc'));

        labelText = tappedText = null;
        await gesture.moveTo(Offset(center.dx, 9.0));
        await tester.pumpAndSettle();
        expect(gestureKind, equals(GestureKind.exit));
        expect(pointerDeviceKind, equals(PointerDeviceKind.mouse));
        expect(labelText, equals('bbb'));
        expect(tappedText, equals('ccc'));
      },
    );

    testWidgets(
      'Correct info is passed to onGesture specified in definition',
      (tester) async {
        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: const SelectiveCustomTextWidget(
              'aaa[bbb](ccc)ddd',
              onGestureInDef: onGesture,
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);

        await tester.tapAt(center, buttons: kSecondaryButton);
        expect(gestureKind, equals(GestureKind.secondaryTap));
        expect(pointerDeviceKind, equals(PointerDeviceKind.touch));
        expect(element?.matcherType, equals(LinkMatcher));
        expect(labelText, equals('bbb'));
        expect(tappedText, equals('ccc'));
        expect(globalPosition, equals(center));
        expect(localPosition, equals(center - const Offset(10.0, 10.0)));

        labelText = tappedText = null;
        await tester.tapAt(center, buttons: kTertiaryButton);
        expect(gestureKind, equals(GestureKind.tertiaryTap));
        expect(pointerDeviceKind, equals(PointerDeviceKind.touch));
        expect(labelText, equals('bbb'));
        expect(tappedText, equals('ccc'));

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        labelText = tappedText = null;
        await gesture.addPointer(location: Offset(center.dx, 9.0));
        await gesture.moveTo(center);
        await tester.pumpAndSettle();
        expect(gestureKind, equals(GestureKind.enter));
        expect(pointerDeviceKind, equals(PointerDeviceKind.mouse));
        expect(labelText, equals('bbb'));
        expect(tappedText, equals('ccc'));

        labelText = tappedText = null;
        await gesture.moveTo(Offset(center.dx, 9.0));
        await tester.pumpAndSettle();
        expect(gestureKind, equals(GestureKind.exit));
        expect(pointerDeviceKind, equals(PointerDeviceKind.mouse));
        expect(labelText, equals('bbb'));
        expect(tappedText, equals('ccc'));
      },
    );
  });
}
