import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:text_parser/text_parser.dart' show TextElement;

import 'package:custom_text/src/text_span/split_spans.dart';

void main() {
  group('Basic behaviours', () {
    test('Able to split const span with no issue', () {
      const spans = [TextSpan(text: 'abc')];
      expect(
        spans.splitSpans(
          elements: const [
            TextElement('ab'),
            TextElement('c'),
          ],
        ),
        const {
          0: [TextSpan(text: 'ab')],
          1: [TextSpan(text: 'c')],
        },
      );
    });

    test('When element text completely matches span text', () {
      const spans = [TextSpan(text: 'abc')];
      expect(
        spans.splitSpans(
          elements: const [TextElement('abc')],
        ),
        const {
          0: [TextSpan(text: 'abc')],
        },
      );
    });

    test('When element text does not match span text but has same length', () {
      const spans = [TextSpan(text: 'abc')];
      expect(
        // Spans are split based not on text but on length.
        // It does not matter that the corresponding element has different text.
        spans.splitSpans(
          elements: const [TextElement('def')],
        ),
        const {
          0: [TextSpan(text: 'abc')],
        },
      );
    });

    test('When element text is shorter than span text', () {
      const spans = [
        TextSpan(text: 'abc'),
      ];
      expect(
        spans.splitSpans(
          elements: const [
            TextElement('ghijk'),
          ],
        ),
        const {
          0: [
            TextSpan(text: 'abc'),
          ],
        },
      );
    });

    test('When result has fewer spans because element text is shorter', () {
      const spans = [
        TextSpan(
          text: 'abc',
          children: [TextSpan(text: 'def')],
        ),
      ];
      expect(
        spans.splitSpans(
          elements: const [TextElement('ghi')],
        ),
        const {
          0: [TextSpan(text: 'abc')],
        },
      );
    });

    test('When element text is longer than span text', () {
      const spans = [TextSpan(text: 'abc')];
      expect(
        spans.splitSpans(
          elements: const [TextElement('defgh')],
        ),
        const {
          0: [TextSpan(text: 'abc')],
        },
      );
      expect(
        spans.splitSpans(
          elements: const [
            TextElement('def'),
            TextElement('ghi'),
          ],
        ),
        const {
          0: [TextSpan(text: 'abc')],
        },
      );
    });

    test('When some elements are not used because element text is longer', () {
      const spans = [TextSpan(text: 'abc')];
      expect(
        spans.splitSpans(
          elements: const [
            TextElement('def'),
            TextElement('ghi'),
          ],
        ),
        const {
          0: [TextSpan(text: 'abc')],
        },
      );
    });

    test('When multibyte characters are contained', () {
      const spans = [TextSpan(text: 'abあcdいef')];
      expect(
        spans.splitSpans(
          elements: const [
            TextElement('abあcdいef'),
          ],
        ),
        const {
          0: [TextSpan(text: 'abあcdいef')],
        },
      );
      expect(
        spans.splitSpans(
          elements: const [TextElement('abあcd ef')],
        ),
        const {
          0: [TextSpan(text: 'abあcdいef')],
        },
      );
    });

    test('When surrogate pairs are contained', () {
      const spans = [TextSpan(text: 'ab👨‍👨‍👦‍👦cd👨‍👨‍👦‍👦efghijklmnopq')];
      expect(
        spans.splitSpans(
          elements: const [
            TextElement('ab👨‍👨‍👦‍👦cd👨‍👨‍👦‍👦efghijklmnopq'),
          ],
        ),
        const {
          0: [TextSpan(text: 'ab👨‍👨‍👦‍👦cd👨‍👨‍👦‍👦efghijklmnopq')],
        },
      );
      expect(
        spans.splitSpans(
          elements: const [TextElement('ab👨‍👨‍👦‍👦cd efghijklmnopq')],
        ),
        const {
          0: [TextSpan(text: 'ab👨‍👨‍👦‍👦cd👨‍👨‍👦‍👦efg')],
        },
      );
      expect(
        spans.splitSpans(
          elements: const [TextElement('ab👨‍👨‍👦‍👦cd ef')],
        ),
        const {
          0: [TextSpan(text: 'ab👨‍👨‍👦‍👦cd👨‍')],
        },
      );
    });

    test('When each of two elements corresponds to each of two spans', () {
      const spans = [
        TextSpan(text: 'abc'),
        TextSpan(text: 'def'),
      ];
      expect(
        spans.splitSpans(
          elements: const [
            TextElement('abc'),
            TextElement('def'),
          ],
        ),
        const {
          0: [TextSpan(text: 'abc')],
          1: [TextSpan(text: 'def')],
        },
      );
    });

    test('When element ranges over two spans', () {
      const spans = [
        TextSpan(text: 'abc'),
        TextSpan(text: 'def'),
      ];
      expect(
        spans.splitSpans(
          elements: const [
            TextElement('a'),
            TextElement('bcd'),
            TextElement('ef'),
          ],
        ),
        const {
          0: [TextSpan(text: 'a')],
          1: [TextSpan(text: 'bc'), TextSpan(text: 'd')],
          2: [TextSpan(text: 'ef')],
        },
      );
    });

    test('When element ranges over more than two spans', () {
      const spans = [
        TextSpan(text: 'abc'),
        TextSpan(text: 'def'),
        TextSpan(text: 'ghi'),
      ];
      expect(
        spans.splitSpans(
          elements: const [
            TextElement('a'),
            TextElement('bcdefg'),
            TextElement('hi'),
          ],
        ),
        const {
          0: [TextSpan(text: 'a')],
          1: [TextSpan(text: 'bc'), TextSpan(text: 'def'), TextSpan(text: 'g')],
          2: [TextSpan(text: 'hi')],
        },
      );
    });
  });

  group('Inheritance of values from parent to children', () {
    test('Inherits only text, children and style from original spans', () {
      final recognizer = TapGestureRecognizer();
      addTearDown(recognizer.dispose);

      const style1 = TextStyle(color: Color(0x11111111));
      const style2 = TextStyle(color: Color(0x22222222));

      final spans = [
        TextSpan(
          text: 'abc',
          style: style1,
          mouseCursor: SystemMouseCursors.help,
          recognizer: recognizer,
          onEnter: (_) {},
          onExit: (_) {},
          semanticsLabel: 'abc',
          spellOut: true,
          children: [
            TextSpan(
              text: 'def',
              style: style2,
              mouseCursor: SystemMouseCursors.forbidden,
              recognizer: recognizer,
              onEnter: (_) {},
              onExit: (_) {},
              semanticsLabel: 'def',
              spellOut: true,
            ),
          ],
        ),
      ];

      expect(
        spans.splitSpans(
          elements: const [
            TextElement('ab'),
            TextElement('cd'),
            TextElement('ef'),
          ],
        ),
        {
          0: const [
            TextSpan(
              text: 'ab',
              style: style1,
            ),
          ],
          1: const [
            TextSpan(
              text: 'c',
              style: style1,
              children: [
                TextSpan(
                  text: 'd',
                  style: style2,
                ),
              ],
            ),
          ],
          2: const [
            TextSpan(
              style: style1,
              children: [
                TextSpan(
                  text: 'ef',
                  style: style2,
                ),
              ],
            ),
          ],
        },
      );
    });
  });

  group('Complex structures', () {
    test('Spans with multi-level children', () {
      const spans = [
        TextSpan(
          text: 'abc',
          children: [
            TextSpan(
              children: [
                TextSpan(
                  text: 'def',
                  children: [
                    TextSpan(text: 'ghi'),
                    TextSpan(text: 'jkl'),
                  ],
                ),
                TextSpan(
                  children: [
                    TextSpan(text: 'mno'),
                  ],
                ),
              ],
            ),
            TextSpan(
              text: 'pqr',
              children: [
                TextSpan(text: 'stu'),
              ],
            ),
          ],
        ),
        TextSpan(
          children: [
            TextSpan(
              text: 'vw',
              children: [
                TextSpan(text: 'xy'),
              ],
            ),
          ],
        ),
        TextSpan(
          text: 'z',
        ),
      ];
      expect(
        spans.splitSpans(
          elements: const [
            TextElement('abcdefg'),
            TextElement('hij'),
            TextElement('klm'),
            TextElement('nopqrs'),
            TextElement('tuv'),
            TextElement('wxyz'),
          ],
        ),
        const {
          0: [
            TextSpan(
              text: 'abc',
              children: [
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'def',
                      children: [
                        TextSpan(text: 'g'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
          1: [
            TextSpan(
              children: [
                TextSpan(
                  children: [
                    TextSpan(
                      children: [
                        TextSpan(text: 'hi'),
                        TextSpan(text: 'j'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
          2: [
            TextSpan(
              children: [
                TextSpan(
                  children: [
                    TextSpan(
                      children: [
                        TextSpan(text: 'kl'),
                      ],
                    ),
                    TextSpan(
                      children: [
                        TextSpan(text: 'm'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
          3: [
            TextSpan(
              children: [
                TextSpan(
                  children: [
                    TextSpan(
                      children: [
                        TextSpan(text: 'no'),
                      ],
                    ),
                  ],
                ),
                TextSpan(
                  text: 'pqr',
                  children: [
                    TextSpan(text: 's'),
                  ],
                ),
              ],
            ),
          ],
          4: [
            TextSpan(
              children: [
                TextSpan(
                  children: [
                    TextSpan(text: 'tu'),
                  ],
                ),
              ],
            ),
            TextSpan(
              children: [
                TextSpan(
                  text: 'v',
                ),
              ],
            ),
          ],
          5: [
            TextSpan(
              children: [
                TextSpan(
                  text: 'w',
                  children: [
                    TextSpan(text: 'xy'),
                  ],
                ),
              ],
            ),
            TextSpan(
              text: 'z',
            ),
          ],
        },
      );
    });
  });

  group('WidgetSpan', () {
    test('WidgetSpan at the beginning', () {
      const widgetSpan = WidgetSpan(child: Text('AAA'));

      const spans = [
        widgetSpan,
        TextSpan(text: 'abc'),
      ];

      expect(
        spans.splitSpans(
          elements: const [
            TextElement('_abc'),
          ],
        ),
        const {
          0: [
            widgetSpan,
            TextSpan(text: 'abc'),
          ],
        },
      );

      expect(
        spans.splitSpans(
          elements: const [
            TextElement('_'),
            TextElement('abc'),
          ],
        ),
        const {
          0: [
            widgetSpan,
          ],
          1: [
            TextSpan(text: 'abc'),
          ],
        },
      );
    });

    test('WidgetSpan at the end', () {
      const widgetSpan = WidgetSpan(child: Text('AAA'));

      const spans = [
        TextSpan(text: 'abc'),
        widgetSpan,
      ];

      expect(
        spans.splitSpans(
          elements: const [
            TextElement('abc_'),
          ],
        ),
        const {
          0: [
            TextSpan(text: 'abc'),
            widgetSpan,
          ],
        },
      );

      expect(
        spans.splitSpans(
          elements: const [
            TextElement('abc'),
            TextElement('_'),
          ],
        ),
        const {
          0: [
            TextSpan(text: 'abc'),
          ],
          1: [
            widgetSpan,
          ],
        },
      );
    });

    test('WidgetSpan at the beginning of children', () {
      const widgetSpan = WidgetSpan(child: Text('AAA'));

      const spans = [
        TextSpan(
          text: 'abc',
          children: [
            widgetSpan,
            TextSpan(text: 'def'),
          ],
        ),
      ];

      expect(
        spans.splitSpans(
          elements: const [
            TextElement('abc_def'),
          ],
        ),
        const {
          0: [
            TextSpan(
              text: 'abc',
              children: [
                widgetSpan,
                TextSpan(text: 'def'),
              ],
            ),
          ],
        },
      );

      expect(
        spans.splitSpans(
          elements: const [
            TextElement('abc_'),
            TextElement('def'),
          ],
        ),
        const {
          0: [
            TextSpan(
              text: 'abc',
              children: [
                widgetSpan,
              ],
            ),
          ],
          1: [
            TextSpan(
              children: [
                TextSpan(text: 'def'),
              ],
            ),
          ],
        },
      );

      expect(
        spans.splitSpans(
          elements: const [
            TextElement('abc'),
            TextElement('_'),
            TextElement('def'),
          ],
        ),
        const {
          0: [
            TextSpan(text: 'abc'),
          ],
          1: [
            TextSpan(
              children: [widgetSpan],
            ),
          ],
          2: [
            TextSpan(
              children: [TextSpan(text: 'def')],
            ),
          ],
        },
      );

      expect(
        spans.splitSpans(
          elements: const [
            TextElement('abc'),
            TextElement('_def'),
          ],
        ),
        const {
          0: [
            TextSpan(text: 'abc'),
          ],
          1: [
            TextSpan(
              children: [
                widgetSpan,
                TextSpan(text: 'def'),
              ],
            ),
          ],
        },
      );
    });

    test('WidgetSpan at the end of children', () {
      const widgetSpan = WidgetSpan(child: Text('AAA'));

      const spans = [
        TextSpan(
          text: 'abc',
          children: [
            TextSpan(text: 'def'),
            widgetSpan,
          ],
        ),
        TextSpan(text: 'ghi'),
      ];

      expect(
        spans.splitSpans(
          elements: const [
            TextElement('abcdef_ghi'),
          ],
        ),
        const {
          0: [
            TextSpan(
              text: 'abc',
              children: [
                TextSpan(text: 'def'),
                widgetSpan,
              ],
            ),
            TextSpan(text: 'ghi'),
          ],
        },
      );

      expect(
        spans.splitSpans(
          elements: const [
            TextElement('abcdef_'),
            TextElement('ghi'),
          ],
        ),
        const {
          0: [
            TextSpan(
              text: 'abc',
              children: [
                TextSpan(text: 'def'),
                widgetSpan,
              ],
            ),
          ],
          1: [
            TextSpan(text: 'ghi'),
          ],
        },
      );

      expect(
        spans.splitSpans(
          elements: const [
            TextElement('abcdef'),
            TextElement('_ghi'),
          ],
        ),
        const {
          0: [
            TextSpan(
              text: 'abc',
              children: [
                TextSpan(text: 'def'),
              ],
            ),
          ],
          1: [
            TextSpan(
              children: [
                widgetSpan,
              ],
            ),
            TextSpan(text: 'ghi'),
          ],
        },
      );

      expect(
        spans.splitSpans(
          elements: const [
            TextElement('abcdef'),
            TextElement('_'),
            TextElement('ghi'),
          ],
        ),
        const {
          0: [
            TextSpan(
              text: 'abc',
              children: [
                TextSpan(text: 'def'),
              ],
            ),
          ],
          1: [
            TextSpan(
              children: [
                widgetSpan,
              ],
            ),
          ],
          2: [
            TextSpan(text: 'ghi'),
          ],
        },
      );
    });
  });
}
