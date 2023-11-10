import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'widget_utils.dart';
import 'widgets.dart';

void main() {
  setUp(reset);

  group('SpanDefinition', () {
    testWidgets(
      'SpanDefinition passes correct text and groups to builder',
      (tester) async {
        await tester.pumpWidget(
          SpanCustomTextWidget(
            '[bbb](ccc)',
            definitions: [
              SpanDefinition(
                matcher: const LinkMatcher(),
                builder: (text, groups) => TextSpan(
                  children: [
                    TextSpan(text: text),
                    for (var i = 0; i < groups.length; i++)
                      TextSpan(text: '$i: ${groups[i]}'),
                  ],
                ),
              ),
            ],
          ),
        );
        await tester.pump();

        final spans = getInlineSpans();
        expect(spans[0].toPlainText(), '[bbb](ccc)');
        expect(spans[1].toPlainText(), '0: bbb');
        expect(spans[2].toPlainText(), '1: ccc');
      },
    );
  });
}
