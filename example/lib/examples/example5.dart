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
          // `labelSelector` is used to choose the string to show.
          // `groups` provided to `labelSelector` is an array of
          // strings matching the fragments enclosed in parentheses
          // within the match pattern.
          labelSelector: (groups) => groups[0]!,
          // `tapSelector` is used to choose the string to be passed
          // to the `onTap` and `onLongPress` callbacks.
          tapSelector: (groups) => groups[1]!,
        ),
      ],
      matchStyle: const TextStyle(color: Colors.lightBlue),
      tapStyle: const TextStyle(color: Colors.lightGreen),
      onTap: (_, text) => output(text),
    );
  }
}
