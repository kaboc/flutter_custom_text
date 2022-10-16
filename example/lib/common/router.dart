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
          redirect: (state) {
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
    description: 'A very basic example to apply a colour to URLs and email '
        'addresses.\nThey are not tappable in this example.',
    builder: (_) => const Example1(),
    hasOutput: false,
    additionalInfo: 'Tapping on text in this example does not print '
        'anything here.',
  ),
  2: const ExamplePage(
    page: 2,
    title: 'Unique styles and actions',
    description: 'An example to apply styles to URLs, email addresses and '
        'phone numbers, and enable them to be tapped / long-pressed.\n'
        'Phone numbers are styled differently according to the `matchStyle` '
        'and `tapStyle` set in the definition.',
    builder: Example2.new,
    additionalInfo: 'Try tapping / long-pressing on coloured strings.',
  ),
  3: const ExamplePage(
    page: 3,
    title: 'Overwritten match pattern',
    description: 'An example to overwrite the default match pattern of '
        '`TelMatcher`.\n'
        'The new pattern regards only the `{3 digits}-{4 digits}-{4 digits}` '
        'format as a phone number.',
    builder: Example3.new,
  ),
  4: const ExamplePage(
    page: 4,
    title: 'Custom pattern',
    description: 'An example to parse hashtags using a custom matcher '
        'and apply styles to them.\n'
        'A hashtag has a wide variety of definitions, but here as an '
        'example, it is defined as a string that starts with `#` followed '
        'by an alphabet and then by alphanumerics, and is enclosed with '
        'white spaces.',
    builder: Example4.new,
  ),
  5: const ExamplePage(
    page: 5,
    title: 'SelectiveDefinition',
    description:
        'An example to parse markdown-style links, like `[label](url)` '
        'using `SelectiveDefinition`, and make them tappable.\n'
        'Each of the string shown in the widget and the string passed to '
        'the tap callbacks is selected individually from the fragments '
        '(`groups`) that have matched the patterns enclosed with '
        'parentheses within the match pattern.',
    builder: Example5.new,
  ),
  6: const ExamplePage(
    page: 6,
    title: 'SpanDefinition',
    description: 'An example to show both strings and icons using '
        '`SpanDefinition`.\n'
        'The builder parameter takes a function returning an `InlineSpan`.\n'
        'The function is provided with matched string and groups, so '
        'it is possible to construct an `InlineSpan` flexibly with them.',
    builder: Example6.new,
  ),
  7: const ExamplePage(
    page: 7,
    title: 'Mouse cursor and text style on hover',
    description: 'An example to show the feature of changing the mouse '
        'cursor and the text style on hover.\n'
        'The mouse cursor type set to `mouseCursor` of a definition is '
        'used while the mouse pointer hovers over a matching string.',
    builder: Example7.new,
    additionalInfo: 'Run the app on desktop to see how this example '
        'looks and behaves on hover over some strings.',
  ),
  8: const ExamplePage(
    page: 8,
    title: 'CustomText.selectable',
    description: 'A example of selectable CustomText.\n'
        'This is almost the same as example2, but different in that this '
        'one is based on `SelectableText`, allowing text to be selected.',
    builder: Example8.new,
    additionalInfo: 'Will be removed in favour of the SelectionArea '
        'widget in the near future.',
  ),
  9: const ExamplePage(
    page: 9,
    title: 'CustomTextEditingController',
    description: 'An example to decorate strings in `TextField` using '
        '`CustomTextEditingController`.\n\n'
        'Notice:\n'
        '* SelectiveDefinition and SpanDefinition are not available '
        'for CustomTextEditingController.\n'
        '* Not suitable for extremely long text, even with debouncing enabled.',
    builder: Example9.new,
    additionalInfo: 'Try editing the text in the box above.\n'
        'As you type, email addresses, URLs and hashtags are decorated, '
        'URLs become tappable, and a hover effect is enabled on hashtags.',
  ),
};
