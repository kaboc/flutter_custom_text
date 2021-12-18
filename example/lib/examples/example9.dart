import 'package:flutter/material.dart';

import 'package:custom_text/custom_text_editing_controller.dart';

import 'package:custom_text_example/examples/example4.dart';

class Example9 extends StatefulWidget {
  const Example9(this.output);

  final void Function(String) output;

  @override
  _Example9State createState() => _Example9State();
}

class _Example9State extends State<Example9> {
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
        onTap: (url) => widget.output(url),
        onLongPress: (url) => widget.output('long: $url'),
      ),
      TextDefinition(
        matcher: const EmailMatcher(),
        matchStyle: TextStyle(
          color: Colors.green,
          backgroundColor: Colors.lightGreen.withOpacity(0.2),
        ),
      ),
      const TextDefinition(
        matcher: HashTagMatcher(),
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
    return TextField(
      controller: _controller,
      maxLines: null,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
    );
  }
}
