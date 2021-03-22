import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:custom_text/custom_text.dart';

class Experimental extends StatelessWidget {
  const Experimental(this.output);

  final void Function(String) output;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      'URL: https://example.com/\n'
      'Email: foo@example.com',
      definitions: const [
        TextDefinition(matcher: UrlMatcher()),
        TextDefinition(matcher: EmailMatcher()),
      ],
      matchStyle: const TextStyle(color: Colors.lightBlue),
      tapStyle: const TextStyle(color: Colors.lightGreen),
      onTap: (_, text) => output(text),
      // The mouse cursor changes on hover over a clickable element
      // if you opt in to the feature by setting `SystemMouseCursor`s
      // other than `SystemMouseCursors.basic`.
      cursorOnHover: SystemMouseCursors.click,
    );
  }
}
