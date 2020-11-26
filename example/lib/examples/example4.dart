import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';

import 'package:custom_text_example/widgets/appbar.dart';
import 'package:custom_text_example/widgets/description.dart';

class Example4 extends StatelessWidget {
  const Example4(this.title, this.filename, this.description);

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
              'Hello world! #CustomText',
              definitions: const [
                TextDefinition(matcher: HashTagMatcher()),
              ],
              matchStyle: const TextStyle(color: Colors.lightBlue),
            ),
          ),
        ],
      ),
    );
  }
}

/// Matcher for hashtags (provided a hashtag is defined as a string
/// that starts with "#" followed by an alphabet and then alphanumerics,
/// and is enclosed with white spaces)
class HashTagMatcher extends TextMatcher {
  const HashTagMatcher() : super(r'(?<=\s|^)\#[a-zA-Z][a-zA-Z0-9]{1,}(?=\s|$)');
}
