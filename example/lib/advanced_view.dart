import 'package:flutter/material.dart';

import 'package:custom_text_example/routes.dart';

class AdvancedView extends StatelessWidget {
  const AdvancedView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text(ExpressiveTextRoute.title),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => const ExpressiveTextRoute().go(context),
        ),
        ListTile(
          title: const Text(SearchableTextRoute.title),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => const SearchableTextRoute().go(context),
        ),
        ListTile(
          title: const Text(FillInBlanksRoute.title),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => const FillInBlanksRoute().go(context),
        ),
      ],
    );
  }
}
