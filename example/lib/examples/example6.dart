import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';

class Example6 extends StatelessWidget {
  const Example6(this.output);

  final Function(String) output;

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
              Icons.email,
              color: Colors.blueGrey,
              size: 18.0,
            ),
            alignment: PlaceholderAlignment.middle,
          ),
        ),
        TextDefinition(
          matcher: const EmailMatcher(),
          matchStyle: const TextStyle(color: Colors.lightBlue),
          onTap: (email) => output(email),
        ),
      ],
    );
  }
}
