import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';

class PreBuilderExample extends StatelessWidget {
  const PreBuilderExample();

  @override
  Widget build(BuildContext context) {
    return CustomText(
      'KISS is an acronym for "Keep It Simple, Stupid!".',
      definitions: const [
        TextDefinition(
          // This pattern is used for parsing the TextSpan built
          // by preBuilder, not for the original text.
          matcher: PatternMatcher('[A-Z]'),
          matchStyle: TextStyle(color: Colors.red),
        ),
      ],
      preBuilder: CustomSpanBuilder(
        definitions: [
          const TextDefinition(
            // This pattern is used for parsing the original text.
            matcher: PatternMatcher('KISS|Keep.+Stupid!'),
            matchStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
