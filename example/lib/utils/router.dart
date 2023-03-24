import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';

import 'package:custom_text_example/code_view_page.dart';
import 'package:custom_text_example/example_page.dart';
import 'package:custom_text_example/examples/example1.dart';
import 'package:custom_text_example/examples/example2.dart';
import 'package:custom_text_example/examples/example3.dart';
import 'package:custom_text_example/examples/example4.dart';
import 'package:custom_text_example/examples/example5.dart';
import 'package:custom_text_example/examples/example6.dart';
import 'package:custom_text_example/examples/example7.dart';
import 'package:custom_text_example/examples/example8.dart';
import 'package:custom_text_example/examples/example9.dart';
import 'package:custom_text_example/examples/example10.dart';
import 'package:custom_text_example/home_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomePage(),
      routes: [
        GoRoute(
          path: ':path_string',
          builder: (_, state) => state.pageWidget!,
          routes: [
            GoRoute(
              path: 'code',
              builder: (_, state) {
                final widget = state.pageWidget!;
                return CodeViewPage(filename: widget.filename);
              },
            ),
          ],
          redirect: (_, state) {
            return state.pageWidget == null ? '/' : null;
          },
        ),
      ],
    ),
  ],
);

extension on GoRouterState {
  ExamplePage? get pageWidget {
    return pages.firstWhereOrNull((p) => p.pathString == params['path_string']);
  }
}

final pages = [
  ExamplePage(
    pathString: 'simple',
    filename: 'example1.dart',
    title: 'Simple',
    description: 'A very basic example to apply a colour to URLs and '
        'email addresses using preset matchers.',
    builder: (_) => const Example1(),
    hasOutput: false,
    additionalInfo: 'Tapping on text does not trigger anything in '
        'this example.',
  ),
  const ExamplePage(
    pathString: 'styles-and-actions',
    filename: 'example2.dart',
    title: 'Unique styles and actions',
    description: 'An example to decorate URLs, email addresses and phone '
        'numbers, and also enable them to be tapped and long-pressed.\n'
        'Phone numbers are styled differently with the unique `matchStyle` '
        'and `tapStyle`.',
    builder: Example2.new,
    additionalInfo: 'Try tapping or long-pressing on coloured strings.',
  ),
  const ExamplePage(
    pathString: 'overwriting-pattern',
    filename: 'example3.dart',
    title: 'Overwriting match pattern',
    description: 'An example to replace the default pattern of `TelMatcher`.\n'
        'The new pattern regards only the `{3 digits}-{4 digits}-{4 digits}` '
        'format as a phone number.',
    builder: Example3.new,
  ),
  const ExamplePage(
    pathString: 'custom-pattern',
    filename: 'example4.dart',
    title: 'Custom pattern',
    description: 'An example to parse hashtags with a custom matcher '
        'and apply styles to them.\n'
        'Here as an example, a hashtag is defined as a string that starts '
        'with `#` followed by an alphabet and then alphanumerics, and is '
        'enclosed with white spaces.',
    builder: Example4.new,
  ),
  const ExamplePage(
    pathString: 'selective-definition',
    filename: 'example5.dart',
    title: 'SelectiveDefinition',
    description:
        'An example to parse markdown-style links, like `[shown text](url)` '
        'using `SelectiveDefinition`, and make them tappable.\n'
        'Each of the string shown in the widget and the string passed to '
        'the tap callbacks is selected individually from the groups of '
        'matched strings.',
    builder: Example5.new,
  ),
  const ExamplePage(
    pathString: 'span-definition',
    filename: 'example6.dart',
    title: 'SpanDefinition',
    description: 'An example to show both strings and icons using '
        '`SpanDefinition`.\n'
        'The `builder` argument takes a function returning an `InlineSpan`.\n'
        'The function can use the matched string and groups passed to it '
        'to build an `InlineSpan` flexibly with them.',
    builder: Example6.new,
  ),
  const ExamplePage(
    pathString: 'hover',
    filename: 'example7.dart',
    title: 'Mouse cursor and text style on hover',
    description: 'An example to change the mouse cursor and text style '
        'on hover.\n'
        'The mouse cursor type passed to `mouseCursor` of a definition '
        'is used for matched string while the mouse pointer hovers over it.',
    builder: Example7.new,
    additionalInfo: 'Run the app on desktop to see how this example '
        'looks and behaves on hover over some strings.',
  ),
  const ExamplePage(
    pathString: 'event-position',
    filename: 'example8.dart',
    title: 'Event position and onGesture',
    description: 'An example to show a popup at the position of a primary '
        'button press or a mouse enter event.\n'
        'The secondary and tertiary buttons also call the `onGesture` '
        'callback.\n\n'
        'Notice:\n'
        '* On the web, the context menu of your browser will interfere '
        'with secondary button events unless the menu is suppressed.\n'
        '* The popup feature does not come with the package.',
    builder: Example8.new,
    additionalInfo: 'The above text is an extract from the following '
        'Wikipedia entry:\n'
        'https://en.wikipedia.org/wiki/Flutter_(software)',
  ),
  const ExamplePage(
    pathString: 'text-editing-controller',
    filename: 'example9.dart',
    title: 'CustomTextEditingController',
    description: 'An example to use most `CustomText` features in '
        '`TextField` too using `CustomTextEditingController`.\n\n'
        'Notice:\n'
        '* SelectiveDefinition and SpanDefinition are not available '
        'for CustomTextEditingController.\n'
        '* Not suitable for long text, even with debouncing enabled.',
    builder: Example9.new,
    additionalInfo: 'Try editing the text in the box above.\n'
        'As you type, email addresses, URLs and hashtags are decorated, '
        'URLs become tappable, and a hover effect is enabled on hashtags.',
  ),
  const ExamplePage(
    pathString: 'external-parser',
    filename: 'example10.dart',
    title: 'Using an external parser',
    description: 'An example of using an external parser.\n'
        'This example uses a custom parser powered by package:highlight '
        'to achieve keyword highlighting of several different formats '
        'of text, which is not easy with the default parser.',
    builder: Example10.new,
    // If hasOutput is set to true, this example overflows
    // vertically due to a bug of Flutter SDK where IntrinsicHeight
    // (used in layouts.dart) does not work well with TextField.
    // https://github.com/flutter/flutter/issues/59719
    hasOutput: false,
  ),
];
