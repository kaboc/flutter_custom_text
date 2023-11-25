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
              builder: (text, groups) => TextSpan(text: text),
              matchStyle: matchStyle,
            ),
          ],
        ),
      );
      await tester.pump();

      final spans = findInlineSpans(onlyDirectChildren: true);
      expect(spans[0].style, style);
      expect(spans[1].style, matchStyle);
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
              builder: (text, groups) => TextSpan(text: text),
              matchStyle: matchStyle,
            ),
          ],
        ),
      );
      await tester.pump();

      final spans = findInlineSpans(onlyDirectChildren: true);
      expect(spans[0].style, style);
      expect(spans[1].style, style.merge(matchStyle));
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
              builder: (text, groups) => TextSpan(text: text),
              matchStyle: matchStyle,
              tapStyle: tapStyle,
              onTap: (_) {},
            ),
          ],
        ),
      );
      await tester.pump();

      final spans1 = findInlineSpans(onlyDirectChildren: true);
      expect(spans1[0].style, style);
      expect(spans1[1].style, style.merge(matchStyle));

      final targetSpan = findInlineSpans()[1];
      (targetSpan as TextSpan).tapDown();
      await tester.pump();

      final spans2 = findInlineSpans(onlyDirectChildren: true);
      expect(spans2[0].style, style);
      expect(spans2[1].style, style.merge(tapStyle));
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
                  builder: (text, groups) => TextSpan(text: text),
                  matchStyle: matchStyle,
                  hoverStyle: hoverStyle,
                  onTap: (_) {},
                ),
              ],
            ),
          ),
        );
        await tester.pump();

        final spans1 = findInlineSpans(onlyDirectChildren: true);
        expect(spans1[0].style, style);
        expect(spans1[1].style, style.merge(matchStyle));

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        final center = tester.getCenter(find.byType(RichText).first);
        await gesture.addPointer(location: center);
        await tester.pumpAndSettle();

        final spans2 = findInlineSpans(onlyDirectChildren: true);
        expect(spans2[0].style, style);
        expect(spans2[1].style, style.merge(hoverStyle));
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
                  builder: (text, groups) => WidgetSpan(child: Text(text)),
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
                builder: (text, groups) => TextSpan(text: groups[0]),
                onTap: onTap,
                onLongPress: onLongPress,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      final spans = findInlineSpans();
      expect(spans, hasLength(3));
      expect(spans[0].toPlainText(), 'aaa');
      expect(spans[1].toPlainText(), 'bbb');
      expect(spans[2].toPlainText(), 'ddd');

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
                builder: (text, groups) {
                  return const WidgetSpan(
                    child: SizedBox.square(
                      dimension: 30,
                      child: ColoredBox(color: Color(0x11111111)),
                    ),
                  );
                },
                onTap: onTap,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      final spans = findInlineSpans();
      expect(spans, hasLength(3));
      expect(spans[0].toPlainText(), 'aaa');
      expect(spans[1], isA<WidgetSpan>());
      expect(spans[2].toPlainText(), 'ccc');

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
                  builder: (text, groups) {
                    return const WidgetSpan(
                      child: SizedBox.square(dimension: 30),
                    );
                  },
                  onTap: onTap,
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
                builder: (text, groups) => TextSpan(text: groups[0]),
                onGesture: onGesture,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      final spans = findInlineSpans();
      expect(spans, hasLength(3));
      expect(spans[0].toPlainText(), 'aaa');
      expect(spans[1].toPlainText(), 'bbb');
      expect(spans[2].toPlainText(), 'ddd');

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
                builder: (text, groups) {
                  return const WidgetSpan(
                    child: SizedBox.square(
                      dimension: 30,
                      child: ColoredBox(color: Color(0x11111111)),
                    ),
                  );
                },
                onGesture: onGesture,
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      final spans = findInlineSpans();
      expect(spans, hasLength(3));
      expect(spans[0].toPlainText(), 'aaa');
      expect(spans[1], isA<WidgetSpan>());
      expect(spans[2].toPlainText(), 'ccc');

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
                  builder: (text, groups) {
                    return const WidgetSpan(
                      child: SizedBox.square(dimension: 30),
                    );
                  },
                  onGesture: onGesture,
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
              builder: (text, groups) => TextSpan(text: text),
              mouseCursor: SystemMouseCursors.grab,
            ),
          ],
        ),
      );
      await tester.pump();

      expect(findTextSpan('aaa')?.mouseCursor, MouseCursor.defer);
      expect(findTextSpan('bbb')?.mouseCursor, SystemMouseCursors.grab);
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
                    builder: (text, groups) => const TextSpan(
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
        final spans1 = findInlineSpans(onlyDirectChildren: true);
        expect(spans1[1].style, style.merge(hoverStyle));

        final text1 = tester
            .findDescendantWidgetsByType<RichText>(of: RichText)
            .elementAt(0)
            .text;
        expect(text1.toPlainText(), 'def');
        expect(text1.style, style.merge(hoverStyle).merge(innerStyle));

        // Tap on WidgetSpan
        await gesture.down(center);
        await tester.pump();

        final spans2 = findInlineSpans(onlyDirectChildren: true);
        expect(spans2[1].style, style.merge(tapStyle));

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

        final spans3 = findInlineSpans(onlyDirectChildren: true);
        expect(spans3[1].style, style.merge(hoverStyle));

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
