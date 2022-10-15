import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';

class Example8 extends StatelessWidget {
  const Example8(this.output);

  final void Function(String) output;

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return CustomText.selectable(
      'URL: https://example.com/\n'
      'Email: foo@example.com\n'
      'Tel: +1-012-3456-7890',
      definitions: [
        const TextDefinition(matcher: UrlMatcher()),
        const TextDefinition(matcher: EmailMatcher()),
        TextDefinition(
          // TODO: Replace with default TelMatcher if Safari supports lookbehind
          matcher: const TelMatcher(r'(?:\+?[1-9]\d{0,4})?(?:[- ]?\d{1,4})+'),
          matchStyle: const TextStyle(
            color: Colors.green,
            decoration: TextDecoration.underline,
          ),
          tapStyle: const TextStyle(color: Colors.orange),
          onTap: output,
          onLongPress: (tel) => output('[Long press on Tel#] $tel'),
        ),
      ],
      matchStyle: const TextStyle(
        color: Colors.lightBlue,
        decoration: TextDecoration.underline,
      ),
      tapStyle: const TextStyle(color: Colors.indigo),
      onTap: (type, text) => output(text),
      onLongPress: (type, text) => output('[Long press] $text'),
    );
  }
}
