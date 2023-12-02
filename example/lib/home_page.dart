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
            for (var i = 0; i < pages.length; i++)
              ListTile(
                title: Text(pages[i].title),
                subtitle: pages[i].subtitle == null
                    ? null
                    : Text(
                        pages[i].subtitle!,
                        style: const TextStyle(fontSize: 12.0),
                      ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/${pages[i].pathString}'),
              ),
          ],
        ),
      ),
    );
  }
}
