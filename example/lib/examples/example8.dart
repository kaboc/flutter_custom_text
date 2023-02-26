import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';

import 'package:custom_text_example/utils/popup.dart';

class Example8 extends StatefulWidget {
  const Example8(this.output);

  final void Function(String) output;

  @override
  State<Example8> createState() => _Example8State();
}

class _Example8State extends State<Example8> {
  late final _controller = PopupController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomText(
      'Flutter is an [open-source]() [UI]() [software development kit]() '
      'created by [Google](). It is used to develop [cross-platform '
      'applications]() for [Android](), [iOS](), [Linux](), [macOS](), '
      '[Windows](), [Google Fuchsia](), and the [web]() from a single '
      '[codebase]().',
      definitions: [
        const TextDefinition(
          matcher: PatternMatcher('Flutter'),
          matchStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        SelectiveDefinition(
          matcher: const LinkMatcher(),
          shownText: (groups) => groups.first!,
          matchStyle: const TextStyle(color: Color(0xFF3366CC)),
          hoverStyle: const TextStyle(
            color: Color(0xFF3366CC),
            decoration: TextDecoration.underline,
          ),
          onTap: (details) {
            _output(details);
            _controller.toggle(context, details);
          },
          onGesture: (details) {
            _output(details);
            if (details.gestureKind == GestureKind.enter) {
              _controller.show(context, details);
            } else if (details.gestureKind == GestureKind.exit) {
              _controller.startCloseTimer(const Duration(milliseconds: 200));
            }
          },
        ),
      ],
    );
  }

  void _output(GestureDetails details) {
    final x = details.globalPosition.dx.roundToDouble();
    final y = details.globalPosition.dy.roundToDouble();
    widget.output(
      '${details.shownText}\n    ${details.gestureKind.name} ($x, $y)',
    );
  }
}
