// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $homeRoute,
    ];

RouteBase get $homeRoute => ShellRouteData.$route(
      navigatorKey: HomeRoute.$navigatorKey,
      factory: $HomeRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: '/',
          factory: $BasicViewRouteExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: 'simple',
              parentNavigatorKey: SimpleRoute.$parentNavigatorKey,
              factory: $SimpleRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'code',
                  parentNavigatorKey: SimpleCodeRoute.$parentNavigatorKey,
                  factory: $SimpleCodeRouteExtension._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'styles-and-actions',
              parentNavigatorKey: StylesAndActionsRoute.$parentNavigatorKey,
              factory: $StylesAndActionsRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'code',
                  parentNavigatorKey:
                      StylesAndActionsCodeRoute.$parentNavigatorKey,
                  factory: $StylesAndActionsCodeRouteExtension._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'overwriting-pattern',
              parentNavigatorKey: OverwritingPatternRoute.$parentNavigatorKey,
              factory: $OverwritingPatternRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'code',
                  parentNavigatorKey:
                      OverwritingPatternCodeRoute.$parentNavigatorKey,
                  factory: $OverwritingPatternCodeRouteExtension._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'custom-pattern',
              parentNavigatorKey: CustomPatternRoute.$parentNavigatorKey,
              factory: $CustomPatternRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'code',
                  parentNavigatorKey:
                      CustomPatternCodeRoute.$parentNavigatorKey,
                  factory: $CustomPatternCodeRouteExtension._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'selective-definition',
              parentNavigatorKey: SelectiveDefinitionRoute.$parentNavigatorKey,
              factory: $SelectiveDefinitionRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'code',
                  parentNavigatorKey:
                      SelectiveDefinitionCodeRoute.$parentNavigatorKey,
                  factory: $SelectiveDefinitionCodeRouteExtension._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'span-definition',
              parentNavigatorKey: SpanDefinitionRoute.$parentNavigatorKey,
              factory: $SpanDefinitionRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'code',
                  parentNavigatorKey:
                      SpanDefinitionCodeRoute.$parentNavigatorKey,
                  factory: $SpanDefinitionCodeRouteExtension._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'real-hyperlinks',
              parentNavigatorKey: RealHyperlinksRoute.$parentNavigatorKey,
              factory: $RealHyperlinksRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'code',
                  parentNavigatorKey:
                      RealHyperlinksCodeRoute.$parentNavigatorKey,
                  factory: $RealHyperlinksCodeRouteExtension._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'hover-style',
              parentNavigatorKey: HoverStyleRoute.$parentNavigatorKey,
              factory: $HoverStyleRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'code',
                  parentNavigatorKey: HoverStyleCodeRoute.$parentNavigatorKey,
                  factory: $HoverStyleCodeRouteExtension._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'on-gesture',
              parentNavigatorKey: OnGestureRoute.$parentNavigatorKey,
              factory: $OnGestureRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'code',
                  parentNavigatorKey: OnGestureCodeRoute.$parentNavigatorKey,
                  factory: $OnGestureCodeRouteExtension._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'spans-constructor',
              parentNavigatorKey: CustomTextSpansRoute.$parentNavigatorKey,
              factory: $CustomTextSpansRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'code',
                  parentNavigatorKey:
                      CustomTextSpansCodeRoute.$parentNavigatorKey,
                  factory: $CustomTextSpansCodeRouteExtension._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'pre-builder',
              parentNavigatorKey: PreBuilderRoute.$parentNavigatorKey,
              factory: $PreBuilderRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'code',
                  parentNavigatorKey: PreBuilderCodeRoute.$parentNavigatorKey,
                  factory: $PreBuilderCodeRouteExtension._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'text-editing-controller',
              parentNavigatorKey: ControllerRoute.$parentNavigatorKey,
              factory: $ControllerRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'code',
                  parentNavigatorKey: ControllerCodeRoute.$parentNavigatorKey,
                  factory: $ControllerCodeRouteExtension._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'external-parser',
              parentNavigatorKey: ExternalParserRoute.$parentNavigatorKey,
              factory: $ExternalParserRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'code',
                  parentNavigatorKey:
                      ExternalParserCodeRoute.$parentNavigatorKey,
                  factory: $ExternalParserCodeRouteExtension._fromState,
                ),
              ],
            ),
          ],
        ),
        GoRouteData.$route(
          path: '/advanced',
          factory: $AdvancedViewRouteExtension._fromState,
          routes: [
            GoRouteData.$route(
              path: 'expressive-text',
              parentNavigatorKey: ExpressiveTextRoute.$parentNavigatorKey,
              factory: $ExpressiveTextRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'code',
                  parentNavigatorKey:
                      ExpressiveTextCodeRoute.$parentNavigatorKey,
                  factory: $ExpressiveTextCodeRouteExtension._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'searchable-text',
              parentNavigatorKey: SearchableTextRoute.$parentNavigatorKey,
              factory: $SearchableTextRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'code',
                  parentNavigatorKey:
                      SearchableTextCodeRoute.$parentNavigatorKey,
                  factory: $SearchableTextCodeRouteExtension._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'fill-in-blanks',
              parentNavigatorKey: FillInBlanksRoute.$parentNavigatorKey,
              factory: $FillInBlanksRouteExtension._fromState,
              routes: [
                GoRouteData.$route(
                  path: 'code',
                  parentNavigatorKey: FillInBlanksCodeRoute.$parentNavigatorKey,
                  factory: $FillInBlanksCodeRouteExtension._fromState,
                ),
              ],
            ),
          ],
        ),
      ],
    );

