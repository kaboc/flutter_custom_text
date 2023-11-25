[![Pub Version](https://img.shields.io/pub/v/custom_text)](https://pub.dev/packages/custom_text)
[![Flutter CI](https://github.com/kaboc/flutter_custom_text/workflows/Flutter%20CI/badge.svg)](https://github.com/kaboc/flutter_custom_text/actions)
[![codecov](https://codecov.io/gh/kaboc/flutter_custom_text/branch/main/graph/badge.svg?token=H7ILK6CS0V)](https://codecov.io/gh/kaboc/flutter_custom_text)

A highly customisable text widget that enables decorations and gesture actions, and
a special TextEditingController that makes most of the same functionality available also
in a text field.

This package is useful for making partial strings in text (e.g. URLs, email addresses
or phone numbers) react to tap, long-press and hover gestures, or for only highlighting
particular strings with colors and different font settings. You can configure the appearance
and the behaviour using multiple definitions consisting of regular expressions, text styles,
gesture handlers, etc.

## Usage by examples

Most of the examples here are contained in the sample app in the [example/][example] folder.
Just click on the link below to open its web version and see what this package can do.

**[Web Demo][demo]**

The app shows the source code with keywords highlighted, which itself is made possible
by this package (plus [package:highlight](https://pub.dev/packages/highlight) used
as an external parser).

<a href="https://kaboc.github.io/flutter_custom_text/">
<img src="https://github.com/kaboc/flutter_custom_text/assets/20254485/b92d95d2-e0eb-45dd-8fb3-38cc22fb76ff" alt="Code highlighting" height="360">
</a>

### ⭐ <b>Simplest example</b>

example1.dart ([Code][example1] / [Demo][example1_demo])

![example1](https://user-images.githubusercontent.com/20254485/100355817-c0bddb80-3035-11eb-8c5b-3c4d0ee9f921.png)

A very basic example of how to apply a colour to URLs and email addresses using preset
matchers.

The coloured strings are not tappable in this example.

```dart
CustomText(
  'URL: https://example.com/\n'
  'Email: foo@example.com',
  definitions: const [
    TextDefinition(matcher: UrlMatcher()),
    TextDefinition(matcher: EmailMatcher()),
  ],
  matchStyle: const TextStyle(color: Colors.lightBlue),
)
```

#### Preset matchers

The matchers listed below are for general use.
If a stricter pattern is necessary, overwrite the preset pattern or create a custom matcher.

- [UrlMatcher] for URLs
- [UrlLikeMatcher] for URL-like strings
- [EmailMatcher] for email addresses
- [TelMatcher] for phone numbers
- [LinkMatcher] for Markdown-style links or for other strings to be handled
  by [SelectiveDefinition]

### ⭐ <b>Styles and actions per definition</b>

example2.dart ([Code][example2] / [Demo][example2_demo])

![example2](https://user-images.githubusercontent.com/20254485/221410479-c1014891-2e4a-40d6-9fcf-db1a2b946dfd.gif)

An example to decorate URLs, email addresses and phone numbers, and also enable them
to be tapped and long-pressed.

All the three are styled, but only phone numbers among them are styled differently with
the unique `matchStyle` and `tapStyle`.

**Tip**:\
To open a browser or another app when a string is tapped or long-pressed,
use [url_launcher](https://pub.dev/packages/url_launcher) or equivalent in
the `onTap` and/or `onLongPress` handlers.

```dart
CustomText(
  'URL: https://example.com/\n'
  'Email: foo@example.com\n'
  'Tel: +1-012-3456-7890',
  definitions: [
    const TextDefinition(matcher: UrlMatcher()),
    const TextDefinition(matcher: EmailMatcher()),
    TextDefinition(
      matcher: const TelMatcher(),
      // Styles and handlers specified in a definition take
      // precedence over the equivalent arguments of CustomText.
      matchStyle: const TextStyle(
        color: Colors.green,
        decoration: TextDecoration.underline,
      ),
      tapStyle: const TextStyle(color: Colors.orange),
      onTap: (details) => print(details.actionText),
      onLongPress: (details) => print('[Long press] ${details.actionText}'),
    ),
  ],
  matchStyle: const TextStyle(
    color: Colors.lightBlue,
    decoration: TextDecoration.underline,
  ),
  tapStyle: const TextStyle(color: Colors.indigo),
  onTap: (details) => print(details.actionText),
  onLongPress: (details) => print('[Long press] ${details.actionText}'),
)
```

### ⭐ <b>Overwriting pattern</b>

example3.dart ([Code][example3] / [Demo][example3_demo])

![example3](https://user-images.githubusercontent.com/20254485/100355852-ca474380-3035-11eb-8fc9-e9f895f0f17b.png)

An example to replace the default pattern of [TelMatcher].

The new pattern here regards only the `{3 digits}-{4 digits}-{4 digits}` format
as a phone number.

```dart
CustomText(
  'Tel: +1-012-3456-7890',
  definitions: const [
    TextDefinition(matcher: TelMatcher(r'\d{3}-\d{4}-\d{4}')),
  ],
  matchStyle: const TextStyle(color: Colors.lightBlue),
  onTap: (details) => print(details.actionText),
)
```

### ⭐ <b>Custom pattern</b>

example4.dart ([Code][example4] / [Demo][example4_demo])

![example4](https://user-images.githubusercontent.com/20254485/100355864-cddaca80-3035-11eb-9dff-02cd7c97375e.png)

An example to parse hashtags with a custom pattern and apply styles to them.

A hashtag has a wide variety of definitions, but here as an example, it is defined
as a string that starts with "#" followed by an alphabet and then alphanumerics,
and is enclosed with white spaces.

```dart
TextDefinition(
  matcher: PatternMatcher(r'(?<=\s|^)\#[a-zA-Z][a-zA-Z0-9]{1,}(?=\s|$)'),
),
```

Alternatively, you can define a matcher by extending [TextMatcher].
This allows you to distinguish the custom matcher from others by its unique type.

```dart
class HashTagMatcher extends TextMatcher {
  const HashTagMatcher()
      : super(r'(?<=\s|^)\#[a-zA-Z][a-zA-Z0-9]{1,}(?=\s|$)');
}
```

```dart
CustomText(
  'Hello world! #CustomText',
  definitions: const [
    TextDefinition(matcher: HashTagMatcher()),
  ],
  matchStyle: const TextStyle(color: Colors.lightBlue),
  onTap: (details) {
    if (details.element.matcherType == HashTagMatcher) {
      ...; 
    }
  },
)
```

### ⭐ <b>SelectiveDefinition</b>

example5.dart ([Code][example5] / [Demo][example5_demo])

![example5](https://github.com/kaboc/flutter_custom_text/assets/20254485/d47566f4-a92e-4d74-99d4-866387cd4ad8)

An example to parse a markdown-style link in the format of `[shown text](url)`
and make it tappable.

[SelectiveDefinition] allows to select the string to display and the string to
be passed to gesture callbacks individually from the groups of matched strings.

For details of `groups`, see the document of the [text_parser] package used
internally in this package.

```dart
CustomText(
  'Tap [here](Tapped!)',
  definitions: [
    SelectiveDefinition(
      matcher: const LinkMatcher(),
      // `shownText` is used to choose the string to display.
      // It receives a list of strings that have matched the
      // fragments enclosed in parentheses within the match pattern.
      shownText: (groups) => groups[0]!,
      // `actionText` is used to choose the string to be passed
      // to the `onTap`, `onLongPress` and `onGesture` handlers.
      actionText: (groups) => groups[1]!,
    ),
  ],
  matchStyle: TextStyle(color: Colors.blue),
  hoverStyle: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
  onTap: (details) => print(details.actionText),
)
```

`LinkMatcher` is handy if used together with `SelectiveDefinition`, not only for
making a text link but also for just decorating the bracketed strings (without
showing the bracket symbols), in which case `[strings]()` is used as a marker to
indicate which strings to be decorated.

```dart
// "def" and "jkl" are displayed in red.
CustomText(
  'abc[def]()ghi[jkl]()',
  definitions: [
    SelectiveDefinition(
      matcher: const LinkMatcher(),
      shownText: (groups) => groups[0]!,
    ),
  ],
  matchStyle: const TextStyle(color: Colors.red),
)
```

### ⭐ <b>SpanDefinition</b>

example6.dart ([Code][example6] / [Demo][example6_demo])

![example6](https://github.com/kaboc/flutter_custom_text/assets/20254485/7e566862-d986-478b-85ff-9e26d4c47821)

An example to display both text and widgets.

[SpanDefinition] enables a certain portion of text to be replaced with an arbitrary
[InlineSpan]. The `builder` function can use the parse result (the matched string and groups)
to flexibly build an `InlineSpan`.

```dart
CustomText(
  'Hover and click  >>  [logo]Flutter',
  definitions: [
    SpanDefinition(
      matcher: const PatternMatcher('>>'),
      builder: (text, groups) => const WidgetSpan(
        child: Icon(Icons.keyboard_double_arrow_right, ...),
      ),
    ),
    SpanDefinition(
      matcher: const PatternMatcher(r'\[logo\](\w+)'),
      builder: (text, groups) => TextSpan(
        children: [
          const WidgetSpan(child: FlutterLogo()),
          const WidgetSpan(child: SizedBox(width: 2.0)),
          TextSpan(text: groups.first),
        ],
      ),
      matchStyle: TextStyle(color: Colors.blue),
      hoverStyle: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
      onTap: (details) => print(details.element.groups.first!),
    ),
  ],
)
```

### ⭐ <b>Changing mouse cursor and text style on hover</b>

example7.dart ([Code][example7] / [Demo][example7_demo])

![example7](https://user-images.githubusercontent.com/20254485/221410499-23e5dfd2-dc19-4234-b119-17c46ac80a77.gif)

`TextDefinition` and `SelectiveDefinition` have the `mouseCursor` property. The mouse cursor
type passed to it is used for a string that has matched the match pattern while the pointer
hovers over it.

If a tap handler (`onTap` or `onLongPress`) is specified and `mouseCursor` is not,
`SystemMouseCursors.click` is automatically used for the tappable element.

A different text style can also be applied on hover using `hoverStyle` either in `CustomText`
or in a definition.

**Tip**:\
Use `hoverStyle` and omit `tapStyle` if you want the same style for tap and hover.

```dart
CustomText(
  'URL: https://example.com/\n'
  'Email: foo@example.com',
  definitions: [
    const TextDefinition(
      matcher: UrlMatcher(),
      matchStyle: TextStyle(
        color: Colors.grey,
        decoration: TextDecoration.lineThrough,
      ),
      // `SystemMouseCursors.forbidden` is used for URLs.
      mouseCursor: SystemMouseCursors.forbidden,
    ),
    TextDefinition(
      matcher: const EmailMatcher(),
      matchStyle: const TextStyle(
        color: Colors.lightBlue,
        decoration: TextDecoration.underline,
      ),
      tapStyle: const TextStyle(color: Colors.green),
      // Text is shadowed while the mouse pointer hovers over it.
      hoverStyle: TextStyle(
        color: Colors.lightBlue,
        shadows: ...,
      ),
      // `SystemMouseCursors.click` is automatically used for
      // tappable elements even if `mouseCursor` is not specified.
      onTap: (details) => print(details.actionText),
    ),
  ],
)
```

### ⭐ <b>Event position and onGesture</b>

example8.dart ([Code][example8] / [Demo][example8_demo])

![example8](https://user-images.githubusercontent.com/20254485/221400940-c686ab71-8d15-46ad-99fd-9058f7ca30dc.gif)

The `onGesture` handler supports events of the secondary and tertiary buttons and mouse enter and
exit events.

You can check the event type with `gestureKind` contained in the [GestureDetails] object
which is passed to the handler function. The object also has the global and local positions
where an event happened. It is useful for showing a popup or a menu at the position.

**Notes:**

- `onGesture` does not handle events of the primary button. Use `onTap` and/or `onLongPress` instead.
- Unlike `onTap` and `onLongPress`, whether `onGesture` is specified does not affect text styling.
- The handler function is called one microsecond or more after the actual occurrence of an event.
    - This is due to a workaround for preventing the function from being called more times than
      expected by updates of the text span.

### ⭐ <b>CustomTextEditingController</b>

example9.dart ([Code][example9] / [Demo][example9_demo])

![example9](https://user-images.githubusercontent.com/20254485/221410504-f8af0c02-1ccb-4094-bdf1-bb6a1a454874.gif)

Text decoration, tap/long-press actions and hover effects are available also in
an editable text field via [CustomTextEditingController].

```dart
final controller = CustomTextEditingController(
  text: 'abcde foo@example.com\nhttps://example.com/ #hashtag',
  definitions: [
    const TextDefinition(
      matcher: HashTagMatcher(),
      matchStyle: TextStyle(color: Colors.orange),
      hoverStyle: TextStyle(color: Colors.red),
    ),
    ...
  ],
);
```

```dart
@override
Widget build(BuildContext context) {
  return TextField(
    controller: controller,
    ...,
  );
}
```

**Notes:**

- `CustomTextEditingController` does not support `SelectiveDefinition` and `SpanDefinition`.
    - Only `TextDefinition` is available.
- An error is raised on iOS simulators (not on real devices) if the initial text and
  `onTap`, `onLongPress` or `onGesture` are specified.
    - See https://github.com/flutter/flutter/issues/97433.
- Debouncing of text parsing is available as an experimental feature for getting slightly
  better performance in handling long text.
    - Pass some duration to `debounceDuration` to enable the feature.
    - Use it at your own risk.
    - Text input will be still slow even with debouncing because
      [Flutter itself has performance issues](https://github.com/flutter/flutter/issues/114158)
      in editable text.

### ⭐ <b>External parser</b>

example10.dart ([Code][example10] / [Demo][example10_demo])

![example10](https://user-images.githubusercontent.com/20254485/227700405-8ec4bd20-dd30-4ee3-a921-b1a3a019aba6.gif)

It is possible to use an external parser instead of the internal one. It helps you
when a different parser you already have does a better job or can do what is difficult
with the default parser.

```dart
// These empty matchers are used to distinguish the matcher types of
// text elements parsed by an external parser.
// The parser needs to specify one of these matchers in each element. 
class KeywordMatcher extends TextMatcher {
  const KeywordMatcher() : super('');
}

class StringMatcher extends TextMatcher {
  const StringMatcher() : super('');
}
```

```dart
CustomText(
  sourceCode,
  parserOptions: ParserOptions.external(
    (text) => parseLanguage(text, language: 'dart'),
  ),
  definitions: [
    const TextDefinition(
      matcher: KeywordMatcher(),
      matchStyle: TextStyle(color: Colors.orange),
    ),
    const TextDefinition(
      matcher: StringMatcher(),
      matchStyle: TextStyle(color: Colors.teal),
    ),
    ...
  ],
);
```

**Notes:**

- The external parser must generate a list of `TextElement`s.
- If an existing external parser creates hierarchical nodes, they need to be
  flattened as this package only supports a flat list.
- If a custom parser is used with `CustomTextEditingController`, the TextElements
  generated by the parser must all together constitute the original text.
  Otherwise, it will cause unexpected behaviours.
    - This does not apply to `CustomText`.

## Limitations

- The regular expression pattern of `TelMatcher` contains a lookbehind assertion, but
  [Safari versions before 16.4 have no support for it](https://caniuse.com/?search=lookbehind).
  Avoid using `TelMatcher` as is if your app targets older Safari versions.
- `CustomTextEditingController` raises an error on iOS simulators (not on real devices)
  if the initial text and `onTap`, `onLongPress` or `onGesture` are specified.
  See https://github.com/flutter/flutter/issues/97433.

## Links

- [text_parser]
    - CustomText is dependent on the `text_parser` package made by the same author.
      See its documents for details if you're interested or seek troubleshooting on parsing.

[demo]: https://kaboc.github.io/flutter_custom_text/
[example]: https://github.com/kaboc/flutter_custom_text/tree/main/example
[example1]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example1.dart
[example2]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example2.dart
[example3]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example3.dart
[example4]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example4.dart
[example5]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example5.dart
[example6]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example6.dart
[example7]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example7.dart
[example8]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example8.dart
[example9]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example9.dart
[example10]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example10.dart
[example1_demo]: https://kaboc.github.io/flutter_custom_text/#/simple
[example2_demo]: https://kaboc.github.io/flutter_custom_text/#/styles-and-actions
[example3_demo]: https://kaboc.github.io/flutter_custom_text/#/overwriting-pattern
[example4_demo]: https://kaboc.github.io/flutter_custom_text/#/custom-pattern
[example5_demo]: https://kaboc.github.io/flutter_custom_text/#/selective-definition
[example6_demo]: https://kaboc.github.io/flutter_custom_text/#/span-definition
[example7_demo]: https://kaboc.github.io/flutter_custom_text/#/hover
[example8_demo]: https://kaboc.github.io/flutter_custom_text/#/event-position
[example9_demo]: https://kaboc.github.io/flutter_custom_text/#/text-editing-controller
[example10_demo]: https://kaboc.github.io/flutter_custom_text/#/external-parser
[TextMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/TextMatcher-class.html
[UrlMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/UrlMatcher-class.html
[UrlLikeMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/UrlLikeMatcher-class.html
[EmailMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/EmailMatcher-class.html
[TelMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/TelMatcher-class.html
[LinkMatcher]: https://pub.dev/documentation/custom_text/latest/custom_text/LinkMatcher-class.html
[PatternMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/PatternMatcher-class.html
[SelectiveDefinition]: https://pub.dev/documentation/custom_text/latest/custom_text/SelectiveDefinition-class.html
[SpanDefinition]: https://pub.dev/documentation/custom_text/latest/custom_text/SpanDefinition-class.html
[GestureDetails]: https://pub.dev/documentation/custom_text/latest/custom_text/GestureDetails-class.html
[CustomTextEditingController]: https://pub.dev/documentation/custom_text/latest/custom_text/CustomTextEditingController-class.html
[InlineSpan]: https://api.flutter.dev/flutter/painting/InlineSpan-class.html
[text_parser]: https://pub.dev/packages/text_parser
