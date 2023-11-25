import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';

class Example5 extends StatelessWidget {
  const Example5(this.output);

  final void Function(String) output;

  @override
  Widget build(BuildContext context) {
    const matchStyle = TextStyle(color: Colors.blue);

    return CustomText(
      'Tap [here](Tapped!)',
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
      matchStyle: matchStyle,
      hoverStyle: matchStyle.copyWith(decoration: TextDecoration.underline),
      onTap: (details) => output(details.actionText),
    );
  }
}
