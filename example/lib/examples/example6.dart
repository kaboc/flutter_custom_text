import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';

class Example6 extends StatelessWidget {
  const Example6(this.output);

  final void Function(String) output;

  @override
  Widget build(BuildContext context) {
    const matchStyle = TextStyle(color: Colors.blue);

    return CustomText(
      'Hover and click  >>  [logo]Flutter',
      definitions: [
        SpanDefinition(
          matcher: const PatternMatcher(r'\[logo\](\w+)'),
          builder: (text, groups) => TextSpan(
            children: [
              const WidgetSpan(child: FlutterLogo()),
              const WidgetSpan(child: SizedBox(width: 2.0)),
              TextSpan(text: groups.first),
            ],
          ),
        ),
      ],
      matchStyle: matchStyle,
      hoverStyle: matchStyle.copyWith(decoration: TextDecoration.underline),
      onTap: (details) => output(details.element.groups.first!),
    );
  }
}
