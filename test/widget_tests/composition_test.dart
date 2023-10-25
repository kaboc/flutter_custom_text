import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'widget_utils.dart';
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

        final spans = getSpans();
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
        await tester
            .pumpWidget(const SelectiveCustomTextWidget('aaa[bbb](ccc)ddd'));
        await tester.pump();

        final spans = getSpans();
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
          const SpanCustomTextWidget1(
            'Email: foo@example.com, Tel: 012-3456-7890',
          ),
        );
        await tester.pump();

        final spans = getSpans();
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
        await tester.pumpWidget(
          const CustomTextWidget(
            'Pattern 2 Pattern 3 foo@example.com Pattern 1',
            definitions: [
              TextDefinition(
                matcher: EmailMatcher(),
                matchStyle: TextStyle(color: Color(0xFF111111)),
              ),
              TextDefinition(
                matcher: PatternMatcher('Pattern 1'),
                matchStyle: TextStyle(color: Color(0xFF222222)),
              ),
              TextDefinition(
                matcher: PatternMatcher('Pattern 2'),
                matchStyle: TextStyle(color: Color(0xFF333333)),
              ),
            ],
          ),
        );
        await tester.pump();

        final spans = getSpans();
        expect(spans, hasLength(5));
        expect(spans[0].toPlainText(), 'Pattern 2');
        expect(spans[0].style?.color, const Color(0xFF333333));
        expect(spans[2].toPlainText(), 'foo@example.com');
        expect(spans[2].style?.color, const Color(0xFF111111));
        expect(spans[4].toPlainText(), 'Pattern 1');
        expect(spans[4].style?.color, const Color(0xFF222222));
      },
    );
  });
}
