import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';

class Example6Old extends StatelessWidget {
  const Example6Old(this.output);

  final void Function(String) output;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      'Email 1: [@] foo@example.com\n'
      'Email 2: [@] bar@example.com',
      definitions: [
        SpanDefinition(
          matcher: const PatternMatcher(r'\[@\]'),
          builder: (text, groups) => const WidgetSpan(
            child: Icon(
              Icons.email_outlined,
              color: Colors.blueGrey,
              size: 20.0,
            ),
          ),
        ),
        TextDefinition(
          matcher: const EmailMatcher(),
          matchStyle: const TextStyle(color: Colors.lightBlue),
          onTap: (details) => output(details.actionText),
        ),
      ],
    );
  }
}
