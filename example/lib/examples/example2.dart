import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';

class Example2 extends StatelessWidget {
  const Example2(this.output);

  final void Function(String) output;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      'URL: https://example.com/\n'
      'Email: foo@example.com\n'
      'Tel: +1-012-3456-7890',
      definitions: [
        const TextDefinition(matcher: UrlMatcher()),
        const TextDefinition(matcher: EmailMatcher()),
        TextDefinition(
          matcher: const TelMatcher(),
          // `matchStyle`, `tapStyle`, `onTap` and `onLongTap` here
          // override the equivalent parameters of CustomText.
          matchStyle: const TextStyle(
            color: Colors.green,
            decoration: TextDecoration.underline,
          ),
          tapStyle: const TextStyle(color: Colors.orange),
          onTap: (tel) => output(tel),
          onLongTap: (tel) => output('[Long tap] $tel'),
        ),
      ],
      matchStyle: const TextStyle(
        color: Colors.lightBlue,
        decoration: TextDecoration.underline,
      ),
      tapStyle: const TextStyle(color: Colors.indigo),
      onTap: (type, text) => output(text),
      onLongTap: (type, text) => output('[Long tap] $text'),
    );
  }
}
