import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';
import 'widgets.dart';

void main() {
  setUp(() {
    isTap = isLongPress = false;
    matcherType = tappedText = null;
  });

  group('SpanDefinition', () {
    testWidgets(
      'SpanDefinition passes correct text and groups to builder',
      (tester) async {
        await tester.pumpWidget(
          const SpanCustomTextWidget2('[bbb](ccc)'),
        );
        await tester.pump();

        final spans = getSpans();
        expect((spans[0] as TextSpan).text, equals('[bbb](ccc)'));
        expect((spans[1] as TextSpan).text, equals('0: bbb'));
        expect((spans[2] as TextSpan).text, equals('1: ccc'));
      },
    );
  });
}
