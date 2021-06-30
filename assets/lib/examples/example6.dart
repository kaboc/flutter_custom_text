import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';

class Example6 extends StatefulWidget {
  const Example6(this.output);

  final Function(String) output;

  @override
  _Example6State createState() => _Example6State();
}

class _Example6State extends State<Example6> {
  final _recognizers = <String, TapGestureRecognizer>{};

  @override
  void dispose() {
    _recognizers.forEach((_, recognizer) => recognizer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomText(
      'Email 1: foo@example.com\n'
      'Email 2: bar@example.com',
      definitions: [
        SpanDefinition(
          matcher: const EmailMatcher(),
          builder: (text, groups) {
            _recognizers[text] ??= TapGestureRecognizer();

            return TextSpan(
              children: [
                const WidgetSpan(
                  child: Icon(
                    Icons.email,
                    color: Colors.blueGrey,
                    size: 18.0,
                  ),
                  alignment: PlaceholderAlignment.middle,
                ),
                const WidgetSpan(
                  child: SizedBox(width: 6.0),
                ),
                TextSpan(
                  text: text,
                  style: const TextStyle(color: Colors.lightBlue),
                  recognizer: _recognizers[text]!
                    ..onTap = () => widget.output(text),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
