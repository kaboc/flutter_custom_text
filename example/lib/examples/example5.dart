import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';

import 'package:custom_text_example/widgets/appbar.dart';
import 'package:custom_text_example/widgets/description.dart';

class Example5 extends StatelessWidget {
  const Example5(this.title, this.filename, this.description);

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
              'Markdown-style link\n'
              '[Tap here](Tapped!)',
              definitions: [
                SelectiveDefinition(
                  matcher: const MdLinkMatcher(),
                  // `labelSelector` is used to choose the string to show.
                  // `groups` provided to `labelSelector` is an array of
                  // strings matching the fragments enclosed with parentheses
                  // within the match pattern.
                  labelSelector: (groups) => groups[0],
                  // `tapSelector` is used to choose the string to be passed
                  // to the `onTap` and `onLongTap` callbacks.
                  tapSelector: (groups) => groups[1],
                ),
              ],
              matchStyle: const TextStyle(color: Colors.lightBlue),
              tapStyle: const TextStyle(color: Colors.green),
              onTap: (_, text) => print(text),
            ),
          ),
        ],
      ),
    );
  }
}

/// matcher for markdown-style links (like [shown label](https://example.com/))
class MdLinkMatcher extends TextMatcher {
  const MdLinkMatcher() : super(r'\[(.+?)\]\((.+?)\)');
}
