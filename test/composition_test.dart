import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';
import 'widgets.dart';

void main() {
  setUp(() {
    isTap = isLongTap = false;
    matcherType = tappedText = null;
  });

  group('Compositions', () {
    testWidgets(
      'CustomText with TextDefinitions composes correct spans',
      (tester) async {
        const text = 'aaa bbb@example.com https://example.com/';

        await tester.pumpWidget(const CustomTextWidget(text));
        await tester.pump();

        final spans = getSpans();
        expect(spans.length, equals(4));
        expect((spans[0] as TextSpan).text, equals('aaa '));
        expect((spans[1] as TextSpan).text, equals('bbb@example.com'));
        expect((spans[2] as TextSpan).text, equals(' '));
        expect((spans[3] as TextSpan).text, equals('https://example.com/'));
      },
    );

    testWidgets(
      'CustomText with SelectiveDefinition composes correct spans',
      (tester) async {
        await tester
            .pumpWidget(const SelectiveCustomTextWidget('aaa[bbb](ccc)ddd'));
        await tester.pump();

        final spans = getSpans();
        expect(spans.length, equals(3));
        expect((spans[0] as TextSpan).text, equals('aaa'));
        expect((spans[1] as TextSpan).text, equals('bbb'));
        expect((spans[2] as TextSpan).text, equals('ddd'));
      },
    );

    testWidgets(
      'CustomText with SpanDefinition composes correct spans',
      (tester) async {
        await tester.pumpWidget(const SpanCustomTextWidget1(
          'Email: foo@example.com, Tel: 012-3456-7890',
        ));
        await tester.pump();

        final spans = getSpans();
        expect(spans.length, equals(5));
        expect((spans[0] as TextSpan).text, equals('Email: '));
        expect(spans[1], equals(isA<WidgetSpan>()));
        expect((spans[2] as TextSpan).text, equals('foo@example.com'));
        expect((spans[3] as TextSpan).text, equals(', Tel: '));
        expect((spans[4] as TextSpan).text, equals('012-3456-7890'));
      },
    );
  });
}
