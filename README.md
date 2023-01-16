[![Pub Version](https://img.shields.io/pub/v/custom_text)](https://pub.dev/packages/custom_text)
[![Flutter CI](https://github.com/kaboc/flutter_custom_text/workflows/Flutter%20CI/badge.svg)](https://github.com/kaboc/flutter_custom_text/actions)
[![codecov](https://codecov.io/gh/kaboc/flutter_custom_text/branch/main/graph/badge.svg?token=H7ILK6CS0V)](https://codecov.io/gh/kaboc/flutter_custom_text)

A highly customisable text widget that enables decorations and gestures on strings, and
the special TextEditingController that makes most of the functionality available in an
editable text field too.

This package is useful for making part of text (e.g. URLs, email addresses or phone numbers)
react to taps / long-presses / hover, or for only highlighting partial strings with colors
and different font settings. You can configure the appearance and the behaviour using multiple
definitions consisting of regular expressions, text styles, gesture callbacks, etc.

## Usage by examples

Most of the examples here are contained in the sample app in the [example/][example] folder.
Just click on the link below to open its web version and see what this package can achieve.

**[Web Demo][demo]**

The app also shows the source code with keywords highlighted, which itself is made possible
by this package.

![Code highlighting](https://user-images.githubusercontent.com/20254485/203714827-af1bdd43-666b-417a-9f29-96a7c7f18b35.png)

### Simplest example

example1.dart ([Code][example1] / [Demo][example1_demo])

![example1](https://user-images.githubusercontent.com/20254485/100355817-c0bddb80-3035-11eb-8c5b-3c4d0ee9f921.png)

A very basic example showing how to apply a colour to URLs and email addresses using preset
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
If stricter patterns are necessary, create custom matchers instead of using these.

- [UrlMatcher][UrlMatcher] for URLs
- [EmailMatcher][EmailMatcher] for email addresses
- [TelMatcher][TelMatcher] for phone numbers
- [LinkMatcher][LinkMatcher] for Markdown-style links or for use with
  [SelectiveDefinition][SelectiveDefinition]

### Unique styles and actions per definition

example2.dart ([Code][example2] / [Demo][example2_demo])

![example2](https://user-images.githubusercontent.com/20254485/100355833-c74c5300-3035-11eb-80d2-de64056417a1.gif)

An example to decorate URLs, email addresses and phone numbers, and also enable
them to be tapped/long-pressed.

All of the three are styled, but only phone numbers among them are given unique `matchStyle`
and `tapStyle`.

**Tip**: Use [url_launcher](https://pub.dev/packages/url_launcher) or its equivalent to open
a browser or another app by a tap/long-press on a string.

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
      // Parameters of a definition override the equivalent
      // parameters of CustomText.
      matchStyle: const TextStyle(
        color: Colors.green,
        decoration: TextDecoration.underline,
      ),
      tapStyle: const TextStyle(color: Colors.orange),
      onTap: (tel) => print(tel),
      onLongPress: (tel) => print('[Long press] $tel'),
    ),
  ],
  matchStyle: const TextStyle(
    color: Colors.lightBlue,
    decoration: TextDecoration.underline,
  ),
  tapStyle: const TextStyle(color: Colors.indigo),
  onTap: (type, text) => print(text),
  onLongPress: (type, text) => print('[Long press] $text'),
)
```

### Overwriting patterns

example3.dart ([Code][example3] / [Demo][example3_demo])

![example3](https://user-images.githubusercontent.com/20254485/100355852-ca474380-3035-11eb-8fc9-e9f895f0f17b.png)

An example to overwrite the default pattern of [TelMatcher][TelMatcher].

The new pattern regards only the `{3 digits}-{4 digits}-{4 digits}` format as a phone number.

```dart
CustomText(
  'Tel: +1-012-3456-7890',
  definitions: const [
    TextDefinition(matcher: TelMatcher(r'\d{3}-\d{4}-\d{4}')),
  ],
  matchStyle: const TextStyle(color: Colors.lightBlue),
  onTap: (_, text) => print(text),
)
```

### Custom pattern

example4.dart ([Code][example4] / [Demo][example4_demo])

![example4](https://user-images.githubusercontent.com/20254485/100355864-cddaca80-3035-11eb-9dff-02cd7c97375e.png)

An example to parse hashtags with a custom pattern and apply styles to them.

A hashtag has a wide variety of definitions, but here as an example, it is defined
as a string that starts with "#" followed by an alphabet and then by alphanumerics,
and is enclosed with white spaces.

```dart
TextDefinition(
  matcher: PatternMatcher(r'(?<=\s|^)\#[a-zA-Z][a-zA-Z0-9]{1,}(?=\s|$)'),
),
```

Alternatively, you can define a matcher by extending [TextMatcher][TextMatcher].
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
  onTap: (type, text) {
    if (type == HashTagMatcher) {
      ...; 
    }
  },
)
```

### SelectiveDefinition

example5.dart ([Code][example5] / [Demo][example5_demo])

![example5](https://user-images.githubusercontent.com/20254485/100355868-d0d5bb00-3035-11eb-836f-863f1af599ac.png)

An example to parse markdown-style links, like `[label](url)` using
[SelectiveDefinition][SelectiveDefinition], and make them tappable.

Each of the string shown in the widget and the string passed to the tap callbacks is selected
individually from the fragments (`groups`) that have matched the patterns enclosed with
parentheses within the match pattern.

For details of `groups`, see the document of the [text_parser][text_parser] package that this package uses internally.

```dart
// This matcher comes with the package, so there's no need to prepare it yourself.
class LinkMatcher extends TextMatcher {
  const LinkMatcher([String pattern = r'\[(.+?)\]\((.*?)\)']) : super(pattern);
}
```

```dart
CustomText(
  'Markdown-style link\n'
  '[Tap here](Tapped!)',
  definitions: [
    SelectiveDefinition(
      matcher: const LinkMatcher(),
      // `labelSelector` is used to choose the string to show.
      // `groups` provided to `labelSelector` is an array of
      // strings matching the fragments enclosed in parentheses
      // within the match pattern.
      labelSelector: (groups) => groups[0]!,
      // `tapSelector` is used to choose the string to be passed
      // to the `onTap` and `onLongPress` callbacks.
      tapSelector: (groups) => groups[1]!,
    ),
  ],
  matchStyle: const TextStyle(color: Colors.lightBlue),
  tapStyle: const TextStyle(color: Colors.green),
  onTap: (_, text) => print(text),
)
```

`LinkMatcher` used together with `SelectiveDefinition` is handy not only for making a text link
but also for just decorating the bracketed strings (but not showing the bracket symbols).

```dart
// "def" and "jkl" are displayed in red.
CustomText(
  'abc[def]()ghi[jkl]()',
  definitions: [
    SelectiveDefinition(
      matcher: const LinkMatcher(),
      labelSelector: (groups) => groups[0]!,
    ),
  ],
  matchStyle: const TextStyle(color: Colors.red),
)
```

### SpanDefinition

example6.dart ([Code][example6] / [Demo][example6_demo])

![example6](https://user-images.githubusercontent.com/20254485/100355876-d501d880-3035-11eb-9ec5-f9694a7811cf.png)

An example to show both strings and icons using [SpanDefinition][SpanDefinition].

The builder parameter takes a function returning an [InlineSpan][InlineSpan].
The function is provided with the matching string and groups, so it is possible to compose
an `InlineSpan` flexibly with them.

```dart
CustomText(
  'Email 1: [@] foo@example.com\n'
  'Email 2: [@] bar@example.com',
  definitions: [
    SpanDefinition(
      matcher: const PatternMatcher(r'\[@\]'),
      builder: (text, groups) => const WidgetSpan(
        child: Icon(
          Icons.email,
          color: Colors.blueGrey,
          size: 18.0,
        ),
        alignment: PlaceholderAlignment.middle,
      ),
    ),
    const TextDefinition(
      matcher: EmailMatcher(),
      matchStyle: TextStyle(color: Colors.lightBlue),
      onTap: print,
    ),
  ],
)
```

#### Notes

- `SpanDefinition` does not have arguments for styles and tap callbacks, so it is totally
  up to you how the `InlineSpan` returned from it is decorated and how it reacts to gestures.
- The `builder` function is called on every rebuild. If you use `GestureRecognizer` to make a
  WidgetSpan tappable, be careful not to create it inside the function, or make sure to
  dispose of existing recognizers before creating a new one.

### Changing mouse cursor and text style on hover

example7.dart ([Code][example7] / [Demo][example7_demo])

![example7](https://user-images.githubusercontent.com/20254485/119790338-cf1a8080-bf0e-11eb-8c76-3116a540b159.gif)

`TextDefinition` and `SelectiveDefinition` have the `mouseCursor` property. The mouse cursor type set to it
is used while the pointer hovers over a string that has matched the matcher specified in the definition.

If a tap callback (`onTap` or `onLongPress`) is set and `mouseCursor` is not set, `SystemMouseCursors.click`
is automatically used for the string that the tap callback is applied to.

A different text style can also be applied on hover using `hoverStyle` either in `CustomText` or in definitions.

**Tip**: Use `hoverStyle` and omit `tapStyle` if you want the same style to be applied on tap and hover.

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
      // `SystemMouseCursors.click` is used for URLs automatically
      // even if `mouseCursor` is not set because a tap has been
      // enabled by the `onTap` callback.
      onTap: (text) => output(text),
    ),
  ],
)
```

### CustomText.selectable

example8.dart ([Code][example8] / [Demo][example8_demo])

![example8](https://user-images.githubusercontent.com/20254485/146570773-41495fc9-9d27-4754-a71e-b2b06e706d4a.gif)

`CustomText.selectable` is now deprecated. Use either of the followings instead:

- [SelectionArea](https://api.flutter.dev/flutter/material/SelectionArea-class.html) available on Flutter 3.3 and above
- [CustomTextEditingController][CustomTextEditingController] and `TextField` with `readOnly: true`

<details>
<summary>Click to view details</summary>

This example is almost the same as example2, but with the `CustomText.selectable` constructor.
It is based on `SelectableText.rich`, so text can be selected while it is partially decorated/tappable.

```dart
CustomText.selectable(
  'URL: https://example.com/\n'
  'Email: foo@example.com\n'
  'Tel: +1-012-3456-7890',
  definitions: [
    const TextDefinition(matcher: UrlMatcher()),
    ...,
  ],
  matchStyle: const TextStyle(...),
  ...,
)
```
</details>

### CustomTextEditingController

example9.dart ([Code][example9] / [Demo][example9_demo])

![example9](https://user-images.githubusercontent.com/20254485/146570812-563abbaf-f3d0-466b-bfec-504c69f60236.gif)

Text decoration, tap/long-press actions and hover effects are available also in an editable text field
via [CustomTextEditingController][CustomTextEditingController].

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

#### Notes

- `CustomTextEditingController` does not support `SelectiveDefinition` and `SpanDefinition`.
  It only accepts `TextDefinition`.
- Debouncing of text parsing is available as an experimental feature for getting slightly better
  performance in handling long text.
    - Pass some duration to `debounceDuration` to enable the feature.
    - Use it at your own risk.
    - Text input will be still slow even with debouncing because
      [Flutter itself has performance issues](https://github.com/flutter/flutter/issues/114158)
      in editable text.

## Limitations

- The regular expression pattern of `TelMatcher` contains a lookbehind assertion, but
  [Safari does not support it](https://caniuse.com/?search=lookbehind). Avoid using
  `TelMatcher` as is if your app targets Safari.
- Highlight of selected text in `CustomText.selectable` is lost if the widget is rebuild,
  e.g. when `hoverStyle` is applied or removed.

## Links

- [text_parser][text_parser]
    - CustomText is dependent on the `text_parser` package made by the same author.
      See its documentation for details if you're interested or for troubleshooting on parsing.

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
[example1_demo]: https://kaboc.github.io/flutter_custom_text/#/1
[example2_demo]: https://kaboc.github.io/flutter_custom_text/#/2
[example3_demo]: https://kaboc.github.io/flutter_custom_text/#/3
[example4_demo]: https://kaboc.github.io/flutter_custom_text/#/4
[example5_demo]: https://kaboc.github.io/flutter_custom_text/#/5
[example6_demo]: https://kaboc.github.io/flutter_custom_text/#/6
[example7_demo]: https://kaboc.github.io/flutter_custom_text/#/7
[example8_demo]: https://kaboc.github.io/flutter_custom_text/#/8
[example9_demo]: https://kaboc.github.io/flutter_custom_text/#/9
[TextMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/TextMatcher-class.html
[UrlMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/UrlMatcher-class.html
[EmailMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/EmailMatcher-class.html
[TelMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/TelMatcher-class.html
[LinkMatcher]: https://pub.dev/documentation/custom_text/latest/custom_text/LinkMatcher-class.html
[PatternMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/PatternMatcher-class.html
[SelectiveDefinition]: https://pub.dev/documentation/custom_text/latest/custom_text/SelectiveDefinition-class.html
[SpanDefinition]: https://pub.dev/documentation/custom_text/latest/custom_text/SpanDefinition-class.html
[CustomTextEditingController]: https://pub.dev/documentation/custom_text/latest/custom_text_editing_controller/CustomTextEditingController-class.html
[InlineSpan]: https://api.flutter.dev/flutter/painting/InlineSpan-class.html
[text_parser]: https://pub.dev/packages/text_parser
