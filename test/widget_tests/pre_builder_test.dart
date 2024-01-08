import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'utils.dart';

void main() {
  var isParsedEntirely = false;

  final externalParser = ParserOptions.external((text) async {
    isParsedEntirely = true;
    return const [
      TextElement('aaa', matcherType: PatternMatcher),
      TextElement('bbb'),
    ];
  });

  tearDown(() => isParsedEntirely = false);

  group('Composition', () {
    testWidgets('Spans are built by builder', (tester) async {
      const style = TextStyle(color: Color(0x11111111));
      const matchStyle = TextStyle(color: Color(0x22222222));

      await tester.pumpWidget(
        CustomText(
          'aaabbbccc',
          textDirection: TextDirection.ltr,
          definitions: const [
            TextDefinition(matcher: PatternMatcher('')),
          ],
          preBuilder: CustomSpanBuilder(
            definitions: const [
              TextDefinition(
                matcher: PatternMatcher('bbb'),
                matchStyle: matchStyle,
              ),
            ],
            style: style,
          ),
        ),
      );
      await tester.pump();

      expect(
        findFirstTextSpan(),
        const TextSpan(
          children: [
            TextSpan(
              children: [
                TextSpan(text: 'aaa', style: style),
                TextSpan(text: 'bbb', style: matchStyle),
                TextSpan(text: 'ccc', style: style),
              ],
            ),
          ],
        ),
      );
    });

    testWidgets(
      'CustomText parses children of TextSpan built by builder',
      (tester) async {
        const style = TextStyle(color: Color(0x11111111));
        const matchStyle1 = TextStyle(decoration: TextDecoration.underline);
        const matchStyle2 = TextStyle(color: Color(0x22222222));

        await tester.pumpWidget(
          CustomText(
            'aaabbbccc',
            textDirection: TextDirection.ltr,
            definitions: const [
              TextDefinition(
                matcher: PatternMatcher('abbbc'),
                matchStyle: matchStyle1,
              ),
            ],
            preBuilder: CustomSpanBuilder(
              definitions: const [
                TextDefinition(
                  matcher: PatternMatcher('bbb'),
                  matchStyle: matchStyle2,
                ),
              ],
              style: style,
            ),
          ),
        );
        await tester.pump();

        expect(
          findFirstTextSpan(),
          const TextSpan(
            children: [
              TextSpan(
                children: [
                  TextSpan(text: 'aa', style: style),
                ],
              ),
              TextSpan(
                style: matchStyle1,
                children: [
                  TextSpan(text: 'a', style: style),
                  TextSpan(text: 'bbb', style: matchStyle2),
                  TextSpan(text: 'c', style: style),
                ],
              ),
              TextSpan(
                children: [
                  TextSpan(text: 'cc', style: style),
                ],
              ),
            ],
          ),
        );
      },
    );

    testWidgets(
      'Arguments other than style and matchStyle in definition are ignored '
      '(cf. mouseCursor is used when builder is used independently)',
      (tester) async {
        const style = TextStyle(color: Color(0x11111111));
        const matchStyle = TextStyle(color: Color(0x22222222));
        const tapStyle = TextStyle(color: Color(0x33333333));
        const hoverStyle = TextStyle(color: Color(0x44444444));

        await tester.pumpWidget(
          CustomText(
            'aaabbbccc',
            textDirection: TextDirection.ltr,
            definitions: const [
              TextDefinition(matcher: PatternMatcher('')),
            ],
            preBuilder: CustomSpanBuilder(
              definitions: [
                TextDefinition(
                  matcher: const PatternMatcher('bbb'),
                  matchStyle: matchStyle,
                  mouseCursor: SystemMouseCursors.help,
                  tapStyle: tapStyle,
                  hoverStyle: hoverStyle,
                  onTap: (_) {},
                  onLongPress: (_) {},
                  onGesture: (_) {},
                ),
              ],
              style: style,
            ),
          ),
        );
        await tester.pump();

        expect(
          findFirstTextSpan(),
          const TextSpan(
            children: [
              TextSpan(
                children: [
                  TextSpan(text: 'aaa', style: style),
                  TextSpan(text: 'bbb', style: matchStyle),
                  TextSpan(text: 'ccc', style: style),
                ],
              ),
            ],
          ),
        );
      },
    );
  });

  group('Optimisation', () {
    testWidgets(
      'Rebuilding widget with same builder config does not rebuild spans',
      (tester) async {
        late CustomSpanBuilder builder;
        var isWidgetBuilt = false;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              isWidgetBuilt = true;

              return Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  children: [
                    CustomText(
                      'aaabbb',
                      parserOptions: externalParser,
                      definitions: const [
                        TextDefinition(matcher: PatternMatcher('')),
                      ],
                      preBuilder: builder = CustomSpanBuilder(
                        definitions: const [
                          TextDefinition(matcher: PatternMatcher('aaa')),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Button'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
        await tester.pump();

        final span1 = findFirstTextSpan();

        isWidgetBuilt = false;
        isParsedEntirely = false;
        await tester.tapButton();
        await tester.pumpAndSettle();

        final span2 = findFirstTextSpan();
        expect(isWidgetBuilt, isTrue);
        expect(builder.parsed, isFalse);
        expect(isParsedEntirely, isFalse);
        expect(builder.built, isFalse);
        expect(span2, same(span1));
      },
    );

    testWidgets(
      'Changing text causes parsing of text and rebuild of spans in both '
      'builder and CustomText',
      (tester) async {
        late CustomSpanBuilder builder;
        var text = 'aaabbb';

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  children: [
                    CustomText(
                      text,
                      parserOptions: externalParser,
                      definitions: const [
                        TextDefinition(matcher: PatternMatcher('')),
                      ],
                      preBuilder: builder = CustomSpanBuilder(
                        definitions: const [
                          TextDefinition(matcher: PatternMatcher('aaa')),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => text = 'aaaccc'),
                      child: const Text('Button'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
        await tester.pump();

        final span1 = findFirstTextSpan();

        isParsedEntirely = false;
        await tester.tapButton();
        await tester.pumpAndSettle();

        final span2 = findFirstTextSpan();
        expect(builder.parsed, isTrue);
        expect(isParsedEntirely, isTrue);
        expect(builder.built, isTrue);
        expect(span2, isNot(same(span1)));
      },
    );

    testWidgets(
      'Change of text or definition that results in same plain text '
      'causes parsing and rebuilding only in builder',
      (tester) async {
        late CustomSpanBuilder builder;
        Definition definition = const TextDefinition(
          matcher: PatternMatcher('aaa'),
        );
        var text = 'aaabbb';

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  children: [
                    CustomText(
                      text,
                      parserOptions: externalParser,
                      definitions: const [
                        TextDefinition(matcher: PatternMatcher('')),
                      ],
                      preBuilder: builder = CustomSpanBuilder(
                        definitions: [definition],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          text = '[aaa]()bbb';
                          definition = SelectiveDefinition(
                            matcher: const LinkMatcher(),
                            shownText: (_) => 'aaa',
                          );
                        });
                      },
                      child: const Text('Button'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
        await tester.pump();

        final span1 = findFirstTextSpan();

        isParsedEntirely = false;
        await tester.tapButton();
        await tester.pumpAndSettle();

        final span2 = findFirstTextSpan();
        expect(builder.parsed, isTrue);
        expect(isParsedEntirely, isFalse);
        expect(builder.built, isTrue);
        expect(span2, same(span1));
      },
    );

    testWidgets(
      'Change of particular definition causes builder to rebuild only '
      'relevant spans, but then triggers CustomText to rebuild entire spans',
      (tester) async {
        late CustomSpanBuilder builder;
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
        var parsedEntirely = false;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  children: [
                    CustomText(
                      'aaabbbccc',
                      parserOptions: ParserOptions.external((text) async {
                        parsedEntirely = true;
                        return const [
                          TextElement('aaa'),
                          TextElement(
                            'bbb',
                            matcherType: PatternMatcher,
                            matcherIndex: 1,
                          ),
                          TextElement(
                            'ccc',
                            matcherType: PatternMatcher,
                            matcherIndex: 2,
                          ),
                        ];
                      }),
                      definitions: const [
                        TextDefinition(matcher: PatternMatcher('')),
                      ],
                      preBuilder: builder = CustomSpanBuilder(
                        definitions: definitions,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          definitions = List.of(definitions)
                            ..[0] = const TextDefinition(
                              matcher: PatternMatcher('bbb'),
                              matchStyle: TextStyle(color: Color(0x33333333)),
                            );
                        });
                      },
                      child: const Text('Button'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
        await tester.pump();

        final spansByBuilder1 = builder.span.children!;
        final span1a = findTextSpanByText('aaa');
        final span1b = findTextSpanByText('bbb');
        final span1c = findTextSpanByText('ccc');

        parsedEntirely = false;
        await tester.tapButton();
        await tester.pumpAndSettle();

        final spansByBuilder2 = builder.span.children!;
        final span2a = findTextSpanByText('aaa');
        final span2b = findTextSpanByText('bbb');
        final span2c = findTextSpanByText('ccc');
        expect(builder.parsed, isFalse);
        expect(parsedEntirely, isFalse);
        expect(builder.built, isTrue);
        expect(spansByBuilder2[0], same(spansByBuilder1[0]));
        expect(spansByBuilder2[1], isNot(same(spansByBuilder1[1])));
        expect(spansByBuilder2[2], same(spansByBuilder1[2]));
        expect(span2a, isNot(same(span1a)));
        expect(span2b, isNot(same(span1b)));
        expect(span2c, isNot(same(span1c)));
      },
    );

    testWidgets(
      'Change of callbacks do not cause parsing of text nor rebuild of spans',
      (tester) async {
        late CustomSpanBuilder builder;
        var shownText = (_) => '111';

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  children: [
                    CustomText(
                      'aaabbb',
                      parserOptions: externalParser,
                      definitions: const [
                        TextDefinition(matcher: PatternMatcher('')),
                      ],
                      preBuilder: builder = CustomSpanBuilder(
                        definitions: [
                          SelectiveDefinition(
                            matcher: const PatternMatcher('aaa'),
                            shownText: shownText,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => shownText = (_) => '222');
                      },
                      child: const Text('Button'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
        await tester.pump();

        final span1 = findFirstTextSpan();

        isParsedEntirely = false;
        await tester.tapButton();
        await tester.pumpAndSettle();

        final span2 = findFirstTextSpan();
        expect(builder.parsed, isFalse);
        expect(isParsedEntirely, isFalse);
        expect(builder.built, isFalse);
        expect(span2, same(span1));
      },
    );
  });
}
