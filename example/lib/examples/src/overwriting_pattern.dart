import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';

class OverwritingPatternExample extends StatelessWidget {
  const OverwritingPatternExample(this.output);

  final void Function(String) output;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      'Tel: +1-012-3456-7890',
      definitions: const [
        TextDefinition(matcher: TelMatcher(r'\d{3}-\d{4}-\d{4}')),
      ],
      matchStyle: const TextStyle(color: Colors.lightBlue),
      tapStyle: const TextStyle(color: Colors.lightGreen),
      onTap: (details) => output(details.actionText),
    );
  }
}
