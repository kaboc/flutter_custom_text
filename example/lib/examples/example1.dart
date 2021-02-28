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
      body: ListView(
        children: [
          Description(description, filename: filename),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CustomText(
              'URL: https://example.com/\n'
              'Email: foo@example.com',
              definitions: [
                TextDefinition(matcher: UrlMatcher()),
                TextDefinition(matcher: EmailMatcher()),
              ],
              matchStyle: TextStyle(color: Colors.lightBlue),
              // `tapStyle` is not used if both `onTap` and `onLongTap`
              // are null or not set.
              tapStyle: TextStyle(color: Colors.yellow),
              onTap: null,
            ),
          ),
        ],
      ),
    );
  }
}
