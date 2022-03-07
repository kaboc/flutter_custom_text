import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';

class Example3 extends StatelessWidget {
  const Example3(this.output);

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
      onTap: (_, text) => output(text),
    );
  }
}
