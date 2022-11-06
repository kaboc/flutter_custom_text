import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:text_parser/text_parser.dart';

import 'utils.dart';
import 'widgets.dart';

void main() {
  setUp(() {
    isTap = isLongPress = false;
    matcherType = tappedText = null;
  });

  group('Styles', () {
    testWidgets('DefaultTextStyle is used for RichText itself', (tester) async {
      await tester.pumpWidget(
        const DefaultTextStyle(
          style: TextStyle(color: Color(0xFF111111)),
          child: CustomTextWidget('aaa bbb@example.com'),
        ),
      );
      await tester.pump();

      final richText = findRichText();
      expect(richText.text.style?.color, equals(const Color(0xFF111111)));
    });

    testWidgets(
      'style and matchStyle are used even if w/o onTap',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: TextStyle(color: Color(0xFF111111)),
            matchStyle: TextStyle(color: Color(0xFF222222)),
          ),
        );
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2 = findSpan('bbb@example.com');
        expect(span1?.style?.color, const Color(0xFF111111));
        expect(span2?.style?.color, const Color(0xFF222222));
      },
    );

    testWidgets(
      'tapStyle is not applied if tap callbacks are not set',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            style: TextStyle(color: Color(0xFF111111)),
            tapStyle: TextStyle(color: Color(0xFF222222)),
          ),
        );
        await tester.pump();

        final spanA = findSpan('bbb@example.com');
        tapDownSpan(spanA);
        await tester.pump();

        final spanB = findSpan('bbb@example.com');
        expect(spanB?.style?.color, const Color(0xFF111111));
      },
    );

    testWidgets('tapStyle is applied if onTap is set', (tester) async {
      await tester.pumpWidget(
        const CustomTextWidget(
          'aaa bbb@example.com https://example.com/',
          style: TextStyle(color: Color(0xFF111111)),
          matchStyle: TextStyle(color: Color(0xFF222222)),
          tapStyle: TextStyle(color: Color(0xFF333333)),
          onTap: onTap,
        ),
      );
      await tester.pump();

      final span2A = findSpan('bbb@example.com');
      tapDownSpan(span2A);
      await tester.pump();

      final span1 = findSpan('aaa ');
      final span2B = findSpan('bbb@example.com');
      final span3 = findSpan('https://example.com/');
      expect(span1?.style?.color, const Color(0xFF111111));
      expect(span2B?.style?.color, const Color(0xFF333333));
      expect(span3?.style?.color, const Color(0xFF222222));

      tapUpSpan(span2B);
      await tester.pump();

      final span2C = findSpan('bbb@example.com');
      expect(span2C?.style?.color, const Color(0xFF222222));
    });

    testWidgets('tapStyle is applied if onLongPress is set', (tester) async {
      await tester.pumpWidget(
        const CustomTextWidget(
          'aaa bbb@example.com https://example.com/',
          style: TextStyle(color: Color(0xFF111111)),
          matchStyle: TextStyle(color: Color(0xFF222222)),
          tapStyle: TextStyle(color: Color(0xFF333333)),
          onLongPress: onLongPress,
        ),
      );
      await tester.pump();

      final span2A = findSpan('bbb@example.com');
      tapDownSpan(span2A);
      await tester.pump();

      final span1 = findSpan('aaa ');
      final span2B = findSpan('bbb@example.com');
      final span3 = findSpan('https://example.com/');
      expect(span1?.style?.color, const Color(0xFF111111));
      expect(span2B?.style?.color, const Color(0xFF333333));
      expect(span3?.style?.color, const Color(0xFF222222));

      tapUpSpan(span2B);
      await tester.pump();

      final span2C = findSpan('bbb@example.com');
      expect(span2C?.style?.color, const Color(0xFF222222));
    });
  });

  group('Tap callbacks', () {
    testWidgets('Correct values are passed to onTap callback', (tester) async {
      await tester.pumpWidget(
        const CustomTextWidget('aaa bbb@example.com', onTap: onTap),
      );
      await tester.pump();

      const email = 'bbb@example.com';
      final span = findSpan(email);

      tapDownSpan(span);
      await tester.pump();
      tapUpSpan(span);
      await tester.pump();

      expect(isTap, isTrue);
      expect(matcherType, equals(EmailMatcher));
      expect(tappedText, equals(email));
    });

    testWidgets(
      'Correct values are passed to onLongPress callback',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            onLongPress: onLongPress,
          ),
        );
        await tester.pump();

        const email = 'bbb@example.com';
        final span = findSpan(email);

        tapDownSpan(span);
        await tester.pump(const Duration(milliseconds: 610));
        tapUpSpan(span);
        await tester.pump();

        expect(isLongPress, isTrue);
        expect(matcherType, equals(EmailMatcher));
        expect(tappedText, equals(email));
      },
    );

    testWidgets('Only onTap is called on short tap', (tester) async {
      await tester.pumpWidget(
        const CustomTextWidget(
          'aaa bbb@example.com',
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      );
      await tester.pump();

      const email = 'bbb@example.com';
      final span = findSpan(email);

      tapDownSpan(span);
      await tester.pump();
      tapUpSpan(span);
      await tester.pump();

      expect(isTap, isTrue);
      expect(isLongPress, isFalse);
    });

    testWidgets('Only onLongPress is called on long-press', (tester) async {
      await tester.pumpWidget(
        const CustomTextWidget(
          'aaa bbb@example.com',
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      );
      await tester.pump();

      const email = 'bbb@example.com';
      final span = findSpan(email);

      tapDownSpan(span);
      await tester.pump(const Duration(milliseconds: 610));
      tapUpSpan(span);
      await tester.pump();

      expect(isTap, isFalse);
      expect(isLongPress, isTrue);
    });

    testWidgets(
      'specified long-press duration is used instead of default value',
      (tester) async {
        await tester.pumpWidget(
          const CustomTextWidget(
            'aaa bbb@example.com',
            onLongPress: onLongPress,
            longPressDuration: Duration(milliseconds: 300),
          ),
        );
        await tester.pump();

        const email = 'bbb@example.com';
        final span = findSpan(email);

        tapDownSpan(span);
        await tester.pump(const Duration(milliseconds: 310));
        tapUpSpan(span);
        await tester.pump();

        expect(isLongPress, isTrue);
      },
    );
  });

  group('Updating properties', () {
    testWidgets(
      'change of tapStyle specified in definition is reflected '
      'when the widget is rebuilt',
      (tester) async {
        var tapStyle = const TextStyle(color: Color(0xFF111111));

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (_, setState) {
              return CustomTextWidget(
                'aaa bbb@example.com',
                tapStyleInDef: tapStyle,
                onTapInDef: (_) {},
                onButtonPressed: () => setState(() {
                  tapStyle = tapStyle.copyWith(color: const Color(0xFF222222));
                }),
              );
            },
          ),
        );
        await tester.pump();

        await tapButton(tester);
        await tester.pumpAndSettle();

        const email = 'bbb@example.com';

        final span1 = findSpan(email);
        tapDownSpan(span1);
        await tester.pump();

        final span2 = findSpan(email);
        expect(span2?.style?.color, const Color(0xFF222222));

        tapUpSpan(span1);
        await tester.pump();
      },
    );

    testWidgets(
      'change of tapStyle specified in CustomText is reflected '
      'when the widget is rebuilt',
      (tester) async {
        var tapStyle = const TextStyle(color: Color(0xFF111111));

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (_, setState) {
              return CustomTextWidget(
                'aaa bbb@example.com',
                tapStyle: tapStyle,
                onTap: (_, __) {},
                onButtonPressed: () => setState(() {
                  tapStyle = tapStyle.copyWith(color: const Color(0xFF222222));
                }),
              );
            },
          ),
        );
        await tester.pump();

        await tapButton(tester);
        await tester.pumpAndSettle();

        const email = 'bbb@example.com';

        final span1 = findSpan(email);
        tapDownSpan(span1);
        await tester.pump();

        final span2 = findSpan(email);
        expect(span2?.style?.color, const Color(0xFF222222));

        tapUpSpan(span1);
        await tester.pump();
      },
    );

    testWidgets(
      'change of tap callback specified in definition is reflected '
      'when the widget is rebuilt',
      (tester) async {
        void onTap2(Type? _, String text) => tappedText = text.toUpperCase();

        var callback = onTap;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (_, setState) {
              return CustomTextWidget(
                'aaa bbb@example.com',
                onTapInDef: (text) => callback(null, text),
                onButtonPressed: () {
                  setState(() => callback = onTap2);
                },
              );
            },
          ),
        );
        await tester.pump();

        await tapButton(tester);
        await tester.pumpAndSettle();

        const email = 'bbb@example.com';

        final span = findSpan(email);
        tapDownSpan(span);
        await tester.pump();
        tapUpSpan(span);
        await tester.pump();

        expect(tappedText, equals(email.toUpperCase()));
      },
    );

    testWidgets(
      'change of tap callback specified in CustomText is reflected '
      'when the widget is rebuilt',
      (tester) async {
        void onTap2(Type? _, String text) => tappedText = text.toUpperCase();

        var callback = onTap;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (_, setState) {
              return CustomTextWidget(
                'aaa bbb@example.com',
                onTap: (_, text) => callback(null, text),
                onButtonPressed: () {
                  setState(() => callback = onTap2);
                },
              );
            },
          ),
        );
        await tester.pump();

        await tapButton(tester);
        await tester.pumpAndSettle();

        const email = 'bbb@example.com';

        final span = findSpan(email);
        tapDownSpan(span);
        await tester.pump();
        tapUpSpan(span);
        await tester.pump();

        expect(tappedText, equals(email.toUpperCase()));
      },
    );

    testWidgets(
      'text change is reflected to onTap specified in definition '
      'when the widget is rebuilt',
      (tester) async {
        var text = 'aaa bbb@example.com';

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (_, setState) {
              return CustomTextWidget(
                text,
                onTapInDef: (text) => onTap(null, text),
                onButtonPressed: () => setState(() {
                  text = text.toUpperCase();
                }),
              );
            },
          ),
        );
        await tester.pump();

        const email = 'BBB@EXAMPLE.COM';

        await tapButton(tester);
        await tester.pumpAndSettle();

        final span = findSpan(email);
        tapDownSpan(span);
        await tester.pump();
        tapUpSpan(span);
        await tester.pump();

        expect(tappedText, equals(email));
      },
    );

    testWidgets(
      'text change is reflected to onTap specified in CustomText '
      'when the widget is rebuilt',
      (tester) async {
        var text = 'aaa bbb@example.com';

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (_, setState) {
              return CustomTextWidget(
                text,
                onTap: (_, text) => onTap(null, text),
                onButtonPressed: () => setState(() {
                  text = text.toUpperCase();
                }),
              );
            },
          ),
        );
        await tester.pump();

        const email = 'BBB@EXAMPLE.COM';

        await tapButton(tester);
        await tester.pumpAndSettle();

        final span = findSpan(email);
        tapDownSpan(span);
        await tester.pump();
        tapUpSpan(span);
        await tester.pump();

        expect(tappedText, equals(email));
      },
    );
  });
}
