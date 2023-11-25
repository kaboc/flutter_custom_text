import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/widgets.dart';

// Workaround for the bug where properties of TextSpan is not
// applied to its children.
// https://github.com/flutter/flutter/issues/10623
//
// NOTE:
// If this is changed to an extension, a new instance of
// _WidgetSpanChild is created every time the method is called.
// Old instances keep existing and it leads to stack overflow.
TextSpan applyPropsToChildren(
  TextSpan rootSpan, {
  TextSpan? targetSpan,
  TextStyle? mergedStyle,
}) {
  final span = targetSpan ?? rootSpan;
  final children = span.children;

  final newMergedStyle = span.style == null
      ? mergedStyle
      : mergedStyle == null
          ? span.style
          : mergedStyle.merge(span.style);

  return TextSpan(
    text: span.text,
    style: span.style,
    // Only span with text needs gesture settings.
    recognizer: span.text == null ? null : rootSpan.recognizer,
    mouseCursor: span.text == null ? null : rootSpan.mouseCursor,
    onEnter: span.text == null ? null : rootSpan.onEnter,
    onExit: span.text == null ? null : rootSpan.onExit,
    // It is necessary to create new children instead of mutating
    // the existing children because they can be const.
    children: children == null
        ? null
        : [
            for (final child in children)
              if (child is TextSpan)
                applyPropsToChildren(
                  rootSpan,
                  targetSpan: child,
                  mergedStyle: newMergedStyle,
                )
              else if (child is WidgetSpan)
                WidgetSpan(
                  alignment: child.alignment,
                  baseline: child.baseline,
                  style: newMergedStyle == null
                      ? null
                      : const TextStyle(
                          // Colours except for the foreground colour are
                          // inherited to WidgetSpan, but other attributes
                          // don't seem to be inherited. Therefore it is
                          // necessary to use DefaultTextStyle to apply
                          // the ancestors' styles to the child.
                          // However, if the background colour is translucent,
                          // the inherited colour and the same colour by
                          // DefaultTextStyle are mixed and become darker.
                          // https://github.com/flutter/flutter/issues/137030
                          //
                          // The transparent colour here is a workaround to
                          // avoid it by negating the inherited colour.
                          backgroundColor: Color(0x00000000),
                          // Text decoration is applied to both TextSpan
                          // and WidgetSpan. In order to prevent WidgetSpan
                          // from getting duplicate decorations, it is
                          // necessary to remove one from WidgetSpan.
                          decoration: TextDecoration.none,
                        ),
                  child: WidgetSpanChild(
                    rootSpan: rootSpan,
                    widgetSpan: child,
                    mergedStyle: newMergedStyle,
                  ),
                ),
          ],
  );
}

class WidgetSpanChild extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const WidgetSpanChild({
    required this.rootSpan,
    required this.widgetSpan,
    required this.mergedStyle,
  });

  final TextSpan rootSpan;
  final WidgetSpan widgetSpan;
  final TextStyle? mergedStyle;

  @override
  Widget build(BuildContext context) {
    final parentRecognizer = rootSpan.recognizer;
    final recognizer =
        parentRecognizer is TapGestureRecognizer ? parentRecognizer : null;

    var child = widgetSpan.child;

    final span = rootSpan;
    if (span.onEnter != null ||
        span.onExit != null ||
        span.mouseCursor != MouseCursor.defer &&
            (recognizer == null ||
                span.mouseCursor != SystemMouseCursors.click)) {
      child = MouseRegion(
        onEnter: span.onEnter,
        onExit: span.onExit,
        cursor: span.mouseCursor,
        child: child,
      );
    }

    if (recognizer != null) {
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: recognizer.onTapDown,
        onTapUp: recognizer.onTapUp,
        onTapCancel: recognizer.onTapCancel,
        onSecondaryTapUp: recognizer.onSecondaryTapUp,
        onTertiaryTapUp: recognizer.onTertiaryTapUp,
        child: child,
      );
    }

    return mergedStyle == null
        ? child
        : DefaultTextStyle(
            style: DefaultTextStyle.of(context).style.merge(mergedStyle),
            child: child,
          );
  }
}
