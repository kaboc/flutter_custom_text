import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';

class Example4 extends StatelessWidget {
  const Example4(this.output);

  final void Function(String) output;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      'Hello world! #CustomText',
      definitions: const [
        TextDefinition(
          // Matcher for hashtags (provided a hashtag is defined as a string
          // that starts with "#" followed by an alphabet and then alpha-
          // numerics, and is enclosed with white spaces)
          matcher: PatternMatcher(r'#[a-zA-Z][a-zA-Z0-9]{1,}(?=\s|$)'),
          // TODO: Replace above with below if Safari supports lookbehind.
          // matcher:
          //     PatternMatcher(r'(?<=\s|^)\#[a-zA-Z][a-zA-Z0-9]{1,}(?=\s|$)'),
        ),
      ],
      matchStyle: const TextStyle(color: Colors.lightBlue),
      tapStyle: const TextStyle(color: Colors.lightGreen),
      onTap: (_, tag) => output(tag),
    );
  }
}
