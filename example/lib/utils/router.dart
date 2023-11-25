import 'dart:io' show Platform;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
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
import 'package:custom_text_example/utils/device_info.dart';

extension on GoRouterState {
  ExamplePage? get pageWidget => pages
      .firstWhereOrNull((p) => p.pathString == pathParameters['path_string']);
}

Page<T> _page<T>({required Widget child}) {
  return !kIsWeb && (Platform.isAndroid || Platform.isIOS)
      ? MaterialPage<T>(child: child)
      : NoTransitionPage<T>(child: child);
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const HomePage(),
      routes: [
        GoRoute(
          path: ':path_string',
          pageBuilder: (_, state) => _page(
            child: state.pageWidget!,
          ),
          routes: [
            GoRoute(
              path: 'code',
              pageBuilder: (_, state) => _page(
                child: CodeViewPage(filename: state.pageWidget!.filename),
              ),
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
    title: 'Styles and actions per definition',
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
    description: 'An example to parse a markdown-style link in the format '
        'of `[shown text](url)` and make it tappable.\n'
        '`SelectiveDefinition` allows to select the string to display and '
        'the string to be passed to gesture callbacks individually from '
        'the groups of matched strings.',
    builder: Example5.new,
  ),
  const ExamplePage(
    pathString: 'span-definition',
    filename: 'example6.dart',
    title: 'SpanDefinition',
    description: 'An example to show both text and widgets. '
        '`SpanDefinition` enables part of text to be replaced with an '
        'arbitrary `InlineSpan`.\n'
        'The `builder` function can use the parse result (the matched '
        'string and groups) to flexibly build an InlineSpan.',
    builder: Example6.new,
    additionalInfo: 'Gestures are detected on both the logo and the text '
        'of "Flutter".',
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
  ExamplePage(
    pathString: 'text-editing-controller',
    filename: 'example9.dart',
    title: 'CustomTextEditingController',
    description: 'An example to use most `CustomText` features in '
        '`TextField` too using `CustomTextEditingController`.\n\n'
        'Notice:\n'
        '* SelectiveDefinition and SpanDefinition are not available '
        'for CustomTextEditingController.\n'
        '* Not suitable for long text, even with debouncing enabled.',
    builder: (text) => Example9(DeviceInfo.isIosSimulator ? null : text),
    additionalInfo: 'Try editing the text in the box above.\n'
        'As you type, email addresses, URLs and hashtags are decorated, '
        '${DeviceInfo.isIosSimulator ? '' : 'URLs become tappable, '}'
        'and a hover effect is enabled on hashtags.',
    hasOutput: !DeviceInfo.isIosSimulator,
  ),
  ExamplePage(
    pathString: 'external-parser',
    filename: 'example10.dart',
    title: 'Using an external parser',
    description: 'An example of using an external parser.\n'
        'This example uses a custom parser powered by package:highlight '
        'to achieve keyword highlighting of several different formats '
        'of text, which is not easy with the default parser.',
    builder: (_) => const Example10(),
    // If hasOutput is set to true, this example overflows
    // vertically due to a bug of Flutter SDK where IntrinsicHeight
    // (used in layouts.dart) does not work well with TextField.
    // https://github.com/flutter/flutter/issues/59719
    hasOutput: false,
  ),
];