extension $HomeRouteExtension on HomeRoute {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();
}

extension $BasicViewRouteExtension on BasicViewRoute {
  static BasicViewRoute _fromState(GoRouterState state) =>
      const BasicViewRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SimpleRouteExtension on SimpleRoute {
  static SimpleRoute _fromState(GoRouterState state) => const SimpleRoute();

  String get location => GoRouteData.$location(
        '/simple',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SimpleCodeRouteExtension on SimpleCodeRoute {
  static SimpleCodeRoute _fromState(GoRouterState state) => SimpleCodeRoute();

  String get location => GoRouteData.$location(
        '/simple/code',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $StylesAndActionsRouteExtension on StylesAndActionsRoute {
  static StylesAndActionsRoute _fromState(GoRouterState state) =>
      const StylesAndActionsRoute();

  String get location => GoRouteData.$location(
        '/styles-and-actions',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $StylesAndActionsCodeRouteExtension on StylesAndActionsCodeRoute {
  static StylesAndActionsCodeRoute _fromState(GoRouterState state) =>
      StylesAndActionsCodeRoute();

  String get location => GoRouteData.$location(
        '/styles-and-actions/code',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $OverwritingPatternRouteExtension on OverwritingPatternRoute {
  static OverwritingPatternRoute _fromState(GoRouterState state) =>
      const OverwritingPatternRoute();

  String get location => GoRouteData.$location(
        '/overwriting-pattern',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $OverwritingPatternCodeRouteExtension on OverwritingPatternCodeRoute {
  static OverwritingPatternCodeRoute _fromState(GoRouterState state) =>
      OverwritingPatternCodeRoute();

  String get location => GoRouteData.$location(
        '/overwriting-pattern/code',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $CustomPatternRouteExtension on CustomPatternRoute {
  static CustomPatternRoute _fromState(GoRouterState state) =>
      const CustomPatternRoute();

  String get location => GoRouteData.$location(
        '/custom-pattern',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $CustomPatternCodeRouteExtension on CustomPatternCodeRoute {
  static CustomPatternCodeRoute _fromState(GoRouterState state) =>
      CustomPatternCodeRoute();

  String get location => GoRouteData.$location(
        '/custom-pattern/code',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SelectiveDefinitionRouteExtension on SelectiveDefinitionRoute {
  static SelectiveDefinitionRoute _fromState(GoRouterState state) =>
      const SelectiveDefinitionRoute();

  String get location => GoRouteData.$location(
        '/selective-definition',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SelectiveDefinitionCodeRouteExtension
    on SelectiveDefinitionCodeRoute {
  static SelectiveDefinitionCodeRoute _fromState(GoRouterState state) =>
      SelectiveDefinitionCodeRoute();

  String get location => GoRouteData.$location(
        '/selective-definition/code',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SpanDefinitionRouteExtension on SpanDefinitionRoute {
  static SpanDefinitionRoute _fromState(GoRouterState state) =>
      const SpanDefinitionRoute();

  String get location => GoRouteData.$location(
        '/span-definition',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SpanDefinitionCodeRouteExtension on SpanDefinitionCodeRoute {
  static SpanDefinitionCodeRoute _fromState(GoRouterState state) =>
      SpanDefinitionCodeRoute();

  String get location => GoRouteData.$location(
        '/span-definition/code',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $RealHyperlinksRouteExtension on RealHyperlinksRoute {
  static RealHyperlinksRoute _fromState(GoRouterState state) =>
      const RealHyperlinksRoute();

  String get location => GoRouteData.$location(
        '/real-hyperlinks',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $RealHyperlinksCodeRouteExtension on RealHyperlinksCodeRoute {
  static RealHyperlinksCodeRoute _fromState(GoRouterState state) =>
      RealHyperlinksCodeRoute();

  String get location => GoRouteData.$location(
        '/real-hyperlinks/code',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $HoverStyleRouteExtension on HoverStyleRoute {
  static HoverStyleRoute _fromState(GoRouterState state) =>
      const HoverStyleRoute();

  String get location => GoRouteData.$location(
        '/hover-style',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $HoverStyleCodeRouteExtension on HoverStyleCodeRoute {
  static HoverStyleCodeRoute _fromState(GoRouterState state) =>
      HoverStyleCodeRoute();

  String get location => GoRouteData.$location(
        '/hover-style/code',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $OnGestureRouteExtension on OnGestureRoute {
  static OnGestureRoute _fromState(GoRouterState state) =>
      const OnGestureRoute();

  String get location => GoRouteData.$location(
        '/on-gesture',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $OnGestureCodeRouteExtension on OnGestureCodeRoute {
  static OnGestureCodeRoute _fromState(GoRouterState state) =>
      OnGestureCodeRoute();

  String get location => GoRouteData.$location(
        '/on-gesture/code',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $CustomTextSpansRouteExtension on CustomTextSpansRoute {
  static CustomTextSpansRoute _fromState(GoRouterState state) =>
      const CustomTextSpansRoute();

  String get location => GoRouteData.$location(
        '/spans-constructor',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $CustomTextSpansCodeRouteExtension on CustomTextSpansCodeRoute {
  static CustomTextSpansCodeRoute _fromState(GoRouterState state) =>
      CustomTextSpansCodeRoute();

  String get location => GoRouteData.$location(
        '/spans-constructor/code',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PreBuilderRouteExtension on PreBuilderRoute {
  static PreBuilderRoute _fromState(GoRouterState state) =>
      const PreBuilderRoute();

  String get location => GoRouteData.$location(
        '/pre-builder',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $PreBuilderCodeRouteExtension on PreBuilderCodeRoute {
  static PreBuilderCodeRoute _fromState(GoRouterState state) =>
      PreBuilderCodeRoute();

  String get location => GoRouteData.$location(
        '/pre-builder/code',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ControllerRouteExtension on ControllerRoute {
  static ControllerRoute _fromState(GoRouterState state) =>
      const ControllerRoute();

  String get location => GoRouteData.$location(
        '/text-editing-controller',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ControllerCodeRouteExtension on ControllerCodeRoute {
  static ControllerCodeRoute _fromState(GoRouterState state) =>
      ControllerCodeRoute();

  String get location => GoRouteData.$location(
        '/text-editing-controller/code',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ExternalParserRouteExtension on ExternalParserRoute {
  static ExternalParserRoute _fromState(GoRouterState state) =>
      const ExternalParserRoute();

  String get location => GoRouteData.$location(
        '/external-parser',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ExternalParserCodeRouteExtension on ExternalParserCodeRoute {
  static ExternalParserCodeRoute _fromState(GoRouterState state) =>
      ExternalParserCodeRoute();

  String get location => GoRouteData.$location(
        '/external-parser/code',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $AdvancedViewRouteExtension on AdvancedViewRoute {
  static AdvancedViewRoute _fromState(GoRouterState state) =>
      const AdvancedViewRoute();

  String get location => GoRouteData.$location(
        '/advanced',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ExpressiveTextRouteExtension on ExpressiveTextRoute {
  static ExpressiveTextRoute _fromState(GoRouterState state) =>
      const ExpressiveTextRoute();

  String get location => GoRouteData.$location(
        '/advanced/expressive-text',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $ExpressiveTextCodeRouteExtension on ExpressiveTextCodeRoute {
  static ExpressiveTextCodeRoute _fromState(GoRouterState state) =>
      ExpressiveTextCodeRoute();

  String get location => GoRouteData.$location(
        '/advanced/expressive-text/code',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SearchableTextRouteExtension on SearchableTextRoute {
  static SearchableTextRoute _fromState(GoRouterState state) =>
      const SearchableTextRoute();

  String get location => GoRouteData.$location(
        '/advanced/searchable-text',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $SearchableTextCodeRouteExtension on SearchableTextCodeRoute {
  static SearchableTextCodeRoute _fromState(GoRouterState state) =>
      SearchableTextCodeRoute();

  String get location => GoRouteData.$location(
        '/advanced/searchable-text/code',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $FillInBlanksRouteExtension on FillInBlanksRoute {
  static FillInBlanksRoute _fromState(GoRouterState state) =>
      const FillInBlanksRoute();

  String get location => GoRouteData.$location(
        '/advanced/fill-in-blanks',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $FillInBlanksCodeRouteExtension on FillInBlanksCodeRoute {
  static FillInBlanksCodeRoute _fromState(GoRouterState state) =>
      FillInBlanksCodeRoute();

  String get location => GoRouteData.$location(
        '/advanced/fill-in-blanks/code',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}
