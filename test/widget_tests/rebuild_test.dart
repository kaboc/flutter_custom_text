import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'utils.dart';
import 'widgets.dart';

void main() {
  testWidgets(
    'Changing rebuildKey causes a rebuild of only relevant spans',
    (tester) async {
      var rebuildKey = const ValueKey(1);

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (_, setState) {
            return CustomTextWidget(
              'aaabbbccc',
              definitions: [
                TextDefinition(
                  rebuildKey: rebuildKey,
                  matcher: const PatternMatcher('bbb'),
                ),
                const TextDefinition(
                  matcher: PatternMatcher('ccc'),
                ),
              ],
              onButtonPressed: () {
                setState(() => rebuildKey = const ValueKey(2));
              },
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
    'Changing rebuildKey in preBuilder causes a rebuild in CustomSpan too '
    'despite no actual change in spans built in preBuilder',
    (tester) async {
      late CustomSpanBuilder builder;
      var rebuildKey = const ValueKey(1);
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
                    definitions: const [
                      TextDefinition(matcher: PatternMatcher('')),
                    ],
                    preBuilder: builder = CustomSpanBuilder(
                      definitions: [
                        TextDefinition(
                          rebuildKey: rebuildKey,
                          matcher: const PatternMatcher('bbb'),
                        ),
                        const TextDefinition(
                          matcher: PatternMatcher('ccc'),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => rebuildKey = const ValueKey(2));
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

      final spansByBuilder1 = builder.span.children!;
      final span1 = findFirstTextSpan();

      parsedEntirely = false;
      await tester.tapButton();
      await tester.pumpAndSettle();

      final spansByBuilder2 = builder.span.children!;
      final span2 = findFirstTextSpan();

      expect(builder.parsed, isFalse);
      expect(parsedEntirely, isFalse);
      expect(builder.built, isTrue);
      expect(spansByBuilder2[0], same(spansByBuilder1[0]));
      expect(spansByBuilder2[1], isNot(same(spansByBuilder1[1])));
      expect(spansByBuilder2[2], same(spansByBuilder1[2]));
      expect(span2, isNot(same(span1)));
    },
  );

  testWidgets(
    'Reassembling app causes an entire rebuild (similarly to when rebuildKey '
    'is replaced), while rebuilding parent of CustomText does not.',
    (tester) async {
      var replace = 'BBB';

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  CustomText(
                    'aaabbb',
                    definitions: [
                      SpanDefinition(
                        matcher: const PatternMatcher('bbb'),
                        builder: (element) => TextSpan(text: replace),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => replace = 'CCC'),
                    child: const Text('Button'),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pump();
      expect(findText().textSpan?.toPlainText(), 'aaaBBB');

      await tester.tapButton();
      await tester.pumpAndSettle();
      expect(findText().textSpan?.toPlainText(), 'aaaBBB');

      unawaited(tester.binding.reassembleApplication());
      await tester.pumpAndSettle();
      expect(findText().textSpan?.toPlainText(), 'aaaCCC');
    },
  );
}
