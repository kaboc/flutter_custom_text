import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'utils.dart';
import 'widgets.dart';

void main() {
  setUp(() {
    isTap = isLongPress = false;
    matcherType = tappedText = null;
  });

  group('Styles for SelectiveDefinition', () {
    testWidgets(
      'matchStyle specified in definition is used even if without onTap',
      (tester) async {
        await tester.pumpWidget(
          const SelectiveCustomTextWidget(
            'aaa[bbb](ccc)ddd',
            matchStyleInDef: TextStyle(color: Color(0xFF111111)),
          ),
        );
        await tester.pump();

        final span = findSpan('bbb');
        expect(span?.style?.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'matchStyle specified in definition is only applied to relevant element',
      (tester) async {
        await tester.pumpWidget(
          const SelectiveCustomTextWidget(
            'aaa[bbb](ccc)ddd 012-3456-7890',
            style: TextStyle(color: Color(0xFF111111)),
            matchStyleInDef: TextStyle(color: Color(0xFF222222)),
          ),
        );
        await tester.pump();

        final span1 = findSpan('bbb');
        final span2 = findSpan('012-3456-7890');
        expect(span1?.style?.color, const Color(0xFF222222));
        expect(span2?.style?.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'matchStyle specified in definition takes priority',
      (tester) async {
        await tester.pumpWidget(
          const SelectiveCustomTextWidget(
            'aaa[bbb](ccc)ddd',
            matchStyle: TextStyle(color: Color(0xFF111111)),
            matchStyleInDef: TextStyle(color: Color(0xFF222222)),
          ),
        );
        await tester.pump();

        final span = findSpan('bbb');
        expect(span?.style?.color, const Color(0xFF222222));
      },
    );

    testWidgets(
      'tapStyle specified in definition is not applied '
      'if tap callbacks are not set',
      (tester) async {
        await tester.pumpWidget(
          const SelectiveCustomTextWidget(
            'aaa[bbb](ccc)ddd',
            style: TextStyle(color: Color(0xFF111111)),
            tapStyleInDef: TextStyle(color: Color(0xFF222222)),
          ),
        );
        await tester.pump();

        final spanA = findSpan('bbb');
        tapDownSpan(spanA);
        await tester.pump();

        final spanB = findSpan('bbb');
        expect(spanB?.style?.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'tapStyle specified in definition is only applied to relevant element',
      (tester) async {
        await tester.pumpWidget(
          const SelectiveCustomTextWidget(
            'aaa[bbb](ccc)ddd 012-3456-7890',
            matchStyle: TextStyle(color: Color(0xFF111111)),
            tapStyleInDef: TextStyle(color: Color(0xFF222222)),
            onTap: onTap,
          ),
        );
        await tester.pump();

        final span1A = findSpan('bbb');
        tapDownSpan(span1A);
        await tester.pump();

        final span1B = findSpan('bbb');
        final span2 = findSpan('012-3456-7890');
        expect(span1B?.style?.color, const Color(0xFF222222));
        expect(span2?.style?.color, const Color(0xFF111111));
      },
    );

    testWidgets(
      'tapStyle specified in definition takes priority',
      (tester) async {
        await tester.pumpWidget(
          const SelectiveCustomTextWidget(
            'aaa[bbb](ccc)ddd',
            tapStyle: TextStyle(color: Color(0xFF111111)),
            tapStyleInDef: TextStyle(color: Color(0xFF222222)),
            onTap: onTap,
          ),
        );
        await tester.pump();

        final spanA = findSpan('bbb');
        tapDownSpan(spanA);
        await tester.pump();

        final spanB = findSpan('bbb');
        expect(spanB?.style?.color, const Color(0xFF222222));
      },
    );
  });

  group('Tap callbacks of SelectiveDefinition', () {
    testWidgets(
      'Correct string is passed to onTap specified in CustomText',
      (tester) async {
        await tester.pumpWidget(
          const SelectiveCustomTextWidget('aaa[bbb](ccc)ddd', onTap: onTap),
        );
        await tester.pump();

        const link = 'bbb';
        final span = findSpan(link);

        tapDownSpan(span);
        await tester.pump();
        tapUpSpan(span);
        await tester.pump();

        expect(isTap, isTrue);
        expect(matcherType, equals(LinkMatcher));
        expect(tappedText, equals('ccc'));
      },
    );

    testWidgets(
      'Correct string is passed to onLongPress specified in CustomText',
      (tester) async {
        await tester.pumpWidget(
          const SelectiveCustomTextWidget(
            'aaa[bbb](ccc)ddd',
            onLongPress: onLongPress,
          ),
        );
        await tester.pump();

        const link = 'bbb';
        final span = findSpan(link);

        tapDownSpan(span);
        await tester.pump(const Duration(milliseconds: 610));
        tapUpSpan(span);
        await tester.pump();

        expect(isLongPress, isTrue);
        expect(matcherType, equals(LinkMatcher));
        expect(tappedText, equals('ccc'));
      },
    );

    testWidgets(
      'Correct string is passed to onTap specified in definition',
      (tester) async {
        await tester.pumpWidget(
          SelectiveCustomTextWidget(
            'aaa[bbb](ccc)ddd',
            onTapInDef: (text) => onTap(null, text),
          ),
        );
        await tester.pump();

        const link = 'bbb';
        final span = findSpan(link);

        tapDownSpan(span);
        await tester.pump();
        tapUpSpan(span);
        await tester.pump();

        expect(isTap, isTrue);
        expect(tappedText, equals('ccc'));
      },
    );

    testWidgets(
      'Correct string is passed to onLongPress specified in definition',
      (tester) async {
        await tester.pumpWidget(
          SelectiveCustomTextWidget(
            'aaa[bbb](ccc)ddd',
            onLongPressInDef: (text) => onLongPress(null, text),
          ),
        );
        await tester.pump();

        const link = 'bbb';
        final span = findSpan(link);

        tapDownSpan(span);
        await tester.pump(const Duration(milliseconds: 610));
        tapUpSpan(span);
        await tester.pump();

        expect(isLongPress, isTrue);
        expect(tappedText, equals('ccc'));
      },
    );
  });

  group('mouse hover', () {
    testWidgets(
      'default mouse cursors for TextSpan with/without tap callbacks',
      (tester) async {
        await tester.pumpWidget(
          SelectiveCustomTextWidget(
            'aaa [bbb](ccc)',
            onTap: (_, __) {},
          ),
        );
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2 = findSpan('bbb');
        expect((span1 as TextSpan?)?.mouseCursor, MouseCursor.defer);
        expect((span2 as TextSpan?)?.mouseCursor, SystemMouseCursors.click);
      },
    );

    testWidgets(
      'mouse cursor for TextSpan with mouseCursor set',
      (tester) async {
        await tester.pumpWidget(
          const SelectiveCustomTextWidget(
            'aaa [bbb](ccc)',
            mouseCursor: SystemMouseCursors.grab,
          ),
        );
        await tester.pump();

        final span1 = findSpan('aaa ');
        final span2 = findSpan('bbb');
        expect((span1 as TextSpan?)?.mouseCursor, MouseCursor.defer);
        expect((span2 as TextSpan?)?.mouseCursor, SystemMouseCursors.grab);
      },
    );

    testWidgets('hoverStyle', (tester) async {
      await tester.pumpWidget(
        const SelectiveCustomTextWidget(
          'aaa [bbbbbbbbbbbb](ccc) 012-3456-7890',
          style: TextStyle(color: Color(0xFF111111)),
          matchStyle: TextStyle(color: Color(0xFF222222)),
          hoverStyle: TextStyle(color: Color(0xFF333333)),
          hoverStyleInDef: TextStyle(color: Color(0xFF444444)),
        ),
      );
      await tester.pump();

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      final center = tester.getCenter(find.byType(RichText));

      await gesture.moveTo(Offset(center.dx / 2, center.dy));
      await tester.pump();

      final span1A = findSpan('aaa ');
      final span2A = findSpan('bbbbbbbbbbbb');
      final span3A = findSpan('012-3456-7890');
      expect(span1A?.style?.color, const Color(0xFF111111));
      expect(span2A?.style?.color, const Color(0xFF444444));
      expect(span3A?.style?.color, const Color(0xFF222222));

      await gesture.moveTo(Offset(center.dx / 2 * 3, center.dy));
      await tester.pump();

      final span1B = findSpan('aaa ');
      final span2B = findSpan('bbbbbbbbbbbb');
      final span3B = findSpan('012-3456-7890');
      expect(span1B?.style?.color, const Color(0xFF111111));
      expect(span2B?.style?.color, const Color(0xFF222222));
      expect(span3B?.style?.color, const Color(0xFF333333));

      await gesture.removePointer();
    });

    testWidgets(
      'tapStyle is used while being tapped even if hoverStyle is set',
      (tester) async {
        await tester.pumpWidget(
          SelectiveCustomTextWidget(
            'aaa [bbbbbbbbbbbb](ccc)',
            style: const TextStyle(color: Color(0xFF111111)),
            tapStyle: const TextStyle(color: Color(0xFF222222)),
            hoverStyle: const TextStyle(color: Color(0xFF333333)),
            onTap: (_, __) {},
          ),
        );
        await tester.pump();

        final gesture =
            await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        await gesture.moveTo(tester.getCenter(find.byType(RichText)));
        await tester.pump();

        final spanA = findSpan('bbbbbbbbbbbb');
        expect(spanA?.style?.color, const Color(0xFF333333));

        await gesture.removePointer();

        tapDownSpan(spanA);
        await tester.pump();

        final spanB = findSpan('bbbbbbbbbbbb');
        expect(spanB?.style?.color, const Color(0xFF222222));
      },
    );
  });
}
