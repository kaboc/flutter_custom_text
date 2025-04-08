import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ExpressiveTextExample extends StatefulWidget {
  const ExpressiveTextExample();

  @override
  State<ExpressiveTextExample> createState() => _ExpressiveTextExampleState();
}

class _ExpressiveTextExampleState extends State<ExpressiveTextExample> {
  String _text = "*italic* **bold** ~~lineThrough~~ 'code'\n"
      '{{dash}} [Link](https://pub.dev/packages/custom_text) {{dash}}\n\n'
      'Urls and email addresses are automatically turned into links, '
      'e.g. https://pub.dev/packages/custom_text';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpressiveText(
          _text,
          icons: const {
            '{{dash}}': Icon(Icons.flutter_dash),
          },
          onLinkTap: launchUrlString,
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          initialValue: _text,
          maxLines: null,
          onChanged: (text) => setState(() => _text = text),
        ),
      ],
    );
  }
}

class ExpressiveText extends StatelessWidget {
  const ExpressiveText(
    this.text, {
    super.key,
    this.icons = const {},
    this.codeStyle,
    this.linkColor,
    this.iconColor,
    this.onLinkTap,
  });

  final String text;
  final Map<String, Widget> icons;
  final TextStyle? codeStyle;
  final Color? linkColor;
  final Color? iconColor;
  final void Function(String url)? onLinkTap;

  @override
  Widget build(BuildContext context) {
    final textColor = DefaultTextStyle.of(context).style.color;

    final linkMatchStyle = TextStyle(
      color: linkColor ?? Colors.blue,
    );
    final linkHoverStyle = TextStyle(
      color: linkColor ?? Colors.blue,
      decoration: TextDecoration.underline,
      decorationColor: Colors.blue,
    );

    return CustomText(
      text,
      definitions: [
        SelectiveDefinition(
          matcher: const PatternMatcher(r'\*\*\*(.+?)\*\*\*'),
          shownText: (element) => element.groups.first!,
          matchStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        SelectiveDefinition(
          matcher: const PatternMatcher(r'\*\*(.+?)\*\*'),
          shownText: (element) => element.groups.first!,
          matchStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        SelectiveDefinition(
          matcher: const PatternMatcher(r'\*(.+?)\*'),
          shownText: (element) => element.groups.first!,
          matchStyle: const TextStyle(
            fontStyle: FontStyle.italic,
          ),
        ),
        SelectiveDefinition(
          matcher: const PatternMatcher('~~(.+?)~~'),
          shownText: (element) => element.groups.first!,
          matchStyle: const TextStyle(
            decoration: TextDecoration.lineThrough,
          ),
        ),
        SelectiveDefinition(
          matcher: const PatternMatcher("'(.+?)'"),
          shownText: (element) => element.groups.first!,
          matchStyle: codeStyle ??
              TextStyle(
                backgroundColor: textColor?.withOpacity(0.1),
              ),
        ),
        SelectiveDefinition(
          matcher: const LinkMatcher(),
          shownText: (element) => element.groups.first!,
          actionText: (element) => element.groups.last!,
          matchStyle: linkMatchStyle,
          hoverStyle: linkHoverStyle,
          onTap: onLinkTap == null
              ? null
              : (details) => onLinkTap!(details.actionText),
        ),
        TextDefinition(
          matcher: const UrlMatcher(),
          matchStyle: linkMatchStyle,
          hoverStyle: linkHoverStyle,
          onTap: onLinkTap == null
              ? null
              : (details) => onLinkTap!(details.actionText),
        ),
        TextDefinition(
          matcher: const EmailMatcher(),
          matchStyle: linkMatchStyle,
          hoverStyle: linkHoverStyle,
          onTap: onLinkTap == null
              ? null
              : (details) => onLinkTap!('mailto:${details.actionText}'),
        ),
        if (icons.isNotEmpty)
          SpanDefinition(
            matcher: ExactMatcher(icons.keys),
            builder: (element) => TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Builder(
                    builder: (context) {
                      final textStyle = DefaultTextStyle.of(context).style;
                      return Theme(
                        data: Theme.of(context).copyWith(
                          iconTheme: IconThemeData(
                            size: textStyle.fontSize,
                            color: iconColor ??
                                textStyle.color ??
                                Colors.transparent,
                          ),
                        ),
                        child: icons[element.text]!,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
