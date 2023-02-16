import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text_editing_controller.dart';
import 'package:custom_text/src/text_span/data.dart';
import 'package:custom_text/src/text_span/text_span_notifier.dart';
import 'package:custom_text/src/text_span/transient_elements_builder.dart';

extension on List<TextElement> {
  String get text => map((v) => v.text).join();
}

extension on List<InlineSpan> {
  String get text => map((v) => v is TextSpan ? v.text : '').join();
}

void main() {
  final definitions = [
    TextDefinition(
      matcher: const UrlMatcher(),
      matchStyle: const TextStyle(),
      tapStyle: const TextStyle(),
      onTap: (_) {},
    ),
    const TextDefinition(
      matcher: EmailMatcher(),
      matchStyle: TextStyle(),
    ),
    const TextDefinition(
      matcher: PatternMatcher('#[a-z]+'),
      matchStyle: TextStyle(),
      hoverStyle: TextStyle(),
    ),
  ];
  final matchers = definitions.map((def) => def.matcher).toList();
  final notifier = CustomTextSpanNotifier(
    text: '',
    settings: NotifierSettings(definitions: definitions),
  );

  late List<TextElement> elements;

  tearDownAll(notifier.dispose);

  List<InlineSpan> buildTransientSpan({
    required List<TextElement> initialElements,
    required BuildResult elementsBuilderResult,
  }) {
    notifier
      ..elements = initialElements
      ..buildSpan(
        style: const TextStyle(),
        oldElementsLength: 30,
      )
      ..elements = elementsBuilderResult.elements
      ..buildTransientSpan(
        style: const TextStyle(),
        replaceRange: elementsBuilderResult.replaceRange,
        spanRange: elementsBuilderResult.spanRange,
      );

    return notifier.value.children ?? [];
  }

  group('Transient text elements and spans', () {
    const initialText =
        'abc aaa@bbb.cc abc aaa@bbb.cc \nhttps://bbb.cc abc aaa#hashtag';

    setUpAll(() async {
      elements = await TextParser(matchers: matchers).parse(initialText);
    });

    test('Successfully parsed', () {
      expect(elements, hasLength(8));
      expect(elements.text, equals(initialText));
    });

    group('Transient elements and spans have correct text after changes', () {
      test('Deletions', () {
        for (var letterLen = 1; letterLen <= initialText.length; letterLen++) {
          for (var i = 0; i <= initialText.length - letterLen; i++) {
            final newText = initialText.substring(0, i) +
                initialText.substring(i + letterLen);

            final builder = TransientTextElementsBuilder(
              oldElements: elements,
              oldText: initialText,
              newText: newText,
            );
            final result = builder.build(
              changeRange: builder.findUpdatedElementsRange(),
            );
            expect(result.elements.text, newText);

            final spans = buildTransientSpan(
              initialElements: elements,
              elementsBuilderResult: result,
            );
            expect(spans.text, equals(newText));
          }
        }
      });

      test('Additions', () {
        for (var letterLen = 1; letterLen <= 2; letterLen++) {
          for (var i = 0; i <= initialText.length; i++) {
            final newText = initialText.substring(0, i) +
                ('A' * letterLen) +
                initialText.substring(i);

            final builder = TransientTextElementsBuilder(
              oldElements: elements,
              oldText: initialText,
              newText: newText,
            );
            final result = builder.build(
              changeRange: builder.findUpdatedElementsRange(),
            );
            expect(result.elements.text, newText);

            final spans = buildTransientSpan(
              initialElements: elements,
              elementsBuilderResult: result,
            );
            expect(spans.text, equals(newText));
          }
        }
      });

      test('Replacements', () {
        for (var fromLen = 1; fromLen <= initialText.length; fromLen++) {
          for (var replLen = 1; replLen <= fromLen + 1; replLen++) {
            for (var i = 0; i <= initialText.length - fromLen; i++) {
              final newText = initialText.substring(0, i) +
                  ('A' * replLen) +
                  initialText.substring(i + fromLen);

              final builder = TransientTextElementsBuilder(
                oldElements: elements,
                oldText: initialText,
                newText: newText,
              );
              final result = builder.build(
                changeRange: builder.findUpdatedElementsRange(),
              );
              expect(result.elements.text, newText);

              final spans = buildTransientSpan(
                initialElements: elements,
                elementsBuilderResult: result,
              );
              expect(spans.text, equals(newText));
            }
          }
        }
      });
    });

    group('Transient elements and spans are built correctly', () {
      const initialText =
          'abcde foo@example.com\nhttps://example.com/ abc #hashtag';

      setUpAll(() async {
        elements = await TextParser(matchers: matchers).parse(initialText);
      });

      test('', () {
        const text = 'a';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(1));
        expect(result.elements[0].text, equals('a'));
        expect(result.elements[0].matcherType, equals(TextMatcher));
        expect(result.elements[0].offset, equals(0));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(1));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text =
            '||abcde foo@example.com\nhttps://example.com/ abc #hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[0].text, equals('||abcde '));
        expect(result.elements[0].matcherType, equals(TextMatcher));
        expect(result.elements[0].offset, equals(0));
        expect(result.elements[1].text, equals('foo@example.com'));
        expect(result.elements[1].matcherType, equals(EmailMatcher));
        expect(result.elements[1].offset, equals(8));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text = '||de foo@example.com\nhttps://example.com/ abc #hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[0].text, equals('||de '));
        expect(result.elements[0].matcherType, equals(TextMatcher));
        expect(result.elements[0].offset, equals(0));
        expect(result.elements[1].text, equals('foo@example.com'));
        expect(result.elements[1].matcherType, equals(EmailMatcher));
        expect(result.elements[1].offset, equals(5));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text =
            'ab||de foo@example.com\nhttps://example.com/ abc #hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[0].text, equals('ab||de '));
        expect(result.elements[0].matcherType, equals(TextMatcher));
        expect(result.elements[0].offset, equals(0));
        expect(result.elements[1].text, equals('foo@example.com'));
        expect(result.elements[1].matcherType, equals(EmailMatcher));
        expect(result.elements[1].offset, equals(7));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text =
            'abcde ||foo@example.com\nhttps://example.com/ abc #hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[0].text, equals('abcde ||'));
        expect(result.elements[0].matcherType, equals(TextMatcher));
        expect(result.elements[0].offset, equals(0));
        expect(result.elements[1].text, equals('foo@example.com'));
        expect(result.elements[1].matcherType, equals(EmailMatcher));
        expect(result.elements[1].offset, equals(8));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text = 'ab||foo@example.com\nhttps://example.com/ abc #hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[0].text, equals('ab||'));
        expect(result.elements[0].matcherType, equals(TextMatcher));
        expect(result.elements[0].offset, equals(0));
        expect(result.elements[1].text, equals('foo@example.com'));
        expect(result.elements[1].matcherType, equals(EmailMatcher));
        expect(result.elements[1].offset, equals(4));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text = 'foo@example.com\nhttps://example.com/ abc #hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(5));
        expect(result.elements[0].text, equals('foo@example.com'));
        expect(result.elements[0].matcherType, equals(EmailMatcher));
        expect(result.elements[0].offset, equals(0));
        expect(result.elements[1].text, equals('\n'));
        expect(result.elements[1].matcherType, equals(TextMatcher));
        expect(result.elements[1].offset, equals(15));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(5));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text = 'example.com\nhttps://example.com/ abc #hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(5));
        expect(result.elements[0].text, equals('example.com'));
        expect(result.elements[0].matcherType, equals(TextMatcher));
        expect(result.elements[0].offset, equals(0));
        expect(result.elements[1].text, equals('\n'));
        expect(result.elements[1].matcherType, equals(TextMatcher));
        expect(result.elements[1].offset, equals(11));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(5));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text = 'abc||example.com\nhttps://example.com/ abc #hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[0].text, equals('abc||'));
        expect(result.elements[0].matcherType, equals(TextMatcher));
        expect(result.elements[0].offset, equals(0));
        expect(result.elements[1].text, equals('example.com'));
        expect(result.elements[1].matcherType, equals(EmailMatcher));
        expect(result.elements[1].offset, equals(5));
        expect(result.elements[2].text, equals('\n'));
        expect(result.elements[2].matcherType, equals(TextMatcher));
        expect(result.elements[2].offset, equals(16));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text =
            'abcde foo@example.com||\nhttps://example.com/ abc #hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[1].text, equals('foo@example.com||'));
        expect(result.elements[1].matcherType, equals(EmailMatcher));
        expect(result.elements[1].offset, equals(6));
        expect(result.elements[2].text, equals('\n'));
        expect(result.elements[2].matcherType, equals(TextMatcher));
        expect(result.elements[2].offset, equals(23));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text =
            'abcde foo@example.com\n||https://example.com/ abc #hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[1].text, equals('foo@example.com'));
        expect(result.elements[1].matcherType, equals(EmailMatcher));
        expect(result.elements[1].offset, equals(6));
        expect(result.elements[2].text, equals('\n||'));
        expect(result.elements[2].matcherType, equals(TextMatcher));
        expect(result.elements[2].offset, equals(21));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text = 'abcde foo@example.com||https://example.com/ abc #hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[1].text, equals('foo@example.com'));
        expect(result.elements[1].matcherType, equals(EmailMatcher));
        expect(result.elements[1].offset, equals(6));
        expect(result.elements[2].text, equals('||'));
        expect(result.elements[2].matcherType, equals(TextMatcher));
        expect(result.elements[2].offset, equals(21));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text = 'abcde foo@example.com||example.com/ abc #hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[2].text, equals('||'));
        expect(result.elements[2].matcherType, equals(TextMatcher));
        expect(result.elements[2].offset, equals(21));
        expect(result.elements[3].text, equals('example.com/'));
        expect(result.elements[3].matcherType, equals(UrlMatcher));
        expect(result.elements[3].offset, equals(23));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text = 'abcde foo@example.comexample.com/ abc #hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(5));
        expect(result.elements[1].text, equals('foo@example.com'));
        expect(result.elements[1].matcherType, equals(EmailMatcher));
        expect(result.elements[1].offset, equals(6));
        expect(result.elements[2].text, equals('example.com/'));
        expect(result.elements[2].matcherType, equals(UrlMatcher));
        expect(result.elements[2].offset, equals(21));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(5));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text = 'abcde foo@example.com/ abc #hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(5));
        expect(result.elements[1].text, equals('foo@example.com'));
        expect(result.elements[1].matcherType, equals(EmailMatcher));
        expect(result.elements[1].offset, equals(6));
        expect(result.elements[2].text, equals('/'));
        expect(result.elements[2].matcherType, equals(UrlMatcher));
        expect(result.elements[2].offset, equals(21));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(5));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text =
            'abcde foo@example.com\nhttps://example.com/|| abc #hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[3].text, equals('https://example.com/||'));
        expect(result.elements[3].matcherType, equals(UrlMatcher));
        expect(result.elements[3].offset, equals(22));
        expect(result.elements[4].text, equals(' abc '));
        expect(result.elements[4].matcherType, equals(TextMatcher));
        expect(result.elements[4].offset, equals(44));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text =
            'abcde foo@example.com\nhttps://example.com/||abc #hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[3].text, equals('https://example.com/'));
        expect(result.elements[3].matcherType, equals(UrlMatcher));
        expect(result.elements[3].offset, equals(22));
        expect(result.elements[4].text, equals('||abc '));
        expect(result.elements[4].matcherType, equals(TextMatcher));
        expect(result.elements[4].offset, equals(42));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text =
            'abcde foo@example.com\nhttps://example.com/ abc ||#hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[4].text, equals(' abc ||'));
        expect(result.elements[4].matcherType, equals(TextMatcher));
        expect(result.elements[4].offset, equals(42));
        expect(result.elements[5].text, equals('#hashtag'));
        expect(result.elements[5].matcherType, equals(PatternMatcher));
        expect(result.elements[5].offset, equals(49));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text =
            'abcde foo@example.com\nhttps://example.com/ abc||#hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[4].text, equals(' abc||'));
        expect(result.elements[4].matcherType, equals(TextMatcher));
        expect(result.elements[4].offset, equals(42));
        expect(result.elements[5].text, equals('#hashtag'));
        expect(result.elements[5].matcherType, equals(PatternMatcher));
        expect(result.elements[5].offset, equals(48));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text = 'abcde foo@example.com\nhttps://example.com/ #hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[3].text, equals('https://example.com/'));
        expect(result.elements[3].matcherType, equals(UrlMatcher));
        expect(result.elements[3].offset, equals(22));
        expect(result.elements[4].text, equals(' '));
        expect(result.elements[4].matcherType, equals(TextMatcher));
        expect(result.elements[4].offset, equals(42));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text = 'abcde foo@example.com\nhttps://example|| #hashtag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[3].text, equals('https://example||'));
        expect(result.elements[3].matcherType, equals(UrlMatcher));
        expect(result.elements[3].offset, equals(22));
        expect(result.elements[4].text, equals(' '));
        expect(result.elements[4].matcherType, equals(TextMatcher));
        expect(result.elements[4].offset, equals(39));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text = 'abcde foo@example.com\nhttps://example.com/ abc #||tag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[5].text, equals('#||tag'));
        expect(result.elements[5].matcherType, equals(PatternMatcher));
        expect(result.elements[5].offset, equals(47));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text =
            'abcde foo@example.com\nhttps://example.com/ abc #hashtag||';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[4].text, equals(' abc '));
        expect(result.elements[4].matcherType, equals(TextMatcher));
        expect(result.elements[4].offset, equals(42));
        expect(result.elements[5].text, equals('#hashtag||'));
        expect(result.elements[5].matcherType, equals(PatternMatcher));
        expect(result.elements[5].offset, equals(47));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text = 'abcde foo@example.com\nhttps://example.com/ abc #hash||';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(6));
        expect(result.elements[5].text, equals('#hash||'));
        expect(result.elements[5].matcherType, equals(PatternMatcher));
        expect(result.elements[5].offset, equals(47));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text = 'abcde foo@example.com\nhttps://example.com/ abc ';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: 'abcde foo@example.com\nhttps://example.com/ abc ',
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(5));
        expect(result.elements[4].text, equals(' abc '));
        expect(result.elements[4].matcherType, equals(TextMatcher));
        expect(result.elements[4].offset, equals(42));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(5));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text = 'abcde foo@example.com\nhttps://example.com/ abc';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(5));
        expect(result.elements[4].text, equals(' abc'));
        expect(result.elements[4].matcherType, equals(TextMatcher));
        expect(result.elements[4].offset, equals(42));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(5));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text = 'abcde foo||tag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(3));
        expect(result.elements[0].text, equals('abcde '));
        expect(result.elements[0].matcherType, equals(TextMatcher));
        expect(result.elements[0].offset, equals(0));
        expect(result.elements[1].text, equals('foo||'));
        expect(result.elements[1].matcherType, equals(EmailMatcher));
        expect(result.elements[1].offset, equals(6));
        expect(result.elements[2].text, equals('tag'));
        expect(result.elements[2].matcherType, equals(PatternMatcher));
        expect(result.elements[2].offset, equals(11));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(3));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text = 'abag';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(2));
        expect(result.elements[0].text, equals('ab'));
        expect(result.elements[0].matcherType, equals(TextMatcher));
        expect(result.elements[0].offset, equals(0));
        expect(result.elements[1].text, equals('ag'));
        expect(result.elements[1].matcherType, equals(PatternMatcher));
        expect(result.elements[1].offset, equals(2));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(2));
        expect(spans.text, equals(text));
      });

      test('', () {
        const text = 'g';
        final builder = TransientTextElementsBuilder(
          oldElements: elements,
          oldText: initialText,
          newText: text,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(1));
        expect(result.elements[0].text, equals('g'));
        expect(result.elements[0].matcherType, equals(TextMatcher));
        expect(result.elements[0].offset, equals(0));

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(1));
        expect(spans.text, equals(text));
      });

      test('', () async {
        const oldText = 'aaa bbb@ccc.ddd \nhttps://eee.fff/';
        const newText = 'aaa bbb@ccc.ddd aaa bbb@ccc.ddd \nhttps://eee.fff/';
        final oldElements = await TextParser(
          matchers: const [
            UrlMatcher(),
            EmailMatcher(),
            PatternMatcher('#[a-z]+'),
          ],
        ).parse(oldText);
        final builder = TransientTextElementsBuilder(
          oldElements: oldElements,
          oldText: oldText,
          newText: newText,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(4));
        expect(result.elements[1].text, equals('bbb@ccc.ddd aaa bbb@ccc.ddd'));
        expect(result.elements[1].matcherType, equals(EmailMatcher));
        expect(result.elements[1].offset, equals(4));
        expect(result.elements[2].text, equals(' \n'));
        expect(result.elements[2].matcherType, equals(TextMatcher));
        expect(result.elements[2].offset, equals(31));

        final elements = await TextParser(matchers: matchers).parse(oldText);
        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(4));
        expect(spans.text, equals(newText));
      });

      test('', () async {
        const oldText = 'aaa bbb@ccc.ddd aaa bbb@ccc.ddd \nhttps://eee.fff/';
        const newText = 'aaa bbb@ccc.ddd \nhttps://eee.fff/';
        final oldElements = await TextParser(
          matchers: const [
            UrlMatcher(),
            EmailMatcher(),
            PatternMatcher('#[a-z]+'),
          ],
        ).parse(oldText);
        final builder = TransientTextElementsBuilder(
          oldElements: oldElements,
          oldText: oldText,
          newText: newText,
        );
        final result = builder.build(
          changeRange: builder.findUpdatedElementsRange(),
        );
        expect(result.elements, hasLength(4));
        expect(result.elements[1].text, equals('bbb@ccc.ddd'));
        expect(result.elements[1].matcherType, equals(EmailMatcher));
        expect(result.elements[1].offset, equals(4));
        expect(result.elements[2].text, equals(' \n'));
        expect(result.elements[2].matcherType, equals(TextMatcher));
        expect(result.elements[2].offset, equals(15));

        final elements = await TextParser(matchers: matchers).parse(oldText);
        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(4));
        expect(spans.text, equals(newText));
      });
    });
  });
}
