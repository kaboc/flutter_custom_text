import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';

class FillInBlanksExample extends StatelessWidget {
  const FillInBlanksExample();

  @override
  Widget build(BuildContext context) {
    return const FillInBlanks(
      'O Romeo, Romeo, {{wherefore}} {{art}} {{thou}} Romeo? '
      'Deny {{thy}} father and refuse {{thy}} name; '
      'Or, if {{thou}} {{wilt}} not, be but sworn my love, '
      "And I'll no longer be a Capulet.",
    );
  }
}

class FillInBlanks extends StatelessWidget {
  const FillInBlanks(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    const hoverColor = Colors.green;

    return CustomText(
      text,
      style: const TextStyle(fontSize: 24.0),
      definitions: [
        SpanDefinition(
          matcher: const PatternMatcher('{{(.+?)}}'),
          hoverStyle: const TextStyle(
            color: hoverColor,
            fontWeight: FontWeight.bold,
          ),
          builder: (element) {
            return WidgetSpan(
              baseline: TextBaseline.alphabetic,
              alignment: PlaceholderAlignment.baseline,
              child: Builder(
                builder: (context) {
                  final style = DefaultTextStyle.of(context).style;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: style.color == hoverColor
                        ? Text(element.groups.first!)
                        : ColoredBox(
                            color: Colors.teal.shade300,
                            child: Text(
                              element.groups.first!,
                              style: const TextStyle(
                                color: Colors.transparent,
                                fontWeight: FontWeight.bold,
                              ),
                              textHeightBehavior: const TextHeightBehavior(
                                applyHeightToFirstAscent: false,
                                applyHeightToLastDescent: false,
                              ),
                            ),
                          ),
                  );
                },
              ),
            );
          },
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
