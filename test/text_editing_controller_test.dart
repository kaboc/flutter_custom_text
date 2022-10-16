import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text_editing_controller.dart';

class _EditorApp extends StatefulWidget {
  const _EditorApp({required this.controller, required this.onDispose});

  final CustomTextEditingController controller;
  final VoidCallback onDispose;

  @override
  State<_EditorApp> createState() => _EditorAppState();
}

class _EditorAppState extends State<_EditorApp> {
  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: TextField(controller: widget.controller),
      ),
    );
  }
}

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
        _EditorApp(controller: controller, onDispose: controller.dispose),
      );
      await tester.pump();

      expect(controller.elements, hasLength(2));
      expect(controller.elements.first.text, equals('aaa '));
      expect(controller.elements.first.matcherType, equals(TextMatcher));
      expect(controller.elements.last.text, equals('bbb@example.com'));
      expect(controller.elements.last.matcherType, equals(EmailMatcher));
    });

    testWidgets('Text is parsed on change', (tester) async {
      final controller = CustomTextEditingController(
        text: 'aaa bbb@example.com',
        definitions: definitions,
      );
      await tester.pumpWidget(
        _EditorApp(controller: controller, onDispose: controller.dispose),
      );
      await tester.pump();

      controller.text = 'aaa bbb@exa mple.com';
      await tester.pump();

      expect(controller.elements, hasLength(2));
      expect(controller.elements.first.text, equals('aaa bbb@exa '));
      expect(controller.elements.first.matcherType, equals(TextMatcher));
      expect(controller.elements.last.text, equals('mple.com'));
      expect(controller.elements.last.matcherType, equals(UrlMatcher));
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
        _EditorApp(controller: controller, onDispose: controller.dispose),
      );
      await tester.pump();

      expect(controller.elements, hasLength(2));
      expect(controller.elements.first.matcherType, equals(TextMatcher));
      expect(controller.elements.last.matcherType, equals(EmailMatcher));
    });

    testWidgets('Parsing is debounced', (tester) async {
      final controller = CustomTextEditingController(
        text: 'aaa bbb@example.com',
        definitions: definitions,
        debounceDuration: const Duration(milliseconds: 100),
      );
      await tester.pumpWidget(
        _EditorApp(controller: controller, onDispose: controller.dispose),
      );
      await tester.pump();

      controller.text = 'aaa bbb@exa mple.com';
      await tester.pump();

      expect(controller.elements, hasLength(2));
      expect(controller.elements.first.text, equals('aaa '));
      expect(controller.elements.first.matcherType, equals(TextMatcher));
      expect(controller.elements.last.text, equals('bbb@exa mple.com'));
      expect(controller.elements.last.matcherType, equals(EmailMatcher));

      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.elements, hasLength(2));
      expect(controller.elements.first.text, equals('aaa bbb@exa '));
      expect(controller.elements.first.matcherType, equals(TextMatcher));
      expect(controller.elements.last.text, equals('mple.com'));
      expect(controller.elements.last.matcherType, equals(UrlMatcher));
    });

    testWidgets('debounceDuration can be updated', (tester) async {
      final controller = CustomTextEditingController(
        text: 'aaa bbb@example.com',
        definitions: definitions,
        debounceDuration: const Duration(milliseconds: 100),
      );
      await tester.pumpWidget(
        _EditorApp(controller: controller, onDispose: controller.dispose),
      );
      await tester.pump();

      controller.text = 'aaa bbb@exa mple.com';
      await tester.pump();

      expect(controller.elements, hasLength(2));
      expect(controller.elements[0].matcherType, equals(TextMatcher));
      expect(controller.elements[1].text, equals('bbb@exa mple.com'));
      expect(controller.elements[1].matcherType, equals(EmailMatcher));

      await tester.pump(const Duration(milliseconds: 300));

      controller
        ..debounceDuration = null
        ..text = 'aaa bbb@exa mple.com https://ccc.dd/';
      await tester.pump();

      expect(controller.elements, hasLength(4));
      expect(controller.elements[1].text, equals('mple.com'));
      expect(controller.elements[1].matcherType, equals(UrlMatcher));
      expect(controller.elements[2].text, equals(' '));
      expect(controller.elements[2].matcherType, equals(TextMatcher));
      expect(controller.elements[3].text, equals('https://ccc.dd/'));
      expect(controller.elements[3].matcherType, equals(UrlMatcher));
    });
  });
}