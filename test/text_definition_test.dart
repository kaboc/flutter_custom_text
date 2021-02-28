import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';
import 'widgets.dart';

void main() {
  setUp(() {
    isTap = isLongTap = false;
    matcherType = tappedText = null;
  });

  group('Styles for TextDefinition', () {
    testWidgets(
      'matchStyle specified in definition is used even if without onTap',
      (tester) async {
        await tester.pumpWidget(const CustomTextWidget(
          'aaa bbb@example.com',
          style: TextStyle(color: Color(0xFF111111)),
          matchStyleInDef: TextStyle(color: Color(0xFF222222)),
        ));
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2 = findSpan('bbb@example.com');
        expect(span1.style.color, const Color(0xFF111111));
        expect(span2.style.color, const Color(0xFF222222));
      },
    );

    testWidgets(
      'matchStyle specified in definition is only applied to relevant element',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com https://example.com/',
            style: TextStyle(color: Color(0xFF111111)),
            matchStyleInDef: TextStyle(color: Color(0xFF222222)),
          ),
        );
        await tester.pump();

        final span1 = findSpan('bbb@example.com');
        final span2 = findSpan('https://example.com/');
        expect(span1.style.color, const Color(0xFF222222));
        expect(span2.style.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'matchStyle specified in definition takes priority',
      (tester) async {
        await tester.pumpWidget(const CustomTextWidget(
          'aaa bbb@example.com',
          matchStyle: TextStyle(color: Color(0xFF111111)),
          matchStyleInDef: TextStyle(color: Color(0xFF222222)),
        ));
        await tester.pump();

        final span = findSpan('bbb@example.com');
        expect(span.style.color, const Color(0xFF222222));
      },
    );

    testWidgets(
      'tapStyle specified in definition is not applied if tap callbacks are not set',
      (tester) async {
        await tester.pumpWidget(const CustomTextWidget(
          'aaa bbb@example.com',
          style: TextStyle(color: Color(0xFF111111)),
          tapStyleInDef: TextStyle(color: Color(0xFF222222)),
        ));
        await tester.pump();

        final spanA = findSpan('bbb@example.com');
        tapDownSpan(spanA);
        await tester.pump();

        final spanB = findSpan('bbb@example.com');
        expect(spanB.style.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'tapStyle specified in definition is only applied to relevant element',
      (tester) async {
        await tester.pumpWidget(const CustomTextWidget(
          'aaa bbb@example.com https://example.com/',
          style: TextStyle(color: Color(0xFF111111)),
          tapStyleInDef: TextStyle(color: Color(0xFF222222)),
          onTap: onTap,
        ));
        await tester.pump();

        final span2A = findSpan('bbb@example.com');
        tapDownSpan(span2A);
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2B = findSpan('bbb@example.com');
        final span3 = findSpan('https://example.com/');
        expect(span1.style.color, const Color(0xFF111111));
        expect(span2B.style.color, const Color(0xFF222222));
        expect(span3.style.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'tapStyle specified in definition takes priority',
      (tester) async {
        await tester.pumpWidget(const CustomTextWidget(
          'aaa bbb@example.com',
          tapStyle: TextStyle(color: Color(0xFF111111)),
          tapStyleInDef: TextStyle(color: Color(0xFF222222)),
          onTap: onTap,
        ));
        await tester.pump();

        final spanA = findSpan('bbb@example.com');
        tapDownSpan(spanA);
        await tester.pump();

        final spanB = findSpan('bbb@example.com');
        expect(spanB.style.color, const Color(0xFF222222));
      },
    );

    testWidgets(
      'tapStyle specified in CustomText is applied if onTap is set in definition',
      (tester) async {
        await tester.pumpWidget(CustomTextWidget(
          'aaa bbb@example.com https://example.com/',
          style: const TextStyle(color: Color(0xFF111111)),
          matchStyle: const TextStyle(color: Color(0xFF222222)),
          tapStyle: const TextStyle(color: Color(0xFF333333)),
          onTapInDef: (text) => onTap(null, text),
        ));
        await tester.pump();

        final span2A = findSpan('bbb@example.com');
        tapDownSpan(span2A);
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2B = findSpan('bbb@example.com');
        final span3 = findSpan('https://example.com/');
        expect(span1.style.color, const Color(0xFF111111));
        expect(span2B.style.color, const Color(0xFF333333));
        expect(span3.style.color, const Color(0xFF222222));

        tapUpSpan(span2B);
        await tester.pump();

        final span2C = findSpan('bbb@example.com');
        expect(span2C.style.color, const Color(0xFF222222));
      },
    );

    testWidgets(
      'tapStyle specified in CustomText is applied if onLongTap is set in definition',
      (tester) async {
        await tester.pumpWidget(CustomTextWidget(
          'aaa bbb@example.com https://example.com/',
          style: const TextStyle(color: Color(0xFF111111)),
          matchStyle: const TextStyle(color: Color(0xFF222222)),
          tapStyle: const TextStyle(color: Color(0xFF333333)),
          onLongTapInDef: (text) => onLongTap(null, text),
        ));
        await tester.pump();

        final span2A = findSpan('bbb@example.com');
        tapDownSpan(span2A);
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2B = findSpan('bbb@example.com');
        final span3 = findSpan('https://example.com/');
        expect(span1.style.color, const Color(0xFF111111));
        expect(span2B.style.color, const Color(0xFF333333));
        expect(span3.style.color, const Color(0xFF222222));

        tapUpSpan(span2B);
        await tester.pump();

        final span2C = findSpan('bbb@example.com');
        expect(span2C.style.color, const Color(0xFF222222));
      },
    );

    testWidgets(
      'tapStyle specified in definition is applied if onTap is set in CustomText',
      (tester) async {
        await tester.pumpWidget(const CustomTextWidget(
          'aaa bbb@example.com',
          style: TextStyle(color: Color(0xFF111111)),
          tapStyleInDef: TextStyle(color: Color(0xFF222222)),
          onTap: onTap,
        ));
        await tester.pump();

        final span2A = findSpan('bbb@example.com');
        tapDownSpan(span2A);
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2B = findSpan('bbb@example.com');
        expect(span1.style.color, const Color(0xFF111111));
        expect(span2B.style.color, const Color(0xFF222222));

        tapUpSpan(span2B);
        await tester.pump();

        final span2C = findSpan('bbb@example.com');
        expect(span2C.style.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'tapStyle specified in definition is applied if onLongTap is set in CustomText',
      (tester) async {
        await tester.pumpWidget(const CustomTextWidget(
          'aaa bbb@example.com',
          style: TextStyle(color: Color(0xFF111111)),
          tapStyleInDef: TextStyle(color: Color(0xFF222222)),
          onLongTap: onLongTap,
        ));
        await tester.pump();

        final span2A = findSpan('bbb@example.com');
        tapDownSpan(span2A);
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2B = findSpan('bbb@example.com');
        expect(span1.style.color, const Color(0xFF111111));
        expect(span2B.style.color, const Color(0xFF222222));

        tapUpSpan(span2B);
        await tester.pump();

        final span2C = findSpan('bbb@example.com');
        expect(span2C.style.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'tapStyle specified in definition is applied if onTap is set in definition',
      (tester) async {
        await tester.pumpWidget(CustomTextWidget(
          'aaa bbb@example.com',
          style: const TextStyle(color: Color(0xFF111111)),
          tapStyleInDef: const TextStyle(color: Color(0xFF222222)),
          onTapInDef: (text) => onTap(null, text),
        ));
        await tester.pump();

        final span2A = findSpan('bbb@example.com');
        tapDownSpan(span2A);
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2B = findSpan('bbb@example.com');
        expect(span1.style.color, const Color(0xFF111111));
        expect(span2B.style.color, const Color(0xFF222222));

        tapUpSpan(span2B);
        await tester.pump();

        final span2C = findSpan('bbb@example.com');
        expect(span2C.style.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'tapStyle specified in definition is applied if onLongTap is set in definition',
      (tester) async {
        await tester.pumpWidget(CustomTextWidget(
          'aaa bbb@example.com',
          style: const TextStyle(color: Color(0xFF111111)),
          tapStyleInDef: const TextStyle(color: Color(0xFF222222)),
          onLongTapInDef: (text) => onLongTap(null, text),
        ));
        await tester.pump();

        final span2A = findSpan('bbb@example.com');
        tapDownSpan(span2A);
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2B = findSpan('bbb@example.com');
        expect(span1.style.color, const Color(0xFF111111));
        expect(span2B.style.color, const Color(0xFF222222));

        tapUpSpan(span2B);
        await tester.pump();

        final span2C = findSpan('bbb@example.com');
        expect(span2C.style.color, const Color(0xFF111111));
      },
    );
  });

  group('Tap callbacks of TextDefinition', () {
    testWidgets(
      'Correct string is passed to onTap specified in definition',
      (tester) async {
        await tester.pumpWidget(CustomTextWidget(
          'aaa bbb@example.com',
          onTapInDef: (text) => onTap(null, text),
        ));
        await tester.pump();

        const email = 'bbb@example.com';
        final span = findSpan(email);

        tapDownSpan(span);
        await tester.pump();
        tapUpSpan(span);
        await tester.pump();

        expect(isTap, isTrue);
        expect(tappedText, equals(email));
      },
    );

    testWidgets(
      'Correct string is passed to onLongTap specified in definition',
      (tester) async {
        await tester.pumpWidget(CustomTextWidget(
          'aaa bbb@example.com',
          onLongTapInDef: (text) => onLongTap(null, text),
        ));
        await tester.pump();

        const email = 'bbb@example.com';
        final span = findSpan(email);

        tapDownSpan(span);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 610));
        tapUpSpan(span);
        await tester.pump();

        expect(isLongTap, isTrue);
        expect(tappedText, equals(email));
      },
    );

    testWidgets(
      'Only onTap specified in definition is called on short tap',
      (tester) async {
        await tester.pumpWidget(CustomTextWidget(
          'aaa bbb@example.com',
          onTapInDef: (text) => onTap(null, text),
          onLongTapInDef: (text) => onLongTap(null, text),
        ));
        await tester.pump();

        const email = 'bbb@example.com';
        final span = findSpan(email);

        tapDownSpan(span);
        await tester.pump();
        tapUpSpan(span);
        await tester.pump();

        expect(isTap, isTrue);
        expect(isLongTap, isFalse);
      },
    );

    testWidgets(
      'Only onLongTap specified in definition is called on long tap',
      (tester) async {
        await tester.pumpWidget(CustomTextWidget(
          'aaa bbb@example.com',
          onTapInDef: (text) => onTap(null, text),
          onLongTapInDef: (text) => onLongTap(null, text),
        ));
        await tester.pump();

        const email = 'bbb@example.com';
        final span = findSpan(email);

        tapDownSpan(span);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 610));
        tapUpSpan(span);
        await tester.pump();

        expect(isTap, isFalse);
        expect(isLongTap, isTrue);
      },
    );

    testWidgets('onTap specified in definition takes priority', (tester) async {
      await tester.pumpWidget(CustomTextWidget(
        'aaa bbb@example.com',
        onTap: (_, __) => onTap(null, 'tap1'),
        onTapInDef: (_) => onTap(null, 'tap2'),
      ));
      await tester.pump();

      const email = 'bbb@example.com';
      final span = findSpan(email);

      tapDownSpan(span);
      await tester.pump();
      tapUpSpan(span);
      await tester.pump();

      expect(tappedText, 'tap2');
    });

    testWidgets(
      'onLongTap specified in definition takes priority',
      (tester) async {
        await tester.pumpWidget(CustomTextWidget(
          'aaa bbb@example.com',
          onLongTap: (_, __) => onLongTap(null, 'longTap1'),
          onLongTapInDef: (_) => onLongTap(null, 'longTap2'),
        ));
        await tester.pump();

        const email = 'bbb@example.com';
        final span = findSpan(email);

        tapDownSpan(span);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 610));
        tapUpSpan(span);
        await tester.pump();

        expect(tappedText, 'longTap2');
      },
    );
  });
}
