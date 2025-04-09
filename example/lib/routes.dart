import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:custom_text_example/advanced_view.dart';
import 'package:custom_text_example/basic_view.dart';
import 'package:custom_text_example/code_view_page.dart';
import 'package:custom_text_example/common/device_info.dart';
import 'package:custom_text_example/example_page.dart';
import 'package:custom_text_example/examples/advanced/expressive_text.dart';
import 'package:custom_text_example/examples/advanced/fill_in_blanks.dart';
import 'package:custom_text_example/examples/advanced/searchable_text.dart';
import 'package:custom_text_example/examples/basic/custom_pattern.dart';
import 'package:custom_text_example/examples/basic/external_parser.dart';
import 'package:custom_text_example/examples/basic/hover_style.dart';
import 'package:custom_text_example/examples/basic/on_gesture.dart';
import 'package:custom_text_example/examples/basic/overwriting_pattern.dart';
import 'package:custom_text_example/examples/basic/pre_builder.dart';
import 'package:custom_text_example/examples/basic/real_hyperlinks.dart';
import 'package:custom_text_example/examples/basic/selective_definition.dart';
import 'package:custom_text_example/examples/basic/simple.dart';
import 'package:custom_text_example/examples/basic/span_definition.dart';
import 'package:custom_text_example/examples/basic/spans_constructor.dart';
import 'package:custom_text_example/examples/basic/styles_and_actions.dart';
import 'package:custom_text_example/examples/basic/text_editing_controller.dart';
import 'package:custom_text_example/home_page.dart';

part 'routes.g.dart';

enum ViewType {
  basic,
  advanced;

  static ViewType of(GoRouterState state) {
    return state.uri.path.startsWith('/advanced')
        ? ViewType.advanced
        : ViewType.basic;
  }
}

extension GoRouterExt on GoRouter {
  Uri get uri => routerDelegate.currentConfiguration.uri;
}

extension UriExt on Uri {
  String get exampleFilename {
    final segment = ([...pathSegments]..remove('code')).last;
    return '${segment.replaceAll('-', '_')}.dart';
  }
}

final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

@TypedShellRoute<HomeRoute>(
  routes: [
    TypedGoRoute<BasicViewRoute>(
      path: '/',
      routes: [
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
    ),
    TypedGoRoute<AdvancedViewRoute>(
      path: '/advanced',
      routes: [
        TypedGoRoute<ExpressiveTextRoute>(
          path: 'expressive-text',
          routes: [TypedGoRoute<ExpressiveTextCodeRoute>(path: 'code')],
        ),
        TypedGoRoute<SearchableTextRoute>(
          path: 'searchable-text',
          routes: [TypedGoRoute<SearchableTextCodeRoute>(path: 'code')],
        ),
        TypedGoRoute<FillInBlanksRoute>(
          path: 'fill-in-blanks',
          routes: [TypedGoRoute<FillInBlanksCodeRoute>(path: 'code')],
        ),
      ],
    ),
  ],
)
class HomeRoute extends ShellRouteData {
  const HomeRoute();

  static final GlobalKey<NavigatorState> $navigatorKey = shellNavigatorKey;

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return HomePage(child: navigator);
  }
}

class BasicViewRoute extends GoRouteData {
  const BasicViewRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(
      child: BasicView(),
    );
  }
}

class AdvancedViewRoute extends GoRouteData {
  const AdvancedViewRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage(
      child: AdvancedView(),
    );
  }
}

class SimpleRoute extends GoRouteData {
  const SimpleRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
  static const String title = 'Simple (no gesture)';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideTransitionPage(
      child: ExamplePage(
        title: title,
        description:
            'Applies a colour to URLs and email addresses using preset '
            'matchers.',
        additionalInfo:
            'Tapping on text does not trigger anything in this example.',
        hasOutput: false,
        builder: (_) => const SimpleExample(),
      ),
    );
  }
}

class StylesAndActionsRoute extends GoRouteData {
  const StylesAndActionsRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
  static const String title = 'Styles and actions per definition';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideTransitionPage(
      child: const ExamplePage(
        title: title,
        description:
            'Decorates URLs, email addresses and phone numbers, and also '
            'enables them to be tapped and long-pressed.\n\n'
            'Phone numbers are styled differently with the unique `matchStyle` '
            'and `tapStyle`.',
        additionalInfo: 'Try tapping or long-pressing on coloured strings.',
        builder: StylesAndActionsExample.new,
      ),
    );
  }
}

