import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

void main() {
  group('CustomSpanBuilder', () {
    test('Styles are applied as specified', () async {
      const style = TextStyle(color: Color(0x11111111));
      const matchStyle = TextStyle(color: Color(0x22222222));

      final builder = CustomSpanBuilder(
        definitions: [
          const TextDefinition(
            matcher: PatternMatcher('bbb'),
            matchStyle: matchStyle,
          ),
        ],
        style: style,
      );
      final builtSpan = await builder.build(text: 'aaabbbccc');

      expect(
        builtSpan.children,
        const [
          TextSpan(text: 'aaa', style: style),
          TextSpan(text: 'bbb', style: matchStyle),
          TextSpan(text: 'ccc', style: style),
        ],
      );
    });

    test('Builder also works with ParserOptions.external', () async {
      const style = TextStyle(color: Color(0x11111111));
      const matchStyle = TextStyle(color: Color(0x22222222));

      final builder = CustomSpanBuilder(
        style: style,
        definitions: const [
          TextDefinition(
            matcher: PatternMatcher(''),
            matchStyle: matchStyle,
          ),
        ],
        parserOptions: ParserOptions.external((text) async {
          return const [
            TextElement('aaa'),
            TextElement('bbb', matcherType: PatternMatcher),
            TextElement('ccc'),
          ];
        }),
      );
      final builtSpan = await builder.build(text: 'aaabbbccc');

      expect(
        builtSpan.children,
        const [
          TextSpan(text: 'aaa', style: style),
          TextSpan(text: 'bbb', style: matchStyle),
          TextSpan(text: 'ccc', style: style),
        ],
      );
    });

    test(
      'Arguments other than style, matchStyle, mouseCursor in definition '
      'are ignored (cf. mouseCursor is also not used if builder is used '
      'with CustomText)',
      () async {
        const style = TextStyle(color: Color(0x11111111));
        const matchStyle = TextStyle(color: Color(0x22222222));
        const tapStyle = TextStyle(color: Color(0x33333333));
        const hoverStyle = TextStyle(color: Color(0x44444444));

        final builder = CustomSpanBuilder(
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
        );
        final builtSpan = await builder.build(text: 'aaabbbccc');

        expect(
          builtSpan.children,
          const [
            TextSpan(text: 'aaa', style: style),
            TextSpan(
              text: 'bbb',
              style: matchStyle,
              mouseCursor: SystemMouseCursors.help,
            ),
            TextSpan(text: 'ccc', style: style),
          ],
        );
      },
    );

    test('New builder with same config reuses the existing span', () async {
      const definition = TextDefinition(matcher: PatternMatcher('bbb'));

      final builder1 = CustomSpanBuilder(definitions: [definition]);
      final builtSpan1 = await builder1.build(text: 'aaabbbccc');

      expect(builder1.parsed, isTrue);
      expect(builder1.built, isTrue);

      final builder2 = CustomSpanBuilder(definitions: [definition]);
      final builtSpan2 =
          await builder2.build(text: 'aaabbbccc', oldBuilder: builder1);

      expect(builder2.parsed, isFalse);
      expect(builder2.built, isFalse);
      expect(builtSpan2, same(builtSpan1));
    });

    test('Changing text causes text parsing', () async {
      const definition = TextDefinition(matcher: PatternMatcher('bbb'));

      final builder1 = CustomSpanBuilder(definitions: [definition]);
      await builder1.build(text: 'aaabbbccc');

      expect(builder1.parsed, isTrue);
      expect(builder1.built, isTrue);

      final builder2 = CustomSpanBuilder(definitions: [definition]);
      await builder2.build(text: 'aaabbbddd', oldBuilder: builder1);

      expect(builder2.parsed, isTrue);
      expect(builder2.built, isTrue);
    });

    test('Changing pattern causes text parsing', () async {
      final builder1 = CustomSpanBuilder(
        definitions: const [
          TextDefinition(matcher: PatternMatcher('bbb')),
        ],
      );
      await builder1.build(text: 'aaabbbccc');

      expect(builder1.parsed, isTrue);
      expect(builder1.built, isTrue);

      final builder2 = CustomSpanBuilder(
        definitions: const [
          TextDefinition(matcher: PatternMatcher('ccc')),
        ],
      );
      await builder2.build(text: 'aaabbbccc', oldBuilder: builder1);

      expect(builder2.parsed, isTrue);
      expect(builder2.built, isTrue);
    });

    test('Changing parserOptions causes text parsing', () async {
      const definition = TextDefinition(matcher: PatternMatcher('bbb'));

      final builder1 = CustomSpanBuilder(
        // ignore: avoid_redundant_argument_values
        parserOptions: const ParserOptions(caseSensitive: true),
        definitions: [definition],
      );
      await builder1.build(text: 'aaabbbccc');

      expect(builder1.parsed, isTrue);
      expect(builder1.built, isTrue);

      final builder2 = CustomSpanBuilder(
        parserOptions: const ParserOptions(caseSensitive: false),
        definitions: [definition],
      );
      await builder2.build(text: 'aaabbbccc', oldBuilder: builder1);

      expect(builder2.parsed, isTrue);
      expect(builder2.built, isTrue);
    });

    test(
      'Changing style or matchStyle causes a rebuild without text parsing',
      () async {
        final builder1 = CustomSpanBuilder(
          definitions: const [
            TextDefinition(matcher: PatternMatcher('bbb')),
          ],
          style: const TextStyle(color: Color(0x11111111)),
        );
        await builder1.build(text: 'aaabbbccc');

        expect(builder1.parsed, isTrue);
        expect(builder1.built, isTrue);

        final builder2 = CustomSpanBuilder(
          definitions: const [
            TextDefinition(matcher: PatternMatcher('bbb')),
          ],
          style: const TextStyle(color: Color(0x22222222)),
        );
        await builder2.build(text: 'aaabbbccc', oldBuilder: builder1);

        expect(builder2.parsed, isFalse);
        expect(builder2.built, isTrue);

        final builder3 = CustomSpanBuilder(
          definitions: const [
            TextDefinition(
              matcher: PatternMatcher('bbb'),
              matchStyle: TextStyle(color: Color(0x33333333)),
            ),
          ],
          style: const TextStyle(color: Color(0x22222222)),
        );
        await builder3.build(text: 'aaabbbccc', oldBuilder: builder2);

        expect(builder2.parsed, isFalse);
        expect(builder2.built, isTrue);
      },
    );

    test('preventBlocking does not affect the resulting span', () async {
      const definition = TextDefinition(
        matcher: PatternMatcher('bbb'),
        matchStyle: TextStyle(color: Color(0x11111111)),
      );

      final builder1 = CustomSpanBuilder(
        definitions: [definition],
        // ignore: avoid_redundant_argument_values
        preventBlocking: false,
      );
      final builtSpan1 = await builder1.build(text: 'aaabbbccc');

      final builder2 = CustomSpanBuilder(
        definitions: [definition],
        preventBlocking: true,
      );
      final builtSpan2 = await builder2.build(text: 'aaabbbccc');

      expect(builtSpan2, isNotNull);
      expect(builtSpan2, builtSpan1);
    });
  });
}
