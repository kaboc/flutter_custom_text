# custom_text

[![Pub Version](https://img.shields.io/pub/v/custom_text)](https://pub.dev/packages/custom_text)
[![Flutter CI](https://github.com/kaboc/flutter_custom_text/workflows/Flutter%20CI/badge.svg)](https://github.com/kaboc/flutter_custom_text/actions)

A highly customisable text widget that allows styles and tap gestures to be applied to
strings in it flexibly.

This widget is useful for making link strings tappable, such as URLs, email addresses or
phone numbers, or for only highlighting partial strings in text with colors and different
font settings depending on the types of the string elements parsed by regular expressions.

## Examples / Usage

The examples here are all contained in the sample app in the [example/][example] folder.
Just click on the link below to open the web demo and see what this package is like if
you're unwilling to read through all of this document.

**[Web Demo](https://kaboc.github.io/flutter_custom_text/)**

The app also shows the source code with keywords highlighted, which is itself thanks
to this package.

![highlighting](https://user-images.githubusercontent.com/20254485/100355884-d9c68c80-3035-11eb-8460-545afebf683c.png)

### Simplest example

A very basic example with URLs and email addresses styled.
They are not tappable in this example.

![example1](https://user-images.githubusercontent.com/20254485/100355817-c0bddb80-3035-11eb-8c5b-3c4d0ee9f921.png)

[example1.dart][example1]

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

An example to apply styles to URLs, email addresses and phone numbers, and also enable
them to be tapped/long-pressed.

All of the three are styled, but only phone numbers among them are given unique `matchStyle`
and `tapStyle`.

![example2](https://user-images.githubusercontent.com/20254485/100355833-c74c5300-3035-11eb-80d2-de64056417a1.gif)

[example2.dart][example2]

TIPS: Use [url_launcher](https://pub.dev/packages/url_launcher) or its equivalent to open
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

An example to overwrite the default match pattern of [TelMatcher][TelMatcher].

The new pattern regards only the `{3 digits}-{4 digits}-{4 digits}` format as a phone number.

![example3](https://user-images.githubusercontent.com/20254485/100355852-ca474380-3035-11eb-8fc9-e9f895f0f17b.png)

[example3.dart][example3]

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

An example to parse hashtags using a custom matcher and apply styles to them.

A hashtag has a wide variety of definitions, but here as an example, it is defined
as a string that starts with "#" followed by an alphabet and then by alphanumerics,
and is enclosed with white spaces.

![example4](https://user-images.githubusercontent.com/20254485/100355864-cddaca80-3035-11eb-9dff-02cd7c97375e.png)

[example4.dart][example4]

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

An example to parse markdown-style links, like `[label](url)` using
[SelectiveDefinition][SelectiveDefinition], and make them tappable.

Each of the string shown in the widget and the string passed to the tap callbacks is selected
individually from the fragments (`groups`) that have matched the patterns enclosed with
parentheses within the match pattern.

For details of `groups`, please see the document of the
[text_parser][text_parser] package, which this package uses internally.

![example5](https://user-images.githubusercontent.com/20254485/100355868-d0d5bb00-3035-11eb-836f-863f1af599ac.png)

[example5.dart][example5]

```dart
class MdLinkMatcher extends TextMatcher {
  const MdLinkMatcher() : super(r'\[(.+?)\]\((.+?)\)');
}

...

CustomText(
  'Markdown-style link\n'
  '[Tap here](Tapped!)',
  definitions: [
    SelectiveDefinition(
      matcher: const MdLinkMatcher(),
      // `labelSelector` is used to choose the string to show.
      // `groups` provided to `labelSelector` is an array of
      // strings matching the fragments enclosed in parentheses
      // within the match pattern.
      labelSelector: (groups) => groups[0],
      // `tapSelector` is used to choose the string to be passed
      // to the `onTap` and `onLongPress` callbacks.
      tapSelector: (groups) => groups[1],
    ),
  ],
  matchStyle: const TextStyle(color: Colors.lightBlue),
  tapStyle: const TextStyle(color: Colors.green),
  onTap: (_, text) => print(text),
)
```

### SpanDefinition

An example to show both strings and icons using [SpanDefinition][SpanDefinition].

The builder parameter takes a function returning an [InlineSpan][InlineSpan].
The function is provided with matched string and groups, so it is possible to compose
an `InlineSpan` flexibly with them.

#### Notes

- `SpanDefinition` does not have arguments for styles and tap callbacks, so it is totally
up to you how the `InlineSpan` returned from it is decorated and how it reacts to gestures.
- The `builder` function is called on every rebuild. If you create a `GestureRecognizer`
inside the function, store it in such a way that you can check if one already exists to
avoid so many recognizers being created.

![example6](https://user-images.githubusercontent.com/20254485/100355876-d501d880-3035-11eb-9ec5-f9694a7811cf.png)

[example6.dart][example6]

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

### Changing mouse cursor on hover

`TextDefinition` and `SelectiveDefinition` have the `mouseCursor` property. The mouse cursor type set to it
is used while the pointer hovers over a string that has matched the matcher specified in the definition.

If a tap callback (`onTap` or `onLongPress`) is set and `mouseCursor` is not set, `SystemMouseCursors.click`
is automatically used for the string that the tap callback is applied to.

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
      // `SystemMouseCursors.forbidden` is used for email addresses.
      mouseCursor: SystemMouseCursors.forbidden,
    ),
    TextDefinition(
      matcher: const EmailMatcher(),
      matchStyle: const TextStyle(color: Colors.lightBlue),
      tapStyle: const TextStyle(color: Colors.lightGreen),
      // `SystemMouseCursors.click` is used for URLs automatically
      // even if `mouseCursor` is not set because a tap has been
      // enabled by the `onTap` callback.
      onTap: (text) => output(text),
    ),
  ],
)
```

## Limitations

- The regular expression pattern of `TelMatcher` contains a lookbehind assertion, but
[Safari does not support it](https://caniuse.com/?search=lookbehind). Avoid using `TelMatcher`
as is if your app targets Safari.

## Links

- [text_parser][text_parser]
    - CustomText is dependent on the `text_parser` package. Please see its documentation
    for details or troubleshooting on parsing.

[example]: https://github.com/kaboc/flutter_custom_text/tree/main/example
[example1]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example1.dart
[example2]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example2.dart
[example3]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example3.dart
[example4]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example4.dart
[example5]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example5.dart
[example6]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/example6.dart
[TelMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/TelMatcher/TelMatcher.html
[SelectiveDefinition]: https://pub.dev/documentation/custom_text/latest/custom_text/SelectiveDefinition-class.html
[SpanDefinition]: https://pub.dev/documentation/custom_text/latest/custom_text/SpanDefinition-class.html
[InlineSpan]: https://api.flutter.dev/flutter/painting/InlineSpan-class.html
[text_parser]: https://pub.dev/packages/text_parser
