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
import 'package:custom_text_example/home_page.dart';

extension on GoRouterState {
  int? get page => int.tryParse(params['page'] ?? '');
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomePage(),
      routes: [
        GoRoute(
          path: ':page',
          builder: (_, state) => pages[state.page]!,
          routes: [
            GoRoute(
              path: 'code',
              builder: (_, state) {
                return CodeViewPage(filename: 'example${state.page}.dart');
              },
            ),
          ],
          redirect: (_, state) {
            final page = state.page;
            return page == null || page < 0 || page > pages.length ? '/' : null;
          },
        ),
      ],
    ),
  ],
);

final pages = {
  1: ExamplePage(
    page: 1,
    title: 'Simple',
    description: 'A very basic example to apply a colour to URLs and '
        'email addresses using preset matchers.',
    builder: (_) => const Example1(),
    hasOutput: false,
    additionalInfo: 'Tapping on text does not trigger anything in '
        'this example.',
  ),
  2: const ExamplePage(
    page: 2,
    title: 'Unique styles and actions',
    description: 'An example to decorate URLs, email addresses and phone '
        'numbers, and also enable them to be tapped and long-pressed.\n'
        'Phone numbers are styled differently with the unique `matchStyle` '
        'and `tapStyle`.',
    builder: Example2.new,
    additionalInfo: 'Try tapping or long-pressing on coloured strings.',
  ),
  3: const ExamplePage(
    page: 3,
    title: 'Overwriting match pattern',
    description: 'An example to replace the default pattern of `TelMatcher`.\n'
        'The new pattern regards only the `{3 digits}-{4 digits}-{4 digits}` '
        'format as a phone number.',
    builder: Example3.new,
  ),
  4: const ExamplePage(
    page: 4,
    title: 'Custom pattern',
    description: 'An example to parse hashtags with a custom matcher '
        'and apply styles to them.\n'
        'Here as an example, a hashtag is defined as a string that starts '
        'with `#` followed by an alphabet and then alphanumerics, and is '
        'enclosed with white spaces.',
    builder: Example4.new,
  ),
  5: const ExamplePage(
    page: 5,
    title: 'SelectiveDefinition',
    description:
        'An example to parse markdown-style links, like `[label](url)` '
        'using `SelectiveDefinition`, and make them tappable.\n'
        'Each of the string shown in the widget and the string passed to '
        'the tap callbacks is selected individually from the groups of '
        'matched strings.',
    builder: Example5.new,
  ),
  6: const ExamplePage(
    page: 6,
    title: 'SpanDefinition',
    description: 'An example to show both strings and icons using '
        '`SpanDefinition`.\n'
        'The `builder` argument takes a function returning an `InlineSpan`.\n'
        'The function can use the matched string and groups passed to it '
        'to build an `InlineSpan` flexibly with them.',
    builder: Example6.new,
  ),
  7: const ExamplePage(
    page: 7,
    title: 'Mouse cursor and text style on hover',
    description: 'An example to change the mouse cursor and text style '
        'on hover.\n'
        'The mouse cursor type passed to `mouseCursor` of a definition '
        'is used for matched string while the mouse pointer hovers over it.',
    builder: Example7.new,
    additionalInfo: 'Run the app on desktop to see how this example '
        'looks and behaves on hover over some strings.',
  ),
  8: const ExamplePage(
    page: 8,
    title: 'CustomTextEditingController',
    description: 'An example to use most `CustomText` features in '
        '`TextField` too using `CustomTextEditingController`.\n\n'
        'Notice:\n'
        '* SelectiveDefinition and SpanDefinition are not available '
        'for CustomTextEditingController.\n'
        '* Not suitable for long text, even with debouncing enabled.',
    builder: Example8.new,
    additionalInfo: 'Try editing the text in the box above.\n'
        'As you type, email addresses, URLs and hashtags are decorated, '
        'URLs become tappable, and a hover effect is enabled on hashtags.',
  ),
};
