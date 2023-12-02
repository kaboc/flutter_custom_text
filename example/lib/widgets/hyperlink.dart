import 'package:custom_text/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

class Hyperlink extends StatelessWidget {
  const Hyperlink({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Link(
      uri: Uri.parse(url),
      target: LinkTarget.blank,
      builder: (context, followLink) {
        return CustomText(
          '$label[i]',
          definitions: [
            SpanDefinition(
              matcher: const PatternMatcher(r'(.+)\[i\]'),
              builder: (text, groups) => TextSpan(
                children: [
                  TextSpan(text: groups.first),
                  const WidgetSpan(child: SizedBox(width: 2.0)),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.open_in_new,
                      size: 10.0,
                      color: Colors.lightBlue.shade100,
                    ),
                  ),
                ],
              ),
              hoverStyle: const TextStyle(decoration: TextDecoration.underline),
              onTap: (_) => followLink!(),
            ),
          ],
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: Colors.lightBlue.shade100),
        );
      },
    );
  }
}
