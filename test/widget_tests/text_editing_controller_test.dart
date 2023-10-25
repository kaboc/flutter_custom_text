import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'widgets.dart';

void main() {
  const definitions = [
    TextDefinition(matcher: UrlMatcher()),
    TextDefinition(matcher: EmailMatcher()),
  ];

  group('CustomTextEditingController with debounceDuration', () {
    testWidgets('Initial text is parsed right away', (tester) async {
      final controller = CustomTextEditingController(
        text: 'aaa bbb@example.com',
        definitions: definitions,
      );
      await tester.pumpWidget(
        TextFieldWidget(controller: controller, onDispose: controller.dispose),
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
      await tester.pumpWidget(
        TextFieldWidget(controller: controller, onDispose: controller.dispose),
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
      await tester.pumpWidget(
        TextFieldWidget(controller: controller, onDispose: controller.dispose),
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
      await tester.pumpWidget(
        TextFieldWidget(controller: controller, onDispose: controller.dispose),
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
      await tester.pumpWidget(
        TextFieldWidget(controller: controller, onDispose: controller.dispose),
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
      await tester.pumpWidget(
        TextFieldWidget(controller: controller, onDispose: controller.dispose),
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
