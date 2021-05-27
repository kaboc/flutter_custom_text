import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';

class Example7 extends StatelessWidget {
  const Example7(this.output);

  final void Function(String) output;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      'URL: https://example.com/\n'
      'Email: foo@example.com',
      definitions: [
        const TextDefinition(
          matcher: UrlMatcher(),
          matchStyle: TextStyle(
            color: Colors.grey,
            decoration: TextDecoration.lineThrough,
          ),
          // `SystemMouseCursors.forbidden` is used for email addresses.
          mouseCursor: SystemMouseCursors.forbidden,
        ),
        TextDefinition(
          matcher: const EmailMatcher(),
          matchStyle: const TextStyle(
            color: Colors.lightBlue,
            decoration: TextDecoration.underline,
          ),
          tapStyle: const TextStyle(color: Colors.green),
          // Text is shadowed while the mouse pointer hovers over it.
          hoverStyle: TextStyle(
            color: Colors.lightBlue,
            shadows: [_shadow(Colors.lightBlue)],
          ),
          // `SystemMouseCursors.click` is used for URLs automatically
          // even if `mouseCursor` is not set because a tap has been
          // enabled by the `onTap` callback.
          onTap: (text) => output(text),
        ),
      ],
    );
  }

  Shadow _shadow(MaterialColor color) {
    return Shadow(
      offset: const Offset(2.0, 2.0),
      blurRadius: 4.0,
      color: color.shade400,
    );
  }
}
