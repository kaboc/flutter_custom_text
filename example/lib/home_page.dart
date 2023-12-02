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
        actions: const [
          Center(
            child: _PubLink(),
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

class _PubLink extends StatelessWidget {
  const _PubLink();

  @override
  Widget build(BuildContext context) {
    return Link(
      uri: Uri.tryParse('https://pub.dev/packages/custom_text'),
      target: LinkTarget.blank,
      builder: (context, followLink) {
        return CustomText(
          'pub.dev[i]',
          definitions: [
            SpanDefinition(
              matcher: const PatternMatcher(r'(.+)\[i\]'),
              builder: (text, groups) => TextSpan(
                children: [
                  TextSpan(text: groups.first),
                  const WidgetSpan(child: SizedBox(width: 4.0)),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.open_in_new,
                      size: 12.0,
                      color: Colors.lightBlue.shade100,
                    ),
                  ),
                ],
              ),
            ),
          ],
          style: TextStyle(color: Colors.lightBlue.shade100),
          hoverStyle: const TextStyle(decoration: TextDecoration.underline),
          onTap: (_) => followLink!(),
        );
      },
    );
  }
}
