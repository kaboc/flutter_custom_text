import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:custom_text_example/code_view_page.dart';
import 'package:custom_text_example/common/device_info.dart';
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

part 'routes.g.dart';

extension GoRouterExt on GoRouter {
  Uri get _uri => routerDelegate.currentConfiguration.uri;

  String get currentPath => _uri.path;

  String get exampleFilename {
    final pathSegments = [..._uri.pathSegments];
    final path = (pathSegments..remove('code')).join('/');
    return '${path.replaceAll('-', '_')}.dart';
  }
}

@TypedGoRoute<HomeRoute>(
  path: '/',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<SimpleRoute>(
      path: 'simple',
      routes: [TypedGoRoute<SimpleCodeRoute>(path: 'code')],
    ),
    TypedGoRoute<StylesAndActionsRoute>(
      path: 'styles-and-actions',
      routes: [TypedGoRoute<StylesAndActionsCodeRoute>(path: 'code')],
    ),
    TypedGoRoute<OverwritingPatternRoute>(
      path: 'overwriting-pattern',
      routes: [TypedGoRoute<OverwritingPatternCodeRoute>(path: 'code')],
    ),
    TypedGoRoute<CustomPatternRoute>(
      path: 'custom-pattern',
      routes: [TypedGoRoute<CustomPatternCodeRoute>(path: 'code')],
    ),
    TypedGoRoute<SelectiveDefinitionRoute>(
      path: 'selective-definition',
      routes: [TypedGoRoute<SelectiveDefinitionCodeRoute>(path: 'code')],
    ),
    TypedGoRoute<SpanDefinitionRoute>(
      path: 'span-definition',
      routes: [TypedGoRoute<SpanDefinitionCodeRoute>(path: 'code')],
    ),
    TypedGoRoute<RealHyperlinksRoute>(
      path: 'real-hyperlinks',
      routes: [TypedGoRoute<RealHyperlinksCodeRoute>(path: 'code')],
    ),
    TypedGoRoute<HoverStyleRoute>(
      path: 'hover-style',
      routes: [TypedGoRoute<HoverStyleCodeRoute>(path: 'code')],
    ),
    TypedGoRoute<OnGestureRoute>(
      path: 'on-gesture',
      routes: [TypedGoRoute<OnGestureCodeRoute>(path: 'code')],
    ),
    TypedGoRoute<CustomTextSpansRoute>(
      path: 'spans-constructor',
      routes: [TypedGoRoute<CustomTextSpansCodeRoute>(path: 'code')],
    ),
    TypedGoRoute<PreBuilderRoute>(
      path: 'pre-builder',
      routes: [TypedGoRoute<PreBuilderCodeRoute>(path: 'code')],
    ),
    TypedGoRoute<ControllerRoute>(
      path: 'text-editing-controller',
      routes: [TypedGoRoute<ControllerCodeRoute>(path: 'code')],
    ),
    TypedGoRoute<ExternalParserRoute>(
      path: 'external-parser',
      routes: [TypedGoRoute<ExternalParserCodeRoute>(path: 'code')],
    ),
  ],
)
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomePage();
  }
}

class SimpleRoute extends GoRouteData {
  const SimpleRoute();

  static const String title = 'Simple (no gesture)';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ExamplePage(
      title: title,
      description:
          'Applies a colour to URLs and email addresses using preset matchers.',
      additionalInfo:
          'Tapping on text does not trigger anything in this example.',
      hasOutput: false,
      builder: (_) => const SimpleExample(),
    );
  }
}

class StylesAndActionsRoute extends GoRouteData {
  const StylesAndActionsRoute();

  static const String title = 'Styles and actions per definition';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ExamplePage(
      title: title,
      description:
          'Decorates URLs, email addresses and phone numbers, and also '
          'enables them to be tapped and long-pressed.\n\n'
          'Phone numbers are styled differently with the unique `matchStyle` '
          'and `tapStyle`.',
      additionalInfo: 'Try tapping or long-pressing on coloured strings.',
      builder: StylesAndActionsExample.new,
    );
  }
}

