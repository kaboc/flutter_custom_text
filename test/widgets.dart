import 'package:flutter/widgets.dart';

import 'package:custom_text/custom_text.dart';

class CustomTextWidget extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const CustomTextWidget(
    this.text, {
    this.style,
    this.matchStyle,
    this.tapStyle,
    this.matchStyleInDef,
    this.tapStyleInDef,
    this.onTap,
    this.onLongTap,
    this.onTapInDef,
    this.onLongTapInDef,
    this.longTapDuration,
  });

  final String text;
  final TextStyle? style;
  final TextStyle? matchStyle;
  final TextStyle? tapStyle;
  final TextStyle? matchStyleInDef;
  final TextStyle? tapStyleInDef;
  final void Function(Type, String)? onTap;
  final void Function(Type, String)? onLongTap;
  final void Function(String)? onTapInDef;
  final void Function(String)? onLongTapInDef;
  final Duration? longTapDuration;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text,
      textDirection: TextDirection.ltr,
      definitions: [
        const TextDefinition(
          matcher: UrlMatcher(),
        ),
        TextDefinition(
          matcher: const EmailMatcher(),
          matchStyle: matchStyleInDef,
          tapStyle: tapStyleInDef,
          onTap: onTapInDef,
          onLongTap: onLongTapInDef,
        ),
      ],
      style: style,
      matchStyle: matchStyle,
      tapStyle: tapStyle,
      onTap: onTap,
      onLongTap: onLongTap,
      longTapDuration: longTapDuration,
    );
  }
}

/// CustomText using SpanDefinition.
class SelectiveCustomTextWidget extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const SelectiveCustomTextWidget(
    this.text, {
    this.style,
    this.matchStyle,
    this.tapStyle,
    this.matchStyleInDef,
    this.tapStyleInDef,
    this.onTap,
    this.onLongTap,
    this.onTapInDef,
    this.onLongTapInDef,
  });

  final String text;
  final TextStyle? style;
  final TextStyle? matchStyle;
  final TextStyle? tapStyle;
  final TextStyle? matchStyleInDef;
  final TextStyle? tapStyleInDef;
  final void Function(Type, String)? onTap;
  final void Function(Type, String)? onLongTap;
  final void Function(String)? onTapInDef;
  final void Function(String)? onLongTapInDef;

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
          matcher: const MdLinkMatcher(),
          labelSelector: (groups) => groups[0] ?? '',
          tapSelector: (groups) => groups[1] ?? '',
          matchStyle: matchStyleInDef,
          tapStyle: tapStyleInDef,
          onTap: onTapInDef,
          onLongTap: onLongTapInDef,
        ),
      ],
      style: style,
      matchStyle: matchStyle,
      tapStyle: tapStyle,
      onTap: onTap,
      onLongTap: onLongTap,
    );
  }
}

class SpanCustomTextWidget1 extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
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
  // ignore: use_key_in_widget_constructors
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
          matcher: const MdLinkMatcher(),
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

class MdLinkMatcher extends TextMatcher {
  const MdLinkMatcher() : super(r'\[(.+?)\]\((.+?)\)');
}
