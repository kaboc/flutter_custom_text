import 'dart:io' show Platform;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:custom_text_example/code_view_page.dart';
import 'package:custom_text_example/example_page.dart';
import 'package:custom_text_example/examples/src/custom_pattern.dart';
import 'package:custom_text_example/examples/src/external_parser.dart';
import 'package:custom_text_example/examples/src/hover_style.dart';
import 'package:custom_text_example/examples/src/on_gesture.dart';
import 'package:custom_text_example/examples/src/overwriting_pattern.dart';
import 'package:custom_text_example/examples/src/pre_builder.dart';
import 'package:custom_text_example/examples/src/real_hyperlinks.dart';
import 'package:custom_text_example/examples/src/selective_definition.dart';
import 'package:custom_text_example/examples/src/simple.dart';
import 'package:custom_text_example/examples/src/span_definition.dart';
import 'package:custom_text_example/examples/src/spans_constructor.dart';
import 'package:custom_text_example/examples/src/styles_and_actions.dart';
import 'package:custom_text_example/examples/src/text_editing_controller.dart';
import 'package:custom_text_example/home_page.dart';
import 'package:custom_text_example/common/device_info.dart';

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
        ),
      ],
    ),
  ],
  redirect: (_, state) {
    return state.pageWidget == null ? '/' : null;
  },
);

