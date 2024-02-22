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
    testWidgets('Spans are built by preBuilder', (tester) async {
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
      'Match pattern in CustomText itself is used for TextSpan built by '
      'preBuilder, not for the original text',
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
                matcher: PatternMatcher('adddc'),
                matchStyle: matchStyle1,
              ),
            ],
            preBuilder: CustomSpanBuilder(
              definitions: [
                SelectiveDefinition(
                  matcher: const PatternMatcher('bbb'),
                  shownText: (_) => 'ddd',
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
                  TextSpan(text: 'ddd', style: matchStyle2),
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
      '(cf. mouseCursor is used when CustomSpanBuilder is used independently)',
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

    // This is a test to avoid recurrence of the issue #58.
    testWidgets(
      'Text elements in previous builder are inherited to new builder '
      'when both parsing and building are skipped',
      (tester) async {
        var rebuildKey = const ValueKey(1);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    CustomText(
                      'aaabbb',
                      textDirection: TextDirection.ltr,
                      definitions: const [
                        TextDefinition(matcher: PatternMatcher('')),
                      ],
                      preBuilder: CustomSpanBuilder(
                        definitions: [
                          TextDefinition(
                            rebuildKey: rebuildKey,
                            matcher: const PatternMatcher('bbb'),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('Button'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
        await tester.pump();

        const expectedSpan = TextSpan(
          children: [
            TextSpan(
              children: [
                TextSpan(text: 'aaa'),
                TextSpan(text: 'bbb'),
              ],
            ),
          ],
        );

        expect(findFirstTextSpan(), expectedSpan);

        // Rebuilds CustomText to run the preBuilder function.
        // Configs have not changed, so preBuilder skips both
        // parsing and building.
        await tester.tapButton();
        await tester.pumpAndSettle();

        expect(findFirstTextSpan(), expectedSpan);

        // Rebuilds CustomText to run the preBuilder function.
        // This time, preBuilder skips parsing but performs building.
        rebuildKey = const ValueKey(2);
        await tester.tapButton();
        await tester.pumpAndSettle();

        // Having the same span as above indicates text elements were
        // inherited to the new builder as expected.
        expect(findFirstTextSpan(), expectedSpan);
      },
    );
  });

  group('Optimisation', () {
    testWidgets(
      'Rebuilding widget with same preBuilder config does not rebuild spans',
      (tester) async {
        late CustomSpanBuilder preBuilder;
        var isWidgetBuilt = false;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: StatefulBuilder(
              builder: (context, setState) {
                isWidgetBuilt = true;

                return Column(
                  children: [
                    CustomText(
                      'aaabbb',
                      parserOptions: externalParser,
                      definitions: const [
                        TextDefinition(matcher: PatternMatcher('')),
                      ],
                      preBuilder: preBuilder = CustomSpanBuilder(
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
                );
              },
            ),
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
        expect(preBuilder.parsed, isFalse);
        expect(isParsedEntirely, isFalse);
        expect(preBuilder.built, isFalse);
        expect(span2, same(span1));
      },
    );

    testWidgets(
      'Changing text causes parsing of text and rebuild of spans in both '
      'preBuilder and CustomText',
      (tester) async {
        late CustomSpanBuilder preBuilder;
        var text = 'aaabbb';

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    CustomText(
                      text,
                      parserOptions: externalParser,
                      definitions: const [
                        TextDefinition(matcher: PatternMatcher('')),
                      ],
                      preBuilder: preBuilder = CustomSpanBuilder(
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
                );
              },
            ),
          ),
        );
        await tester.pump();

        final span1 = findFirstTextSpan();

        isParsedEntirely = false;
        await tester.tapButton();
        await tester.pumpAndSettle();

        final span2 = findFirstTextSpan();

        expect(preBuilder.parsed, isTrue);
        expect(isParsedEntirely, isTrue);
        expect(preBuilder.built, isTrue);
        expect(span2, isNot(same(span1)));
      },
    );

    testWidgets(
      'Change of text or definition that results in same plain text '
      'causes parsing only in builder, but then also triggers CustomText '
      'to rebuild entire span',
      (tester) async {
        late CustomSpanBuilder preBuilder;
        Definition definition = const TextDefinition(
          matcher: PatternMatcher('aaa'),
        );
        var text = 'aaabbb';

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    CustomText(
                      text,
                      parserOptions: externalParser,
                      definitions: const [
                        TextDefinition(matcher: PatternMatcher('')),
                      ],
                      preBuilder: preBuilder = CustomSpanBuilder(
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
                );
              },
            ),
          ),
        );
        await tester.pump();

        final span1 = findFirstTextSpan();

        isParsedEntirely = false;
        await tester.tapButton();
        await tester.pumpAndSettle();

        final span2 = findFirstTextSpan();

        expect(preBuilder.parsed, isTrue);
        expect(isParsedEntirely, isFalse);
        expect(preBuilder.built, isTrue);
        expect(span2, isNot(same(span1)));
      },
    );

    testWidgets(
      'Change of definition causes preBuilder to rebuild only relevant '
      'spans, but then also triggers CustomText to rebuild entire span',
      (tester) async {
        late CustomSpanBuilder preBuilder;
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
          Directionality(
            textDirection: TextDirection.ltr,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
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
                      preBuilder: preBuilder = CustomSpanBuilder(
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
                );
              },
            ),
          ),
        );
        await tester.pump();

        final spansByBuilder1 = preBuilder.span.children!;
        final spans1 = findFirstTextSpan();

        parsedEntirely = false;
        await tester.tapButton();
        await tester.pumpAndSettle();

        final spansByBuilder2 = preBuilder.span.children!;
        final spans2 = findFirstTextSpan();

        expect(preBuilder.parsed, isFalse);
        expect(parsedEntirely, isFalse);
        expect(preBuilder.built, isTrue);
        expect(spansByBuilder2[0], same(spansByBuilder1[0]));
        expect(spansByBuilder2[1], isNot(same(spansByBuilder1[1])));
        expect(spansByBuilder2[2], same(spansByBuilder1[2]));
        expect(spans2, isNot(same(spans1)));
      },
    );

    testWidgets(
      'Change of callbacks do not cause parsing of text nor rebuild of spans',
      (tester) async {
        late CustomSpanBuilder preBuilder;
        var shownText = (_) => '111';

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    CustomText(
                      'aaabbb',
                      parserOptions: externalParser,
                      definitions: const [
                        TextDefinition(matcher: PatternMatcher('')),
                      ],
                      preBuilder: preBuilder = CustomSpanBuilder(
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
                );
              },
            ),
          ),
        );
        await tester.pump();

        final span1 = findFirstTextSpan();

        isParsedEntirely = false;
        await tester.tapButton();
        await tester.pumpAndSettle();

        final span2 = findFirstTextSpan();

        expect(preBuilder.parsed, isFalse);
        expect(isParsedEntirely, isFalse);
        expect(preBuilder.built, isFalse);
        expect(span2, same(span1));
      },
    );
  });
}
