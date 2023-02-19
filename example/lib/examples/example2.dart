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
          // TODO: Use default TelMatcher if Safari supports lookbehind.
          matcher: const TelMatcher(r'(?:\+?[1-9]\d{0,4})?(?:[- ]?\d{1,4})+'),
          // Styles and handlers specified in a definition take
          // precedence over the equivalent arguments of CustomText.
          matchStyle: const TextStyle(
            color: Colors.green,
            decoration: TextDecoration.underline,
          ),
          tapStyle: const TextStyle(color: Colors.orange),
          onTap: (details) => output(details.actionText),
          onLongPress: (details) =>
              output('[Long press on Tel#] ${details.actionText}'),
        ),
      ],
      matchStyle: const TextStyle(
        color: Colors.lightBlue,
        decoration: TextDecoration.underline,
      ),
      tapStyle: const TextStyle(color: Colors.indigo),
      onTap: (details) => output(details.actionText),
      onLongPress: (details) => output('[Long press] ${details.actionText}'),
    );
  }
}
