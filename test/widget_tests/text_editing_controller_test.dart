import 'dart:async' show Completer;

import 'package:flutter/material.dart' show Material, Theme;
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart' show Builder;
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'utils.dart';
import 'widgets.dart';

void main() {
  const definitions = [
    TextDefinition(matcher: UrlMatcher()),
    TextDefinition(matcher: EmailMatcher()),
  ];

  group('Text style', () {
    testWidgets(
      '`style` of editable text (not that of controller) is used for '
      'top-level style of TextSpan even before initial parsing completes, '
      'and styles specified in controller are used for children',
      (tester) async {
        const style = TextStyle(color: Color(0x11111111));
        const matchStyle = TextStyle(color: Color(0x22222222));
        const fieldStyle = TextStyle(color: Color(0x33333333));

        final completer = Completer<List<TextElement>>();

        final controller = CustomTextEditingController(
          text: 'aaa bbb@example.com',
          parserOptions: ParserOptions.external((text) => completer.future),
          definitions: const [
            TextDefinition(
              matcher: EmailMatcher(),
              matchStyle: matchStyle,
            ),
          ],
          style: style,
        );
        addTearDown(controller.dispose);

        late TextStyle bodyLarge;
        await tester.pumpWidget(
          Material(
            child: Builder(
              builder: (context) {
                bodyLarge = Theme.of(context).textTheme.bodyLarge!;
                return TextFieldWidget(
                  controller: controller,
                  style: fieldStyle,
                );
              },
            ),
          ),
        );
        await tester.pump();

        expect(
          tester.findRenderEditable()!.text,
          TextSpan(
            style: bodyLarge.merge(fieldStyle),
            text: 'aaa bbb@example.com',
          ),
        );

        completer.complete(const [
          TextElement('aaa '),
          TextElement('bbb@example.com', matcherType: EmailMatcher),
        ]);
        await tester.pumpAndSettle();

        expect(
          tester.findRenderEditable()!.text,
          TextSpan(
            style: bodyLarge.merge(fieldStyle),
            children: const [
              TextSpan(text: 'aaa ', style: style),
              TextSpan(text: 'bbb@example.com', style: matchStyle),
            ],
          ),
        );
      },
    );
  });

  group('CustomTextEditingController with debounceDuration', () {
    testWidgets('Initial text is parsed right away', (tester) async {
      final controller = CustomTextEditingController(
        text: 'aaa bbb@example.com',
        definitions: definitions,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        TextFieldWidget(controller: controller),
      );
      await tester.pump();

      expect(controller.elements, hasLength(2));
      expect(controller.elements.first.text, 'aaa ');
      expect(controller.elements.first.matcherType, TextMatcher);
      expect(controller.elements.last.text, 'bbb@example.com');
      expect(controller.elements.last.matcherType, EmailMatcher);
    });

    testWidgets('Text is parsed on change', (tester) async {
      final controller = CustomTextEditingController(
        text: 'aaa bbb@example.com',
        definitions: definitions,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        TextFieldWidget(controller: controller),
      );
      await tester.pump();

      controller.text = 'aaa bbb https://example.com';
      await tester.pump();

      expect(controller.elements, hasLength(2));
      expect(controller.elements.first.text, 'aaa bbb ');
      expect(controller.elements.first.matcherType, TextMatcher);
      expect(controller.elements.last.text, 'https://example.com');
      expect(controller.elements.last.matcherType, UrlMatcher);
    });

    testWidgets('`fromValue` constructor works too', (tester) async {
      final controller = CustomTextEditingController.fromValue(
        const TextEditingValue(text: 'aaa bbb@example.com'),
        definitions: definitions,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        TextFieldWidget(controller: controller),
      );
      await tester.pump();

      expect(controller.elements, hasLength(2));
      expect(controller.elements.first.text, 'aaa ');
      expect(controller.elements.first.matcherType, TextMatcher);
      expect(controller.elements.last.text, 'bbb@example.com');
      expect(controller.elements.last.matcherType, EmailMatcher);
    });
  });

  group('CustomTextEditingController with debounceDuration', () {
    testWidgets('Initial parsing is not debounced', (tester) async {
      final controller = CustomTextEditingController(
        text: 'aaa bbb@example.com',
        definitions: definitions,
        debounceDuration: const Duration(milliseconds: 100),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        TextFieldWidget(controller: controller),
      );
      await tester.pump();

      expect(controller.elements, hasLength(2));
      expect(controller.elements.first.matcherType, TextMatcher);
      expect(controller.elements.last.matcherType, EmailMatcher);
    });

    testWidgets('Parsing is debounced', (tester) async {
      final controller = CustomTextEditingController(
        text: 'aaa bbb@example.com',
        definitions: definitions,
        debounceDuration: const Duration(milliseconds: 100),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        TextFieldWidget(controller: controller),
      );
      await tester.pump();

      controller.text = 'aaa bbb https://example.com';
      await tester.pump();

      expect(controller.elements, hasLength(2));
      expect(controller.elements.first.text, 'aaa ');
      expect(controller.elements.first.matcherType, TextMatcher);
      expect(controller.elements.last.text, 'bbb https://example.com');
      expect(controller.elements.last.matcherType, EmailMatcher);

      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.elements, hasLength(2));
      expect(controller.elements.first.text, 'aaa bbb ');
      expect(controller.elements.first.matcherType, TextMatcher);
      expect(controller.elements.last.text, 'https://example.com');
      expect(controller.elements.last.matcherType, UrlMatcher);
    });

    testWidgets('debounceDuration can be updated', (tester) async {
      final controller = CustomTextEditingController(
        text: 'aaa bbb@example.com',
        definitions: definitions,
        debounceDuration: const Duration(milliseconds: 100),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        TextFieldWidget(controller: controller),
      );
      await tester.pump();

      controller.text = 'aaa bbb https://example.com';
      await tester.pump();

      expect(controller.elements, hasLength(2));
      expect(controller.elements[0].text, 'aaa ');
      expect(controller.elements[0].matcherType, TextMatcher);
      expect(controller.elements[1].text, 'bbb https://example.com');
      expect(controller.elements[1].matcherType, EmailMatcher);

      await tester.pump(const Duration(milliseconds: 300));

      controller
        ..debounceDuration = null
        ..text = 'aaa bbb https://example.com https://ccc.dd/';
      await tester.pump();

      expect(controller.elements, hasLength(4));
      expect(controller.elements[0].text, 'aaa bbb ');
      expect(controller.elements[0].matcherType, TextMatcher);
      expect(controller.elements[1].text, 'https://example.com');
      expect(controller.elements[1].matcherType, UrlMatcher);
      expect(controller.elements[2].text, ' ');
      expect(controller.elements[2].matcherType, TextMatcher);
      expect(controller.elements[3].text, 'https://ccc.dd/');
      expect(controller.elements[3].matcherType, UrlMatcher);
    });
  });
}
