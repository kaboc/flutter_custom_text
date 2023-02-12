import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'utils.dart';
import 'widgets.dart';

void main() {
  setUp(reset);

  group('onTap and onLongPress', () {
    testWidgets(
      'Correct info is passed to onTap specified in CustomText',
      (tester) async {
        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: const SelectiveCustomTextWidget(
              'aaa[bbb](ccc)ddd',
              onTap: onTap,
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);
        await tester.tapAt(center);

        expect(gestureType, equals(GestureType.tap));
        expect(matcherType, equals(LinkMatcher));
        expect(labelText, equals('bbb'));
        expect(tappedText, equals('ccc'));
        expect(globalPosition, equals(center));
        expect(localPosition, equals(center - const Offset(10.0, 10.0)));
      },
    );

    testWidgets(
      'Correct info is passed to onLongPress specified in CustomText',
      (tester) async {
        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: const SelectiveCustomTextWidget(
              'aaa[bbb](ccc)ddd',
              onLongPress: onLongPress,
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);
        final gesture = await tester.startGesture(center);
        await tester.pump(kTestLongPressDuration);
        await gesture.up();

        expect(gestureType, equals(GestureType.longPress));
        expect(matcherType, equals(LinkMatcher));
        expect(labelText, equals('bbb'));
        expect(tappedText, equals('ccc'));
        expect(globalPosition, equals(center));
        expect(localPosition, equals(center - const Offset(10.0, 10.0)));
      },
    );

    testWidgets(
      'Correct info is passed to onTap specified in definition',
      (tester) async {
        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: const SelectiveCustomTextWidget(
              'aaa[bbb](ccc)ddd',
              onTapInDef: onTap,
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);
        await tester.tapAt(center);

        expect(gestureType, equals(GestureType.tap));
        expect(matcherType, equals(LinkMatcher));
        expect(labelText, equals('bbb'));
        expect(tappedText, equals('ccc'));
        expect(globalPosition, equals(center));
        expect(localPosition, equals(center - const Offset(10.0, 10.0)));
      },
    );

    testWidgets(
      'Correct info is passed to onLongPress specified in definition',
      (tester) async {
        await tester.pumpWidget(
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: const SelectiveCustomTextWidget(
              'aaa[bbb](ccc)ddd',
              onLongPressInDef: onLongPress,
            ),
          ),
        );
        await tester.pump();

        final center = tester.getCenter(find.byType(RichText).first);
        final gesture = await tester.startGesture(center);
        await tester.pump(kTestLongPressDuration);
        await gesture.up();

        expect(gestureType, equals(GestureType.longPress));
        expect(matcherType, equals(LinkMatcher));
        expect(labelText, equals('bbb'));
        expect(tappedText, equals('ccc'));
        expect(globalPosition, equals(center));
        expect(localPosition, equals(center - const Offset(10.0, 10.0)));
      },
    );
  });
}
