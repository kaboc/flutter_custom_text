// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';

class CustomTextWidget extends StatelessWidget {
  const CustomTextWidget(
    this.text, {
    this.definitions,
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
    this.onButtonPressed,
  });

  final String text;
  final List<TextDefinition>? definitions;
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
  final VoidCallback? onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          CustomText(
            text,
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

class SelectiveCustomTextWidget extends StatelessWidget {
  const SelectiveCustomTextWidget(
    this.text, {
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
    this.mouseCursor,
  });

  final String text;
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
  final MouseCursor? mouseCursor;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text,
      textDirection: TextDirection.ltr,
      definitions: [
        const TextDefinition(
          matcher: TelMatcher(),
        ),
        SelectiveDefinition(
          matcher: const LinkMatcher(),
          shownText: (groups) => groups[0] ?? '',
          actionText: (groups) => groups[1] ?? '',
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
    );
  }
}

class SpanCustomTextWidget1 extends StatelessWidget {
  const SpanCustomTextWidget1(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text,
      textDirection: TextDirection.ltr,
      definitions: [
        const TextDefinition(
          matcher: TelMatcher(),
        ),
        SpanDefinition(
          matcher: const EmailMatcher(),
          builder: (text, groups) => TextSpan(
            children: [
              const WidgetSpan(
                child: SizedBox(
                  width: 18.0,
                  height: 18.0,
                ),
                alignment: PlaceholderAlignment.middle,
              ),
              TextSpan(text: text),
            ],
          ),
        ),
      ],
    );
  }
}

class SpanCustomTextWidget2 extends StatelessWidget {
  const SpanCustomTextWidget2(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text,
      textDirection: TextDirection.ltr,
      definitions: [
        const TextDefinition(
          matcher: TelMatcher(),
        ),
        SpanDefinition(
          matcher: const LinkMatcher(),
          builder: (text, groups) => TextSpan(
            children: [
              TextSpan(text: text),
              for (var i = 0; i < groups.length; i++)
                TextSpan(text: '$i: ${groups[i]}'),
            ],
          ),
        ),
      ],
    );
  }
}
