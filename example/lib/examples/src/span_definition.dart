import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';

class SpanDefinitionExample extends StatelessWidget {
  const SpanDefinitionExample(this.output);

  final void Function(String) output;

  @override
  Widget build(BuildContext context) {
    const matchStyle = TextStyle(color: Colors.blue);

    return CustomText(
      'Hover and click  >>  @@Flutter',
      definitions: [
        SpanDefinition(
          matcher: ExactMatcher(const ['>>']),
          builder: (text, groups) => const WidgetSpan(
            child: Icon(
              Icons.keyboard_double_arrow_right,
              color: Colors.grey,
              size: 18.0,
            ),
          ),
        ),
        SpanDefinition(
          matcher: const PatternMatcher(r'@@(\w+)'),
          builder: (text, groups) => TextSpan(
            children: [
              const WidgetSpan(child: FlutterLogo()),
              const WidgetSpan(child: SizedBox(width: 2.0)),
              TextSpan(text: groups.first),
            ],
          ),
          matchStyle: matchStyle,
          hoverStyle: matchStyle.copyWith(decoration: TextDecoration.underline),
          onTap: (details) => output(details.element.groups.first!),
        ),
      ],
    );
  }
}