class OverwritingPatternRoute extends GoRouteData {
  const OverwritingPatternRoute();

  static const String title = 'Overwriting a match pattern';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ExamplePage(
      title: title,
      description: 'Replaces the default pattern of `TelMatcher`.\n\n'
          'The new pattern regards only the `{3 digits}-{4 digits}-{4 digits}` '
          'format as a phone number.',
      builder: OverwritingPatternExample.new,
    );
  }
}

class CustomPatternRoute extends GoRouteData {
  const CustomPatternRoute();

  static const String title = 'Custom match pattern';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ExamplePage(
      title: title,
      description:
          'Parses hashtags with a custom matcher and applies styles.\n\n'
          'For simplicity in this example, a hashtag is defined as a string '
          'starting with `#` followed by an alphabet and then alphanumerics, '
          'and is enclosed with white spaces.',
      builder: CustomPatternExample.new,
    );
  }
}

class SelectiveDefinitionRoute extends GoRouteData {
  const SelectiveDefinitionRoute();

  static const String title = 'SelectiveDefinition';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ExamplePage(
      title: title,
      description:
          'Parses a markdown-style link in the format of `[shown text](url)` '
          'and makes it tappable.\n\n'
          '`SelectiveDefinition` allows to select the string to display and '
          'the string to be passed to gesture callbacks individually.',
      builder: SelectiveDefinitionExample.new,
    );
  }
}

class SpanDefinitionRoute extends GoRouteData {
  const SpanDefinitionRoute();

  static const String title = 'SpanDefinition';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ExamplePage(
      title: title,
      description: 'Shows both text and widgets.\n\n'
          '`SpanDefinition` enables part of text to be replaced with an '
          'arbitrary `InlineSpan`. The `builder` function can use the parse '
          'result to flexibly build an InlineSpan.',
      additionalInfo:
          'Gestures are detected on both the logo and the text of "Flutter".',
      builder: SpanDefinitionExample.new,
    );
  }
}

class RealHyperlinksRoute extends GoRouteData {
  const RealHyperlinksRoute();

  static const String title = 'Real hyperlinks';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ExamplePage(
      title: title,
      description:
          'Embeds web hyperlinks using `SpanDefinition` together with the '
          '`Link` widget of package:url_launcher.',
      additionalInfo:
          'Run this example in a desktop web browser and place the mouse '
          'pointer or right-click on a link.\n\n'
          'Note:\n'
          'Sadly, WidgetSpans are vertically misaligned with plain text '
          'on the web due to issues existing on the Flutter SDK side.',
      hasOutput: false,
      builder: (_) => const RealHyperlinksExample(),
    );
  }
}

class HoverStyleRoute extends GoRouteData {
  const HoverStyleRoute();

  static const String title = 'Mouse cursor and text style on hover';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ExamplePage(
      title: title,
      description: 'Changes the mouse cursor and text style on hover.\n\n'
          'The mouse cursor type passed to `mouseCursor` of a definition '
          'is used for matched string while the mouse pointer hovers over it.',
      additionalInfo:
          'Run the app on desktop to see how this example looks and behaves '
          'on hover over some strings.',
      builder: HoverStyleExample.new,
    );
  }
}

class OnGestureRoute extends GoRouteData {
  const OnGestureRoute();

  static const String title = 'Event positions and onGesture';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ExamplePage(
      title: title,
      description:
          'Shows a popup at the position of a primary button press or a mouse '
          'enter event.\n\n'
          'The secondary and tertiary buttons also call the `onGesture` '
          'callback.\n\n'
          'Notice:\n'
          '* On the web, the context menu of your browser will interfere '
          'with secondary button events unless the menu is suppressed.\n'
          '* The popup feature does not come with the package.',
      additionalInfo:
          'The above text is an excerpt from the following Wikipedia entry:\n'
          'https://en.wikipedia.org/wiki/Flutter_(software)',
      builder: OnGestureExample.new,
    );
  }
}

