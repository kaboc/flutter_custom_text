import 'package:flutter_test/flutter_test.dart';

import 'widget_utils.dart';
import 'widgets.dart';

void main() {
  setUp(reset);

  group('SpanDefinition', () {
    testWidgets(
      'SpanDefinition passes correct text and groups to builder',
      (tester) async {
        await tester.pumpWidget(
          const SpanCustomTextWidget2('[bbb](ccc)'),
        );
        await tester.pump();

        final spans = getSpans();
        expect(spans[0].toPlainText(), '[bbb](ccc)');
        expect(spans[1].toPlainText(), '0: bbb');
        expect(spans[2].toPlainText(), '1: ccc');
      },
    );
  });
}
