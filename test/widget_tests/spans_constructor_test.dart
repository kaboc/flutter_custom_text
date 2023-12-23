import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'utils.dart';

void main() {
  setUp(reset);

  group('InlineSpans are split to match TextElements', () {
    testWidgets(
      'Spans are split so that each of resulting spans corresponds '
      'to a TextElement',
      (tester) async {
        const spans = [
          TextSpan(
            text: 'aaa ',
            style: TextStyle(decoration: TextDecoration.underline),
            children: [
              TextSpan(text: 'bbb@example.com'),
              TextSpan(text: ' '),
            ],
          ),
          TextSpan(text: 'https://example.com/'),
        ];

        await tester.pumpWidget(
          const CustomText.spans(
            spans: spans,
            textDirection: TextDirection.ltr,
            definitions: [
              TextDefinition(
                matcher: UrlMatcher(),
                matchStyle: TextStyle(color: Color(0x22222222)),
              ),
              TextDefinition(
                matcher: EmailMatcher(),
                matchStyle: TextStyle(color: Color(0x33333333)),
              ),
            ],
            style: TextStyle(color: Color(0x11111111)),
          ),
        );
        await tester.pump();

        expect(
          findFirstTextSpan(),
          const TextSpan(
            children: [
              TextSpan(
                style: TextStyle(color: Color(0x11111111)),
                children: [
                  TextSpan(
                    text: 'aaa ',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ],
              ),
              TextSpan(
                style: TextStyle(color: Color(0x33333333)),
                children: [
                  TextSpan(
                    style: TextStyle(decoration: TextDecoration.underline),
                    children: [TextSpan(text: 'bbb@example.com')],
                  ),
                ],
              ),
              TextSpan(
                style: TextStyle(color: Color(0x11111111)),
                children: [
                  TextSpan(
                    style: TextStyle(decoration: TextDecoration.underline),
                    children: [TextSpan(text: ' ')],
                  ),
                ],
              ),
              TextSpan(
                style: TextStyle(color: Color(0x22222222)),
                children: [
                  TextSpan(text: 'https://example.com/'),
                ],
              ),
            ],
          ),
        );
      },
    );

    testWidgets(
      'Spans are split correctly even if pattern matches text '
      'ranging over several spans',
      (tester) async {
        const spans = [
          TextSpan(
            text: 'aaa bbb',
            style: TextStyle(decoration: TextDecoration.underline),
            children: [
              TextSpan(text: '@example.'),
            ],
          ),
          TextSpan(text: 'com https://example.com/'),
        ];

        await tester.pumpWidget(
          const CustomText.spans(
            spans: spans,
            textDirection: TextDirection.ltr,
            definitions: [
              TextDefinition(
                matcher: UrlMatcher(),
                matchStyle: TextStyle(color: Color(0x22222222)),
              ),
              TextDefinition(
                matcher: EmailMatcher(),
                matchStyle: TextStyle(color: Color(0x33333333)),
              ),
            ],
            style: TextStyle(color: Color(0x11111111)),
          ),
        );
        await tester.pump();

        expect(
          findFirstTextSpan(),
          const TextSpan(
            children: [
              TextSpan(
                style: TextStyle(color: Color(0x11111111)),
                children: [
                  TextSpan(
                    text: 'aaa ',
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ],
              ),
              TextSpan(
                style: TextStyle(color: Color(0x33333333)),
                children: [
                  TextSpan(
                    text: 'bbb',
                    style: TextStyle(decoration: TextDecoration.underline),
                    children: [TextSpan(text: '@example.')],
                  ),
                  TextSpan(text: 'com'),
                ],
              ),
              TextSpan(
                style: TextStyle(color: Color(0x11111111)),
                children: [
                  TextSpan(text: ' '),
                ],
              ),
              TextSpan(
                style: TextStyle(color: Color(0x22222222)),
                children: [
                  TextSpan(text: 'https://example.com/'),
                ],
              ),
            ],
          ),
        );
      },
    );
  });

  group('Tap/gesture callbacks', () {
    testWidgets(
      'GestureRecognizer is applied to descendants (except for those '
      'without text) if a tap callback is specified',
      (tester) async {
        const spans = [
          TextSpan(
            text: 'aaa bbb',
            children: [
              TextSpan(
                children: [
                  TextSpan(text: '@example.com'),
                ],
              ),
            ],
          ),
        ];

        await tester.pumpWidget(
          const CustomText.spans(
            spans: spans,
            textDirection: TextDirection.ltr,
            definitions: [
              TextDefinition(
                matcher: EmailMatcher(),
                onTap: onAction,
              ),
            ],
          ),
        );
        await tester.pump();

        final bbbSpan = findTextSpanByText('bbb')!;
        final recognizer = bbbSpan.recognizer;
        expect(recognizer, isNotNull);

        expect(
          findFirstTextSpan(),
          TextSpan(
            children: [
              const TextSpan(
                children: [
                  TextSpan(text: 'aaa '),
                ],
              ),
              TextSpan(
                children: [
                  TextSpan(
                    text: 'bbb',
                    recognizer: recognizer,
                    mouseCursor: SystemMouseCursors.click,
                    children: [
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '@example.com',
                            recognizer: recognizer,
                            mouseCursor: SystemMouseCursors.click,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    testWidgets(
      'GestureRecognizer, onEnter and onExit are applied to descendants '
      '(except for those without text) if a gesture callback is specified',
      (tester) async {
        const spans = [
          TextSpan(
            text: 'aaa bbb',
            children: [
              TextSpan(
                children: [
                  TextSpan(text: '@example.com'),
                ],
              ),
            ],
          ),
        ];

        await tester.pumpWidget(
          const CustomText.spans(
            spans: spans,
            textDirection: TextDirection.ltr,
            definitions: [
              TextDefinition(
                matcher: EmailMatcher(),
                onGesture: onAction,
              ),
            ],
          ),
        );
        await tester.pump();

        final bbbSpan = findTextSpanByText('bbb')!;
        final recognizer = bbbSpan.recognizer;
        final onEnter = bbbSpan.onEnter;
        final onExit = bbbSpan.onExit;
        expect(recognizer, isNotNull);
        expect(onEnter, isNotNull);
        expect(onExit, isNotNull);

        expect(
          findFirstTextSpan(),
          TextSpan(
            children: [
              const TextSpan(
                children: [
                  TextSpan(text: 'aaa '),
                ],
              ),
              TextSpan(
                children: [
                  TextSpan(
                    text: 'bbb',
                    recognizer: recognizer,
                    onEnter: onEnter,
                    onExit: onExit,
                    mouseCursor: SystemMouseCursors.click,
                    children: [
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '@example.com',
                            recognizer: recognizer,
                            onEnter: onEnter,
                            onExit: onExit,
                            mouseCursor: SystemMouseCursors.click,
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  });

  group('hoverStyle and mouseCursor', () {
    testWidgets(
      'TextSpan is styled on hover and its children (except for those w/o '
      'text) get onError and onExit callbacks if hoverStyle is specified',
      (tester) async {
        const hoverStyle = TextStyle(color: Color(0x11111111));

        const spans = [
          TextSpan(
            text: 'aaa bbb',
            children: [
              TextSpan(
                children: [
                  TextSpan(text: '@example.com'),
                ],
              ),
            ],
          ),
        ];

        await tester.pumpWidget(
          const Align(
            alignment: Alignment.topLeft,
            child: CustomText.spans(
              spans: spans,
              textDirection: TextDirection.ltr,
              definitions: [
                TextDefinition(
                  matcher: EmailMatcher(),
                  hoverStyle: hoverStyle,
                ),
              ],
            ),
          ),
        );
        await tester.pump();

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        final center = tester.getCenter(find.byType(RichText).first);
        await gesture.addPointer(location: center);
        await tester.pumpAndSettle();

        final bbbSpan = findTextSpanByText('bbb')!;
        final onEnter = bbbSpan.onEnter;
        final onExit = bbbSpan.onExit;
        expect(onEnter, isNotNull);
        expect(onExit, isNotNull);

        expect(
          findFirstTextSpan(),
          TextSpan(
            children: [
              const TextSpan(
                children: [
                  TextSpan(text: 'aaa '),
                ],
              ),
              TextSpan(
                style: hoverStyle,
                children: [
                  TextSpan(
                    text: 'bbb',
                    onEnter: onEnter,
                    onExit: onExit,
                    children: [
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '@example.com',
                            onEnter: onEnter,
                            onExit: onExit,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    testWidgets(
      'Mouse cursor type is applied to descendants (except for those '
      'without text) if mouseCursor is specified',
      (tester) async {
        const spans = [
          TextSpan(
            text: 'aaa bbb',
            children: [
              TextSpan(
                children: [
                  TextSpan(text: '@example.com'),
                ],
              ),
            ],
          ),
        ];

        await tester.pumpWidget(
          const CustomText.spans(
            spans: spans,
            textDirection: TextDirection.ltr,
            definitions: [
              TextDefinition(
                matcher: EmailMatcher(),
                mouseCursor: SystemMouseCursors.help,
              ),
            ],
          ),
        );
        await tester.pump();

        expect(
          findFirstTextSpan(),
          const TextSpan(
            children: [
              TextSpan(
                children: [
                  TextSpan(text: 'aaa '),
                ],
              ),
              TextSpan(
                children: [
                  TextSpan(
                    text: 'bbb',
                    mouseCursor: SystemMouseCursors.help,
                    children: [
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '@example.com',
                            mouseCursor: SystemMouseCursors.help,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  });

  group('WidgetSpan', () {
    testWidgets(
      'placeholderCodeUnit (0xFFFC) in pattern matches WidgetSpan',
      (tester) async {
        const spans = [
          TextSpan(text: 'aaabbb'),
          WidgetSpan(child: Text('ccc')),
          TextSpan(text: 'dddeee'),
        ];

        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: CustomText.spans(
              spans: spans,
              definitions: [
                TextDefinition(
                  matcher: PatternMatcher('bbb\uFFFCddd'),
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
              const TextSpan(
                children: [
                  TextSpan(text: 'aaa'),
                ],
              ),
              TextSpan(
                children: [
                  const TextSpan(text: 'bbb'),
                  builtSpan.findWidgetSpans().first,
                  const TextSpan(text: 'ddd'),
                ],
              ),
              const TextSpan(
                children: [
                  TextSpan(text: 'eee'),
                ],
              ),
            ],
          ),
        );
      },
    );

    testWidgets(
      'Text style is provided to WidgetSpan too, whether matched '
      'or not matched by pattern',
      (tester) async {
        const style = TextStyle(color: Color(0x11111111));
        const matchStyle = TextStyle(color: Color(0x22222222));
        TextStyle? childStyle1;
        TextStyle? childStyle2;

        final spans = [
          const TextSpan(text: 'aaa'),
          WidgetSpan(
            child: Builder(
              builder: (context) {
                childStyle1 = DefaultTextStyle.of(context).style;
                return const Text('bbb');
              },
            ),
          ),
          const TextSpan(text: 'ccc'),
          WidgetSpan(
            child: Builder(
              builder: (context) {
                childStyle2 = DefaultTextStyle.of(context).style;
                return const Text('ddd');
              },
            ),
          ),
        ];

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomText.spans(
              spans: spans,
              definitions: const [
                TextDefinition(matcher: PatternMatcher('ccc\uFFFC')),
              ],
              style: style,
              matchStyle: matchStyle,
            ),
          ),
        );
        await tester.pump();

        expect(childStyle1, style);
        expect(childStyle2, matchStyle);
      },
    );

    testWidgets(
      'Changes of text style are quickly applied to child of WidgetSpan',
      (tester) async {
        const style = TextStyle(color: Color(0x11111111));
        const matchStyle = TextStyle(color: Color(0x22222222));
        const hoverStyle = TextStyle(color: Color(0x33333333));
        TextStyle? childStyle;

        final spans = [
          const TextSpan(text: 'aaa'),
          WidgetSpan(
            child: Builder(
              builder: (context) {
                childStyle = DefaultTextStyle.of(context).style;
                return const Text('bbb');
              },
            ),
          ),
          const TextSpan(text: 'ccc'),
        ];

        await tester.pumpWidget(
          Align(
            alignment: Alignment.centerLeft,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: CustomText.spans(
                spans: spans,
                definitions: const [
                  TextDefinition(matcher: PatternMatcher('\uFFFC')),
                ],
                style: style,
                matchStyle: matchStyle,
                hoverStyle: hoverStyle,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(childStyle, matchStyle);

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        addTearDown(gesture.removePointer);

        final center = tester.getCenter(find.byType(RichText).first);
        await gesture.addPointer(location: center);
        await tester.pumpAndSettle();

        expect(childStyle, hoverStyle);
      },
    );

    testWidgets(
      'Both TextSpan and WidgetSpan are tappable if pattern matches '
      'the range covering the two and tap callback has been provided',
      (tester) async {
        var count = 0;

        const spans = [
          TextSpan(text: 'aaa'),
          WidgetSpan(child: SizedBox.square(dimension: 30.0)),
          TextSpan(text: 'ccc'),
        ];

        await tester.pumpWidget(
          Align(
            alignment: Alignment.centerLeft,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: CustomText.spans(
                spans: spans,
                definitions: [
                  TextDefinition(
                    matcher: const PatternMatcher('\uFFFCccc'),
                    onTap: (details) => count++,
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump();

        expect(count, 0);

        final rect = tester.getRect(find.byType(RichText).first);

        final centerLeft = rect.centerLeft;
        await tester.tapAt(Offset(centerLeft.dx + 10.0, centerLeft.dy));
        expect(count, 0);

        await tester.tapAt(rect.center);
        expect(count, 1);

        final centerRight = rect.centerRight;
        await tester.tapAt(Offset(centerRight.dx - 10.0, centerRight.dy));
        expect(count, 2);
      },
    );
  });

  group('ParserOptions.external', () {
    testWidgets(
      'ParserOptions.external works fine with CustomText.spans',
      (tester) async {
        const style = TextStyle(color: Color(0x11111111));
        const matchStyle = TextStyle(color: Color(0x22222222));
        String? parserText;

        const spans = [
          TextSpan(text: 'aaabbb'),
          WidgetSpan(child: Text('ccc')),
          TextSpan(text: 'dddeee'),
        ];

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomText.spans(
              spans: spans,
              parserOptions: ParserOptions.external((text) async {
                parserText = text;
                return const [
                  TextElement('aaa'),
                  TextElement('bbb\uFFFCddd', matcherType: PatternMatcher),
                  TextElement('eee'),
                ];
              }),
              definitions: const [
                TextDefinition(
                  matcher: PatternMatcher('dummy'),
                  matchStyle: matchStyle,
                ),
              ],
              style: style,
            ),
          ),
        );
        await tester.pump();

        expect(parserText, 'aaabbb\uFFFCdddeee');

        final builtSpan = findFirstTextSpan();

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
                style: matchStyle,
                children: [
                  const TextSpan(text: 'bbb'),
                  builtSpan.findWidgetSpans().first,
                  const TextSpan(text: 'ddd'),
                ],
              ),
              const TextSpan(
                style: style,
                children: [
                  TextSpan(text: 'eee'),
                ],
              ),
            ],
          ),
        );
      },
    );
  });
}
