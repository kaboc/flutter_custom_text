import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'data.dart';

// Workaround for the bug where properties of TextSpan is not
// applied to its children.
// https://github.com/flutter/flutter/issues/75622#issuecomment-776184709
//
// NOTE:
// If this is changed to an extension, a new instance of
// _WidgetSpanChild is created every time the method is called.
// Old instances keep existing and it leads to stack overflow.
void applyPropsToChildren({
  required TextSpan textSpan,
  required NotifierSettings settings,
  required SpanData spanData,
  TextStyle? mergedStyle,
}) {
  final children = textSpan.children;
  if (children == null) {
    return;
  }

  final self = textSpan;
  final newMergedStyle = const TextStyle().merge(mergedStyle).merge(self.style);

  for (var i = 0; i < children.length; i++) {
    final span = children[i];

    if (span is TextSpan) {
      children[i] = TextSpan(
        text: span.text,
        style: span.style,
        children: span.children,
        recognizer: self.recognizer,
        mouseCursor: self.mouseCursor,
        onEnter: self.onEnter,
        onExit: self.onExit,
      );

      applyPropsToChildren(
        textSpan: children[i] as TextSpan,
        settings: settings,
        spanData: spanData,
        mergedStyle: newMergedStyle,
      );
    }

    if (span is WidgetSpan) {
      children[i] = WidgetSpan(
        alignment: span.alignment,
        baseline: span.baseline,
        style: const TextStyle(
          // Some colours (seemingly exclusive of the foreground color)
          // are inherited to the child of WidgetSpan, while it does
          // not seem to be true of other styles. So DefaultTextStyle
          // is necessary to apply all the styles to children. However,
          // if the background colour is translucent, the inherited
          // colour and the same colour by DefaultTextStyle are mixed,
          // causing children to be darker.
          // https://github.com/flutter/flutter/issues/137030
          //
          // The transparent colour here is a workaround to avoid it.
          backgroundColor: Color(0x00000000),
          // It appears that the same workaround as the background
          // colour does not work for the decoration colour. The alpha
          // value or either of the RGB values need to be slightly above
          // zero to be not completely transparent.
          decorationColor: Color(0x01000000),
        ),
        child: _WidgetSpanChild(
          settings: settings,
          spanData: spanData,
          span: span,
          parentSpan: self,
          mergedStyle: newMergedStyle,
        ),
      );
    }
  }
}

class _WidgetSpanChild extends StatefulWidget {
  const _WidgetSpanChild({
    required this.settings,
    required this.spanData,
    required this.span,
    required this.parentSpan,
    required this.mergedStyle,
  });

  final NotifierSettings settings;
  final SpanData spanData;
  final WidgetSpan span;
  final TextSpan parentSpan;
  final TextStyle mergedStyle;

  @override
  State<_WidgetSpanChild> createState() => _WidgetSpanChildState();
}

class _WidgetSpanChildState extends State<_WidgetSpanChild> {
  late final Widget _child;

  @override
  void initState() {
    super.initState();

    final parentRecognizer = widget.parentSpan.recognizer;
    final recognizer =
        parentRecognizer is TapGestureRecognizer ? parentRecognizer : null;

    _child = GestureDetector(
      onTapDown: recognizer?.onTapDown,
      onTapUp: recognizer?.onTapUp,
      onTapCancel: recognizer?.onTapCancel,
      onSecondaryTapUp: recognizer?.onSecondaryTapUp,
      onTertiaryTapUp: recognizer?.onTertiaryTapUp,
      child: MouseRegion(
        onEnter: widget.parentSpan.onEnter,
        onExit: widget.parentSpan.onExit,
        cursor: widget.parentSpan.mouseCursor,
        child: widget.span.child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: DefaultTextStyle.of(context).style.merge(widget.mergedStyle),
      child: _child,
    );
  }
}
