import 'dart:async' show Completer;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'utils.dart';
import 'widgets.dart';

void main() {
  setUp(reset);

  group('Compositions', () {
    testWidgets(
      'CustomText with TextDefinitions composes correct spans',
      (tester) async {
        const text = 'aaa bbb@example.com https://example.com/';

        await tester.pumpWidget(const CustomTextWidget(text));
        await tester.pump();

        final spans = findInlineSpans();
        expect(spans, hasLength(4));
        expect(spans[0].toPlainText(), 'aaa ');
        expect(spans[1].toPlainText(), 'bbb@example.com');
        expect(spans[2].toPlainText(), ' ');
        expect(spans[3].toPlainText(), 'https://example.com/');
      },
    );

    testWidgets(
      'CustomText with SelectiveDefinition composes correct spans',
      (tester) async {
        await tester.pumpWidget(
          CustomText(
            'aaa[bbb](ccc)ddd',
            textDirection: TextDirection.ltr,
            definitions: [
              SelectiveDefinition(
                matcher: const LinkMatcher(),
                shownText: (groups) => groups[0]!,
                actionText: (groups) => groups[1]!,
              ),
            ],
          ),
        );
        await tester.pump();

        final spans = findInlineSpans();
        expect(spans, hasLength(3));
        expect(spans[0].toPlainText(), 'aaa');
        expect(spans[1].toPlainText(), 'bbb');
        expect(spans[2].toPlainText(), 'ddd');
      },
    );

    testWidgets(
      'CustomText with SpanDefinition composes correct spans',
      (tester) async {
        await tester.pumpWidget(
          CustomText(
            'Email: foo@example.com, Tel: 012-3456-7890',
            textDirection: TextDirection.ltr,
            definitions: [
              const TextDefinition(
                matcher: TelMatcher(),
              ),
              SpanDefinition(
                matcher: const EmailMatcher(),
                builder: (text, groups) => TextSpan(
                  children: [
                    const WidgetSpan(
                      child: SizedBox.square(dimension: 18.0),
                      alignment: PlaceholderAlignment.middle,
                    ),
                    TextSpan(text: text),
                  ],
                ),
              ),
            ],
          ),
        );
        await tester.pump();

        final spans = findInlineSpans();
        expect(spans, hasLength(5));
        expect(spans[0].toPlainText(), 'Email: ');
        expect(spans[1], isA<WidgetSpan>());
        expect(spans[2].toPlainText(), 'foo@example.com');
        expect(spans[3].toPlainText(), ', Tel: ');
        expect(spans[4].toPlainText(), '012-3456-7890');
      },
    );

    testWidgets(
      "Multiple definitions with matcher of same type don't get mixed up",
      (tester) async {
        const matchStyle1 = TextStyle(color: Color(0xFF111111));
        const matchStyle2 = TextStyle(color: Color(0xFF222222));
        const matchStyle3 = TextStyle(color: Color(0xFF333333));

        await tester.pumpWidget(
          const CustomTextWidget(
            'Pattern 2 Pattern 3 foo@example.com Pattern 1',
            definitions: [
              TextDefinition(
                matcher: EmailMatcher(),
                matchStyle: matchStyle1,
              ),
              TextDefinition(
                matcher: PatternMatcher('Pattern 1'),
                matchStyle: matchStyle2,
              ),
              TextDefinition(
                matcher: PatternMatcher('Pattern 2'),
                matchStyle: matchStyle3,
              ),
            ],
          ),
        );
        await tester.pump();

        final spans = findInlineSpans();
        expect(spans, hasLength(5));
        expect(spans[0].toPlainText(), 'Pattern 2');
        expect(spans[0].style, matchStyle3);
        expect(spans[2].toPlainText(), 'foo@example.com');
        expect(spans[2].style, matchStyle1);
        expect(spans[4].toPlainText(), 'Pattern 1');
        expect(spans[4].style, matchStyle2);
      },
    );

    testWidgets(
      'A call to didUpdateWidget() during initial parsing does not '
      'cause an empty span to be built by having no element yet',
      (tester) async {
        final completer = Completer<List<TextElement>>();
        var matchStyle = const TextStyle(color: Color(0x11111111));

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return CustomTextWidget(
                'abc',
                parserOptions: ParserOptions.external(
                  (text) => completer.future,
                ),
                definitions: const [
                  TextDefinition(matcher: PatternMatcher('dummy')),
                ],
                matchStyle: matchStyle,
                onButtonPressed: () => setState(() {
                  matchStyle = const TextStyle(color: Color(0x22222222));
                }),
              );
            },
          ),
        );
        await tester.pump();

        expect(findInlineSpans(), const [TextSpan(text: 'abc')]);

        await tester.tapButton();
        await tester.pump();

        expect(findInlineSpans(), const [TextSpan(text: 'abc')]);
      },
    );
  });
}
