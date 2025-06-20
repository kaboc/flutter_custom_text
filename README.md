[![Pub Version](https://img.shields.io/pub/v/custom_text)](https://pub.dev/packages/custom_text)
[![Flutter CI](https://github.com/kaboc/flutter_custom_text/workflows/Flutter%20CI/badge.svg)](https://github.com/kaboc/flutter_custom_text/actions)
[![codecov](https://codecov.io/gh/kaboc/flutter_custom_text/branch/main/graph/badge.svg?token=H7ILK6CS0V)](https://codecov.io/gh/kaboc/flutter_custom_text)

A highly customisable text widget that enables decorations and gesture actions, and
a special TextEditingController that makes some of the features available also
in a text field.

This package is useful for making partial strings in text (e.g. URLs, email addresses
or phone numbers) react to tap, long-press and hover gestures, or for only highlighting
particular strings with colors and different font settings. You can configure the appearance
and the behaviour using multiple definitions consisting of regular expressions, text styles,
gesture handlers, etc.

---

## Usage by example

Most of the examples here are included in the sample app in the [example] folder.
Just click on the link below to see it in action on the web.

**[Web Demo][demo]**

The app shows the source code with keywords highlighted, which itself is made possible
by this package (plus the [highlight] package used as an external parser).

<a href="https://kaboc.github.io/flutter_custom_text/">
<img src="https://github.com/kaboc/flutter_custom_text/assets/20254485/b92d95d2-e0eb-45dd-8fb3-38cc22fb76ff" alt="Code highlighting" height="360">
</a>

---

### ⭐ <b>Simplest example</b>

A very basic example of how to apply a colour to URLs and email addresses using preset
matchers.

[Code][example_simple] / [Demo][demo_simple]

![Image - Simplest example image](https://user-images.githubusercontent.com/20254485/100355817-c0bddb80-3035-11eb-8c5b-3c4d0ee9f921.png)

<details>
<summary>Click to see the details</summary>
<br>

Gestures are not available on the coloured strings in this example.

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
</details>

---

### ⭐ <b>Styles and actions per definition</b>

An example to decorate URLs, email addresses and phone numbers, and also enable them
to be tapped and long-pressed.

[Code][example_styles_and_actions] / [Demo][demo_styles_and_actions]

![Image - Styles and actions per definition](https://user-images.githubusercontent.com/20254485/221410479-c1014891-2e4a-40d6-9fcf-db1a2b946dfd.gif)

<details>
<summary>Click to see the details</summary>
<br>

All the three are styled, but only phone numbers among them are styled differently with
the unique `matchStyle` and `tapStyle`.

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

> [!TIP]
> To open a browser or another app when a string is tapped or long-pressed, use the
  [url_launcher] package or equivalent in the `onTap` and/or `onLongPress` handlers.
</details>

---

### ⭐ <b>Overwriting a match pattern</b>

An example to replace the default pattern of [TelMatcher].

[Code][example_overwriting_pattern] / [Demo][demo_overwriting_pattern]

![Image - Overwriting match pattern](https://user-images.githubusercontent.com/20254485/100355852-ca474380-3035-11eb-8fc9-e9f895f0f17b.png)

<details>
<summary>Click to see the details</summary>
<br>

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
</details>

---

### ⭐ <b>Custom match pattern</b>

An example to parse hashtags with a custom pattern and apply styles to them.

[Code][example_custom_pattern] / [Demo][demo_custom_pattern]

![Image - Custom match pattern](https://user-images.githubusercontent.com/20254485/100355864-cddaca80-3035-11eb-9dff-02cd7c97375e.png)

<details>
<summary>Click to see the details</summary>
<br>

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
</details>

---

### ⭐ <b>SelectiveDefinition</b>

An example to parse a markdown-style link in the format of `[shown text](url)`
and make it tappable.

[Code][example_selective_definition] / [Demo][demo_selective_definition]

![Image - SelectiveDefinition](https://github.com/kaboc/flutter_custom_text/assets/20254485/d47566f4-a92e-4d74-99d4-866387cd4ad8)

<details>
<summary>Click to see the details</summary>
<br>

[SelectiveDefinition] allows to select the string to display and the string to
be passed to gesture callbacks individually.

The `shownText` and `actionText` functions receive a [TextElement] object
containing various pieces of information provided by the parser. For its
details, see the document of the [text_parser] package used internally in
this package.

```dart
CustomText(
  'Tap [here](Tapped!)',
  definitions: [
    SelectiveDefinition(
      matcher: const LinkMatcher(),
      // `shownText` is used to choose the string to display.
      shownText: (element) => element.groups[0]!,
      // `actionText` is used to choose the string to be passed
      // to the `onTap`, `onLongPress` and `onGesture` handlers.
      actionText: (element) => element.groups[1]!,
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
      shownText: (element) => element.groups[0]!,
    ),
  ],
  matchStyle: const TextStyle(color: Colors.red),
)
```
</details>

---

### ⭐ <b>SpanDefinition</b>

An example to display both text and widgets.

[Code][example_span_definition] / [Demo][demo_span_definition]

![Image - SpanDefinition](https://github.com/kaboc/flutter_custom_text/assets/20254485/7e566862-d986-478b-85ff-9e26d4c47821)

<details>
<summary>Click to see the details</summary>
<br>

[SpanDefinition] enables a certain portion of text to be replaced with an arbitrary
[InlineSpan]. The `builder` function receives a [TextElement] object containing
various pieces of information provided by the parser so that you can use it
to flexibly build an `InlineSpan`.

Text styles, gesture handlers and the mouse cursor type are applied to the entire
`InlineSpan` returned by the `builder` function. In this example, hovering is detected
on all the children specified in the second SpanDefinition, i.e. the text in a TextSpan
is decorated based on `hoverStyle` while the mouse pointer is hovering over the logo
as well as over the text.

```dart
CustomText(
  'Hover and click  >>  [logo]Flutter',
  definitions: [
    SpanDefinition(
      matcher: const PatternMatcher('>>'),
      builder: (element) => const WidgetSpan(
        child: Icon(Icons.keyboard_double_arrow_right, ...),
      ),
    ),
    SpanDefinition(
      matcher: const PatternMatcher(r'\[logo\](\w+)'),
      builder: (element) => TextSpan(
        children: [
          const WidgetSpan(child: FlutterLogo()),
          const WidgetSpan(child: SizedBox(width: 2.0)),
          TextSpan(text: element.groups.first),
        ],
      ),
      matchStyle: TextStyle(color: Colors.blue),
      hoverStyle: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
      onTap: (details) => print(details.element.groups.first!),
    ),
  ],
)
```
</details>

---

### ⭐ <b>Real hyperlinks</b>

An example to embed real hyperlinks for the web by making use of [SpanDefinition]
together with the `Link` widget of [url_launcher].

[Code][example_real_hyperlinks] / [Demo][demo_real_hyperlinks]

![Image - Real hyperlinks](https://github.com/kaboc/flutter_custom_text/assets/20254485/fd93cf5f-36b7-411e-9ba4-37d85e33075e)

<details>
<summary>Click to see the details</summary>
<br>

```dart
CustomText(
  'Please visit [pub.dev](https://pub.dev/packages/custom_text) and ...',
  definitions: [
    SpanDefinition(
      matcher: const LinkMatcher(),
      builder: (element) {
        return WidgetSpan(
          baseline: TextBaseline.alphabetic,
          alignment: PlaceholderAlignment.baseline,
          child: Link(
            uri: Uri.parse(element.groups[1]!),
            target: LinkTarget.blank,
            builder: (context, openLink) {
              return GestureDetector(
                onTap: openLink,
                child: Text(element.groups[0]!),
              );
            },
          ),
        );
      },
      matchStyle: const TextStyle(color: Colors.blue),
      hoverStyle: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
      mouseCursor: SystemMouseCursors.click,
    ),
  ],
)
```
</details>

---

### ⭐ <b>Changing mouse cursor and text style on hover</b>

An example to change the mouse cursor type on certain substrings.

[Code][example_hover_style] / [Demo][demo_hover_style]

![Image - Mouse cursor and text style on hover](https://user-images.githubusercontent.com/20254485/221410499-23e5dfd2-dc19-4234-b119-17c46ac80a77.gif)

<details>
<summary>Click to see the details</summary>
<br>

This is easily possible by just passing your desired type to `mouseCursor`.

If a tap handler (`onTap` or `onLongPress`) is specified and `mouseCursor` is not,
`SystemMouseCursors.click` is automatically used for the tappable region.

A different text style can also be applied on hover using `hoverStyle` either in `CustomText`
or in a definition.

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

> [!TIP]
> Use `hoverStyle` and omit `tapStyle` if you want the same style for tap and hover.
</details>

---

### ⭐ <b>Event positions and onGesture</b>

An example to trigger an action by a secondary or tertiary button press or a
mouse enter or exit gesture.

[Code][example_on_gesture] / [Demo][demo_on_gesture]

![Image - Event positions and onGesture](https://user-images.githubusercontent.com/20254485/221400940-c686ab71-8d15-46ad-99fd-9058f7ca30dc.gif)

<details>
<summary>Click to see the details</summary>
<br>

The `onGesture` handler is called on an event of a non-primary button or mouse
gesture.

You can check the event type with `gestureKind` contained in the [GestureDetails]
object which is passed to the handler function. The object also has the global
and local positions where an event happened.

> [!NOTE]
> - `onGesture` does not handle events of the primary button. Use `onTap` and/or
    `onLongPress` instead.
> - Unlike `onTap` and `onLongPress`, whether `onGesture` is specified does not
    affect text styling.
> - The handler function is called one microsecond or more after the actual
    occurrence of an event.
>     - This is due to a workaround for preventing the function from being called
        more times than expected by updates of the text span.
</details>

---

### ⭐ <b>CustomText.spans</b>

An example of the [CustomText.spans] constructor that allows to use a list of `InlineSpan`s
instead of plain text.

[Code][example_spans_constructor] / [Demo][demo_spans_constructor]

![Image - CustomText.spans](https://github.com/kaboc/flutter_custom_text/assets/20254485/3d9f47d3-5ace-4191-9297-b1321f7b39cd)

<details>
<summary>Click to see the details</summary>
<br>

This constructor is useful if you already have styled spans and want to decorate them
additionally.

In this example, the match pattern matches the range containing multiple `InlineSpan`s
including a `WidgetSpan`, and the specified styles and gestures are applied to that range.

```dart
CustomText.spans(
  style: const TextStyle(fontSize: 40.0),
  definitions: [
    TextDefinition(
      // WidgetSpan is matched by `\uFFFC` or `.` in a match pattern.
      matcher: const PatternMatcher('Flutter devs\uFFFC'),
      matchStyle: const TextStyle(color: Colors.blue),
      hoverStyle: TextStyle(color: Colors.blue.shade300),
      mouseCursor: SystemMouseCursors.forbidden,
      onGesture: (details) => output(details.gestureKind.name),
    ),
  ],
  spans: [
    const TextSpan(text: 'Hi, '),
    const TextSpan(
      text: 'Flutter',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        shadows: [Shadow(blurRadius: 4.0, color: Colors.cyan)],
      ),
    ),
    const TextSpan(text: ' devs'),
    WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Builder(
        builder: (context) {
          // Text style is available also in WidgetSpan via DefaultTextStyle.
          final style = DefaultTextStyle.of(context).style;
          return Icon(
            Icons.flutter_dash,
            size: style.fontSize,
            color: style.color,
          );
        },
      ),
    ),
  ],
)
```

> [!NOTE]
> - Arguments other than `text` and `style` in the spans passed to `spans` are
    not used even if specified.
</details>

---

### ⭐ <b>CustomText with preBuilder</b>

An example of [preBuilder] that allows to apply decorations and then additionally
apply more decorations and enable gestures.

[Code][example_pre_builder] / [Demo][demo_pre_builder]

![Image - CustomText with preBuilder](https://github.com/kaboc/flutter_custom_text/assets/20254485/3066d802-b444-4ea7-9206-54941e572ac4)

<details>
<summary>Click to see the details</summary>
<br>

It has similar use cases to [CustomText.spans], but is more helpful when it is
not easy to compose complex spans manually.

The example below makes "KISS" and "Keep It Simple, Stupid!" bold, and then
applies a colour to capital letters contained in them.

```dart
CustomText(
  'KISS is an acronym for "Keep It Simple, Stupid!".',
  definitions: const [
    TextDefinition(
      // This pattern is used for parsing the TextSpan built
      // by preBuilder, not for the original text.
      matcher: PatternMatcher('[A-Z]'),
      matchStyle: TextStyle(color: Colors.red),
    ),
  ],
  preBuilder: CustomSpanBuilder(
    definitions: [
      const TextDefinition(
        // This pattern is used for parsing the original text.
        matcher: PatternMatcher('KISS|Keep.+Stupid!'),
        matchStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  ),
)
```

> [!NOTE]
> - Parsing is performed first in the builder and then in `CustomText` itself.
    It is important to understand that the match patterns in the builder are used
    for the original text and the patterns in `CustomText` are used for the `TextSpan`
    built by the builder. 
> - Parsing and building of spans are avoided if not necessary, but still happen
    in two steps as written above when unavoidable. Be careful how much it affects
    the performance of your app.
> - Gesture callbacks and `mouseCursor` in the builder are not used even if specified.
</details>

---

### ⭐ <b>CustomTextEditingController</b>

An example of [CustomTextEditingController] that makes some of the CustomText
functionality available in an editable text.

[Code][example_text_editing_controller] / [Demo][demo_text_editing_controller]

![Image - CustomTextEditingController](https://user-images.githubusercontent.com/20254485/221410504-f8af0c02-1ccb-4094-bdf1-bb6a1a454874.gif)

<details>
<summary>Click to see the details</summary>
<br>

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

> [!NOTE]
> - `CustomTextEditingController` does not support `SelectiveDefinition` and `SpanDefinition`.
> - An error is raised on iOS simulators (not on real devices) if the initial text
    and `onTap`, `onLongPress` or `onGesture` are specified.
>     - See https://github.com/flutter/flutter/issues/97433.
> - Debouncing of text parsing is available as an experimental feature for getting
    slightly better performance in handling long text.
>     - Pass some duration to `debounceDuration` to enable the feature.
>     - Use it at your own risk.
>     - Text input will be still slow even with debouncing because
        [Flutter itself has performance issues](https://github.com/flutter/flutter/issues/114158)
        in editable text.
</details>

---

### ⭐ <b>Using an external parser</b>

An example of using an external parser instead of the internal one.

[Code][example_external_parser] / [Demo][demo_external_parser]

![Image - External parser](https://user-images.githubusercontent.com/20254485/227700405-8ec4bd20-dd30-4ee3-a921-b1a3a019aba6.gif)

<details>
<summary>Click to see the details</summary>
<br>

`ParserOptions.external` helps you when a different parser you already have does
a better job or can do what is difficult with the default parser.

```dart
// These empty matchers are used to distinguish the matcher types of
// text elements parsed by an external parser.
// Each of the elements created by the parser needs to have the type
// of one of these matchers or `TextMatcher`. 
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

> [!NOTE]
> - The external parser must generate a list of [TextElement]s.
> - If an existing external parser creates hierarchical nodes, they need to be
    flattened as this package only supports a flat list.
> - If a custom parser is used with `CustomTextEditingController`, the `TextElement`s
    generated by the parser must all together constitute the original text.
    Otherwise, it will cause unexpected behaviours.
>     - This does not apply to `CustomText`.
</details>

---

## Limitations

- `decorationColor` does not automatically inherit the text colour in Material 3.
  See https://github.com/flutter/flutter/issues/129553.
- The regular expression pattern of `TelMatcher` contains a lookbehind assertion.
  [It is not supported in Safari versions before 16.4](https://caniuse.com/?search=lookbehind).
- `CustomTextEditingController` raises an error on iOS simulators (not on real devices)
  if the initial text and `onTap`, `onLongPress` or `onGesture` are specified.
  See https://github.com/flutter/flutter/issues/97433.

## Links

- [text_parser]
    - CustomText is dependent on the `text_parser` package made by the same author.
      See its documents for details if you're interested or seek troubleshooting on parsing.

[demo]: https://kaboc.github.io/flutter_custom_text/
[example]: https://github.com/kaboc/flutter_custom_text/tree/main/example
[example_simple]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/basic/simple.dart
[example_styles_and_actions]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/basic/styles_and_actions.dart
[example_overwriting_pattern]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/basic/overwriting_pattern.dart
[example_custom_pattern]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/basic/custom_pattern.dart
[example_selective_definition]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/basic/selective_definition.dart
[example_span_definition]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/basic/span_definition.dart
[example_real_hyperlinks]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/basic/real_hyperlinks.dart
[example_hover_style]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/basic/hover_style.dart
[example_on_gesture]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/basic/on_gesture.dart
[example_spans_constructor]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/basic/spans_constructor.dart
[example_pre_builder]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/basic/pre_builder.dart
[example_text_editing_controller]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/basic/text_editing_controller.dart
[example_external_parser]: https://github.com/kaboc/flutter_custom_text/blob/main/example/lib/examples/basic/external_parser.dart
[demo_simple]: https://kaboc.github.io/flutter_custom_text/#/simple
[demo_styles_and_actions]: https://kaboc.github.io/flutter_custom_text/#/styles-and-actions
[demo_overwriting_pattern]: https://kaboc.github.io/flutter_custom_text/#/overwriting-pattern
[demo_custom_pattern]: https://kaboc.github.io/flutter_custom_text/#/custom-pattern
[demo_selective_definition]: https://kaboc.github.io/flutter_custom_text/#/selective-definition
[demo_span_definition]: https://kaboc.github.io/flutter_custom_text/#/span-definition
[demo_real_hyperlinks]: https://kaboc.github.io/flutter_custom_text/#/real-hyperlinks
[demo_hover_style]: https://kaboc.github.io/flutter_custom_text/#/hover-style
[demo_on_gesture]: https://kaboc.github.io/flutter_custom_text/#/on-gesture
[demo_spans_constructor]: https://kaboc.github.io/flutter_custom_text/#/spans-constructor
[demo_pre_builder]: https://kaboc.github.io/flutter_custom_text/#/pre-builder
[demo_text_editing_controller]: https://kaboc.github.io/flutter_custom_text/#/text-editing-controller
[demo_external_parser]: https://kaboc.github.io/flutter_custom_text/#/external-parser
[CustomText.spans]: https://pub.dev/documentation/custom_text/latest/custom_text/CustomText/CustomText.spans.html
[preBuilder]: https://pub.dev/documentation/custom_text/latest/custom_text/CustomText/preBuilder.html
[CustomTextEditingController]: https://pub.dev/documentation/custom_text/latest/custom_text/CustomTextEditingController-class.html
[TextMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/TextMatcher-class.html
[UrlMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/UrlMatcher-class.html
[UrlLikeMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/UrlLikeMatcher-class.html
[EmailMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/EmailMatcher-class.html
[TelMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/TelMatcher-class.html
[LinkMatcher]: https://pub.dev/documentation/custom_text/latest/custom_text/LinkMatcher-class.html
[PatternMatcher]: https://pub.dev/documentation/text_parser/latest/text_parser/PatternMatcher-class.html
[SelectiveDefinition]: https://pub.dev/documentation/custom_text/latest/custom_text/SelectiveDefinition-class.html
[SpanDefinition]: https://pub.dev/documentation/custom_text/latest/custom_text/SpanDefinition-class.html
[TextElement]: https://pub.dev/documentation/text_parser/latest/text_parser/TextElement-class.html
[GestureDetails]: https://pub.dev/documentation/custom_text/latest/custom_text/GestureDetails-class.html
[InlineSpan]: https://api.flutter.dev/flutter/painting/InlineSpan-class.html
[WidgetSpan]: https://api.flutter.dev/flutter/widgets/WidgetSpan-class.html
[text_parser]: https://pub.dev/packages/text_parser
[url_launcher]: https://pub.dev/packages/url_launcher
[highlight]: https://pub.dev/packages/highlight
