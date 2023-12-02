import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';
import 'package:url_launcher/link.dart';

class RealHyperlinksExample extends StatelessWidget {
  const RealHyperlinksExample();

  @override
  Widget build(BuildContext context) {
    return CustomText(
      'Please visit [pub.dev](https://pub.dev/packages/custom_text) or '
      '[GitHub](https://github.com/kaboc/flutter_custom_text) for more '
      'details of this package.',
      definitions: [
        SpanDefinition(
          matcher: const LinkMatcher(),
          builder: (text, groups) {
            return WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Builder(
                builder: (context) {
                  return Link(
                    uri: Uri.parse(groups[1]!),
                    target: LinkTarget.blank,
                    builder: (context, openLink) {
                      return GestureDetector(
                        onTap: openLink,
                        child: Text(groups[0]!),
                      );
                    },
                  );
                },
              ),
            );
          },
          matchStyle: const TextStyle(color: Colors.blue),
          hoverStyle: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          mouseCursor: SystemMouseCursors.click,
        ),
      ],
    );
  }
}