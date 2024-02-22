import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/src/span/span_utils.dart';

import 'utils.dart';

void main() {
  group('applyPropsToChildren()', () {
    testWidgets(
      'Recognizer of root span is applied to descendant WidgetSpans and '
      'SystemMouseCursors.click is used even if it is not specified',
      (tester) async {
        final recognizer = TapGestureRecognizer();
        addTearDown(recognizer.dispose);

        const child1 = Text('aaa');
        const child2 = Text('bbb');

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text.rich(
              applyPropsToChildren(
                TextSpan(
                  recognizer: recognizer,
                  children: const [
                    TextSpan(
                      children: [
                        WidgetSpan(child: child1),
                      ],
                    ),
                    WidgetSpan(child: child2),
                  ],
                ),
              ),
            ),
          ),
        );

        // Simulating a tap on GestureDetector does not work for unknown
        // reasons, so this test checks that GestureDetectors are found
        // and that they have the same GestureRecognizer as the root span.
        final gestureDetectors = tester.findWidgetsByType<GestureDetector>();
        expect(gestureDetectors, hasLength(2));

        final gestureDetector1 = gestureDetectors.first;
        expect(gestureDetector1.onTapDown, recognizer.onTapDown);
        expect(gestureDetector1.onTapUp, recognizer.onTapUp);
        expect(gestureDetector1.onTapCancel, recognizer.onTapCancel);
        expect(gestureDetector1.onSecondaryTapUp, recognizer.onSecondaryTapUp);
        expect(gestureDetector1.onTertiaryTapUp, recognizer.onTertiaryTapUp);

        expect(gestureDetector1.child, isA<MouseRegion>());
        final mouseRegion1 = gestureDetector1.child! as MouseRegion;
        expect(mouseRegion1.cursor, SystemMouseCursors.click);
        expect(mouseRegion1.child, child1);

        final gestureDetector2 = gestureDetectors.last;
        expect(gestureDetector2.onTapDown, recognizer.onTapDown);
        expect(gestureDetector2.onTapUp, recognizer.onTapUp);
        expect(gestureDetector2.onTapCancel, recognizer.onTapCancel);
        expect(gestureDetector2.onSecondaryTapUp, recognizer.onSecondaryTapUp);
        expect(gestureDetector2.onTertiaryTapUp, recognizer.onTertiaryTapUp);

        expect(gestureDetector2.child, isA<MouseRegion>());
        final mouseRegion2 = gestureDetector2.child! as MouseRegion;
        expect(mouseRegion2.cursor, SystemMouseCursors.click);
        expect(mouseRegion2.child, child2);
      },
    );

    testWidgets(
      'onEnter, onExit and mouseCursor of root span are applied to '
      'descendant WidgetSpans',
      (tester) async {
        final events = <String>[];
        void onEnter(PointerEnterEvent _) => events.add('enter');
        void onExit(PointerExitEvent _) => events.add('exit');

        const child1 = Text('aaa');
        const child2 = Text('bbb');

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text.rich(
              applyPropsToChildren(
                TextSpan(
                  onEnter: onEnter,
                  onExit: onExit,
                  mouseCursor: SystemMouseCursors.wait,
                  children: const [
                    TextSpan(
                      children: [
                        WidgetSpan(child: child1),
                      ],
                    ),
                    WidgetSpan(child: child2),
                  ],
                ),
              ),
            ),
          ),
        );

        final mouseRegions = tester.findWidgetsByType<MouseRegion>();
        expect(mouseRegions, hasLength(2));
        expect(mouseRegions.first.child, child1);
        expect(mouseRegions.last.child, child2);

        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
          pointer: 1,
        );

        final finder = find.byType(MouseRegion);

        await gesture.addPointer(location: tester.getBottomLeft(finder.first));
        expect(
          RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
          SystemMouseCursors.basic,
        );

        await gesture.moveTo(tester.getCenter(finder.first));
        expect(
          RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
          SystemMouseCursors.wait,
        );

        await gesture.moveTo(tester.getBottomLeft(finder.last));
        expect(
          RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
          SystemMouseCursors.basic,
        );

        await gesture.moveTo(tester.getCenter(finder.last));
        expect(
          RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
          SystemMouseCursors.wait,
        );

        expect(events, ['enter', 'exit', 'enter']);
      },
    );

    testWidgets(
      'TextStyles of Ancestors are merged and set as default text style',
      (tester) async {
        const style1 = TextStyle(backgroundColor: Color(0x11111111));
        const style2 = TextStyle(
          backgroundColor: Color(0x22222222),
          decoration: TextDecoration.underline,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text.rich(
              applyPropsToChildren(
                const TextSpan(
                  style: style1,
                  children: [
                    TextSpan(
                      style: style2,
                      children: [
                        WidgetSpan(child: Text('aaa')),
                      ],
                    ),
                    WidgetSpan(child: Text('bbb')),
                  ],
                ),
              ),
            ),
          ),
        );

        final defaultTextStyles = tester.findWidgetsByType<DefaultTextStyle>();
        expect(defaultTextStyles, hasLength(2));
        expect(defaultTextStyles.first.style, style1.merge(style2));
        expect(defaultTextStyles.last.style, style1);

        final richTexts = tester.findWidgetsByType<RichText>();
        expect(richTexts, hasLength(3));
        expect(richTexts.elementAt(0).text.toPlainText(), '\uFFFC\uFFFC');
        expect(richTexts.elementAt(1).text.toPlainText(), 'aaa');
        expect(richTexts.elementAt(1).text.style, style1.merge(style2));
        expect(richTexts.elementAt(2).text.toPlainText(), 'bbb');
        expect(richTexts.elementAt(2).text.style, style1);
      },
    );

    testWidgets(
      'DefaultTextStyle is used only if any ancestor has a style',
      (tester) async {
        const style = TextStyle(backgroundColor: Color(0x11111111));

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text.rich(
              applyPropsToChildren(
                const TextSpan(
                  children: [
                    TextSpan(
                      style: style,
                      children: [
                        WidgetSpan(child: Text('aaa')),
                      ],
                    ),
                    WidgetSpan(child: Text('bbb')),
                  ],
                ),
              ),
            ),
          ),
        );

        final defaultTextStyles = tester.findWidgetsByType<DefaultTextStyle>();
        expect(defaultTextStyles, hasLength(1));
        expect(defaultTextStyles.first.style, style);

        final richTexts = tester.findWidgetsByType<RichText>();
        expect(richTexts, hasLength(3));
        expect(richTexts.elementAt(0).text.toPlainText(), '\uFFFC\uFFFC');
        expect(richTexts.elementAt(1).text.toPlainText(), 'aaa');
        expect(richTexts.elementAt(1).text.style, style);
        expect(richTexts.elementAt(2).text.toPlainText(), 'bbb');
        expect(richTexts.elementAt(2).text.style, const TextStyle());
      },
    );

    testWidgets(
      'GestureDetector is not used if root span does not have recognizer',
      (tester) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text.rich(
              applyPropsToChildren(
                const TextSpan(
                  children: [
                    TextSpan(
                      children: [
                        WidgetSpan(child: Text('aaa')),
                      ],
                    ),
                    WidgetSpan(child: Text('bbb')),
                  ],
                ),
              ),
            ),
          ),
        );

        final gestureDetectors = tester.findWidgetsByType<GestureDetector>();
        expect(gestureDetectors, isEmpty);
      },
    );

    testWidgets(
      'MouseRegion is not used if root span does not have hover '
      'callbacks nor mouseCursor',
      (tester) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text.rich(
              applyPropsToChildren(
                const TextSpan(
                  children: [
                    TextSpan(
                      children: [
                        WidgetSpan(child: Text('aaa')),
                      ],
                    ),
                    WidgetSpan(child: Text('bbb')),
                  ],
                ),
              ),
            ),
          ),
        );

        final gestureDetectors = tester.findWidgetsByType<MouseRegion>();
        expect(gestureDetectors, isEmpty);
      },
    );

    testWidgets(
      'DefaultTextStyle is not used if TextStyle does not have to be merged',
      (tester) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text.rich(
              applyPropsToChildren(
                const TextSpan(
                  style: TextStyle(color: Color(0x11111111)),
                  children: [
                    TextSpan(
                      children: [
                        WidgetSpan(child: Text('aaa')),
                      ],
                    ),
                    WidgetSpan(child: Text('bbb')),
                  ],
                ),
              ),
            ),
          ),
        );

        final gestureDetectors = tester.findWidgetsByType<GestureDetector>();
        expect(gestureDetectors, isEmpty);
      },
    );
  });
}
