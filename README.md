# custom_text

A text widget for Flutter that enables strings in it to be styled flexibly and/or tapped.

This widget may be useful for making link strings tappable, such as URLs, email addresses or
phone numbers, or for only highlighting string elements in text with colors / different font
settings depending on the types of string elements.

## Examples / Usage

The following examples are all contained in the sample app in the `example/` folder.
Just run it and see what this package is like if you're reluctant to read through all
this document.

The app also shows the source code with keywords highlighted, which is itself thanks 
to this package.

### Simplest example

A very basic example with URLs and email addresses styled.
They are not tappable in this example.

[example1.dart](example/lib/examples/example1.dart)

```dart
CustomText(
  'URL: https://example.com/\n'
  'Email: foo@example.com',
  definitions: const [
    TextDefinition(matcher: UrlMatcher()),
    TextDefinition(matcher: EmailMatcher()),
  ],
  matchStyle: const TextStyle(color: Colors.lightBlue),
  // `tapStyle` does not work on tap even if set
  // unless `onTap` / `onLongTap` is set.
  tapStyle: const TextStyle(color: Colors.yellow),
  //onTap: (text) => print(text),
)
```

### Unique styles and actions per definition

An example to apply styles to URLs, email addresses and phone numbers, and also enable
them to be tapped / long-tapped.

All of the three are styled, but only phone numbers among them are given unique `matchStyle`
and `tapStyle`.

[example2.dart](example/lib/examples/example2.dart)

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
      // `matchStyle`, `tapStyle`, `onTap` and `onLongTap` here take
      // precedence over the equivalent parameters of CustomText.
      matchStyle: const TextStyle(
        color: Colors.green,
        decoration: TextDecoration.underline,
      ),
      tapStyle: const TextStyle(color: Colors.orange),
      onTap: (tel) => print('tel: $tel'),
      onLongTap: (tel) => print('[Long-tapped] tel: $tel'),
    ),
  ],
  matchStyle: const TextStyle(
    color: Colors.lightBlue,
    decoration: TextDecoration.underline,
  ),
  tapStyle: const TextStyle(color: Colors.indigo),
  onTap: (type, text) => print('$type: $text'),
  onLongTap: (type, text) => print('[Long-tapped] $type: $text'),
)
```

### Overwriting match patterns

An example to overwrite the default match pattern of `TelMatcher`.

The new pattern regards only the `{3 digits}-{4 digits}-{4 digits}` format as a phone number.

[example3.dart](example/lib/examples/example3.dart)

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

[example4.dart](example/lib/examples/example4.dart)

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

An example to parse markdown-style links, like `[label](url)` using `SelectiveDefinition`,
and make them tappable.

Each of the string shown in the widget and the string passed to the tap callbacks is selected
individually from the fragments (`groups`) that have matched the patterns enclosed with
parentheses within the match pattern.

For details of `groups`, please see the document of the
[text_parser](https://pub.dev/packages/text_parser) package, which this package uses internally.

[example5.dart](example/lib/examples/example5.dart)

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
      // strings matching the fragments enclosed with parentheses
      // within the match pattern.
      labelSelector: (groups) => groups[0],
      // `tapSelector` is used to choose the string to be passed
      // to the `onTap` and `onLongTap` callbacks.
      tapSelector: (groups) => groups[1],
    ),
  ],
  matchStyle: const TextStyle(color: Colors.lightBlue),
  tapStyle: const TextStyle(color: Colors.green),
  onTap: (_, text) => print(text),
)
```

### SpanDefinition

An example to show both strings and icons using `SpanDefinition`.

The builder parameter takes a function returning an
[InlineSpan](https://api.flutter.dev/flutter/painting/InlineSpan-class.html).
The function is provided with matched string and groups, so it is possible to construct
an `InlineSpan` flexibly with them.

[example6.dart](example/lib/examples/example6.dart)

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
            recognizer: TapGestureRecognizer()
              ..onTap = () => print(text),
          ),
        ],
      ),
    ),
  ],
)
```

## Limitations

On the web, taps/long-taps on some string elements that should be tappable do not work
due to some issues in Flutter itself.

- [TapGestureRecognizer doesn't work on web, does work on mobile. · Issue #46975 · flutter/flutter](https://github.com/flutter/flutter/issues/46975)
- [[web]: TextSpans interact with wrong TapGestureRecognizers  · Issue #63638 · flutter/flutter](https://github.com/flutter/flutter/issues/63638)

## Links

- [text_parser](https://pub.dev/packages/text_parser) package
    - CustomText is heavily dependent on text_parser. Please see its documentation for details
    or troubleshooting on parsing.
