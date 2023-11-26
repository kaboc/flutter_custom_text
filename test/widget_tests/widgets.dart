import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';

class CustomTextWidget extends StatelessWidget {
  const CustomTextWidget(
    this.text, {
    super.key,
    this.definitions,
    this.parserOptions = const ParserOptions(),
    this.style,
    this.matchStyle,
    this.tapStyle,
    this.hoverStyle,
    this.matchStyleInDef,
    this.tapStyleInDef,
    this.hoverStyleInDef,
    this.onTap,
    this.onLongPress,
    this.onGesture,
    this.onTapInDef,
    this.onLongPressInDef,
    this.onGestureInDef,
    this.longPressDuration,
    this.mouseCursor,
    this.preventBlocking = false,
    this.onButtonPressed,
  });

  final String text;
  final List<TextDefinition>? definitions;
  final ParserOptions parserOptions;
  final TextStyle? style;
  final TextStyle? matchStyle;
  final TextStyle? tapStyle;
  final TextStyle? hoverStyle;
  final TextStyle? matchStyleInDef;
  final TextStyle? tapStyleInDef;
  final TextStyle? hoverStyleInDef;
  final GestureCallback? onTap;
  final GestureCallback? onLongPress;
  final GestureCallback? onGesture;
  final GestureCallback? onTapInDef;
  final GestureCallback? onLongPressInDef;
  final GestureCallback? onGestureInDef;
  final Duration? longPressDuration;
  final MouseCursor? mouseCursor;
  final bool preventBlocking;
  final VoidCallback? onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          CustomText(
            text,
            parserOptions: parserOptions,
            definitions: definitions ??
                [
                  const TextDefinition(
                    matcher: UrlMatcher(),
                  ),
                  TextDefinition(
                    matcher: const EmailMatcher(),
                    matchStyle: matchStyleInDef,
                    tapStyle: tapStyleInDef,
                    hoverStyle: hoverStyleInDef,
                    onTap: onTapInDef,
                    onLongPress: onLongPressInDef,
                    onGesture: onGestureInDef,
                    mouseCursor: mouseCursor,
                  ),
                ],
            style: style,
            matchStyle: matchStyle,
            tapStyle: tapStyle,
            hoverStyle: hoverStyle,
            onTap: onTap,
            onLongPress: onLongPress,
            onGesture: onGesture,
            longPressDuration: longPressDuration,
            preventBlocking: preventBlocking,
          ),
          ElevatedButton(
            onPressed: onButtonPressed,
            child: const Text('Button'),
          ),
        ],
      ),
    );
  }
}

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({
    super.key,
    required this.controller,
    required this.onDispose,
  });

  final CustomTextEditingController controller;
  final VoidCallback onDispose;

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: TextField(controller: widget.controller),
      ),
    );
  }
}
