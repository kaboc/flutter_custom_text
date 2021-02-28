import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';

import 'package:custom_text_example/widgets/appbar.dart';
import 'package:custom_text_example/widgets/description.dart';

class Example6 extends StatelessWidget {
  const Example6(this.title, this.filename, this.description);

  final String title;
  final String filename;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: title, filename: filename),
      body: ListView(
        children: [
          Description(description, filename: filename),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomText(
              'Email 1: foo@example.com\n'
              'Email 2: bar@example.com',
              definitions: [
                SpanDefinition(
                  matcher: const EmailMatcher(),
                  builder: (text, groups) => TextSpan(
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
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => print(text),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
