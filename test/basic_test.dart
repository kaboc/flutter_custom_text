import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'utils.dart';
import 'widgets.dart';

void main() {
  setUp(reset);

  group('Styles', () {
    testWidgets('DefaultTextStyle is used for RichText itself', (tester) async {
      await tester.pumpWidget(
        const DefaultTextStyle(
          style: TextStyle(color: Color(0xFF111111)),
          child: CustomTextWidget('aaa bbb@example.com'),
        ),
      );
      await tester.pump();

      final richText = findRichText();
      expect(richText.text.style?.color, const Color(0xFF111111));
    });

    testWidgets(
      'style and matchStyle are used even if tap callbacks are not specified',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: TextStyle(color: Color(0xFF111111)),
            matchStyle: TextStyle(color: Color(0xFF222222)),
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
      'tapStyle is not applied if tap callbacks are not specified',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: TextStyle(color: Color(0xFF111111)),
            tapStyle: TextStyle(color: Color(0xFF222222)),
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

    testWidgets('tapStyle is applied if onTap is specified', (tester) async {
      await tester.pumpWidget(
        const CustomTextWidget(
          'aaa bbb@example.com https://example.com/',
          style: TextStyle(color: Color(0xFF111111)),
          matchStyle: TextStyle(color: Color(0xFF222222)),
          tapStyle: TextStyle(color: Color(0xFF333333)),
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
      expect(span2B?.style?.color, const Color(0xFF333333));
      expect(span3?.style?.color, const Color(0xFF222222));

      tapUpSpan(span2B);
      await tester.pump();

      final span2C = findSpan('bbb@example.com');
      expect(span2C?.style?.color, const Color(0xFF222222));
    });

    testWidgets(
      'tapStyle is applied if onLongPress is specified',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com https://example.com/',
            style: TextStyle(color: Color(0xFF111111)),
            matchStyle: TextStyle(color: Color(0xFF222222)),
            tapStyle: TextStyle(color: Color(0xFF333333)),
            onLongPress: onLongPress,
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
      'tapStyle is not applied if onGesture is specified '
      'without onTap and onLongPress',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com https://example.com/',
            matchStyle: TextStyle(color: Color(0xFF111111)),
            tapStyle: TextStyle(color: Color(0xFF222222)),
            onGesture: onLongPress,
          ),
        );
        await tester.pump();

        final span1A = findSpan('bbb@example.com');
        tapDownSpan(span1A);
        await tester.pump();

        final span1B = findSpan('bbb@example.com');
        final span2 = findSpan('https://example.com/');
        expect(span1B?.style?.color, const Color(0xFF111111));
        expect(span2?.style?.color, const Color(0xFF111111));
      },
    );
  });

  group('onTap and onLongPress', () {
    testWidgets('Correct info is passed to onTap callback', (tester) async {
      await tester.pumpWidget(
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(left: 10.0, top: 10.0),
          child: const CustomTextWidget('aaa bbb@example.com', onTap: onTap),
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
    });

    testWidgets(
      'Correct info is passed to onLongPress callback',
      (tester) async {
        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: const CustomTextWidget(
              'aaa bbb@example.com',
              onLongPress: onLongPress,
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

    testWidgets('Only onTap is called on short tap', (tester) async {
      var tap = false;
      var long = false;

      await tester.pumpWidget(
        CustomTextWidget(
          'aaa bbb@example.com',
          onTap: (_) => tap = true,
          onLongPress: (_) => long = true,
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
    });

    testWidgets('Only onLongPress is called on long-press', (tester) async {
      var tap = false;
      var long = false;

      await tester.pumpWidget(
        CustomTextWidget(
          'aaa bbb@example.com',
          onTap: (_) => tap = true,
          onLongPress: (_) => long = true,
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
    });

    testWidgets(
      'specified long-press duration is used instead of default value',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            onLongPress: onLongPress,
            longPressDuration: Duration(milliseconds: 300),
          ),
        );
        await tester.pump();

        const email = 'bbb@example.com';
        final span = findSpan(email);

        tapDownSpan(span);
        await tester.pump(const Duration(milliseconds: 310));
        tapUpSpan(span);
        await tester.pump();

        expect(gestureKind, GestureKind.longPress);
      },
    );
  });

  group('onGesture', () {
    testWidgets('Correct info is passed to onGesture callback', (tester) async {
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

      actionText = globalPosition = localPosition = null;
      await tester.tapAt(center, buttons: kTertiaryButton);
      expect(gestureKind, GestureKind.tertiaryTap);
      expect(pointerDeviceKind, PointerDeviceKind.touch);
      expect(actionText, 'bbb@example.com');
      expect(globalPosition, center);
      expect(localPosition, center - const Offset(10.0, 10.0));

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);

      actionText = globalPosition = localPosition = null;
      await gesture.addPointer(location: Offset(center.dx, 9.0));
      await gesture.moveTo(center);
      await tester.pumpAndSettle();
      expect(gestureKind, GestureKind.enter);
      expect(pointerDeviceKind, PointerDeviceKind.mouse);
      expect(actionText, 'bbb@example.com');
      expect(globalPosition, center);
      expect(localPosition, center - const Offset(10.0, 10.0));

      actionText = globalPosition = localPosition = null;
      await gesture.moveTo(Offset(center.dx, 9.0));
      await tester.pumpAndSettle();
      expect(gestureKind, GestureKind.exit);
      expect(pointerDeviceKind, PointerDeviceKind.mouse);
      expect(actionText, 'bbb@example.com');
    });

    testWidgets(
      'Exit and enter are not triggered by rebuild caused by tapStyle',
      (tester) async {
        final events = <String>[];

        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: CustomTextWidget(
              'aaa bbb@example.com',
              tapStyle: const TextStyle(color: Color(0xFF111111)),
              onTap: (details) => events.add(details.gestureKind.name),
              onGesture: (details) => events.add(details.gestureKind.name),
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);
        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        await gesture.addPointer(location: Offset(center.dx, 9.0));
        await gesture.moveTo(center);
        await tester.pumpAndSettle();
        expect(events, ['enter']);

        await gesture.down(center);
        await tester.pumpAndSettle();
        final spanA = findSpan('bbb@example.com');
        expect(spanA?.style?.color, const Color(0xFF111111));
        expect(events, ['enter']);

        await gesture.up();
        await tester.pumpAndSettle();
        final spanB = findSpan('bbb@example.com');
        expect(spanB?.style?.color, isNull);
        expect(events, ['enter', 'tap']);
      },
    );

    testWidgets(
      'Exit and enter are not triggered by rebuild by tapStyle and hoverStyle',
      (tester) async {
        final events = <String>[];

        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: CustomTextWidget(
              'aaa bbb@example.com',
              tapStyle: const TextStyle(color: Color(0xFF111111)),
              hoverStyle: const TextStyle(color: Color(0xFF222222)),
              onTap: (details) => events.add(details.gestureKind.name),
              onGesture: (details) => events.add(details.gestureKind.name),
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);
        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        await gesture.addPointer(location: Offset(center.dx, 9.0));
        await gesture.moveTo(center);
        await tester.pumpAndSettle();
        final spanA = findSpan('bbb@example.com');
        expect(spanA?.style?.color, const Color(0xFF222222));
        expect(events, ['enter']);

        await gesture.down(center);
        await tester.pumpAndSettle();
        final spanB = findSpan('bbb@example.com');
        expect(spanB?.style?.color, const Color(0xFF111111));
        expect(events, ['enter']);

        await gesture.up();
        await tester.pumpAndSettle();
        final spanC = findSpan('bbb@example.com');
        expect(spanC?.style?.color, const Color(0xFF222222));
        expect(events, ['enter', 'tap']);
      },
    );
  });

  group('Mouse hover', () {
    testWidgets('default mouse cursor is used', (tester) async {
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
    });

    testWidgets('Specified mouse cursor is used', (tester) async {
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

    testWidgets(
      'hoverStyle is applied to only currently hovered text span '
      'when mouse pointer is moved between spans quickly',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            '012-3456-7890https://example.com/',
            definitions: [
              TextDefinition(matcher: TelMatcher()),
              TextDefinition(matcher: UrlMatcher()),
            ],
            hoverStyle: TextStyle(color: Color(0xFF111111)),
          ),
        );
        await tester.pump();

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        final center = tester.getCenter(find.byType(RichText).first);
        await gesture.addPointer(location: Offset(center.dx / 2, center.dy));
        await tester.pumpAndSettle();
        final span1a = findSpan('012-3456-7890');
        final span2a = findSpan('https://example.com/');
        expect(span1a?.style?.color, const Color(0xFF111111));
        expect(span2a?.style?.color, isNull);

        await gesture.moveTo(Offset(center.dx / 2 * 3, center.dy));
        await tester.pumpAndSettle();
        final span1b = findSpan('012-3456-7890');
        final span2b = findSpan('https://example.com/');
        expect(span1b?.style?.color, isNull);
        expect(span2b?.style?.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'hoverStyle is applied on hover even if onGesture is not specified',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            hoverStyle: TextStyle(color: Color(0xFF111111)),
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
        expect(spanA?.style?.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'matchStyle is used if hoverStyle is not specified.',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: TextStyle(color: Color(0xFF111111)),
            matchStyle: TextStyle(color: Color(0xFF222222)),
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
      'tapStyle is used while being pressed even if hoverStyle is specified',
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
        await tester.pumpAndSettle();

        final spanA = findSpan('bbb@example.com');
        expect(spanA?.style?.color, const Color(0xFF333333));

        tapDownSpan(spanA);
        await tester.pumpAndSettle();

        final spanB = findSpan('bbb@example.com');
        expect(spanB?.style?.color, const Color(0xFF222222));
      },
    );

    testWidgets(
      'hoverStyle is used while being pressed '
      'if both style and tapStyle are not specified',
      (tester) async {
        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            hoverStyle: const TextStyle(color: Color(0xFF111111)),
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
        expect(spanA?.style?.color, const Color(0xFF111111));

        tapDownSpan(spanA);
        await tester.pumpAndSettle();

        final spanB = findSpan('bbb@example.com');
        expect(spanB?.style?.color, const Color(0xFF111111));
      },
    );
  });

  group('Updating properties', () {
    testWidgets('change of matcher is reflected by rebuild', (tester) async {
      String? value;
      var definitions = const [
        TextDefinition(matcher: PatternMatcher('aaa')),
      ];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (_, setState) {
            return CustomTextWidget(
              'aaa bbb',
              definitions: definitions,
              onTap: (details) => value = details.actionText,
              onButtonPressed: () => setState(() {
                definitions = const [
                  TextDefinition(matcher: PatternMatcher('bbb')),
                ];
              }),
            );
          },
        ),
      );
      await tester.pump();

      final span1 = findSpan('aaa');
      tapDownSpan(span1);
      tapUpSpan(span1);
      await tester.pump();
      expect(value, 'aaa');

      await tapButton(tester);
      await tester.pumpAndSettle();

      final span2 = findSpan('bbb');
      tapDownSpan(span2);
      tapUpSpan(span2);
      await tester.pump();
      expect(value, 'bbb');
    });

    testWidgets(
      'change of tapStyle specified in definition is reflected by rebuild',
      (tester) async {
        var tapStyle = const TextStyle(color: Color(0xFF111111));

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (_, setState) {
              return CustomTextWidget(
                'aaa bbb@example.com',
                tapStyleInDef: tapStyle,
                onTapInDef: (_) {},
                onButtonPressed: () => setState(() {
                  tapStyle = tapStyle.copyWith(color: const Color(0xFF222222));
                }),
              );
            },
          ),
        );
        await tester.pump();

        await tapButton(tester);
        await tester.pumpAndSettle();

        const email = 'bbb@example.com';

        final span1 = findSpan(email);
        tapDownSpan(span1);
        await tester.pump();

        final span2 = findSpan(email);
        expect(span2?.style?.color, const Color(0xFF222222));

        tapUpSpan(span1);
        await tester.pump();
      },
    );

    testWidgets(
      'change of tapStyle specified in CustomText is reflected by rebuild',
      (tester) async {
        var tapStyle = const TextStyle(color: Color(0xFF111111));

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (_, setState) {
              return CustomTextWidget(
                'aaa bbb@example.com',
                tapStyle: tapStyle,
                onTap: (_) {},
                onButtonPressed: () => setState(() {
                  tapStyle = tapStyle.copyWith(color: const Color(0xFF222222));
                }),
              );
            },
          ),
        );
        await tester.pump();

        await tapButton(tester);
        await tester.pumpAndSettle();

        const email = 'bbb@example.com';

        final span1 = findSpan(email);
        tapDownSpan(span1);
        await tester.pump();

        final span2 = findSpan(email);
        expect(span2?.style?.color, const Color(0xFF222222));

        tapUpSpan(span1);
        await tester.pump();
      },
    );

    testWidgets(
      'change of tap callback specified in definition is reflected by rebuild',
      (tester) async {
        void onTap2(GestureDetails details) =>
            actionText = details.actionText.toUpperCase();

        var callback = onTap;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (_, setState) {
              return CustomTextWidget(
                'aaa bbb@example.com',
                onTapInDef: (details) => callback(details),
                onButtonPressed: () {
                  setState(() => callback = onTap2);
                },
              );
            },
          ),
        );
        await tester.pump();

        await tapButton(tester);
        await tester.pumpAndSettle();

        const email = 'bbb@example.com';

        final span = findSpan(email);
        tapDownSpan(span);
        await tester.pump();
        tapUpSpan(span);
        await tester.pump();

        expect(actionText, email.toUpperCase());
      },
    );

    testWidgets(
      'change of tap callback specified in CustomText is reflected by rebuild',
      (tester) async {
        void onTap2(GestureDetails details) =>
            actionText = details.actionText.toUpperCase();

        var callback = onTap;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (_, setState) {
              return CustomTextWidget(
                'aaa bbb@example.com',
                onTap: (details) => callback(details),
                onButtonPressed: () {
                  setState(() => callback = onTap2);
                },
              );
            },
          ),
        );
        await tester.pump();

        await tapButton(tester);
        await tester.pumpAndSettle();

        const email = 'bbb@example.com';

        final span = findSpan(email);
        tapDownSpan(span);
        await tester.pump();
        tapUpSpan(span);
        await tester.pump();

        expect(actionText, email.toUpperCase());
      },
    );

    testWidgets(
      'text change is reflected to onTap specified in definition by rebuild',
      (tester) async {
        var text = 'aaa bbb@example.com';

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (_, setState) {
              return CustomTextWidget(
                text,
                onTapInDef: onTap,
                onButtonPressed: () => setState(() {
                  text = text.toUpperCase();
                }),
              );
            },
          ),
        );
        await tester.pump();

        const email = 'BBB@EXAMPLE.COM';

        await tapButton(tester);
        await tester.pumpAndSettle();

        final span = findSpan(email);
        tapDownSpan(span);
        await tester.pump();
        tapUpSpan(span);
        await tester.pump();

        expect(actionText, email);
      },
    );

    testWidgets(
      'text change is reflected to onTap specified in CustomText by rebuild',
      (tester) async {
        var text = 'aaa bbb@example.com';

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (_, setState) {
              return CustomTextWidget(
                text,
                onTap: onTap,
                onButtonPressed: () => setState(() {
                  text = text.toUpperCase();
                }),
              );
            },
          ),
        );
        await tester.pump();

        const email = 'BBB@EXAMPLE.COM';

        await tapButton(tester);
        await tester.pumpAndSettle();

        final span = findSpan(email);
        tapDownSpan(span);
        await tester.pump();
        tapUpSpan(span);
        await tester.pump();

        expect(actionText, email);
      },
    );
  });
}
