import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';
import 'package:go_router/go_router.dart';

class Description extends StatelessWidget {
  const Description({
    required this.path,
    required this.filename,
    required this.description,
  });

  final String path;
  final String filename;
  final String description;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodySmall!,
      child: Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.85),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              filename,
              definitions: [
                TextDefinition(
                  matcher: const _FilenameMatcher(),
                  hoverStyle: const TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                  onTap: (_) => context.go('$path/code'),
                ),
              ],
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue.shade100,
              ),
            ),
            const SizedBox(height: 12.0),
            CustomText(
              description,
              definitions: [
                SelectiveDefinition(
                  matcher: const _CodeMatcher(),
                  shownText: (element) => element.groups[0] ?? '',
                  matchStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
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
