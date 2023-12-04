import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';

class CustomTextSpansExample extends StatelessWidget {
  const CustomTextSpansExample(this.output);

  final void Function(String) output;

  @override
  Widget build(BuildContext context) {
    return CustomText.spans(
      style: const TextStyle(fontSize: 40.0),
      definitions: [
        TextDefinition(
          // WidgetSpan is matched by `\uFFFC` or `.` in a match pattern.
          matcher: const PatternMatcher('Flutter devs\uFFFC'),
          matchStyle: const TextStyle(color: Colors.blue),
          hoverStyle: TextStyle(color: Colors.blue.shade300),
          mouseCursor: SystemMouseCursors.forbidden,
          onTap: (details) => output(details.gestureKind.name),
          onGesture: (details) => output(details.gestureKind.name),
        ),
      ],
      spans: [
        const TextSpan(text: 'Hi, '),
        const TextSpan(
          text: 'Flutter',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 4.0, color: Colors.cyan)],
          ),
        ),
        const TextSpan(text: ' devs'),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Builder(
            builder: (context) {
              // Text style is available also in WidgetSpan
              // via DefaultTextStyle.
              final style = DefaultTextStyle.of(context).style;
              return Icon(
                Icons.flutter_dash,
                size: style.fontSize,
                color: style.color,
              );
            },
          ),
        ),
      ],
    );
  }
}
