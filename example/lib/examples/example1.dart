import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';

class Example1 extends StatelessWidget {
  const Example1();

  @override
  Widget build(BuildContext context) {
    return const CustomText(
      'URL: https://example.com/\n'
      'Email: foo@example.com',
      definitions: [
        TextDefinition(matcher: UrlMatcher()),
        TextDefinition(matcher: EmailMatcher()),
      ],
      matchStyle: TextStyle(color: Colors.lightBlue),
    );
  }
}
