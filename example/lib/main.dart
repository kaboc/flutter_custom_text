import 'package:flutter/material.dart';

import 'package:custom_text_example/examples/example1.dart';
import 'package:custom_text_example/examples/example2.dart';
import 'package:custom_text_example/examples/example3.dart';
import 'package:custom_text_example/examples/example4.dart';
import 'package:custom_text_example/examples/example5.dart';
import 'package:custom_text_example/examples/example6.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CustomText Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: const TextTheme(
          bodyText2: TextStyle(fontSize: 18.0, height: 1.5),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CustomText'),
        ),
        body: ListView(
          children: [
            _ListTile(
              title: 'Simple',
              builder: (title) => Example1(
                title,
                'example1.dart',
                'A very basic example with URLs and email addresses styled.\n'
                    'They are not tappable in this example.',
              ),
            ),
            _ListTile(
              title: 'Unique styles and actions',
              builder: (title) => Example2(
                title,
                'example2.dart',
                'An example to apply styles to URLs, email addresses and '
                    'phone numbers, and enable them to be tapped / '
                    'long-tapped.\n'
                    'All of the three are styled, but only phone numbers '
                    'among them are given unique `matchStyle` and `tapStyle`.',
              ),
            ),
            _ListTile(
              title: 'Overwritten match pattern',
              builder: (title) => Example3(
                title,
                'example3.dart',
                'An example to overwrite the default match pattern of '
                    '`TelMatcher`.\n'
                    'The new pattern regards only the `{3 digits}-{4 digits}'
                    '-{4 digits}` format as a phone number.',
              ),
            ),
            _ListTile(
              title: 'Custom matchers',
              builder: (title) => Example4(
                title,
                'example4.dart',
                'An example to parse hashtags using a custom matcher and '
                    'apply styles to them.\n'
                    'A hashtag has a wide variety of definitions, but here '
                    'as an example, it is defined as a string that starts '
                    'with `#` followed by an alphabet and then by '
                    'alphanumerics, and is enclosed with white spaces.',
              ),
            ),
            _ListTile(
              title: 'SelectiveDefinition',
              builder: (title) => Example5(
                  title,
                  'example5.dart',
                  'An example to parse markdown-style links, like [label](url) '
                      'using `SelectiveDefinition`, and make them tappable.\n'
                      'Each of the string shown in the widget and the string '
                      'passed to the tap callbacks is selected individually '
                      'from the fragments (`groups`) that have matched the'
                      'patterns enclosed with parentheses within the match '
                      'pattern.'),
            ),
            _ListTile(
              title: 'SpanDefinition',
              builder: (title) => Example6(
                title,
                'example6.dart',
                'An example to show both strings and icons using '
                    '`SpanDefinition`.\n'
                    'The builder parameter takes a function returning an '
                    '`InlineSpan`.\n'
                    'The function is provided with matched string and groups, '
                    'so it is possible to construct an `InlineSpan` flexibly '
                    'with them.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({required this.title, required this.builder});

  final String title;
  final Widget Function(String title) builder;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => builder(title)),
      ),
    );
  }
}
