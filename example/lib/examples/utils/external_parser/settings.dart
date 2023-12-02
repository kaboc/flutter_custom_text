import 'package:custom_text/custom_text.dart';

import 'package:custom_text_example/common/highlight/highlight.dart';

enum LanguageType {
  dart('Dart', _dart, dartDefinitions),
  json('JSON', _json, jsonDefinitions),
  xml('XML', _xml, xmlDefinitions),
  markdown('Markdown', _markdown, markdownDefinitions);

  const LanguageType(this.label, this.sourceText, this.definitions);

  final String label;
  final String sourceText;
  final List<TextDefinition> definitions;
}

const _dart = r'''
void main() {
  final number = 123;
  final result = multiply(number);
  
  print('$number * 2 = $result');
}

int multiply(int n) {
  return n * 2;
}
''';

const _json = '''
{
  "version": 1.0,
  "users": [
    {
      "name": "Claire",
      "student": true
    },
    {
      "name": "Daniel",
      "student": false,
      "attributes": [ "MSc", null, 2023 ]
    }
  ]
}
''';

const _xml = '''
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
<channel>
  <title>Packages</title>
  <link>https://pub.dev/</link>
  <description>The official package repository.</description>
  <item>
    <title>Publisher</title>
    <link>https://pub.dev/publishers/kaboc.cc/packages</link>
  </item>
  <item>
    <title>This package</title>
    <link>https://pub.dev/packages/custom_text</link>
  </item>
</channel>
</rss>
''';

const _markdown = '''
# Heading

- Pizza
    - Cheese
    - Tomato
- Pasta

1. Orange
2. Peach

[link](https://example.com/)

**Bold**
*Italic*

> Quote

This is `inline code`.

```
// Code block
void main() {
  print('Hello world!');
}
```
''';