final pages = [
  ExamplePage(
    pathString: 'simple',
    title: 'Simple (no gesture)',
    description: 'A very basic example to apply a colour to URLs and '
        'email addresses using preset matchers.',
    builder: (_) => const SimpleExample(),
    hasOutput: false,
    additionalInfo: 'Tapping on text does not trigger anything in '
        'this example.',
  ),
  const ExamplePage(
    pathString: 'styles-and-actions',
    title: 'Styles and actions per definition',
    description: 'An example to decorate URLs, email addresses and phone '
        'numbers, and also enable them to be tapped and long-pressed.\n'
        'Phone numbers are styled differently with the unique `matchStyle` '
        'and `tapStyle`.',
    builder: StylesAndActionsExample.new,
    additionalInfo: 'Try tapping or long-pressing on coloured strings.',
  ),
  const ExamplePage(
    pathString: 'overwriting-pattern',
    title: 'Overwriting a match pattern',
    description: 'An example to replace the default pattern of `TelMatcher`.\n'
        'The new pattern regards only the `{3 digits}-{4 digits}-{4 digits}` '
        'format as a phone number.',
    builder: OverwritingPatternExample.new,
  ),
  const ExamplePage(
    pathString: 'custom-pattern',
    title: 'Custom match pattern',
    description: 'An example to parse hashtags with a custom matcher '
        'and apply styles to them.\n'
        'Here as an example, a hashtag is defined as a string that starts '
        'with `#` followed by an alphabet and then alphanumerics, and is '
        'enclosed with white spaces.',
    builder: CustomPatternExample.new,
  ),
  const ExamplePage(
    pathString: 'selective-definition',
    title: 'SelectiveDefinition',
    description: 'An example to parse a markdown-style link in the format '
        'of `[shown text](url)` and make it tappable.\n'
        '`SelectiveDefinition` allows to select the string to display and '
        'the string to be passed to gesture callbacks individually.',
    builder: SelectiveDefinitionExample.new,
  ),
  const ExamplePage(
    pathString: 'span-definition',
    title: 'SpanDefinition',
    description: 'An example to show both text and widgets. '
        '`SpanDefinition` enables part of text to be replaced with an '
        'arbitrary `InlineSpan`.\n'
        'The `builder` function can use the parse result to flexibly '
        'build an InlineSpan.',
    builder: SpanDefinitionExample.new,
    additionalInfo: 'Gestures are detected on both the logo and the text '
        'of "Flutter".',
  ),
  ExamplePage(
    pathString: 'real-hyperlinks',
    title: 'Real hyperlinks',
    description: 'An example to embed real hyperlinks for the web '
        'by making use of `SpanDefinition` together with the `Link` '
        'widget of package:url_launcher.',
    builder: (_) => const RealHyperlinksExample(),
    additionalInfo: 'Run this example in a desktop web browser and '
        'place the mouse pointer or right-click on a link.\n\n'
        'Note:\n'
        'Sadly, WidgetSpans are vertically misaligned with plain text '
        'on the web due to issues existing on the Flutter SDK side.',
    hasOutput: false,
  ),
  const ExamplePage(
    pathString: 'hover-style',
    title: 'Mouse cursor and text style on hover',
    description: 'An example to change the mouse cursor and text style '
        'on hover.\n'
        'The mouse cursor type passed to `mouseCursor` of a definition '
        'is used for matched string while the mouse pointer hovers over it.',
    builder: HoverStyleExample.new,
    additionalInfo: 'Run the app on desktop to see how this example '
        'looks and behaves on hover over some strings.',
  ),
  const ExamplePage(
    pathString: 'on-gesture',
    title: 'Event positions and onGesture',
    description: 'An example to show a popup at the position of a primary '
        'button press or a mouse enter event.\n'
        'The secondary and tertiary buttons also call the `onGesture` '
        'callback.\n\n'
        'Notice:\n'
        '* On the web, the context menu of your browser will interfere '
        'with secondary button events unless the menu is suppressed.\n'
        '* The popup feature does not come with the package.',
    builder: OnGestureExample.new,
    additionalInfo: 'The above text is an excerpt from the following '
        'Wikipedia entry:\n'
        'https://en.wikipedia.org/wiki/Flutter_(software)',
  ),
  const ExamplePage(
    pathString: 'spans-constructor',
    title: 'CustomText.spans',
    description: 'The `CustomText.spans` constructor allows to use a '
        'list of `InlineSpan`s instead of plain text.\n'
        'This is useful if you already have styled spans and want to '
        'decorate them additionally.',
    builder: CustomTextSpansExample.new,
    additionalInfo: 'This example applies hoverStyle and onGesture '
        'to the range containing multiple styled InlineSpans including '
        'a WidgetSpan.\n\n'
        'Note that arguments other than `text` and `style` in the spans '
        'are not used even if specified.',
  ),
  ExamplePage(
    pathString: 'pre-builder',
    title: 'CustomText with preBuilder',
    description: '`preBuilder` allows to apply decorations and then '
        'additionally apply more decorations and enable gestures.\n'
        'It has similar use cases to `CustomText.spans`, but is more '
        'helpful when it is not easy to compose complex spans manually.',
    builder: (_) => const PreBuilderExample(),
    additionalInfo: 'Note that gesture callbacks and `mouseCursor` '
        'in the builder are not used even if specified.',
    hasOutput: false,
  ),
  ExamplePage(
    pathString: 'text-editing-controller',
    title: 'CustomTextEditingController',
    description: 'An example to use most `CustomText` features in '
        '`TextField` too using `CustomTextEditingController`.\n\n'
        'Notice:\n'
        '* SelectiveDefinition and SpanDefinition are not available '
        'for CustomTextEditingController.\n'
        '* Not suitable for long text, even with debouncing enabled.',
    builder: (text) =>
        ControllerExample(DeviceInfo.isIosSimulator ? null : text),
    additionalInfo: 'Try editing the text in the box above.\n'
        'As you type, email addresses, URLs and hashtags are decorated, '
        '${DeviceInfo.isIosSimulator ? '' : 'URLs become tappable, '}'
        'and a hover effect is enabled on hashtags.',
    hasOutput: !DeviceInfo.isIosSimulator,
  ),
  ExamplePage(
    pathString: 'external-parser',
    title: 'Using an external parser',
    description: 'An example of using an external parser.\n'
        'This example uses a custom parser powered by package:highlight '
        'to achieve keyword highlighting of several different formats '
        'of text, which is not easy with the default parser.',
    builder: (_) => const ExternalParserExample(),
    // If hasOutput is set to true, this example overflows
    // vertically due to a bug of Flutter SDK where IntrinsicHeight
    // (used in layouts.dart) does not work well with TextField.
    // https://github.com/flutter/flutter/issues/59719
    hasOutput: false,
  ),
];
