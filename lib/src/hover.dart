import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class Hover {
  final textKey = GlobalKey();

  RenderParagraph? get _renderParagraph =>
      textKey.currentContext?.findRenderObject() as RenderParagraph?;

  void onHover(PointerHoverEvent event, void Function(bool) callback) {
    final paragraph = _renderParagraph;
    if (paragraph == null) {
      return;
    }

    final span = _span(paragraph, event.localPosition);
    if (span is TextSpan) {
      final isOverTappable =
          span.recognizer != null && _isOverText(event.localPosition);
      callback(isOverTappable);
      return;
    }
    callback(false);
  }

  InlineSpan? _span(RenderParagraph paragraph, Offset localPosition) {
    final textPosition = paragraph.getPositionForOffset(localPosition);
    return paragraph.text.getSpanForPosition(textPosition);
  }

  bool _isOverText(Offset localPosition) {
    for (final rect in _computeRects()) {
      if (rect.contains(localPosition)) {
        return true;
      }
    }
    return false;
  }

  List<Rect> _computeRects() {
    final paragraph = _renderParagraph;
    if (paragraph == null) {
      return [];
    }

    final selection = TextSelection(
      baseOffset: 0,
      extentOffset: paragraph.text.toPlainText().length,
    );

    return paragraph
        .getBoxesForSelection(selection)
        .map((box) => box.toRect())
        .toList();
  }
}
