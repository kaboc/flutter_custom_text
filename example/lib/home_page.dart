import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:custom_text_example/common/router.dart';

class HomePage extends StatelessWidget {
  const HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CustomText'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            for (var i = 1; i <= 9; i++)
              ListTile(
                title: Text('$i. ${pages[i]!.title}'),
                subtitle: i < 8
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: Text(
                          [
                            'Available on v0.6.0-dev.1 and above',
                            if (i == 8) '\nDeprecated'
                          ].join(),
                          style: const TextStyle(fontSize: 12.0),
                        ),
                      ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/$i'),
              )
          ],
        ),
      ),
    );
  }
}
