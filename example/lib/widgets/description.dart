import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';

import 'package:custom_text_example/code_view_page.dart';

class Description extends StatelessWidget {
  const Description(this.description, {required this.filename});

  final String description;
  final String filename;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade300,
      padding: const EdgeInsets.all(16.0),
      child: DefaultTextStyle(
        style: Theme.of(context)
            .textTheme
            .bodyText2!
            .copyWith(fontSize: 14.0, height: 1.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              filename,
              definitions: [
                TextDefinition(
                  matcher: const _FilenameMatcher(),
                  matchStyle: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  tapStyle: TextStyle(color: Colors.teal.shade300),
                  onTap: (filename) => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => CodeViewPage(filename: filename),
                    ),
                  ),
                ),
              ],
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            CustomText(
              description,
              definitions: [
                SelectiveDefinition(
                  matcher: const _CodeMatcher(),
                  labelSelector: (groups) => groups[0] ?? '',
                  matchStyle: const TextStyle(
                    color: Colors.indigo,
                    // fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilenameMatcher extends TextMatcher {
  const _FilenameMatcher() : super(r'\w+\.dart');
}

class _CodeMatcher extends TextMatcher {
  const _CodeMatcher() : super(r'`(.+?)`');
}
