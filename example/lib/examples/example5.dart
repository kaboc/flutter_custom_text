import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';

class Example5 extends StatelessWidget {
  const Example5(this.output);

  final void Function(String) output;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      'Markdown-style link\n'
      '[Tap here](Tapped!)',
      definitions: [
        SelectiveDefinition(
          matcher: const LinkMatcher(),
          // `shownText` is used to choose the string to display.
          // It receives a list of strings that have matched the
          // fragments enclosed in parentheses within the match pattern.
          shownText: (groups) => groups[0]!,
          // `actionText` is used to choose the string to be passed
          // to the `onTap`, `onLongPress` and `onGesture` handlers.
          actionText: (groups) => groups[1]!,
        ),
      ],
      matchStyle: const TextStyle(color: Colors.lightBlue),
      tapStyle: const TextStyle(color: Colors.lightGreen),
      onTap: (details) => output(details.actionText),
    );
  }
}
