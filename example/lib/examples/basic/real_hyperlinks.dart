import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';
import 'package:url_launcher/link.dart';

class RealHyperlinksExample extends StatelessWidget {
  const RealHyperlinksExample();

  @override
  Widget build(BuildContext context) {
    const matchStyle = TextStyle(color: Colors.blue);

    return CustomText(
      'Please visit [pub.dev](https://pub.dev/packages/custom_text) or '
      '[GitHub](https://github.com/kaboc/flutter_custom_text) for more '
      'details of this package.',
      definitions: [
        SpanDefinition(
          matcher: const LinkMatcher(),
          builder: (element) {
            return WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Link(
                uri: Uri.parse(element.groups[1]!),
                target: LinkTarget.blank,
                builder: (context, openLink) {
                  return GestureDetector(
                    onTap: openLink,
                    child: Text(element.groups[0]!),
                  );
                },
              ),
            );
          },
          matchStyle: matchStyle,
          hoverStyle: matchStyle.copyWith(
            decoration: TextDecoration.underline,
          ),
          mouseCursor: SystemMouseCursors.click,
          onTap: (_) {
            // no-op
            // This callback is only necessary to make hoverStyle
            // applied on tap on mobile devices.
          },
        ),
      ],
    );
  }
}
