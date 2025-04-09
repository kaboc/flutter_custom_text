import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';

class ControllerExample extends StatefulWidget {
  const ControllerExample([this.output]);

  final void Function(String)? output;

  @override
  State<ControllerExample> createState() => _ControllerExampleState();
}

class _ControllerExampleState extends State<ControllerExample> {
  late final _controller = CustomTextEditingController(
    text: 'abcde foo@example.com\nhttps://example.com/ #hashtag',
    definitions: [
      TextDefinition(
        matcher: const UrlMatcher(),
        matchStyle: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        tapStyle: const TextStyle(color: Colors.indigo),
        onTap: widget.output == null
            ? null
            : (details) => widget.output!(details.actionText),
        onLongPress: widget.output == null
            ? null
            : (details) => widget.output!('long: ${details.actionText}'),
      ),
      TextDefinition(
        matcher: const EmailMatcher(),
        matchStyle: TextStyle(
          color: Colors.green,
          backgroundColor: Colors.lightGreen.withOpacity(0.2),
        ),
      ),
      const TextDefinition(
        matcher: PatternMatcher(r'#[a-zA-Z][a-zA-Z0-9]{1,}(?=\s|$)'),
        matchStyle: TextStyle(color: Colors.orange),
        hoverStyle: TextStyle(color: Colors.red),
      ),
    ],
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const debounceDuration = Duration(seconds: 1);

    return Column(
      children: [
        TextField(
          controller: _controller,
          maxLines: null,
          style: const TextStyle(height: 1.4),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              'Debounce\n(experimental)',
              style: TextStyle(fontSize: 11.0, height: 1.1),
              textAlign: TextAlign.center,
            ),
            Switch(
              value: _controller.debounceDuration != null,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (on) {
                setState(() {
                  _controller.debounceDuration = on ? debounceDuration : null;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
