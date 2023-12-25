import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';
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
    initialText: '',
    initialStyle: null,
    settings: SpansBuilderSettings(definitions: definitions),
  );

  late List<TextElement> elements;

  tearDownAll(notifier.dispose);

  List<InlineSpan> buildTransientSpan({
    required List<TextElement> initialElements,
    required BuildResult elementsBuilderResult,
  }) {
    notifier
      ..updateElements(initialElements)
      ..buildSpan(
        style: const TextStyle(),
        updatedDefinitionIndexes: [],
      )
      ..updateElements(elementsBuilderResult.elements)
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
      expect(elements.text, initialText);
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
            expect(spans.text, newText);
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
            expect(spans.text, newText);
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
              expect(spans.text, newText);
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
        expect(result.elements[0].text, 'a');
        expect(result.elements[0].matcherType, TextMatcher);
        expect(result.elements[0].offset, 0);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(1));
        expect(spans.text, text);
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
        expect(result.elements[0].text, '||abcde ');
        expect(result.elements[0].matcherType, TextMatcher);
        expect(result.elements[0].offset, 0);
        expect(result.elements[1].text, 'foo@example.com');
        expect(result.elements[1].matcherType, EmailMatcher);
        expect(result.elements[1].offset, 8);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[0].text, '||de ');
        expect(result.elements[0].matcherType, TextMatcher);
        expect(result.elements[0].offset, 0);
        expect(result.elements[1].text, 'foo@example.com');
        expect(result.elements[1].matcherType, EmailMatcher);
        expect(result.elements[1].offset, 5);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[0].text, 'ab||de ');
        expect(result.elements[0].matcherType, TextMatcher);
        expect(result.elements[0].offset, 0);
        expect(result.elements[1].text, 'foo@example.com');
        expect(result.elements[1].matcherType, EmailMatcher);
        expect(result.elements[1].offset, 7);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[0].text, 'abcde ||');
        expect(result.elements[0].matcherType, TextMatcher);
        expect(result.elements[0].offset, 0);
        expect(result.elements[1].text, 'foo@example.com');
        expect(result.elements[1].matcherType, EmailMatcher);
        expect(result.elements[1].offset, 8);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[0].text, 'ab||');
        expect(result.elements[0].matcherType, TextMatcher);
        expect(result.elements[0].offset, 0);
        expect(result.elements[1].text, 'foo@example.com');
        expect(result.elements[1].matcherType, EmailMatcher);
        expect(result.elements[1].offset, 4);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[0].text, 'foo@example.com');
        expect(result.elements[0].matcherType, EmailMatcher);
        expect(result.elements[0].offset, 0);
        expect(result.elements[1].text, '\n');
        expect(result.elements[1].matcherType, TextMatcher);
        expect(result.elements[1].offset, 15);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(5));
        expect(spans.text, text);
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
        expect(result.elements[0].text, 'example.com');
        expect(result.elements[0].matcherType, TextMatcher);
        expect(result.elements[0].offset, 0);
        expect(result.elements[1].text, '\n');
        expect(result.elements[1].matcherType, TextMatcher);
        expect(result.elements[1].offset, 11);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(5));
        expect(spans.text, text);
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
        expect(result.elements[0].text, 'abc||');
        expect(result.elements[0].matcherType, TextMatcher);
        expect(result.elements[0].offset, 0);
        expect(result.elements[1].text, 'example.com');
        expect(result.elements[1].matcherType, EmailMatcher);
        expect(result.elements[1].offset, 5);
        expect(result.elements[2].text, '\n');
        expect(result.elements[2].matcherType, TextMatcher);
        expect(result.elements[2].offset, 16);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[1].text, 'foo@example.com||');
        expect(result.elements[1].matcherType, EmailMatcher);
        expect(result.elements[1].offset, 6);
        expect(result.elements[2].text, '\n');
        expect(result.elements[2].matcherType, TextMatcher);
        expect(result.elements[2].offset, 23);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[1].text, 'foo@example.com');
        expect(result.elements[1].matcherType, EmailMatcher);
        expect(result.elements[1].offset, 6);
        expect(result.elements[2].text, '\n||');
        expect(result.elements[2].matcherType, TextMatcher);
        expect(result.elements[2].offset, 21);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[1].text, 'foo@example.com');
        expect(result.elements[1].matcherType, EmailMatcher);
        expect(result.elements[1].offset, 6);
        expect(result.elements[2].text, '||');
        expect(result.elements[2].matcherType, TextMatcher);
        expect(result.elements[2].offset, 21);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[2].text, '||');
        expect(result.elements[2].matcherType, TextMatcher);
        expect(result.elements[2].offset, 21);
        expect(result.elements[3].text, 'example.com/');
        expect(result.elements[3].matcherType, UrlMatcher);
        expect(result.elements[3].offset, 23);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[1].text, 'foo@example.com');
        expect(result.elements[1].matcherType, EmailMatcher);
        expect(result.elements[1].offset, 6);
        expect(result.elements[2].text, 'example.com/');
        expect(result.elements[2].matcherType, UrlMatcher);
        expect(result.elements[2].offset, 21);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(5));
        expect(spans.text, text);
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
        expect(result.elements[1].text, 'foo@example.com');
        expect(result.elements[1].matcherType, EmailMatcher);
        expect(result.elements[1].offset, 6);
        expect(result.elements[2].text, '/');
        expect(result.elements[2].matcherType, UrlMatcher);
        expect(result.elements[2].offset, 21);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(5));
        expect(spans.text, text);
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
        expect(result.elements[3].text, 'https://example.com/||');
        expect(result.elements[3].matcherType, UrlMatcher);
        expect(result.elements[3].offset, 22);
        expect(result.elements[4].text, ' abc ');
        expect(result.elements[4].matcherType, TextMatcher);
        expect(result.elements[4].offset, 44);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[3].text, 'https://example.com/');
        expect(result.elements[3].matcherType, UrlMatcher);
        expect(result.elements[3].offset, 22);
        expect(result.elements[4].text, '||abc ');
        expect(result.elements[4].matcherType, TextMatcher);
        expect(result.elements[4].offset, 42);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[4].text, ' abc ||');
        expect(result.elements[4].matcherType, TextMatcher);
        expect(result.elements[4].offset, 42);
        expect(result.elements[5].text, '#hashtag');
        expect(result.elements[5].matcherType, PatternMatcher);
        expect(result.elements[5].offset, 49);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[4].text, ' abc||');
        expect(result.elements[4].matcherType, TextMatcher);
        expect(result.elements[4].offset, 42);
        expect(result.elements[5].text, '#hashtag');
        expect(result.elements[5].matcherType, PatternMatcher);
        expect(result.elements[5].offset, 48);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[3].text, 'https://example.com/');
        expect(result.elements[3].matcherType, UrlMatcher);
        expect(result.elements[3].offset, 22);
        expect(result.elements[4].text, ' ');
        expect(result.elements[4].matcherType, TextMatcher);
        expect(result.elements[4].offset, 42);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[3].text, 'https://example||');
        expect(result.elements[3].matcherType, UrlMatcher);
        expect(result.elements[3].offset, 22);
        expect(result.elements[4].text, ' ');
        expect(result.elements[4].matcherType, TextMatcher);
        expect(result.elements[4].offset, 39);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[5].text, '#||tag');
        expect(result.elements[5].matcherType, PatternMatcher);
        expect(result.elements[5].offset, 47);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[4].text, ' abc ');
        expect(result.elements[4].matcherType, TextMatcher);
        expect(result.elements[4].offset, 42);
        expect(result.elements[5].text, '#hashtag||');
        expect(result.elements[5].matcherType, PatternMatcher);
        expect(result.elements[5].offset, 47);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[5].text, '#hash||');
        expect(result.elements[5].matcherType, PatternMatcher);
        expect(result.elements[5].offset, 47);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(6));
        expect(spans.text, text);
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
        expect(result.elements[4].text, ' abc ');
        expect(result.elements[4].matcherType, TextMatcher);
        expect(result.elements[4].offset, 42);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(5));
        expect(spans.text, text);
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
        expect(result.elements[4].text, ' abc');
        expect(result.elements[4].matcherType, TextMatcher);
        expect(result.elements[4].offset, 42);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(5));
        expect(spans.text, text);
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
        expect(result.elements[0].text, 'abcde ');
        expect(result.elements[0].matcherType, TextMatcher);
        expect(result.elements[0].offset, 0);
        expect(result.elements[1].text, 'foo||');
        expect(result.elements[1].matcherType, EmailMatcher);
        expect(result.elements[1].offset, 6);
        expect(result.elements[2].text, 'tag');
        expect(result.elements[2].matcherType, PatternMatcher);
        expect(result.elements[2].offset, 11);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(3));
        expect(spans.text, text);
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
        expect(result.elements[0].text, 'ab');
        expect(result.elements[0].matcherType, TextMatcher);
        expect(result.elements[0].offset, 0);
        expect(result.elements[1].text, 'ag');
        expect(result.elements[1].matcherType, PatternMatcher);
        expect(result.elements[1].offset, 2);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(2));
        expect(spans.text, text);
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
        expect(result.elements[0].text, 'g');
        expect(result.elements[0].matcherType, TextMatcher);
        expect(result.elements[0].offset, 0);

        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(1));
        expect(spans.text, text);
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
        expect(result.elements[1].text, 'bbb@ccc.ddd aaa bbb@ccc.ddd');
        expect(result.elements[1].matcherType, EmailMatcher);
        expect(result.elements[1].offset, 4);
        expect(result.elements[2].text, ' \n');
        expect(result.elements[2].matcherType, TextMatcher);
        expect(result.elements[2].offset, 31);

        final elements = await TextParser(matchers: matchers).parse(oldText);
        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(4));
        expect(spans.text, newText);
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
        expect(result.elements[1].text, 'bbb@ccc.ddd');
        expect(result.elements[1].matcherType, EmailMatcher);
        expect(result.elements[1].offset, 4);
        expect(result.elements[2].text, ' \n');
        expect(result.elements[2].matcherType, TextMatcher);
        expect(result.elements[2].offset, 15);

        final elements = await TextParser(matchers: matchers).parse(oldText);
        final spans = buildTransientSpan(
          initialElements: elements,
          elementsBuilderResult: result,
        );
        expect(spans, hasLength(4));
        expect(spans.text, newText);
      });
    });
  });
}
