[![Pub Version](https://img.shields.io/pub/v/custom_text)](https://pub.dev/packages/custom_text)
[![Flutter CI](https://github.com/kaboc/flutter_custom_text/workflows/Flutter%20CI/badge.svg)](https://github.com/kaboc/flutter_custom_text/actions)

A highly customisable text widget that allows styles and tap gestures to be applied to
strings in it flexibly.

This widget is useful for making part of text tappable, such as URLs, email addresses or
phone numbers, or for only highlighting partial strings in text with colors and different
font settings depending on the types of the elements parsed by regular expressions.

## Usage by examples

Most of the examples here are contained in the sample app in the [example/][example] folder.
Just click on the link below to open its web version and see what this package can achieve.

**[Web Demo](https://kaboc.github.io/flutter_custom_text/)**

The app also shows the source code with keywords highlighted, which itself is made possible
by this package.

![highlighting](https://user-images.githubusercontent.com/20254485/100355884-d9c68c80-3035-11eb-8460-545afebf683c.png)

### Simplest example

[example1.dart][example1]

![example1](https://user-images.githubusercontent.com/20254485/100355817-c0bddb80-3035-11eb-8c5b-3c4d0ee9f921.png)

A very basic example with URLs and email addresses styled.
They are not tappable in this example.

```dart
CustomText(
  'URL: https://example.com/\n'
  'Email: foo@example.com',
  definitions: const [
    TextDefinition(matcher: UrlMatcher()),
    TextDefinition(matcher: EmailMatcher()),
  ],
  matchStyle: const TextStyle(color: Colors.lightBlue),
  // `tapStyle` is not used if both `onTap` and `onLongPress`
  // are null or not set.
  tapStyle: const TextStyle(color: Colors.yellow),
  onTap: null,
)
```

### Unique styles and actions per definition

[example2.dart][example2]

![example2](https://user-images.githubusercontent.com/20254485/100355833-c74c5300-3035-11eb-80d2-de64056417a1.gif)

An example to apply styles to URLs, email addresses and phone numbers, and also enable
them to be tapped/long-pressed.

All of the three are styled, but only phone numbers among them are given unique `matchStyle`
and `tapStyle`.

Tip: Use [url_launcher](https://pub.dev/packages/url_launcher) or its equivalent to open
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
      // `matchStyle`, `tapStyle`, `onTap` and `onLongPress` here
      // override the equivalent parameters of CustomText.
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

### Overwriting match patterns

[example3.dart][example3]

![example3](https://user-images.githubusercontent.com/20254485/100355852-ca474380-3035-11eb-8fc9-e9f895f0f17b.png)

An example to overwrite the default match pattern of [TelMatcher][TelMatcher].

The new pattern regards only the `{3 digits}-{4 digits}-{4 digits}` format as a phone number.

```dart
CustomText(
  'Tel: +1-012-3456-7890',
  definitions: const [
    // Match patterns of preset matchers can be overwritten.
    TextDefinition(matcher: TelMatcher(r'\d{3}-\d{4}-\d{4}')),
  ],
  matchStyle: const TextStyle(color: Colors.lightBlue),
  onTap: (_, text) => print(text),
)
```

### Custom matchers

[example4.dart][example4]

![example4](https://user-images.githubusercontent.com/20254485/100355864-cddaca80-3035-11eb-9dff-02cd7c97375e.png)

An example to parse hashtags using a custom matcher and apply styles to them.

A hashtag has a wide variety of definitions, but here as an example, it is defined
as a string that starts with "#" followed by an alphabet and then by alphanumerics,
and is enclosed with white spaces.

```dart
// You can create a custom matcher easily by extending TextMatcher.
class HashTagMatcher extends TextMatcher {
  const HashTagMatcher()
      : super(r'(?<=\s|^)\#[a-zA-Z][a-zA-Z0-9]{1,}(?=\s|$)');
}

...

CustomText(
  'Hello world! #CustomText',
  definitions: const [
    TextDefinition(matcher: HashTagMatcher()),
  ],
  matchStyle: const TextStyle(color: Colors.lightBlue),
)
```

### SelectiveDefinition

[example5.dart][example5]

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
but also for just decorating the bracketed strings (but not showing the brackets).

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

[example6.dart][example6]

![example6](https://user-images.githubusercontent.com/20254485/100355876-d501d880-3035-11eb-9ec5-f9694a7811cf.png)

An example to show both strings and icons using [SpanDefinition][SpanDefinition].

The builder parameter takes a function returning an [InlineSpan][InlineSpan].
The function is provided with matched string and groups, so it is possible to compose
an `InlineSpan` flexibly with them.

```dart
CustomText(
  'Email 1: foo@example.com\n'
  'Email 2: bar@example.com',
  definitions: [
    SpanDefinition(
      matcher: const EmailMatcher(),
      builder: (text, groups) => TextSpan(
        children: [
          const WidgetSpan(
            child: Icon(
              Icons.email,
              color: Colors.blueGrey,
              size: 18.0,
            ),
            alignment: PlaceholderAlignment.middle,
          ),
          const WidgetSpan(
            child: SizedBox(width: 6.0),
          ),
          TextSpan(
            text: text,
            style: const TextStyle(color: Colors.lightBlue),
            recognizer: ...,
          ),
        ],
      ),
    ),
  ],
)
```

#### Notes

- `SpanDefinition` does not have arguments for styles and tap callbacks, so it is totally
  up to you how the `InlineSpan` returned from it is decorated and how it reacts to gestures.
- The `builder` function is called on every rebuild. Be careful not to create a `GestureRecognizer`
  inside the function, or make sure to dispose of existing recognizers before creating a new one.

### Changing mouse cursor and text style on hover

[example7.dart][example7]

![example7](https://user-images.githubusercontent.com/20254485/119790338-cf1a8080-bf0e-11eb-8c76-3116a540b159.gif)

`TextDefinition` and `SelectiveDefinition` have the `mouseCursor` property. The mouse cursor type set to it
is used while the pointer hovers over a string that has matched the matcher specified in the definition.

If a tap callback (`onTap` or `onLongPress`) is set and `mouseCursor` is not set, `SystemMouseCursors.click`
is automatically used for the string that the tap callback is applied to.

A different text style can also be applied on hover using `hoverStyle` either in `CustomText` or in definitions.

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

[example8.dart][example8]

![example8](https://user-images.githubusercontent.com/20254485/146570773-41495fc9-9d27-4754-a71e-b2b06e706d4a.gif)

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

### CustomTextEditingController

[example9.dart][example9]

![example9](https://user-images.githubusercontent.com/20254485/146570812-563abbaf-f3d0-466b-bfec-504c69f60236.gif)

The features of text decoration and tap/long-press gestures are also available for editable text fields
via `CustomTextEditingController`.

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

...

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
  

## Limitations

- The regular expression pattern of `TelMatcher` contains a lookbehind assertion, but
[Safari does not support it](https://caniuse.com/?search=lookbehind). Avoid using `TelMatcher`
as is if your app targets Safari.

## Links

- [text_parser][text_parser]
    - CustomText is dependent on the `text_parser` package made by the same author.
    See its documentation for details if you're interested or for troubleshooting on parsing.

[example]: https://github.com/kaboc/flutter_custom_text/tree/main/example
[example1]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example1.dart
[example2]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example2.dart
[example3]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example3.dart
[example4]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example4.dart
[example5]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example5.dart
[example6]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example6.dart
[example7]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example7.dart
[example8]: https://github.com/kaboc/flutter_custom_text/blob/dev/example/lib/examples/example8.dart
[example9]: https://github.com/kaboc/flutter_custom_text/blob/dev/example/lib/examples/example9.dart
[TelMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/TelMatcher/TelMatcher.html
[SelectiveDefinition]: https://pub.dev/documentation/custom_text/latest/custom_text/SelectiveDefinition-class.html
[SpanDefinition]: https://pub.dev/documentation/custom_text/latest/custom_text/SpanDefinition-class.html
[InlineSpan]: https://api.flutter.dev/flutter/painting/InlineSpan-class.html
[text_parser]: https://pub.dev/packages/text_parser
