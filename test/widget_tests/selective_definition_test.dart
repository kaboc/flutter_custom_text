import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'utils.dart';

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
            child: CustomText(
              'aaa[bbb](ccc)ddd',
              textDirection: TextDirection.ltr,
              definitions: [
                SelectiveDefinition(
                  matcher: const LinkMatcher(),
                  shownText: (groups) => groups[0]!,
                  actionText: (groups) => groups[1]!,
                ),
              ],
              onTap: onAction,
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);
        await tester.tapAt(center);

        expect(gestureKind, GestureKind.tap);
        expect(pointerDeviceKind, PointerDeviceKind.touch);
        expect(element?.matcherType, LinkMatcher);
        expect(shownText, 'bbb');
        expect(actionText, 'ccc');
        expect(globalPosition, center);
        expect(localPosition, center - const Offset(10.0, 10.0));
      },
    );

    testWidgets(
      'Correct info is passed to onLongPress specified in CustomText',
      (tester) async {
        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: CustomText(
              'aaa[bbb](ccc)ddd',
              textDirection: TextDirection.ltr,
              definitions: [
                SelectiveDefinition(
                  matcher: const LinkMatcher(),
                  shownText: (groups) => groups[0]!,
                  actionText: (groups) => groups[1]!,
                ),
              ],
              onLongPress: onAction,
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
        expect(element?.matcherType, LinkMatcher);
        expect(shownText, 'bbb');
        expect(actionText, 'ccc');
        expect(globalPosition, center);
        expect(localPosition, center - const Offset(10.0, 10.0));
      },
    );

    testWidgets(
      'Correct info is passed to onTap specified in definition',
      (tester) async {
        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: CustomText(
              'aaa[bbb](ccc)ddd',
              textDirection: TextDirection.ltr,
              definitions: [
                SelectiveDefinition(
                  matcher: const LinkMatcher(),
                  shownText: (groups) => groups[0]!,
                  actionText: (groups) => groups[1]!,
                  onTap: onAction,
                ),
              ],
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);
        await tester.tapAt(center);

        expect(gestureKind, GestureKind.tap);
        expect(pointerDeviceKind, PointerDeviceKind.touch);
        expect(element?.matcherType, LinkMatcher);
        expect(shownText, 'bbb');
        expect(actionText, 'ccc');
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
            child: CustomText(
              'aaa[bbb](ccc)ddd',
              textDirection: TextDirection.ltr,
              definitions: [
                SelectiveDefinition(
                  matcher: const LinkMatcher(),
                  shownText: (groups) => groups[0]!,
                  actionText: (groups) => groups[1]!,
                  onLongPress: onAction,
                ),
              ],
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
        expect(element?.matcherType, LinkMatcher);
        expect(shownText, 'bbb');
        expect(actionText, 'ccc');
        expect(globalPosition, center);
        expect(localPosition, center - const Offset(10.0, 10.0));
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
            child: CustomText(
              'aaa[bbb](ccc)ddd',
              textDirection: TextDirection.ltr,
              definitions: [
                SelectiveDefinition(
                  matcher: const LinkMatcher(),
                  shownText: (groups) => groups[0]!,
                  actionText: (groups) => groups[1]!,
                ),
              ],
              onGesture: onAction,
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);

        await tester.tapAt(center, buttons: kSecondaryButton);
        expect(gestureKind, GestureKind.secondaryTap);
        expect(pointerDeviceKind, PointerDeviceKind.touch);
        expect(element?.matcherType, LinkMatcher);
        expect(shownText, 'bbb');
        expect(actionText, 'ccc');
        expect(globalPosition, center);
        expect(localPosition, center - const Offset(10.0, 10.0));

        reset();
        await tester.tapAt(center, buttons: kTertiaryButton);
        expect(gestureKind, GestureKind.tertiaryTap);
        expect(pointerDeviceKind, PointerDeviceKind.touch);
        expect(shownText, 'bbb');
        expect(actionText, 'ccc');

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        reset();
        await gesture.addPointer(location: Offset(center.dx, 9.0));
        await gesture.moveTo(center);
        await tester.pumpAndSettle();
        expect(gestureKind, GestureKind.enter);
        expect(pointerDeviceKind, PointerDeviceKind.mouse);
        expect(shownText, 'bbb');
        expect(actionText, 'ccc');

        reset();
        await gesture.moveTo(Offset(center.dx, 9.0));
        await tester.pumpAndSettle();
        expect(gestureKind, GestureKind.exit);
        expect(pointerDeviceKind, PointerDeviceKind.mouse);
        expect(shownText, 'bbb');
        expect(actionText, 'ccc');
      },
    );

    testWidgets(
      'Correct info is passed to onGesture specified in definition',
      (tester) async {
        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: CustomText(
              'aaa[bbb](ccc)ddd',
              textDirection: TextDirection.ltr,
              definitions: [
                SelectiveDefinition(
                  matcher: const LinkMatcher(),
                  shownText: (groups) => groups[0]!,
                  actionText: (groups) => groups[1]!,
                  onGesture: onAction,
                ),
              ],
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);

        await tester.tapAt(center, buttons: kSecondaryButton);
        expect(gestureKind, GestureKind.secondaryTap);
        expect(pointerDeviceKind, PointerDeviceKind.touch);
        expect(element?.matcherType, LinkMatcher);
        expect(shownText, 'bbb');
        expect(actionText, 'ccc');
        expect(globalPosition, center);
        expect(localPosition, center - const Offset(10.0, 10.0));

        reset();
        await tester.tapAt(center, buttons: kTertiaryButton);
        expect(gestureKind, GestureKind.tertiaryTap);
        expect(pointerDeviceKind, PointerDeviceKind.touch);
        expect(shownText, 'bbb');
        expect(actionText, 'ccc');

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        reset();
        await gesture.addPointer(location: Offset(center.dx, 9.0));
        await gesture.moveTo(center);
        await tester.pumpAndSettle();
        expect(gestureKind, GestureKind.enter);
        expect(pointerDeviceKind, PointerDeviceKind.mouse);
        expect(shownText, 'bbb');
        expect(actionText, 'ccc');

        reset();
        await gesture.moveTo(Offset(center.dx, 9.0));
        await tester.pumpAndSettle();
        expect(gestureKind, GestureKind.exit);
        expect(pointerDeviceKind, PointerDeviceKind.mouse);
        expect(shownText, 'bbb');
        expect(actionText, 'ccc');
      },
    );
  });
}