class OverwritingPatternRoute extends GoRouteData {
  const OverwritingPatternRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
  static const String title = 'Overwriting a match pattern';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideTransitionPage(
      child: const ExamplePage(
        title: title,
        description: 'Replaces the default pattern of `TelMatcher`.\n\n'
            'The new pattern regards only the '
            '`{3 digits}-{4 digits}-{4 digits}` format as a phone number.',
        builder: OverwritingPatternExample.new,
      ),
    );
  }
}

class CustomPatternRoute extends GoRouteData {
  const CustomPatternRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
  static const String title = 'Custom match pattern';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideTransitionPage(
      child: const ExamplePage(
        title: title,
        description:
            'Parses hashtags with a custom matcher and applies styles.\n\n'
            'For simplicity in this example, a hashtag is defined as a string '
            'starting with `#` followed by an alphabet and then alphanumerics, '
            'and is enclosed with white spaces.',
        builder: CustomPatternExample.new,
      ),
    );
  }
}

class SelectiveDefinitionRoute extends GoRouteData {
  const SelectiveDefinitionRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
  static const String title = 'SelectiveDefinition';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideTransitionPage(
      child: const ExamplePage(
        title: title,
        description:
            'Parses a markdown-style link in the format of `[shown text](url)` '
            'and makes it tappable.\n\n'
            '`SelectiveDefinition` allows to select the string to display and '
            'the string to be passed to gesture callbacks individually.',
        builder: SelectiveDefinitionExample.new,
      ),
    );
  }
}

class SpanDefinitionRoute extends GoRouteData {
  const SpanDefinitionRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
  static const String title = 'SpanDefinition';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideTransitionPage(
      child: const ExamplePage(
        title: title,
        description: 'Shows both text and widgets.\n\n'
            '`SpanDefinition` enables part of text to be replaced with an '
            'arbitrary `InlineSpan`. The `builder` function can use the parse '
            'result to flexibly build an InlineSpan.',
        additionalInfo:
            'Gestures are detected on both the logo and the text of "Flutter".',
        builder: SpanDefinitionExample.new,
      ),
    );
  }
}

class RealHyperlinksRoute extends GoRouteData {
  const RealHyperlinksRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
  static const String title = 'Real hyperlinks';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideTransitionPage(
      child: ExamplePage(
        title: title,
        description:
            'Embeds web hyperlinks using `SpanDefinition` together with the '
            '`Link` widget of package:url_launcher.',
        additionalInfo:
            'Run this example in a desktop web browser and place the mouse '
            'pointer or right-click on a link.',
        hasOutput: false,
        builder: (_) => const RealHyperlinksExample(),
      ),
    );
  }
}

class HoverStyleRoute extends GoRouteData {
  const HoverStyleRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
  static const String title = 'Mouse cursor and text style on hover';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideTransitionPage(
      child: const ExamplePage(
        title: title,
        description: 'Changes the mouse cursor and text style on hover.\n\n'
            'The mouse cursor type passed to `mouseCursor` of a definition '
            'is used for matched string while the mouse pointer hovers '
            'over it.',
        additionalInfo:
            'Run the app on desktop to see how this example looks and behaves '
            'on hover over some strings.',
        builder: HoverStyleExample.new,
      ),
    );
  }
}

class OnGestureRoute extends GoRouteData {
  const OnGestureRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
  static const String title = 'Event positions and onGesture';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideTransitionPage(
      child: const ExamplePage(
        title: title,
        description:
            'Shows a popup at the position of a primary button press or a '
            'mouse enter event.\n\n'
            'The secondary and tertiary buttons also call the `onGesture` '
            'callback.\n\n'
            'Note:\n'
            '* On the web, the context menu of your browser will interfere '
            'with secondary button events unless the menu is suppressed.\n'
            '* The popup feature does not come with the package.',
        additionalInfo:
            'The above text is an excerpt from the following Wikipedia entry:\n'
            'https://en.wikipedia.org/wiki/Flutter_(software)',
        builder: OnGestureExample.new,
      ),
    );
  }
}

