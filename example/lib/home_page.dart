import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:custom_text_example/common/router.dart';
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
            for (final page in pages)
              ListTile(
                title: Text(page.title),
                subtitle: page.subtitle == null
                    ? null
                    : Text(
                        page.subtitle!,
                        style: const TextStyle(fontSize: 12.0),
                      ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/${page.pathString}'),
              ),
          ],
        ),
      ),
    );
  }
}
