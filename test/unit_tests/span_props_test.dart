import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/src/span/span_utils.dart';

void main() {
  group('applyPropsToChildren()', () {
    test('Using applyPropsToChildren() for const span causes no error', () {
      const span = TextSpan(
        text: 'abc',
        mouseCursor: SystemMouseCursors.forbidden,
        children: [
          TextSpan(text: 'def'),
        ],
      );

      expect(
        applyPropsToChildren(span),
        const TextSpan(
          text: 'abc',
          mouseCursor: SystemMouseCursors.forbidden,
          children: [
            TextSpan(
              text: 'def',
              mouseCursor: SystemMouseCursors.forbidden,
            ),
          ],
        ),
      );
    });

    test('Span with no children results in the same as the original', () {
      final recognizer = TapGestureRecognizer();
      addTearDown(recognizer.dispose);

      final span = TextSpan(
        text: 'abc',
        style: const TextStyle(color: Color(0x11111111)),
        recognizer: recognizer,
        mouseCursor: SystemMouseCursors.help,
        onEnter: (_) {},
        onExit: (_) {},
      );

      expect(applyPropsToChildren(span), span);
    });

    test('Gesture settings of root span are copied to spans with text.', () {
      final recognizer = TapGestureRecognizer();
      addTearDown(recognizer.dispose);

      void onEnter(PointerEnterEvent _) {}
      void onExit(PointerExitEvent _) {}

      final span = TextSpan(
        text: 'abc',
        recognizer: recognizer,
        mouseCursor: SystemMouseCursors.help,
        onEnter: onEnter,
        onExit: onExit,
        children: const [
          TextSpan(
            children: [
              TextSpan(text: 'def'),
              TextSpan(
                children: [
                  TextSpan(text: 'ghi'),
                ],
              ),
            ],
          ),
          TextSpan(
            children: [
              TextSpan(
                text: 'jkl',
                children: [
                  TextSpan(
                    children: [
                      TextSpan(text: 'mno'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      expect(
        applyPropsToChildren(span),
        TextSpan(
          text: 'abc',
          recognizer: recognizer,
          mouseCursor: SystemMouseCursors.help,
          onEnter: onEnter,
          onExit: onExit,
          children: [
            TextSpan(
              children: [
                TextSpan(
                  text: 'def',
                  recognizer: recognizer,
                  mouseCursor: SystemMouseCursors.help,
                  onEnter: onEnter,
                  onExit: onExit,
                ),
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'ghi',
                      recognizer: recognizer,
                      mouseCursor: SystemMouseCursors.help,
                      onEnter: onEnter,
                      onExit: onExit,
                    ),
                  ],
                ),
              ],
            ),
            TextSpan(
              children: [
                TextSpan(
                  text: 'jkl',
                  recognizer: recognizer,
                  mouseCursor: SystemMouseCursors.help,
                  onEnter: onEnter,
                  onExit: onExit,
                  children: [
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'mno',
                          recognizer: recognizer,
                          mouseCursor: SystemMouseCursors.help,
                          onEnter: onEnter,
                          onExit: onExit,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });

    test("Parent's TextStyle is not applied to children", () {
      const span = TextSpan(
        text: 'abc',
        style: TextStyle(color: Color(0x11111111)),
        children: [
          TextSpan(
            text: 'def',
            children: [
              TextSpan(text: 'ghi'),
              TextSpan(
                text: 'jkl',
                style: TextStyle(color: Color(0x22222222)),
                children: [
                  TextSpan(text: 'mno'),
                ],
              ),
            ],
          ),
        ],
      );

      expect(applyPropsToChildren(span), span);
    });

    test('Span containing WidgetSpans results in the same structure', () {
      const span = TextSpan(
        text: 'abc',
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            baseline: TextBaseline.ideographic,
            child: Text('AAA'),
          ),
          TextSpan(
            text: 'def',
            children: [
              TextSpan(text: 'ghi'),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                baseline: TextBaseline.alphabetic,
                child: Text('BBB'),
              ),
            ],
          ),
        ],
      );

      final result = applyPropsToChildren(span);

      // Child of a WidgetSpan in the result is WidgetSpanChild
      // containing the original child as a descendant, so testing
      // the equality of the original and generated spans never passes.
      // This test instead evaluates only the structural equality.
      expect(
        result.getSpanForPosition(const TextPosition(offset: 0)),
        predicate((s) => s is TextSpan && s.text == 'abc'),
      );
      expect(
        result.getSpanForPosition(const TextPosition(offset: 3)),
        predicate(
          (s) =>
              s is WidgetSpan &&
              s.child is WidgetSpanChild &&
              s.alignment == PlaceholderAlignment.top &&
              s.baseline == TextBaseline.ideographic,
        ),
      );
      expect(
        result.getSpanForPosition(const TextPosition(offset: 4)),
        predicate((s) => s is TextSpan && s.text == 'def'),
      );
      expect(
        result.getSpanForPosition(const TextPosition(offset: 7)),
        const TextSpan(text: 'ghi'),
      );
      expect(
        result.getSpanForPosition(const TextPosition(offset: 10)),
        predicate(
          (s) =>
              s is WidgetSpan &&
              s.child is WidgetSpanChild &&
              s.alignment == PlaceholderAlignment.middle &&
              s.baseline == TextBaseline.alphabetic,
        ),
      );
    });

    test(
      'WidgetSpan is given a special text style as a workaround for '
      'a bug of Flutter if any ancestor has a style',
      () {
        const span = TextSpan(
          text: 'abc',
          children: [
            WidgetSpan(child: Text('AAA')),
            TextSpan(
              text: 'def',
              style: TextStyle(backgroundColor: Color(0x11111111)),
              children: [
                TextSpan(text: 'ghi'),
                WidgetSpan(child: Text('BBB')),
              ],
            ),
          ],
        );

        final result = applyPropsToChildren(span);

        const specialStyle = TextStyle(
          backgroundColor: Color(0x00000000),
          decoration: TextDecoration.none,
        );

        expect(
          result.getSpanForPosition(const TextPosition(offset: 3)),
          predicate((s) => s is WidgetSpan && s.style == null),
        );
        expect(
          result.getSpanForPosition(const TextPosition(offset: 10)),
          predicate((s) => s is WidgetSpan && s.style == specialStyle),
        );
      },
    );
  });
}
