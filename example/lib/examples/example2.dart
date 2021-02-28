import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';

import 'package:custom_text_example/widgets/appbar.dart';
import 'package:custom_text_example/widgets/description.dart';

class Example2 extends StatelessWidget {
  const Example2(this.title, this.filename, this.description);

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
              'URL: https://example.com/\n'
              'Email: foo@example.com\n'
              'Tel: +1-012-3456-7890',
              definitions: [
                const TextDefinition(matcher: UrlMatcher()),
                const TextDefinition(matcher: EmailMatcher()),
                TextDefinition(
                  matcher: const TelMatcher(),
                  // `matchStyle`, `tapStyle`, `onTap` and `onLongTap` here
                  // override the equivalent parameters of CustomText.
                  matchStyle: const TextStyle(
                    color: Colors.green,
                    decoration: TextDecoration.underline,
                  ),
                  tapStyle: const TextStyle(color: Colors.orange),
                  onTap: (tel) => print('tel: $tel'),
                  onLongTap: (tel) => print('[Long-tapped] tel: $tel'),
                ),
              ],
              matchStyle: const TextStyle(
                color: Colors.lightBlue,
                decoration: TextDecoration.underline,
              ),
              tapStyle: const TextStyle(color: Colors.indigo),
              onTap: (type, text) => print('$type: $text'),
              onLongTap: (type, text) => print('[Long-tapped] $type: $text'),
            ),
          ),
        ],
      ),
    );
  }
}
