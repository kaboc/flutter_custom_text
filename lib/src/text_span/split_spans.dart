import 'package:flutter/painting.dart' show InlineSpan, TextSpan;

import 'package:text_parser/text_parser.dart' show TextElement;

class _Result {
  const _Result({
    required this.spans,
    required this.elmIndex,
    required this.textOffset,
  });

  final Map<int, List<InlineSpan>> spans;
  final int elmIndex;
  final int textOffset;
}

extension on Map<Object, List<InlineSpan>> {
  void addOrCreate(Object key, InlineSpan span) {
    this[key] ??= [];
    this[key]?.add(span);
  }
}

/// Splits InlineSpans so that each of them corresponds to a TextElement.
extension SplitSpans on List<InlineSpan> {
  Map<int, List<InlineSpan>> splitSpans({required List<TextElement> elements}) {
    return _split(elements: elements).spans;
  }

  _Result _split({
    required List<TextElement> elements,
    int elmIndex = 0,
    int textOffset = 0,
  }) {
    var currentElmIndex = elmIndex;
    var elmTextOffset = textOffset;

    final spans = <int, List<InlineSpan>>{};
    for (final span in this) {
      if (currentElmIndex >= elements.length) {
        break;
      }

      if (span is! TextSpan) {
        spans.addOrCreate(currentElmIndex, span);

        elmTextOffset++;
        final elmTextLen = elements[currentElmIndex].text.length;

        if (elmTextOffset == elmTextLen) {
          currentElmIndex++;
          elmTextOffset = 0;
        }
        continue;
      }

      final spanText = span.text;
      if (spanText == null) {
        spans.addOrCreate(
          currentElmIndex,
          TextSpan(style: span.style),
        );
      } else {
        var spanTextOffset = 0;

        while (true) {
          final spanRemainingText = spanText.substring(spanTextOffset);
          final spanEndOffset = elmTextOffset + spanRemainingText.length;
          final elmTextLen = elements[currentElmIndex].text.length;

          if (spanEndOffset <= elmTextLen) {
            spans.addOrCreate(
              currentElmIndex,
              TextSpan(
                text: spanRemainingText,
                style: span.style,
              ),
            );

            if (spanEndOffset < elmTextLen) {
              elmTextOffset = spanEndOffset;
            } else {
              currentElmIndex++;
              elmTextOffset = 0;
            }
            break;
          }

          final elmEndOffset = elmTextLen - elmTextOffset;
          spans.addOrCreate(
            currentElmIndex,
            TextSpan(
              text: spanRemainingText.substring(0, elmEndOffset),
              style: span.style,
            ),
          );

          currentElmIndex++;
          elmTextOffset = 0;
          spanTextOffset += elmEndOffset;

          if (currentElmIndex >= elements.length) {
            break;
          }
        }
      }

      final spanChildren = span.children;
      if (spanChildren != null) {
        final result = spanChildren._split(
          elements: elements,
          elmIndex: currentElmIndex,
          textOffset: elmTextOffset,
        );

        for (final i in result.spans.keys) {
          if (result.spans[i]!.isNotEmpty) {
            final child = spans[i];
            final j = child == null ? 0 : child.length - 1;
            final lastSpan = child?[j];

            if (child == null || lastSpan is! TextSpan) {
              spans[i] = [
                TextSpan(
                  children: result.spans[i],
                  style: span.style,
                ),
              ];
            } else {
              spans[i]![j] = TextSpan(
                text: lastSpan.text,
                children: result.spans[i],
                style: span.style,
              );
            }
          }
        }

        currentElmIndex = result.elmIndex;
        elmTextOffset = result.textOffset;
      }
    }

    return _Result(
      spans: spans,
      elmIndex: currentElmIndex,
      textOffset: elmTextOffset,
    );
  }
}
