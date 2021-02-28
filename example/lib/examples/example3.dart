import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';

import 'package:custom_text_example/widgets/appbar.dart';
import 'package:custom_text_example/widgets/description.dart';

class Example3 extends StatelessWidget {
  const Example3(this.title, this.filename, this.description);

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
              'Tel: +1-012-3456-7890',
              definitions: const [
                // Match patterns of preset matchers can be overwritten.
                TextDefinition(matcher: TelMatcher(r'\d{3}-\d{4}-\d{4}')),
              ],
              matchStyle: const TextStyle(color: Colors.lightBlue),
              onTap: (_, text) => print(text),
            ),
          ),
        ],
      ),
    );
  }
}
