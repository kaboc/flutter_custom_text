import 'package:text_parser/text_parser.dart'
    show TextElement, TextElementsExtension;

extension on String {
  String safeSubstring(int start, [int? end]) {
    final s = start < 0 ? 0 : (start > length ? length : start);
    return end == null
        ? substring(s)
        : substring(s, end < s ? s : (end > length ? length : end));
  }
}

class Range {
  const Range([this.start = -1, this.end = -1]);

  final int start;
  final int end;

  bool get isInvalid => start < 0 || end < 0;
}

class BuildResult {
  const BuildResult({
    required this.elements,
    required this.replaceRange,
    required this.spanRange,
  });

  final List<TextElement> elements;
  final Range replaceRange;
  final Range spanRange;
}

/// Builds elements to be used transiently while parsing is being debounced.
class TransientTextElementsBuilder {
  TransientTextElementsBuilder({
    required this.oldElements,
    required this.oldText,
    required this.newText,
  });

  final List<TextElement> oldElements;
  final String oldText;
  final String newText;

  Range findUpdatedElementsRange() {
    final elmLen = oldElements.length;
    var start = -1;
    var end = -1;

    for (var i = 0; i < elmLen; i++) {
      final elm = oldElements[i];
      final from = elm.offset;
      final to = i == elmLen - 1 ? newText.length : from + elm.text.length;
      final t = newText.safeSubstring(from, to);
      if (t != elm.text) {
        start = i;
        break;
      }
    }

    if (start < 0) {
      return const Range();
    }

    var from = newText.length;
    for (var i = elmLen - 1; i >= start; i--) {
      final elm = oldElements[i];
      final to = from;
      from -= elm.text.length;
      final t = newText.safeSubstring(i == 0 ? 0 : from, to);
      if (t != elm.text) {
        end = i;
        break;
      }
    }

    if (end < 0) {
      // The change is located in between the text elements.
      // It should be treated as belonging to the former.
      start--;
      end = start;
    }

    return Range(start, end);
  }

  BuildResult build({required Range changeRange}) {
    final oldElmS = oldElements[changeRange.start];
    final oldElmE = oldElements[changeRange.end];

    // Searches the first element in the change range to find the start
    // offset of the string not matching the one previously located at the
    // same offset, and extracts the string before it from the element.
    int offsetS;
    var stringA = '';
    {
      final string = newText.safeSubstring(
        oldElmS.offset,
        oldElmS.offset + oldElmS.text.length,
      );

      final elmTextLen = string.length;
      offsetS = oldElmS.offset;

      for (var i = 0; i < elmTextLen; i++) {
        if (string[i] != oldElmS.text[i]) {
          offsetS = oldElmS.offset + i;
          stringA = oldElmS.text.safeSubstring(0, i);
          break;
        }
      }
    }

    // Searches the last element in the change range to find the end
    // offset of the string not matching the one previously located at
    // the same offset, and extracts the string after it from the element.
    int offsetE;
    var stringB = '';
    {
      var newOffset = newText.length - (oldText.length - oldElmE.offset);
      var elmTextLen = oldElmE.text.length;
      if (newOffset < 0) {
        elmTextLen += newOffset;
        newOffset = 0;
      }

      final string = newText.safeSubstring(newOffset, newOffset + elmTextLen);
      offsetE = newOffset + elmTextLen;

      if (oldElmE != oldElmS) {
        for (var i = 0; i < elmTextLen; i++) {
          final t = oldElmE.text;
          if (string[elmTextLen - i - 1] != t[t.length - i - 1]) {
            offsetE = newOffset + elmTextLen - i;
            stringB = t.safeSubstring(t.length - i);
            break;
          }
        }
      }
    }

    // Text elements before the change range.
    final elmsA = changeRange.start == 0
        ? <TextElement>[]
        : oldElements.getRange(0, changeRange.start).toList();

    // Text elements after the change range.
    final elmsB = changeRange.end == oldElements.length - 1
        ? <TextElement>[]
        : oldElements
            .getRange(changeRange.end + 1, oldElements.length)
            .toList();

    // Appends the changed string to the preceding text.
    stringA += newText.safeSubstring(offsetS, offsetE);

    var replRangeTo = changeRange.end;
    var spanRangeTo = changeRange.start;

    // If the start offset of the change range is greater, it means
    // that the string starting at the offset and possibly also the
    // strings in some elements after that are a duplicate of the
    // strings preceding them. Those have to be removed.
    if (offsetS > offsetE) {
      var diffLen = offsetS - offsetE;

      if (stringA.isNotEmpty) {
        final len = stringA.length < diffLen ? stringA.length : diffLen;
        diffLen -= len;
        stringA = stringA.substring(0, stringA.length - len);
      }
      if (diffLen > 0 && stringB.isNotEmpty) {
        final len = stringB.length < diffLen ? stringB.length : diffLen;
        diffLen -= len;
        stringB = stringB.substring(len);
      }
      if (diffLen > 0) {
        for (var i = 0; i < elmsB.length; i++) {
          replRangeTo++;

          final elm = elmsB[i];
          final len = elm.text.length < diffLen ? elm.text.length : diffLen;
          diffLen -= len;
          elmsB[i] = elm.copyWith(text: elm.text.substring(len));

          if (diffLen == 0) {
            elmsB.removeRange(0, len == elm.text.length ? i + 1 : i);
            if (len < elm.text.length) {
              spanRangeTo++;
            }
            break;
          }
        }
      }
    }

    if (stringA.isNotEmpty) {
      spanRangeTo++;
    }
    if (stringB.isNotEmpty) {
      spanRangeTo++;
    }

    return BuildResult(
      elements: [
        ...elmsA,
        if (stringA.isNotEmpty) oldElmS.copyWith(text: stringA),
        if (stringB.isNotEmpty) oldElmE.copyWith(text: stringB),
        ...elmsB,
      ].reassignOffsets().toList(),
      replaceRange: Range(changeRange.start, replRangeTo),
      spanRange: Range(changeRange.start, spanRangeTo),
    );
  }
}
