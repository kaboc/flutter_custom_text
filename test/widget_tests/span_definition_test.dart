import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'utils.dart';

void main() {
  setUp(reset);

  group('Styles', () {
    testWidgets('matchStyle is applied', (tester) async {
      const style = TextStyle(color: Color(0x11111111));
      const matchStyle = TextStyle(color: Color(0x22222222));

      await tester.pumpWidget(
        CustomText(
          'aaabbbccc',
          style: style,
          textDirection: TextDirection.ltr,
          definitions: [
            SpanDefinition(
              matcher: const PatternMatcher('bbb'),
              builder: (element) => TextSpan(text: element.text),
              matchStyle: matchStyle,
            ),
          ],
        ),
      );
      await tester.pump();

      expect(
        findFirstTextSpan(),
        const TextSpan(
          children: [
            TextSpan(text: 'aaa', style: style),
            TextSpan(
              style: matchStyle,
              children: [
                TextSpan(text: 'bbb'),
              ],
            ),
            TextSpan(text: 'ccc', style: style),
          ],
        ),
      );
    });

    testWidgets('matchStyle is merged with style', (tester) async {
      const style = TextStyle(color: Color(0x11111111));
      const matchStyle = TextStyle(decoration: TextDecoration.underline);

      await tester.pumpWidget(
        CustomText(
          'aaabbbccc',
          style: style,
          textDirection: TextDirection.ltr,
          definitions: [
            SpanDefinition(
              matcher: const PatternMatcher('bbb'),
              builder: (element) => TextSpan(text: element.text),
              matchStyle: matchStyle,
            ),
          ],
        ),
      );
      await tester.pump();

      expect(
        findFirstTextSpan(),
        TextSpan(
          children: [
            const TextSpan(text: 'aaa', style: style),
            TextSpan(
              style: style.merge(matchStyle),
              children: const [
                TextSpan(text: 'bbb'),
              ],
            ),
            const TextSpan(text: 'ccc', style: style),
          ],
        ),
      );
    });

    testWidgets('tapStyle is applied while being pressed', (tester) async {
      const style = TextStyle(color: Color(0x11111111));
      const matchStyle = TextStyle(decoration: TextDecoration.underline);
      const tapStyle = TextStyle(backgroundColor: Color(0x22222222));

      await tester.pumpWidget(
        CustomText(
          'aaabbbccc',
          style: style,
          textDirection: TextDirection.ltr,
          definitions: [
            SpanDefinition(
              matcher: const PatternMatcher('bbb'),
              builder: (element) => TextSpan(text: element.text),
              matchStyle: matchStyle,
              tapStyle: tapStyle,
              onTap: (_) {},
            ),
          ],
        ),
      );
      await tester.pump();

      expect(
        findFirstTextSpan(),
        TextSpan(
          children: [
            const TextSpan(text: 'aaa', style: style),
            TextSpan(
              style: style.merge(matchStyle),
              children: [
                findTextSpanByText('bbb')!,
              ],
            ),
            const TextSpan(text: 'ccc', style: style),
          ],
        ),
      );

      findTextSpanByText('bbb')!.tapDown();
      await tester.pump();

      expect(
        findFirstTextSpan(),
        TextSpan(
          children: [
            const TextSpan(text: 'aaa', style: style),
            TextSpan(
              style: style.merge(tapStyle),
              children: [
                findTextSpanByText('bbb')!,
              ],
            ),
            const TextSpan(text: 'ccc', style: style),
          ],
        ),
      );
    });

    testWidgets(
      'hoverStyle is applied while mouse pointer is on the span',
      (tester) async {
        const style = TextStyle(color: Color(0x11111111));
        const matchStyle = TextStyle(decoration: TextDecoration.underline);
        const hoverStyle = TextStyle(backgroundColor: Color(0x22222222));

        await tester.pumpWidget(
          Align(
            alignment: Alignment.topLeft,
            child: CustomText(
              'aaabbbccc',
              style: style,
              textDirection: TextDirection.ltr,
              definitions: [
                SpanDefinition(
                  matcher: const PatternMatcher('bbb'),
                  builder: (element) => TextSpan(text: element.text),
                  matchStyle: matchStyle,
                  hoverStyle: hoverStyle,
                  onTap: (_) {},
                ),
              ],
            ),
          ),
        );
        await tester.pump();

        expect(
          findFirstTextSpan(),
          TextSpan(
            children: [
              const TextSpan(text: 'aaa', style: style),
              TextSpan(
                style: style.merge(matchStyle),
                children: [
                  findTextSpanByText('bbb')!,
                ],
              ),
              const TextSpan(text: 'ccc', style: style),
            ],
          ),
        );

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        final center = tester.getCenter(find.byType(RichText).first);
        await gesture.addPointer(location: center);
        await tester.pumpAndSettle();

        expect(
          findFirstTextSpan(),
          TextSpan(
            children: [
              const TextSpan(text: 'aaa', style: style),
              TextSpan(
                style: style.merge(hoverStyle),
                children: [
                  findTextSpanByText('bbb')!,
                ],
              ),
              const TextSpan(text: 'ccc', style: style),
            ],
          ),
        );
      },
    );

    testWidgets(
      'Default text style is applied to Text widgets in WidgetSpan',
      (tester) async {
        const style = TextStyle(color: Color(0xFF111111));

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomText(
              'aaabbbccc',
              definitions: [
                SpanDefinition(
                  matcher: const PatternMatcher('bbb'),
                  builder: (element) => WidgetSpan(child: Text(element.text)),
                  matchStyle: style,
                ),
              ],
            ),
          ),
        );
        await tester.pump();

        final text = tester
            .findDescendantWidgetsByType<RichText>(of: RichText)
            .elementAt(0)
            .text;
        expect(text.toPlainText(), 'bbb');
        expect(text.style, style);
      },
    );
  });

  group('onTap and onLongPress', () {
    testWidgets('Tap callbacks receive correct details', (tester) async {
      await tester.pumpWidget(
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(left: 10.0, top: 10.0),
          child: CustomText(
            'aaa[bbb](ccc)ddd',
            textDirection: TextDirection.ltr,
            definitions: [
              SpanDefinition(
                matcher: const LinkMatcher(),
                builder: (element) => TextSpan(text: element.groups[0]),
                onTap: onAction,
                onLongPress: onAction,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(
        findFirstTextSpan(),
        TextSpan(
          children: [
            const TextSpan(text: 'aaa'),
            TextSpan(
              children: [
                findTextSpanByText('bbb')!,
              ],
            ),
            const TextSpan(text: 'ddd'),
          ],
        ),
      );

      final center = tester.getCenter(find.byType(RichText).first);
      await tester.tapAt(center);
      await tester.pump();

      expect(gestureKind, GestureKind.tap);
      expect(pointerDeviceKind, PointerDeviceKind.touch);
      expect(element?.matcherType, LinkMatcher);
      expect(element?.text, '[bbb](ccc)');
      expect(element?.groups, ['bbb', 'ccc']);
      expect(shownText, '[bbb](ccc)');
      expect(actionText, '[bbb](ccc)');
      expect(globalPosition, center);
      expect(localPosition, center - const Offset(10.0, 10.0));

      await tester.longPressAt(center);
      await tester.pump();

      expect(gestureKind, GestureKind.longPress);
      expect(element?.groups, ['bbb', 'ccc']);
      expect(actionText, '[bbb](ccc)');
      expect(localPosition, center - const Offset(10.0, 10.0));
    });

    testWidgets('Tap callbacks are applied to WidgetSpan too', (tester) async {
      await tester.pumpWidget(
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(left: 10.0, top: 10.0),
          child: CustomText(
            'aaabbbccc',
            textDirection: TextDirection.ltr,
            definitions: [
              SpanDefinition(
                matcher: const PatternMatcher('bbb'),
                builder: (element) {
                  return const WidgetSpan(
                    child: SizedBox.square(
                      dimension: 30,
                      child: ColoredBox(color: Color(0x11111111)),
                    ),
                  );
                },
                onTap: onAction,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      final builtSpan = findFirstTextSpan();

      expect(
        builtSpan,
        TextSpan(
          children: [
            const TextSpan(text: 'aaa'),
            TextSpan(
              children: [
                builtSpan.findWidgetSpans().first,
              ],
            ),
            const TextSpan(text: 'ccc'),
          ],
        ),
      );

      final center = tester.getCenter(find.byType(RichText).first);
      await tester.tapAt(center);
      await tester.pump();

      expect(gestureKind, GestureKind.tap);
      expect(element?.matcherType, PatternMatcher);
      expect(actionText, 'bbb');
    });

    testWidgets(
      'Tap callbacks are applied to transparent WidgetSpan too',
      (tester) async {
        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: CustomText(
              'aaabbbccc',
              textDirection: TextDirection.ltr,
              definitions: [
                SpanDefinition(
                  matcher: const PatternMatcher('bbb'),
                  builder: (element) {
                    return const WidgetSpan(
                      child: SizedBox.square(dimension: 30),
                    );
                  },
                  onTap: onAction,
                ),
              ],
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);
        await tester.tapAt(center);
        await tester.pump();

        expect(gestureKind, GestureKind.tap);
        expect(actionText, 'bbb');
      },
    );
  });

  group('onGesture', () {
    testWidgets('onGesture receives correct details', (tester) async {
      await tester.pumpWidget(
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(left: 10.0, top: 10.0),
          child: CustomText(
            'aaa[bbb](ccc)ddd',
            textDirection: TextDirection.ltr,
            definitions: [
              SpanDefinition(
                matcher: const LinkMatcher(),
                builder: (element) => TextSpan(text: element.groups[0]),
                onGesture: onAction,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(
        findFirstTextSpan(),
        TextSpan(
          children: [
            const TextSpan(text: 'aaa'),
            TextSpan(
              children: [
                findTextSpanByText('bbb')!,
              ],
            ),
            const TextSpan(text: 'ddd'),
          ],
        ),
      );

      final center = tester.getCenter(find.byType(RichText).first);
      await tester.tapAt(center, buttons: kSecondaryButton);

      expect(gestureKind, GestureKind.secondaryTap);
      expect(pointerDeviceKind, PointerDeviceKind.touch);
      expect(element?.matcherType, LinkMatcher);
      expect(element?.text, '[bbb](ccc)');
      expect(element?.groups, ['bbb', 'ccc']);
      expect(shownText, '[bbb](ccc)');
      expect(actionText, '[bbb](ccc)');
      expect(globalPosition, center);
      expect(localPosition, center - const Offset(10.0, 10.0));

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);

      reset();
      await gesture.addPointer(location: center);
      await tester.pumpAndSettle();

      expect(gestureKind, GestureKind.enter);
      expect(pointerDeviceKind, PointerDeviceKind.mouse);
      expect(element?.groups, ['bbb', 'ccc']);
      expect(actionText, '[bbb](ccc)');
      expect(globalPosition, center);
      expect(localPosition, center - const Offset(10.0, 10.0));

      reset();
      await gesture.moveTo(Offset(center.dx, 9.0));
      await tester.pumpAndSettle();

      expect(gestureKind, GestureKind.exit);
      expect(element?.groups, ['bbb', 'ccc']);
      expect(actionText, '[bbb](ccc)');
      expect(localPosition, Offset(center.dx, 9.0) - const Offset(10.0, 10.0));
    });

    testWidgets('onGesture is applied to WidgetSpan too', (tester) async {
      await tester.pumpWidget(
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(left: 10.0, top: 10.0),
          child: CustomText(
            'aaabbbccc',
            textDirection: TextDirection.ltr,
            definitions: [
              SpanDefinition(
                matcher: const PatternMatcher('bbb'),
                builder: (element) {
                  return const WidgetSpan(
                    child: SizedBox.square(
                      dimension: 30,
                      child: ColoredBox(color: Color(0x11111111)),
                    ),
                  );
                },
                onGesture: onAction,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      final builtSpan = findFirstTextSpan();

      expect(
        builtSpan,
        TextSpan(
          children: [
            const TextSpan(text: 'aaa'),
            TextSpan(
              children: [
                builtSpan.findWidgetSpans().first,
              ],
            ),
            const TextSpan(text: 'ccc'),
          ],
        ),
      );

      final center = tester.getCenter(find.byType(RichText).first);
      await tester.tapAt(center, buttons: kTertiaryButton);

      expect(gestureKind, GestureKind.tertiaryTap);
      expect(pointerDeviceKind, PointerDeviceKind.touch);
      expect(element?.matcherType, PatternMatcher);
      expect(actionText, 'bbb');

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(gesture.removePointer);

      reset();
      await gesture.addPointer(location: center);
      await tester.pumpAndSettle();

      expect(gestureKind, GestureKind.enter);
      expect(pointerDeviceKind, PointerDeviceKind.mouse);
      expect(actionText, 'bbb');
    });

    testWidgets(
      'onGesture is applied to transparent WidgetSpan too',
      (tester) async {
        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: CustomText(
              'aaabbbccc',
              textDirection: TextDirection.ltr,
              definitions: [
                SpanDefinition(
                  matcher: const PatternMatcher('bbb'),
                  builder: (element) {
                    return const WidgetSpan(
                      child: SizedBox.square(dimension: 30),
                    );
                  },
                  onGesture: onAction,
                ),
              ],
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);
        await tester.tapAt(center, buttons: kTertiaryButton);

        expect(gestureKind, GestureKind.tertiaryTap);
        expect(actionText, 'bbb');

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        reset();
        await gesture.addPointer(location: center);
        await tester.pumpAndSettle();

        expect(gestureKind, GestureKind.enter);
        expect(actionText, 'bbb');
      },
    );
  });

  group('Mouse hover', () {
    testWidgets('Specified mouse cursor is used', (tester) async {
      await tester.pumpWidget(
        CustomText(
          'aaabbbccc',
          textDirection: TextDirection.ltr,
          definitions: [
            SpanDefinition(
              matcher: const PatternMatcher('bbb'),
              builder: (element) => TextSpan(text: element.text),
              mouseCursor: SystemMouseCursors.grab,
            ),
          ],
        ),
      );
      await tester.pump();

      expect(findTextSpanByText('aaa')?.mouseCursor, MouseCursor.defer);
      expect(findTextSpanByText('bbb')?.mouseCursor, SystemMouseCursors.grab);
    });
  });

  group('Complex span', () {
    testWidgets(
      'Children consists of both TextSpan and WidgetSpan have correct styles',
      (tester) async {
        const style = TextStyle(fontSize: 30);
        const hoverStyle = TextStyle(
          decoration: TextDecoration.underline,
          decorationColor: Color(0x11111111),
        );
        const tapStyle = TextStyle(
          decoration: TextDecoration.underline,
          decorationColor: Color(0x22222222),
        );
        const innerStyle = TextStyle(color: Color(0x33333333));

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: CustomText(
                '123#456',
                definitions: [
                  SpanDefinition(
                    matcher: const PatternMatcher('#'),
                    builder: (element) => const TextSpan(
                      children: [
                        TextSpan(
                          text: 'ab',
                        ),
                        TextSpan(
                          text: 'c',
                          children: [
                            WidgetSpan(
                              child: Text('def', style: innerStyle),
                            ),
                          ],
                        ),
                        TextSpan(text: 'ghi'),
                      ],
                    ),
                  ),
                ],
                style: style,
                hoverStyle: hoverStyle,
                tapStyle: tapStyle,
                onTap: (_) {},
              ),
            ),
          ),
        );
        await tester.pump();

        expect(findText().textSpan?.toPlainText(), '123abc\uFFFCghi456');

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        // Hover over WidgetSpan
        final center = tester.getCenter(find.byType(RichText).first);
        await gesture.addPointer(location: center);
        await tester.pumpAndSettle();

        // spans1[0]: TextSpan with text '123'
        // spans1[1]: TextSpan containing TextSpan returned by builder callback
        // spans1[2]: TextSpan with text '456'

        expect(
          findFirstTextSpan()?.children?[1].style,
          style.merge(hoverStyle),
        );

        final text1 = tester
            .findDescendantWidgetsByType<RichText>(of: RichText)
            .elementAt(0)
            .text;
        expect(text1.toPlainText(), 'def');
        expect(text1.style, style.merge(hoverStyle).merge(innerStyle));

        // Tap on WidgetSpan
        await gesture.down(center);
        await tester.pump();

        expect(
          findFirstTextSpan()?.children?[1].style,
          style.merge(tapStyle),
        );

        final text2 = tester
            .findDescendantWidgetsByType<RichText>(of: RichText)
            .elementAt(0)
            .text;
        expect(text2.toPlainText(), 'def');
        expect(text2.style, style.merge(tapStyle).merge(innerStyle));

        // Move pointer and hover over "ghi"
        await gesture.up();
        await gesture.moveTo(center + center / 2);
        await tester.pump();

        expect(
          findFirstTextSpan()?.children?[1].style,
          style.merge(hoverStyle),
        );

        final text3 = tester
            .findDescendantWidgetsByType<RichText>(of: RichText)
            .elementAt(0)
            .text;
        expect(text3.toPlainText(), 'def');
        expect(text3.style, style.merge(hoverStyle).merge(innerStyle));
      },
    );
  });
}
