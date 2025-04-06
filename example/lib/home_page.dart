import 'package:flutter/material.dart';

import 'package:custom_text_example/routes.dart';
import 'package:custom_text_example/widgets/hyperlink.dart';

class HomePage extends StatelessWidget {
  const HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CustomText'),
        actions: const [
          Center(
            child: Hyperlink(
              label: 'pub.dev',
              url: 'https://pub.dev/packages/custom_text',
            ),
          ),
          SizedBox(width: 16.0),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            ListTile(
              title: const Text(SimpleRoute.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => const SimpleRoute().go(context),
            ),
            ListTile(
              title: const Text(StylesAndActionsRoute.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => const StylesAndActionsRoute().go(context),
            ),
            ListTile(
              title: const Text(OverwritingPatternRoute.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => const OverwritingPatternRoute().go(context),
            ),
            ListTile(
              title: const Text(CustomPatternRoute.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => const CustomPatternRoute().go(context),
            ),
            ListTile(
              title: const Text(SelectiveDefinitionRoute.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => const SelectiveDefinitionRoute().go(context),
            ),
            ListTile(
              title: const Text(SpanDefinitionRoute.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => const SpanDefinitionRoute().go(context),
            ),
            ListTile(
              title: const Text(RealHyperlinksRoute.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => const RealHyperlinksRoute().go(context),
            ),
            ListTile(
              title: const Text(HoverStyleRoute.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => const HoverStyleRoute().go(context),
            ),
            ListTile(
              title: const Text(OnGestureRoute.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => const OnGestureRoute().go(context),
            ),
            ListTile(
              title: const Text(CustomTextSpansRoute.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => const CustomTextSpansRoute().go(context),
            ),
            ListTile(
              title: const Text(PreBuilderRoute.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => const PreBuilderRoute().go(context),
            ),
            ListTile(
              title: const Text(ControllerRoute.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => const ControllerRoute().go(context),
            ),
            ListTile(
              title: const Text(ExternalParserRoute.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => const ExternalParserRoute().go(context),
            ),
          ],
        ),
      ),
    );
  }
}
