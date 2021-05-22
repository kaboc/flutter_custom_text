import 'package:flutter/material.dart';

import 'package:custom_text_example/example_page.dart';
import 'package:custom_text_example/examples/example1.dart';
import 'package:custom_text_example/examples/example2.dart';
import 'package:custom_text_example/examples/example3.dart';
import 'package:custom_text_example/examples/example4.dart';
import 'package:custom_text_example/examples/example5.dart';
import 'package:custom_text_example/examples/example6.dart';
import 'package:custom_text_example/examples/experimental.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CustomText Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        textTheme: const TextTheme(
          bodyText1: TextStyle(fontWeight: FontWeight.normal, height: 1.2),
          bodyText2: TextStyle(fontSize: 18.0, height: 1.5),
        ),
        appBarTheme: const AppBarTheme(
          brightness: Brightness.dark,
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
              builder: (title) => ExamplePage(
                title,
                'example1.dart',
                'A very basic example to apply a colour to URLs and email '
                    'addresses.\nThey are not tappable in this example.',
                (_) => const Example1(),
                hasOutput: false,
              ),
            ),
            _ListTile(
              title: 'Unique styles and actions',
              builder: (title) => ExamplePage(
                title,
                'example2.dart',
                'An example to apply styles to URLs, email addresses and '
                    'phone numbers, and enable them to be tapped / '
                    'long-pressed.\n'
                    'Phone numbers are styled differently according to '
                    'the `matchStyle` and `tapStyle` set in the definition. ',
                (outputFunc) => Example2(outputFunc),
                additionalInfo:
                    'Try tapping / long-pressing on coloured strings.',
              ),
            ),
            _ListTile(
              title: 'Overwritten match pattern',
              builder: (title) => ExamplePage(
                title,
                'example3.dart',
                'An example to overwrite the default match pattern of '
                    '`TelMatcher`.\n'
                    'The new pattern regards only the `{3 digits}-{4 digits}'
                    '-{4 digits}` format as a phone number.',
                (outputFunc) => Example3(outputFunc),
              ),
            ),
            _ListTile(
              title: 'Custom matchers',
              builder: (title) => ExamplePage(
                title,
                'example4.dart',
                'An example to parse hashtags using a custom matcher and '
                    'apply styles to them.\n'
                    'A hashtag has a wide variety of definitions, but here '
                    'as an example, it is defined as a string that starts '
                    'with `#` followed by an alphabet and then by '
                    'alphanumerics, and is enclosed with white spaces.',
                (outputFunc) => Example4(outputFunc),
              ),
            ),
            _ListTile(
              title: 'SelectiveDefinition',
              builder: (title) => ExamplePage(
                title,
                'example5.dart',
                'An example to parse markdown-style links, like `[label](url)` '
                    'using `SelectiveDefinition`, and make them tappable.\n'
                    'Each of the string shown in the widget and the string '
                    'passed to the tap callbacks is selected individually '
                    'from the fragments (`groups`) that have matched the '
                    'patterns enclosed with parentheses within the match '
                    'pattern.',
                (outputFunc) => Example5(outputFunc),
              ),
            ),
            _ListTile(
              title: 'SpanDefinition',
              builder: (title) => ExamplePage(
                title,
                'example6.dart',
                'An example to show both strings and icons using '
                    '`SpanDefinition`.\n'
                    'The builder parameter takes a function returning an '
                    '`InlineSpan`.\n'
                    'The function is provided with matched string and groups, '
                    'so it is possible to construct an `InlineSpan` flexibly '
                    'with them.',
                (outputFunc) => Example6(outputFunc),
              ),
            ),
            _ListTile(
              title: 'Changing mouse cursor on hover',
              builder: (title) => ExamplePage(
                title,
                'experimental.dart',
                'An example to show the experimental feature of changing '
                    'the mouse cursor on hover over a clickable element.\n'
                    'Set one of `SystemMouseCursor`s other than '
                    '`SystemMouseCursors.basic` to `cursorOnHover` to opt '
                    'in to the feature.',
                (outputFunc) => Experimental(outputFunc),
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
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => builder(title)),
      ),
    );
  }
}
