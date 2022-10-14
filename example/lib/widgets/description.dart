import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';
import 'package:go_router/go_router.dart';

class Description extends StatelessWidget {
  const Description({required this.page, required this.description});

  final int page;
  final String description;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyText1!,
      child: Container(
        width: double.infinity,
        color: Colors.blueGrey.shade400,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              'example$page.dart',
              definitions: [
                TextDefinition(
                  matcher: const _FilenameMatcher(),
                  matchStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  tapStyle: const TextStyle(),
                  onTap: (_) => context.go('/$page/code'),
                ),
              ],
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.lightBlue.shade100,
              ),
            ),
            const SizedBox(height: 12.0),
            CustomText(
              description,
              definitions: [
                SelectiveDefinition(
                  matcher: const _CodeMatcher(),
                  labelSelector: (groups) => groups[0] ?? '',
                  matchStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              style: const TextStyle(color: Colors.white70),
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
  const _CodeMatcher() : super('`(.+?)`');
}
