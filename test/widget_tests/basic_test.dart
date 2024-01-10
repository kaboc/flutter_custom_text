import 'dart:async' show Completer;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'utils.dart';
import 'widgets.dart';

void main() {
  setUp(reset);

  group('Styles', () {
    testWidgets('DefaultTextStyle is used for RichText itself', (tester) async {
      const style = TextStyle(color: Color(0xFF111111));

      await tester.pumpWidget(
        const DefaultTextStyle(
          style: style,
          child: CustomTextWidget('aaa bbb@example.com'),
        ),
      );
      await tester.pump();

      final richTexts = tester.findWidgetsByType<RichText>();
      expect(richTexts.first.text.style, style);
    });

    testWidgets(
      'style and matchStyle are used even if tap callbacks are not specified',
      (tester) async {
        const style = TextStyle(color: Color(0xFF111111));
        const matchStyle = TextStyle(color: Color(0xFF222222));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: style,
            matchStyle: matchStyle,
          ),
        );
        await tester.pump();

        expect(findTextSpanByText('aaa ')?.style, style);
        expect(findTextSpanByText('bbb@example.com')?.style, matchStyle);
      },
    );

    testWidgets(
      'tapStyle is not applied if tap callbacks are not specified',
      (tester) async {
        const style = TextStyle(color: Color(0xFF111111));
        const tapStyle = TextStyle(color: Color(0xFF222222));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: style,
            tapStyle: tapStyle,
          ),
        );
        await tester.pump();

        findTextSpanByText('bbb@example.com').maybeTapDown();
        await tester.pump();

        expect(findTextSpanByText('bbb@example.com')?.style, style);
      },
    );

    testWidgets('tapStyle is applied if onTap is specified', (tester) async {
      const style = TextStyle(color: Color(0xFF111111));
      const matchStyle = TextStyle(color: Color(0xFF222222));
      const tapStyle = TextStyle(color: Color(0xFF333333));

      await tester.pumpWidget(
        const CustomTextWidget(
          'aaa bbb@example.com https://example.com/',
          style: style,
          matchStyle: matchStyle,
          tapStyle: tapStyle,
          onTap: onAction,
        ),
      );
      await tester.pump();

      findTextSpanByText('bbb@example.com').tapDown();
      await tester.pump();

      expect(findTextSpanByText('aaa ')?.style, style);
      expect(findTextSpanByText('bbb@example.com')?.style, tapStyle);
      expect(findTextSpanByText('https://example.com/')?.style, matchStyle);

      findTextSpanByText('bbb@example.com').tapUp();
      await tester.pump();

      expect(findTextSpanByText('bbb@example.com')?.style, matchStyle);
    });

    testWidgets(
      'tapStyle is applied if onLongPress is specified',
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
            onLongPress: onAction,
          ),
        );
        await tester.pump();

        findTextSpanByText('bbb@example.com').tapDown();
        await tester.pump();

        expect(findTextSpanByText('aaa ')?.style, style);
        expect(findTextSpanByText('bbb@example.com')?.style, tapStyle);
        expect(findTextSpanByText('https://example.com/')?.style, matchStyle);

        findTextSpanByText('bbb@example.com').tapUp();
        await tester.pump();

        expect(findTextSpanByText('bbb@example.com')?.style, matchStyle);
      },
    );

    testWidgets(
      'tapStyle is not applied if onGesture is specified '
      'without onTap and onLongPress',
      (tester) async {
        const matchStyle = TextStyle(color: Color(0xFF111111));
        const tapStyle = TextStyle(color: Color(0xFF222222));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com https://example.com/',
            matchStyle: matchStyle,
            tapStyle: tapStyle,
            onGesture: onAction,
          ),
        );
        await tester.pump();

        findTextSpanByText('bbb@example.com').maybeTapDown();
        await tester.pump();

        expect(findTextSpanByText('bbb@example.com')?.style, matchStyle);
        expect(findTextSpanByText('https://example.com/')?.style, matchStyle);
      },
    );
  });

  group('Initial visibility', () {
    testWidgets(
      'Text is transparent until parsing completes when style is not specified',
      (tester) async {
        final completer = Completer<List<TextElement>>();
        const matchStyle = TextStyle(color: Color(0x11111111));

        await tester.pumpWidget(
          CustomText(
            'aaa[bbb](ccc)',
            textDirection: TextDirection.ltr,
            parserOptions: ParserOptions.external((text) => completer.future),
            definitions: [
              SelectiveDefinition(
                matcher: const LinkMatcher(),
                shownText: (groups) => groups.first!,
              ),
            ],
            matchStyle: matchStyle,
          ),
        );
        await tester.pump();

        expect(
          findFirstTextSpan(),
          const TextSpan(
            text: 'aaa[bbb](ccc)',
            style: TextStyle(color: Color(0x00000000)),
          ),
        );

        completer.complete(const [
          TextElement('aaa'),
          TextElement(
            '[bbb](ccc)',
            matcherType: LinkMatcher,
            groups: ['bbb', 'ccc'],
          ),
        ]);
        await tester.pumpAndSettle();

        expect(
          findFirstTextSpan(),
          const TextSpan(
            children: [
              TextSpan(text: 'aaa'),
              TextSpan(text: 'bbb', style: matchStyle),
            ],
          ),
        );
      },
    );

    testWidgets(
      'Text is transparent until parsing completes when style is specified',
      (tester) async {
        final completer = Completer<List<TextElement>>();
        const style = TextStyle(color: Color(0x11111111), fontSize: 30.0);
        const matchStyle = TextStyle(color: Color(0x22222222));

        await tester.pumpWidget(
          CustomText(
            'aaa[bbb](ccc)',
            textDirection: TextDirection.ltr,
            parserOptions: ParserOptions.external((text) => completer.future),
            definitions: [
              SelectiveDefinition(
                matcher: const LinkMatcher(),
                shownText: (groups) => groups.first!,
              ),
            ],
            style: style,
            matchStyle: matchStyle,
          ),
        );
        await tester.pump();

        expect(
          findFirstTextSpan(),
          TextSpan(
            text: 'aaa[bbb](ccc)',
            style: style.copyWith(color: const Color(0x00000000)),
          ),
        );

        completer.complete(const [
          TextElement('aaa'),
          TextElement(
            '[bbb](ccc)',
            matcherType: LinkMatcher,
            groups: ['bbb', 'ccc'],
          ),
        ]);
        await tester.pumpAndSettle();

        expect(
          findFirstTextSpan(),
          TextSpan(
            children: [
              const TextSpan(text: 'aaa', style: style),
              TextSpan(text: 'bbb', style: style.merge(matchStyle)),
            ],
          ),
        );
      },
    );

    testWidgets(
      'Content including widgets is represented as transparent plain '
      'text until parsing completes in CustomText.spans',
      (tester) async {
        final completer = Completer<List<TextElement>>();
        const style = TextStyle(color: Color(0x11111111), fontSize: 30.0);
        const matchStyle = TextStyle(color: Color(0x22222222));

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomText.spans(
              parserOptions: ParserOptions.external((text) => completer.future),
              definitions: const [
                TextDefinition(matcher: PatternMatcher('bbb\uFFFC')),
              ],
              spans: const [
                TextSpan(text: 'aaa'),
                TextSpan(text: 'bbb'),
                WidgetSpan(child: Icon(Icons.star)),
                WidgetSpan(child: Icon(Icons.star)),
              ],
              style: style,
              matchStyle: matchStyle,
            ),
          ),
        );
        await tester.pump();

        expect(
          findFirstTextSpan(),
          TextSpan(
            text: 'aaabbb\uFFFC\uFFFC',
            style: style.copyWith(color: const Color(0x00000000)),
          ),
        );

        completer.complete(const [
          TextElement('aaa'),
          TextElement('bbb\uFFFC', matcherType: PatternMatcher),
          TextElement('\uFFFC'),
        ]);
        await tester.pumpAndSettle();

        final builtSpan = findFirstTextSpan();
        final widgetSpans = builtSpan.findWidgetSpans();

        expect(
          builtSpan,
          TextSpan(
            children: [
              const TextSpan(
                style: style,
                children: [
                  TextSpan(text: 'aaa'),
                ],
              ),
              TextSpan(
                style: style.merge(matchStyle),
                children: [
                  const TextSpan(text: 'bbb'),
                  widgetSpans[0],
                ],
              ),
              TextSpan(
                style: style,
                children: [
                  widgetSpans[1],
                ],
              ),
            ],
          ),
        );
      },
    );

    testWidgets(
      'Text is visible during parsing if there are only TextDefinitions',
      (tester) async {
        const style = TextStyle(color: Color(0x11111111));
        const matchStyle = TextStyle(color: Color(0x22222222));

        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            parserOptions: ParserOptions.external(
              (text) => Completer<List<TextElement>>().future,
            ),
            style: style,
            matchStyle: matchStyle,
          ),
        );
        await tester.pump();

        expect(
          findFirstTextSpan(),
          const TextSpan(text: 'aaa bbb@example.com', style: style),
        );
      },
    );

    testWidgets(
      'Content is not visible during parsing in CustomText.spans '
      'even if there are only TextDefinitions',
      (tester) async {
        final completer = Completer<List<TextElement>>();
        const style = TextStyle(color: Color(0x11111111));
        const matchStyle = TextStyle(color: Color(0x22222222));

        await tester.pumpWidget(
          CustomText.spans(
            textDirection: TextDirection.ltr,
            parserOptions: ParserOptions.external((text) => completer.future),
            definitions: const [
              TextDefinition(matcher: PatternMatcher('bbb')),
            ],
            spans: const [
              TextSpan(text: 'aaa'),
              TextSpan(text: 'bbb'),
            ],
            style: style,
            matchStyle: matchStyle,
          ),
        );
        await tester.pump();

        expect(
          findFirstTextSpan(),
          const TextSpan(
            text: 'aaabbb',
            style: TextStyle(color: Color(0x00000000)),
          ),
        );

        completer.complete(const [
          TextElement('aaa'),
          TextElement('bbb', matcherType: PatternMatcher),
        ]);
        await tester.pumpAndSettle();

        expect(
          findFirstTextSpan(),
          const TextSpan(
            children: [
              TextSpan(
                style: style,
                children: [
                  TextSpan(text: 'aaa'),
                ],
              ),
              TextSpan(
                style: matchStyle,
                children: [
                  TextSpan(text: 'bbb'),
                ],
              ),
            ],
          ),
        );
      },
    );

    testWidgets(
      'Text is visible during parsing if preventBlocking is enabled',
      (tester) async {
        const style = TextStyle(color: Color(0x11111111));
        const matchStyle = TextStyle(color: Color(0x22222222));

        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            parserOptions: ParserOptions.external(
              (text) => Completer<List<TextElement>>().future,
            ),
            preventBlocking: true,
            style: style,
            matchStyle: matchStyle,
          ),
        );
        await tester.pump();

        expect(
          findFirstTextSpan(),
          const TextSpan(text: 'aaa bbb@example.com', style: style),
        );
      },
    );

    testWidgets(
      'Text is quickly shown before parsing completes when text is given '
      'later than initial build',
      (tester) async {
        var text = '';
        final completer = Completer<List<TextElement>>();
        const style = TextStyle(color: Color(0x11111111));
        const matchStyle = TextStyle(color: Color(0x22222222));

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return CustomTextWidget(
                text,
                parserOptions:
                    ParserOptions.external((text) => completer.future),
                style: style,
                matchStyle: matchStyle,
                onButtonPressed: () {
                  setState(() => text = 'aaa bbb@example.com');
                },
              );
            },
          ),
        );
        await tester.pump();

        expect(findFirstTextSpan(), const TextSpan());

        await tester.tapButton();
        await tester.pump();

        expect(
          findFirstTextSpan(),
          const TextSpan(text: 'aaa bbb@example.com', style: style),
        );

        completer.complete(const [
          TextElement('aaa'),
          TextElement('bbb@example.com', matcherType: EmailMatcher),
        ]);
        await tester.pump();

        expect(
          findFirstTextSpan(),
          const TextSpan(
            children: [
              TextSpan(text: 'aaa', style: style),
              TextSpan(text: 'bbb@example.com', style: matchStyle),
            ],
          ),
        );
      },
    );

    testWidgets('Text is transparent only initially', (tester) async {
      Completer<List<TextElement>>? completer;
      var text = 'aaa[bbb](ccc)';
      const matchStyle = TextStyle(color: Color(0x11111111));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  CustomText(
                    text,
                    parserOptions: ParserOptions.external((text) {
                      completer = Completer<List<TextElement>>();
                      return completer!.future;
                    }),
                    definitions: [
                      SelectiveDefinition(
                        matcher: const LinkMatcher(),
                        shownText: (groups) => groups.first!,
                      ),
                    ],
                    matchStyle: matchStyle,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => text = 'ddd[eee](fff)');
                    },
                    child: const Text('Button'),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(
        findFirstTextSpan(),
        const TextSpan(
          text: 'aaa[bbb](ccc)',
          style: TextStyle(color: Color(0x00000000)),
        ),
      );

      completer?.complete(const [
        TextElement('aaa'),
        TextElement(
          '[bbb](ccc)',
          matcherType: LinkMatcher,
          groups: ['bbb', 'ccc'],
        ),
      ]);
      await tester.pumpAndSettle();

      expect(
        findFirstTextSpan(),
        const TextSpan(
          children: [
            TextSpan(text: 'aaa'),
            TextSpan(text: 'bbb', style: matchStyle),
          ],
        ),
      );

      await tester.tapButton();
      await tester.pump();

      expect(
        findFirstTextSpan(),
        const TextSpan(
          children: [
            TextSpan(text: 'aaa'),
            TextSpan(text: 'bbb', style: matchStyle),
          ],
        ),
      );

      completer?.complete(const [
        TextElement('ddd'),
        TextElement(
          '[eee](fff)',
          matcherType: LinkMatcher,
          groups: ['eee', 'fff'],
        ),
      ]);
      await tester.pump();

      expect(
        findFirstTextSpan(),
        const TextSpan(
          children: [
            TextSpan(text: 'ddd'),
            TextSpan(text: 'eee', style: matchStyle),
          ],
        ),
      );
    });
  });

  group('onTap and onLongPress', () {
    testWidgets('Correct info is passed to onTap callback', (tester) async {
      await tester.pumpWidget(
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(left: 10.0, top: 10.0),
          child: const CustomTextWidget(
            'aaa bbb@example.com',
            onTap: onAction,
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

      findTextSpanByText('bbb@example.com')
        ..tapDown()
        ..tapUp();
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

      final span = findTextSpanByText('bbb@example.com')..tapDown();
      await tester.pump(kTestLongPressDuration);
      span.tapUp();
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
            onLongPress: onAction,
            longPressDuration: Duration(milliseconds: 300),
          ),
        );
        await tester.pump();

        final span = findTextSpanByText('bbb@example.com')..tapDown();
        await tester.pump(const Duration(milliseconds: 310));
        span.tapUp();
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
            onGesture: onAction,
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
      expect(actionText, 'bbb@example.com');
      expect(globalPosition, center);
      expect(localPosition, center - const Offset(10.0, 10.0));

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
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
      expect(localPosition, Offset(center.dx, 9.0) - const Offset(10.0, 10.0));
    });

    testWidgets(
      'Exit and enter are not triggered by rebuild caused by tapStyle',
      (tester) async {
        const tapStyle = TextStyle(color: Color(0xFF111111));

        final events = <String>[];

        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: CustomTextWidget(
              'aaa bbb@example.com',
              tapStyle: tapStyle,
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

        expect(findTextSpanByText('bbb@example.com')?.style, tapStyle);
        expect(events, ['enter']);

        await gesture.up();
        await tester.pumpAndSettle();

        expect(findTextSpanByText('bbb@example.com')!.style, isNull);
        expect(events, ['enter', 'tap']);
      },
    );

    testWidgets(
      'Exit and enter are not triggered by rebuild by tapStyle and hoverStyle',
      (tester) async {
        const tapStyle = TextStyle(color: Color(0xFF111111));
        const hoverStyle = TextStyle(color: Color(0xFF222222));

        final events = <String>[];

        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: CustomTextWidget(
              'aaa bbb@example.com',
              tapStyle: tapStyle,
              hoverStyle: hoverStyle,
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

        expect(findTextSpanByText('bbb@example.com')?.style, hoverStyle);
        expect(events, ['enter']);

        await gesture.down(center);
        await tester.pumpAndSettle();

        expect(findTextSpanByText('bbb@example.com')?.style, tapStyle);
        expect(events, ['enter']);

        await gesture.up();
        await tester.pumpAndSettle();

        expect(findTextSpanByText('bbb@example.com')?.style, hoverStyle);
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

      expect(findTextSpanByText('aaa ')?.mouseCursor, MouseCursor.defer);
      expect(
        findTextSpanByText('bbb@example.com')?.mouseCursor,
        SystemMouseCursors.click,
      );
    });

    testWidgets('Specified mouse cursor is used', (tester) async {
      await tester.pumpWidget(
        const CustomTextWidget(
          'aaa bbb@example.com',
          mouseCursor: SystemMouseCursors.grab,
        ),
      );
      await tester.pump();

      expect(findTextSpanByText('aaa ')?.mouseCursor, MouseCursor.defer);
      expect(
        findTextSpanByText('bbb@example.com')?.mouseCursor,
        SystemMouseCursors.grab,
      );
    });

    testWidgets(
      'hoverStyle is applied to only currently hovered text span '
      'when mouse pointer is moved between spans quickly',
      (tester) async {
        const hoverStyle = TextStyle(color: Color(0xFF111111));

        await tester.pumpWidget(
          const CustomTextWidget(
            '012-3456-7890https://example.com/',
            definitions: [
              TextDefinition(matcher: TelMatcher()),
              TextDefinition(matcher: UrlMatcher()),
            ],
            hoverStyle: hoverStyle,
          ),
        );
        await tester.pump();

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        final center = tester.getCenter(find.byType(RichText).first);
        await gesture.addPointer(location: Offset(center.dx / 2, center.dy));
        await tester.pumpAndSettle();

        expect(findTextSpanByText('012-3456-7890')?.style, hoverStyle);
        expect(findTextSpanByText('https://example.com/')!.style, isNull);

        await gesture.moveTo(Offset(center.dx / 2 * 3, center.dy));
        await tester.pumpAndSettle();

        expect(findTextSpanByText('012-3456-7890')!.style, isNull);
        expect(findTextSpanByText('https://example.com/')?.style, hoverStyle);
      },
    );

    testWidgets(
      'hoverStyle is applied on hover even if onGesture is not specified',
      (tester) async {
        const hoverStyle = TextStyle(color: Color(0xFF111111));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            hoverStyle: hoverStyle,
          ),
        );
        await tester.pump();

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        await gesture.addPointer(location: Offset.zero);
        await gesture.moveTo(tester.getCenter(find.byType(RichText).first));
        await tester.pumpAndSettle();

        expect(findTextSpanByText('bbb@example.com')?.style, hoverStyle);
      },
    );

    testWidgets(
      'matchStyle is used if hoverStyle is not specified.',
      (tester) async {
        const style = TextStyle(color: Color(0xFF111111));
        const matchStyle = TextStyle(color: Color(0xFF222222));

        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: style,
            matchStyle: matchStyle,
          ),
        );
        await tester.pump();

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        await gesture.addPointer(location: Offset.zero);
        await gesture.moveTo(tester.getCenter(find.byType(RichText).first));
        await tester.pumpAndSettle();

        expect(findTextSpanByText('bbb@example.com')?.style, matchStyle);
      },
    );

    testWidgets(
      'tapStyle is used while being pressed even if hoverStyle is specified',
      (tester) async {
        const style = TextStyle(color: Color(0xFF111111));
        const tapStyle = TextStyle(color: Color(0xFF222222));
        const hoverStyle = TextStyle(color: Color(0xFF333333));

        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            style: style,
            tapStyle: tapStyle,
            hoverStyle: hoverStyle,
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

        expect(findTextSpanByText('bbb@example.com')?.style, hoverStyle);

        findTextSpanByText('bbb@example.com').tapDown();
        await tester.pumpAndSettle();

        expect(findTextSpanByText('bbb@example.com')?.style, tapStyle);
      },
    );

    testWidgets(
      'hoverStyle is used while being pressed '
      'if both style and tapStyle are not specified',
      (tester) async {
        const hoverStyle = TextStyle(color: Color(0xFF111111));

        await tester.pumpWidget(
          CustomTextWidget(
            'aaa bbb@example.com',
            hoverStyle: hoverStyle,
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

        expect(findTextSpanByText('bbb@example.com')?.style, hoverStyle);

        findTextSpanByText('bbb@example.com').tapDown();
        await tester.pumpAndSettle();

        expect(findTextSpanByText('bbb@example.com')?.style, hoverStyle);
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

      findTextSpanByText('aaa')
        ..tapDown()
        ..tapUp();
      await tester.pump();

      expect(value, 'aaa');

      await tester.tapButton();
      await tester.pumpAndSettle();

      findTextSpanByText('bbb')
        ..tapDown()
        ..tapUp();
      await tester.pump();

      expect(value, 'bbb');
    });

    testWidgets(
      'change of tapStyle specified in definition is reflected by rebuild',
      (tester) async {
        const tapStyle1 = TextStyle(color: Color(0xFF111111));
        const tapStyle2 = TextStyle(color: Color(0xFF222222));

        var currentTapStyle = tapStyle1;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (_, setState) {
              return CustomTextWidget(
                'aaa bbb@example.com',
                tapStyleInDef: currentTapStyle,
                onTapInDef: (_) {},
                onButtonPressed: () {
                  setState(() => currentTapStyle = tapStyle2);
                },
              );
            },
          ),
        );
        await tester.pump();

        await tester.tapButton();
        await tester.pumpAndSettle();

        findTextSpanByText('bbb@example.com').tapDown();
        await tester.pump();

        expect(findTextSpanByText('bbb@example.com')?.style, tapStyle2);
      },
    );

    testWidgets(
      'change of tapStyle specified in CustomText is reflected by rebuild',
      (tester) async {
        const tapStyle1 = TextStyle(color: Color(0xFF111111));
        const tapStyle2 = TextStyle(color: Color(0xFF222222));

        var currentTapStyle = tapStyle1;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (_, setState) {
              return CustomTextWidget(
                'aaa bbb@example.com',
                tapStyle: currentTapStyle,
                onTap: (_) {},
                onButtonPressed: () {
                  setState(() => currentTapStyle = tapStyle2);
                },
              );
            },
          ),
        );
        await tester.pump();

        await tester.tapButton();
        await tester.pumpAndSettle();

        findTextSpanByText('bbb@example.com').tapDown();
        await tester.pump();

        expect(findTextSpanByText('bbb@example.com')?.style, tapStyle2);
      },
    );

    testWidgets(
      'change of tap callback specified in definition is reflected by rebuild',
      (tester) async {
        void onTap2(GestureDetails details) =>
            actionText = details.actionText.toUpperCase();

        var callback = onAction;

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

        await tester.tapButton();
        await tester.pumpAndSettle();

        findTextSpanByText('bbb@example.com')
          ..tapDown()
          ..tapUp();
        await tester.pump();

        expect(actionText, 'BBB@EXAMPLE.COM');
      },
    );

    testWidgets(
      'change of tap callback specified in CustomText is reflected by rebuild',
      (tester) async {
        void onTap2(GestureDetails details) =>
            actionText = details.actionText.toUpperCase();

        var callback = onAction;

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

        await tester.tapButton();
        await tester.pumpAndSettle();

        findTextSpanByText('bbb@example.com')
          ..tapDown()
          ..tapUp();
        await tester.pump();

        expect(actionText, 'BBB@EXAMPLE.COM');
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
                onTapInDef: onAction,
                onButtonPressed: () => setState(() {
                  text = text.toUpperCase();
                }),
              );
            },
          ),
        );
        await tester.pump();

        await tester.tapButton();
        await tester.pumpAndSettle();

        findTextSpanByText('BBB@EXAMPLE.COM')
          ..tapDown()
          ..tapUp();
        await tester.pump();

        expect(actionText, 'BBB@EXAMPLE.COM');
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
                onTap: onAction,
                onButtonPressed: () => setState(() {
                  text = text.toUpperCase();
                }),
              );
            },
          ),
        );
        await tester.pump();

        await tester.tapButton();
        await tester.pumpAndSettle();

        findTextSpanByText('BBB@EXAMPLE.COM')
          ..tapDown()
          ..tapUp();
        await tester.pump();

        expect(actionText, 'BBB@EXAMPLE.COM');
      },
    );
  });

  testWidgets(
    'Change in definition (except for matcher) causes a rebuild '
    'of only relevant spans',
    (tester) async {
      var definitions = const [
        TextDefinition(
          matcher: PatternMatcher('bbb'),
          matchStyle: TextStyle(color: Color(0x11111111)),
        ),
        TextDefinition(
          matcher: PatternMatcher('ccc'),
          matchStyle: TextStyle(color: Color(0x22222222)),
        ),
      ];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (_, setState) {
            return CustomTextWidget(
              'aaabbbccc',
              definitions: definitions,
              onButtonPressed: () => setState(() {
                definitions = List.of(definitions)
                  ..[0] = const TextDefinition(
                    matcher: PatternMatcher('bbb'),
                    matchStyle: TextStyle(color: Color(0x33333333)),
                  );
              }),
            );
          },
        ),
      );
      await tester.pump();

      final spans1 = List.of(findFirstTextSpan()!.children!);

      await tester.tapButton();
      await tester.pumpAndSettle();

      final spans2 = List.of(findFirstTextSpan()!.children!);

      expect(spans1, hasLength(3));
      expect(spans2, hasLength(3));

      expect(spans2[0], same(spans1[0]));
      expect(spans2[1], isNot(same(spans1[1])));
      expect(spans2[2], same(spans1[2]));
    },
  );

  testWidgets(
    'Change of matcher causes parsing and rebuilds of all spans',
    (tester) async {
      var definitions = const [
        TextDefinition(
          matcher: PatternMatcher('bbb'),
          matchStyle: TextStyle(color: Color(0x11111111)),
        ),
      ];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (_, setState) {
            return CustomTextWidget(
              'aaabbbccc',
              definitions: definitions,
              onButtonPressed: () => setState(() {
                definitions = List.of(definitions)
                  ..[0] = const TextDefinition(
                    matcher: PatternMatcher('bb'),
                    matchStyle: TextStyle(color: Color(0x11111111)),
                  );
              }),
            );
          },
        ),
      );
      await tester.pump();

      final spans1 = List.of(findFirstTextSpan()!.children!);

      await tester.tapButton();
      await tester.pumpAndSettle();

      final spans2 = List.of(findFirstTextSpan()!.children!);

      expect(spans1, hasLength(3));
      expect(spans2, hasLength(3));

      expect(spans2[0], isNot(same(spans1[0])));
      expect(spans2[1], isNot(same(spans1[1])));
      expect(spans2[2], isNot(same(spans1[2])));
    },
  );

  testWidgets(
    'Change in number of definitions causes parsing and rebuilds of all spans',
    (tester) async {
      var definitions = const [
        TextDefinition(
          matcher: PatternMatcher('bbb'),
          matchStyle: TextStyle(color: Color(0x11111111)),
        ),
      ];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (_, setState) {
            return CustomTextWidget(
              'aaabbbccc',
              definitions: definitions,
              onButtonPressed: () => setState(() {
                definitions = List.of(definitions)
                  ..add(
                    const TextDefinition(
                      matcher: PatternMatcher('ccc'),
                      matchStyle: TextStyle(color: Color(0x22222222)),
                    ),
                  );
              }),
            );
          },
        ),
      );
      await tester.pump();

      final spans1 = List.of(findFirstTextSpan()!.children!);

      await tester.tapButton();
      await tester.pumpAndSettle();

      final spans2 = List.of(findFirstTextSpan()!.children!);

      expect(spans1, hasLength(3));
      expect(spans2, hasLength(3));

      expect(spans2[0], isNot(same(spans1[0])));
      expect(spans2[1], isNot(same(spans1[1])));
      expect(spans2[2], isNot(same(spans1[2])));
    },
  );
}
