import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';

import 'package:custom_text_example/widgets/appbar.dart';
import 'package:custom_text_example/widgets/description.dart';

class Example1 extends StatelessWidget {
  const Example1(this.title, this.filename, this.description);

  final String title;
  final String filename;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, title: title, filename: filename),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Description(description, filename: filename),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomText(
              'URL: https://example.com/\n'
              'Email: foo@example.com',
              definitions: const [
                TextDefinition(matcher: UrlMatcher()),
                TextDefinition(matcher: EmailMatcher()),
              ],
              matchStyle: const TextStyle(color: Colors.lightBlue),
              // `tapStyle` does not work on tap even if set
              // unless `onTap` / `onLongTap` is set.
              tapStyle: const TextStyle(color: Colors.yellow),
              //onTap: (text) => print(text),
            ),
          ),
        ],
      ),
    );
  }
}
