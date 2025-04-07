import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:custom_text_example/routes.dart';
import 'package:custom_text_example/widgets/hyperlink.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = GoRouterState.of(context);
    final type = ViewType.of(state);

    return Scaffold(
      appBar: AppBar(
        title: switch (type) {
          ViewType.basic => const Text('Basic Usage'),
          ViewType.advanced => const Text('Advanced examples'),
        },
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
        child: child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: type.index,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              const BasicViewRoute().go(context);
            case 1:
              const AdvancedViewRoute().go(context);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school),
            label: 'Basic',
          ),
          NavigationDestination(
            icon: Icon(Icons.rocket_launch),
            label: 'Advanced',
          ),
        ],
      ),
    );
  }
}
