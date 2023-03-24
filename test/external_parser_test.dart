import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'utils.dart';
import 'widgets.dart';

void main() {
  group('External parser (CustomText)', () {
    testWidgets('Styled acc to result of external parser', (tester) async {
      await tester.pumpWidget(
        const CustomTextWidget(
          'abc1234def5678',
          parserOptions: ParserOptions.external(_parseNumbers),
          definitions: [
            TextDefinition(
              matcher: NumberMatcher(),
              matchStyle: TextStyle(color: Color(0xFF222222)),
            ),
          ],
          style: TextStyle(color: Color(0xFF111111)),
        ),
      );
      await tester.pump();

      expect(findSpan('abc')?.style?.color, const Color(0xFF111111));
      expect(findSpan('1234')?.style?.color, const Color(0xFF222222));
      expect(findSpan('def')?.style?.color, const Color(0xFF111111));
      expect(findSpan('5678')?.style?.color, const Color(0xFF222222));
    });

    testWidgets('External parser reruns when text is updated', (tester) async {
      var text = 'abc1234def';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return CustomTextWidget(
              text,
              parserOptions: const ParserOptions.external(_parseNumbers),
              definitions: [
                TextDefinition(
                  matcher: const NumberMatcher(),
                  matchStyle: const TextStyle(color: Color(0xFF222222)),
                  onTap: (details) => setState(() => text = '123456def'),
                ),
              ],
              style: const TextStyle(color: Color(0xFF111111)),
            );
          },
        ),
      );
      await tester.pump();

      expect(findSpan('abc')?.style?.color, const Color(0xFF111111));
      expect(findSpan('1234')?.style?.color, const Color(0xFF222222));

      tapDownSpan(findSpan('1234'));
      tapUpSpan(findSpan('1234'));
      await tester.pumpAndSettle();

      expect(findSpan('abc'), isNull);
      expect(findSpan('123456')?.style?.color, const Color(0xFF222222));
    });
  });

  group('External parser (CustomTextEditingController)', () {
    testWidgets('TextElements are updated by external parser', (tester) async {
      final controller = CustomTextEditingController(
        text: 'abc1234def5678',
        parserOptions: const ParserOptions.external(_parseNumbers),
        definitions: const [TextDefinition(matcher: NumberMatcher())],
      );

      await tester.pumpWidget(
        TextFieldWidget(
          controller: controller,
          onDispose: controller.dispose,
        ),
      );
      await tester.pump();

      expect(controller.elements[0].text, equals('abc'));
      expect(controller.elements[0].matcherType, equals(TextMatcher));
      expect(controller.elements[1].text, equals('1234'));
      expect(controller.elements[1].matcherType, equals(NumberMatcher));
      expect(controller.elements[2].text, equals('def'));
      expect(controller.elements[2].matcherType, equals(TextMatcher));
      expect(controller.elements[3].text, equals('5678'));
      expect(controller.elements[3].matcherType, equals(NumberMatcher));
    });

    testWidgets('External parser reruns when text is updated', (tester) async {
      final controller = CustomTextEditingController(
        text: 'abc1234def5678',
        parserOptions: const ParserOptions.external(_parseNumbers),
        definitions: const [TextDefinition(matcher: NumberMatcher())],
      );

      await tester.pumpWidget(
        TextFieldWidget(
          controller: controller,
          onDispose: controller.dispose,
        ),
      );
      await tester.pump();

      expect(controller.elements, hasLength(4));
      expect(controller.elements[0].text, equals('abc'));
      expect(controller.elements[1].text, equals('1234'));

      controller.text = '123456def';
      await tester.pump();

      expect(controller.elements, hasLength(2));
      expect(controller.elements[0].text, equals('123456'));
      expect(controller.elements[1].text, equals('def'));
    });
  });
}

Future<List<TextElement>> _parseNumbers(String text) async {
  final elements = <TextElement>[];
  final len = text.length;
  var offset = 0;
  var wasNumeric = false;

  for (var i = 0; i < len; i++) {
    final isNumeric = _isNumeric(text[i]);
    final isEnd = i == len - 1;

    if (i > 0 && (isNumeric != wasNumeric || isEnd)) {
      final substring = text.substring(offset, isEnd ? i + 1 : i);
      elements.add(
        TextElement(
          substring,
          offset: offset,
          matcherType: wasNumeric ? NumberMatcher : TextMatcher,
        ),
      );
      offset = i;
    }

    wasNumeric = isNumeric;
  }

  return elements;
}

bool _isNumeric(String text) {
  return ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'].contains(text[0]);
}

class NumberMatcher extends TextMatcher {
  const NumberMatcher() : super('');
}
