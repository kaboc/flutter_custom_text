import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/link.dart';

import 'package:custom_text_example/common/router.dart';

class HomePage extends StatelessWidget {
  const HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CustomText'),
        actions: [
          const Center(
            child: _PubLink(),
          ),
          const SizedBox(width: 4.0),
          Icon(
            Icons.open_in_new,
            size: 12.0,
            color: Colors.lightBlue.shade100,
          ),
          const SizedBox(width: 16.0),
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            for (var i = 0; i < pages.length; i++)
              ListTile(
                title: Text(pages[i].title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/${pages[i].pathString}'),
              )
          ],
        ),
      ),
    );
  }
}

class _PubLink extends StatelessWidget {
  const _PubLink();

  @override
  Widget build(BuildContext context) {
    return Link(
      uri: Uri.tryParse('https://pub.dev/packages/custom_text'),
      target: LinkTarget.blank,
      builder: (context, followLink) {
        return CustomText(
          'pub.dev',
          definitions: const [
            TextDefinition(
              matcher: PatternMatcher('.+'),
              hoverStyle: TextStyle(decoration: TextDecoration.underline),
            ),
          ],
          style: TextStyle(color: Colors.lightBlue.shade100),
          onTap: (_) => followLink!(),
        );
      },
    );
  }
}