class CustomTextSpansRoute extends GoRouteData {
  const CustomTextSpansRoute();

  static const String title = 'CustomText.spans';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ExamplePage(
      title: title,
      description:
          '`CustomText.spans` allows to use a list of `InlineSpan`s instead '
          'of plain text.\n\n'
          'This is useful if you already have styled spans and want to '
          'decorate them additionally.',
      additionalInfo:
          'This example applies hoverStyle and onGesture to the range '
          'containing multiple styled InlineSpans including a WidgetSpan.\n\n'
          'Note that arguments other than `text` and `style` in the spans '
          'are not used even if specified.',
      builder: CustomTextSpansExample.new,
    );
  }
}

class PreBuilderRoute extends GoRouteData {
  const PreBuilderRoute();

  static const String title = 'CustomText with preBuilder';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ExamplePage(
      title: title,
      description:
          '`preBuilder` allows to apply decorations and then additionally '
          'apply more decorations and enable gestures.\n\n'
          'It has similar use cases to `CustomText.spans`, but is more '
          'helpful when it is not easy to compose complex spans manually.',
      additionalInfo:
          'Note that gesture callbacks and `mouseCursor` in the builder are '
          'not used even if specified.',
      hasOutput: false,
      builder: (_) => const PreBuilderExample(),
    );
  }
}

class ControllerRoute extends GoRouteData {
  const ControllerRoute();

  static const String title = 'CustomTextEditingController';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ExamplePage(
      title: title,
      description: 'Uses most `CustomText` features in `TextField` too using '
          '`CustomTextEditingController`.\n\n'
          'Notice:\n'
          '* SelectiveDefinition and SpanDefinition are not available '
          'for CustomTextEditingController.\n'
          '* Not suitable for long text, even with debouncing enabled.',
      additionalInfo: 'Try editing the text in the box above.\n'
          'As you type, email addresses, URLs and hashtags are decorated, '
          '${DeviceInfo.isIosSimulator ? '' : 'URLs become tappable, '}'
          'and a hover effect is enabled on hashtags.',
      hasOutput: !DeviceInfo.isIosSimulator,
      builder: (text) =>
          ControllerExample(DeviceInfo.isIosSimulator ? null : text),
    );
  }
}

class ExternalParserRoute extends GoRouteData {
  const ExternalParserRoute();

  static const String title = 'Using an external parser';

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ExamplePage(
      title: title,
      description: 'Uses an external parser.\n\n'
          'This example uses a custom parser powered by package:highlight '
          'to achieve keyword highlighting of several different formats '
          'of text, which is not easy with the default parser.',
      hasOutput: false,
      builder: (_) => const ExternalParserExample(),
    );
  }
}

abstract class CodeViewRoute extends GoRouteData {
  const CodeViewRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return CodeViewPage(filename: GoRouter.of(context).exampleFilename);
  }
}

class SimpleCodeRoute extends CodeViewRoute {}

class StylesAndActionsCodeRoute extends CodeViewRoute {}

class OverwritingPatternCodeRoute extends CodeViewRoute {}

class CustomPatternCodeRoute extends CodeViewRoute {}

class SelectiveDefinitionCodeRoute extends CodeViewRoute {}

class SpanDefinitionCodeRoute extends CodeViewRoute {}

class RealHyperlinksCodeRoute extends CodeViewRoute {}

class HoverStyleCodeRoute extends CodeViewRoute {}

class OnGestureCodeRoute extends CodeViewRoute {}

class CustomTextSpansCodeRoute extends CodeViewRoute {}

class PreBuilderCodeRoute extends CodeViewRoute {}

class ControllerCodeRoute extends CodeViewRoute {}

class ExternalParserCodeRoute extends CodeViewRoute {}