class CustomTextSpansRoute extends GoRouteData {
  const CustomTextSpansRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
  static const String title = 'CustomText.spans';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideTransitionPage(
      child: const ExamplePage(
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
      ),
    );
  }
}

class PreBuilderRoute extends GoRouteData {
  const PreBuilderRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
  static const String title = 'CustomText with preBuilder';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideTransitionPage(
      child: ExamplePage(
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
      ),
    );
  }
}

class ControllerRoute extends GoRouteData {
  const ControllerRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
  static const String title = 'CustomTextEditingController';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideTransitionPage(
      child: ExamplePage(
        title: title,
        description: 'Uses most `CustomText` features in `TextField` too using '
            '`CustomTextEditingController`.\n\n'
            'Note:\n'
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
      ),
    );
  }
}

class ExternalParserRoute extends GoRouteData {
  const ExternalParserRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
  static const String title = 'Using an external parser';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideTransitionPage(
      child: ExamplePage(
        title: title,
        description: 'Uses an external parser.\n\n'
            'This example uses a custom parser powered by package:highlight '
            'to achieve keyword highlighting of several different formats '
            'of text, which is not easy with the default parser.',
        hasOutput: false,
        builder: (_) => const ExternalParserExample(),
      ),
    );
  }
}

class ExpressiveTextRoute extends GoRouteData {
  const ExpressiveTextRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
  static const String title = 'Expressive text widget';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideTransitionPage(
      child: ExamplePage(
        title: title,
        description:
            'A text widget you can use to easily apply styles such as bold '
            'and italic with Markdown-ish notification.',
        additionalInfo:
            '{{dash}} is custom markup to be replace with a Dash icon.',
        hasOutput: false,
        builder: (_) => const ExpressiveTextExample(),
      ),
    );
  }
}

class SearchableTextRoute extends GoRouteData {
  const SearchableTextRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
  static const String title = 'Searchable text widget';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideTransitionPage(
      child: ExamplePage(
        title: title,
        description:
            'A text widget that allows you to search for a keyword contained '
            'in it.',
        hasOutput: false,
        scrollable: true,
        builder: (_) => const SearchableTextExample(),
      ),
    );
  }
}

class FillInBlanksRoute extends GoRouteData {
  const FillInBlanksRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
  static const String title = 'Fill-in-the-blanks question';

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideTransitionPage(
      child: ExamplePage(
        title: title,
        description: 'Text with blanks whose content are revealed by a hover.',
        additionalInfo: 'Try this example on a device with a mouse.',
        hasOutput: false,
        builder: (_) => const FillInBlanksExample(),
      ),
    );
  }
}

abstract class CodeViewRoute extends GoRouteData {
  const CodeViewRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return SlideTransitionPage(
      child: CodeViewPage(
        viewType: ViewType.of(state),
        filename: state.uri.exampleFilename,
      ),
    );
  }
}

class SimpleCodeRoute extends CodeViewRoute {
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
}

class StylesAndActionsCodeRoute extends CodeViewRoute {
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
}

class OverwritingPatternCodeRoute extends CodeViewRoute {
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
}

class CustomPatternCodeRoute extends CodeViewRoute {
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
}

class SelectiveDefinitionCodeRoute extends CodeViewRoute {
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
}

class SpanDefinitionCodeRoute extends CodeViewRoute {
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
}

class RealHyperlinksCodeRoute extends CodeViewRoute {
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
}

class HoverStyleCodeRoute extends CodeViewRoute {
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
}

class OnGestureCodeRoute extends CodeViewRoute {
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
}

class CustomTextSpansCodeRoute extends CodeViewRoute {
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
}

class PreBuilderCodeRoute extends CodeViewRoute {
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
}

class ControllerCodeRoute extends CodeViewRoute {
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
}

class ExternalParserCodeRoute extends CodeViewRoute {
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
}

class ExpressiveTextCodeRoute extends CodeViewRoute {
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
}

class SearchableTextCodeRoute extends CodeViewRoute {
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
}

class FillInBlanksCodeRoute extends CodeViewRoute {
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;
}

class SlideTransitionPage<T> extends CustomTransitionPage<T> {
  SlideTransitionPage({required super.child})
      : super(
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
              ),
              child: child,
            );
          },
        );
}
