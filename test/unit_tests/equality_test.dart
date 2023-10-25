import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

void main() {
  group('Definitions', () {
    test('Definitions with same values and runtimeType are equal', () {
      // ignore: prefer_const_constructors
      final definition1 = TextDefinition(
        matcher: const UrlMatcher(),
        matchStyle: const TextStyle(fontSize: 10.0),
        tapStyle: const TextStyle(fontSize: 11.0),
        hoverStyle: const TextStyle(fontSize: 12.0),
        mouseCursor: SystemMouseCursors.click,
      );

      // ignore: prefer_const_constructors
      final definition2 = TextDefinition(
        matcher: const UrlMatcher(),
        matchStyle: const TextStyle(fontSize: 10.0),
        tapStyle: const TextStyle(fontSize: 11.0),
        hoverStyle: const TextStyle(fontSize: 12.0),
        mouseCursor: SystemMouseCursors.click,
      );

      expect(definition1, definition2);
      expect(definition1.hashCode, definition2.hashCode);
    });

    test(
      'Definitions with same values and different runtimeTypes are not equal',
      () {
        const definition1 = _Definition1(matcher: UrlMatcher());
        const definition2 = _Definition2(matcher: UrlMatcher());

        expect(definition1, isNot(definition2));
        expect(definition1.hashCode, isNot(definition2.hashCode));
      },
    );
  });

  group('ParserOptions', () {
    test('ParserOptions with same values and runtimeType are equal', () {
      // ignore: prefer_const_constructors
      final options1 = ParserOptions();
      // ignore: prefer_const_constructors
      final options2 = ParserOptions();

      expect(options1, options2);
      expect(options1.hashCode, options2.hashCode);
    });

    test(
      'ParserOptions with same values and different runtimeTypes are not equal',
      () {
        const options1 = _ParserOptions1();
        const options2 = _ParserOptions2();

        expect(options1, isNot(options2));
        expect(options1.hashCode, isNot(options2.hashCode));
      },
    );
  });
}

class _Definition1 extends TextDefinition {
  const _Definition1({required super.matcher});
}

class _Definition2 extends TextDefinition {
  const _Definition2({required super.matcher});
}

class _ParserOptions1 extends ParserOptions {
  const _ParserOptions1();
}

class _ParserOptions2 extends ParserOptions {
  const _ParserOptions2();
}
