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

int? _id(GoRouterState state) {
  return int.tryParse(state.params['id'] ?? '');
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomePage(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (_, state) => pages[_id(state)]!,
          routes: [
            GoRoute(
              path: 'code',
              builder: (_, state) => CodeViewPage(id: _id(state)!),
            ),
          ],
        ),
      ],
    ),
  ],
  redirect: (state) {
    if (state.params.containsKey('id')) {
      final id = _id(state);
      if (id == null || id < 0 || id > pages.length) {
        return '/';
      }
    }
  },
);

final pages = {
  1: ExamplePage(
    id: 1,
    title: 'Simple',
    description: 'A very basic example to apply a colour to URLs and email '
        'addresses.\nThey are not tappable in this example.',
    builder: (_) => const Example1(),
    hasOutput: false,
    additionalInfo: 'Tapping on text in this example does not print '
        'anything here.',
  ),
  2: ExamplePage(
    id: 2,
    title: 'Unique styles and actions',
    description: 'An example to apply styles to URLs, email addresses and '
        'phone numbers, and enable them to be tapped / long-pressed.\n'
        'Phone numbers are styled differently according to the `matchStyle` '
        'and `tapStyle` set in the definition.',
    builder: (outputFunc) => Example2(outputFunc),
    additionalInfo: 'Try tapping / long-pressing on coloured strings.',
  ),
  3: ExamplePage(
    id: 3,
    title: 'Overwritten match pattern',
    description: 'An example to overwrite the default match pattern of '
        '`TelMatcher`.\n'
        'The new pattern regards only the `{3 digits}-{4 digits}-{4 digits}` '
        'format as a phone number.',
    builder: (outputFunc) => Example3(outputFunc),
  ),
  4: ExamplePage(
    id: 4,
    title: 'Custom matchers',
    description: 'An example to parse hashtags using a custom matcher '
        'and apply styles to them.\n'
        'A hashtag has a wide variety of definitions, but here as an '
        'example, it is defined as a string that starts with `#` followed '
        'by an alphabet and then by alphanumerics, and is enclosed with '
        'white spaces.',
    builder: (outputFunc) => Example4(outputFunc),
  ),
  5: ExamplePage(
    id: 5,
    title: 'SelectiveDefinition',
    description:
        'An example to parse markdown-style links, like `[label](url)` '
        'using `SelectiveDefinition`, and make them tappable.\n'
        'Each of the string shown in the widget and the string passed to '
        'the tap callbacks is selected individually from the fragments '
        '(`groups`) that have matched the patterns enclosed with '
        'parentheses within the match pattern.',
    builder: (outputFunc) => Example5(outputFunc),
  ),
  6: ExamplePage(
    id: 6,
    title: 'SpanDefinition',
    description: 'An example to show both strings and icons using '
        '`SpanDefinition`.\n'
        'The builder parameter takes a function returning an `InlineSpan`.\n'
        'The function is provided with matched string and groups, so '
        'it is possible to construct an `InlineSpan` flexibly with them.',
    builder: (outputFunc) => Example6(outputFunc),
  ),
  7: ExamplePage(
    id: 7,
    title: 'Mouse cursor and text style on hover',
    description: 'An example to show the feature of changing the mouse '
        'cursor and the text style on hover.\n'
        'The mouse cursor type set to `mouseCursor` of a definition is '
        'used while the mouse pointer hovers over a matching string.',
    builder: (outputFunc) => Example7(outputFunc),
    additionalInfo: 'Run the app on desktop to see how this example '
        'looks and behaves on hover over some strings.',
  ),
  8: ExamplePage(
    id: 8,
    title: 'CustomText.selectable',
    description: 'A example of selectable CustomText.\n'
        'This is almost the same as example2, but different in that this '
        'one is based on `SelectableText`, allowing text to be selected.',
    builder: (outputFunc) => Example8(outputFunc),
  ),
  9: ExamplePage(
    id: 9,
    title: 'CustomTextEditingController',
    description: 'An example to decorate URLs, email addresses and '
        'hashtags in `TextField` using `CustomTextEditingController`.\n\n'
        'Note that only `TextDefinition` is available for '
        '`CustomTextEditingController`.\n'
        'Also be careful not to use CustomTextEditingController for '
        'long text. It will lead to poor performance.',
    builder: (outputFunc) => Example9(outputFunc),
    additionalInfo: 'Try editing the text in the box above.\n'
        'As you type, email addresses, URLs and hashtags are decorated, '
        'URLs become tappable, and a hover effect is enabled on hashtags.',
  ),
};
