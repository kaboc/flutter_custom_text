import 'dart:async' show Timer;

import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:custom_text/custom_text.dart';

import 'package:custom_text/src/text_span/data.dart';
import 'package:custom_text/src/text_span/gesture_handler.dart';

void main() {
  late HoverState hoverState;

  setUp(() => hoverState = HoverState());
  tearDown(() => hoverState.reset());

  SpanData createSpanData({
    required int index,
    void Function(PointerEvent, SpanData)? onMouseEvent,
  }) {
    return SpanData(
      index: index,
      element: const TextElement(''),
      text: '',
      shownText: '',
      actionText: '',
      definition: const TextDefinition(matcher: PatternMatcher('')),
      onTapDown: (_) {},
      onTapCancel: (_) {},
      onMouseEnter: onMouseEvent ?? (_, __) {},
      onMouseExit: onMouseEvent ?? (_, __) {},
    );
  }

  group('GestureHandlers', () {
    test('prepareHandler() adds a Map field', () {
      final handlers = GestureHandlers();
      addTearDown(handlers.dispose);

      expect(handlers.map, isEmpty);

      handlers.prepareHandler(
        settings: NotifierSettings(definitions: []),
        spanData: createSpanData(index: 10),
      );

      final map = handlers.map;
      expect(map, hasLength(1));
      expect(map[10], isNotNull);
    });

    test('removeHandler() removes a Map field', () {
      final handlers = GestureHandlers();
      addTearDown(handlers.dispose);

      handlers
        ..prepareHandler(
          settings: NotifierSettings(definitions: []),
          spanData: createSpanData(index: 10),
        )
        ..prepareHandler(
          settings: NotifierSettings(definitions: []),
          spanData: createSpanData(index: 20),
        );
      expect(handlers.map, hasLength(2));

      handlers.removeHandler(index: 10);
      expect(handlers.map, hasLength(1));
    });

    test('dispose() removes all handlers and resets hover state', () {
      final handlers = GestureHandlers();
      addTearDown(handlers.dispose);

      handlers
        ..hoverState = (hoverState..index = 10)
        ..prepareHandler(
          settings: NotifierSettings(
            definitions: [],
            hoverStyle: const TextStyle(),
          ),
          spanData: createSpanData(index: 10),
        )
        ..prepareHandler(
          settings: NotifierSettings(definitions: []),
          spanData: createSpanData(index: 20),
        );
      expect(handlers.map, hasLength(2));
      expect(handlers.hoverState.index, 10);

      handlers.dispose();
      expect(handlers.map, isEmpty);
      expect(handlers.hoverState.index, isNull);
    });

    test('Handler is reused if one for the same index already exists', () {
      final handlers = GestureHandlers();
      addTearDown(handlers.dispose);

      final handler1 = handlers.prepareHandler(
        settings: NotifierSettings(definitions: []),
        spanData: createSpanData(index: 10),
      );
      expect(handler1.recognizer, isNull);

      final handler2 = handlers.prepareHandler(
        settings: NotifierSettings(
          definitions: [],
          onTap: (_) {},
        ),
        spanData: createSpanData(index: 10),
      );
      expect(handler2.recognizer, isNotNull);
      expect(handler2, handler1);
    });
  });

  group('Gesture recognizer and updateSettings()', () {
    test('Tap handlers are available if press is enabled', () {
      final handler1 = GestureHandler();
      final handler2 = GestureHandler();
      addTearDown(handler1.dispose);
      addTearDown(handler2.dispose);

      handler1.updateSettings(
        settings: NotifierSettings(
          definitions: [],
          hoverStyle: const TextStyle(),
          onGesture: (_) {},
        ),
        spanData: createSpanData(index: 10),
        hoverState: hoverState,
      );

      expect(handler1.recognizer!.onTapDown, isNull);
      expect(handler1.recognizer!.onTapUp, isNull);
      expect(handler1.recognizer!.onTapCancel, isNull);

      handler2.updateSettings(
        settings: NotifierSettings(
          definitions: [],
          onTap: (_) {},
        ),
        spanData: createSpanData(index: 20),
        hoverState: hoverState,
      );

      expect(handler2.recognizer?.onTapDown, isNotNull);
      expect(handler2.recognizer?.onTapUp, isNotNull);
      expect(handler2.recognizer?.onTapCancel, isNotNull);
    });

    test(
      'Secondary/tertiary tap handlers are available if gesture is enabled.',
      () {
        final handler1 = GestureHandler();
        final handler2 = GestureHandler();
        addTearDown(handler1.dispose);
        addTearDown(handler2.dispose);

        handler1.updateSettings(
          settings: NotifierSettings(
            definitions: [],
            onTap: (_) {},
            onLongPress: (_) {},
            hoverStyle: const TextStyle(),
          ),
          spanData: createSpanData(index: 10),
          hoverState: hoverState,
        );

        expect(handler1.recognizer!.onSecondaryTapUp, isNull);
        expect(handler1.recognizer!.onTertiaryTapUp, isNull);

        handler2.updateSettings(
          settings: NotifierSettings(
            definitions: [],
            onGesture: (_) {},
          ),
          spanData: createSpanData(index: 20),
          hoverState: hoverState,
        );

        expect(handler2.recognizer?.onSecondaryTapUp, isNotNull);
        expect(handler2.recognizer?.onTertiaryTapUp, isNotNull);
      },
    );

    test('updateSettings() updates settings and recognizer of handler', () {
      final handler = GestureHandler();
      addTearDown(handler.dispose);

      handler.updateSettings(
        settings: NotifierSettings(
          definitions: [],
          onTap: (_) {},
        ),
        spanData: createSpanData(index: 10),
        hoverState: hoverState,
      );
      final recognizerHashCode = handler.recognizer?.hashCode;

      expect(recognizerHashCode, isNotNull);
      expect(handler.recognizer?.onTapDown, isNotNull);
      expect(handler.recognizer!.onSecondaryTapUp, isNull);

      handler.updateSettings(
        settings: NotifierSettings(
          definitions: [],
          onGesture: (_) {},
        ),
        spanData: createSpanData(index: 10),
        hoverState: hoverState,
      );

      expect(handler.recognizer?.hashCode, recognizerHashCode);
      expect(handler.recognizer!.onTapDown, isNull);
      expect(handler.recognizer?.onSecondaryTapUp, isNotNull);
    });

    test(
      'UpdateSettings() disposes of recognizer if only hover is enabled',
      () {
        final handler = GestureHandler();
        addTearDown(handler.dispose);

        handler.updateSettings(
          settings: NotifierSettings(
            definitions: [],
            onTap: (_) {},
          ),
          spanData: createSpanData(index: 10),
          hoverState: hoverState,
        );

        expect(handler.recognizer?.onTapDown, isNotNull);
        expect(handler.onEnter, isNull);

        handler.updateSettings(
          settings: NotifierSettings(
            definitions: [],
            hoverStyle: const TextStyle(),
          ),
          spanData: createSpanData(index: 10),
          hoverState: hoverState,
        );

        expect(handler.recognizer, isNull);
        expect(handler.onEnter, isNotNull);
      },
    );
  });

  group('Availability of mouse enter and exit handlers', () {
    test(
      'Enter/exit handlers are unavailable if gesture/hover are not enabled.',
      () {
        final handler = GestureHandler();
        addTearDown(handler.dispose);

        handler.updateSettings(
          settings: NotifierSettings(
            definitions: [],
            onTap: (_) {},
            onLongPress: (_) {},
          ),
          spanData: createSpanData(index: 10),
          hoverState: hoverState,
        );

        expect(handler.onEnter, isNull);
        expect(handler.onExit, isNull);
      },
    );

    test('Enter/exit handlers are available if gesture is enabled.', () {
      final handler = GestureHandler();
      addTearDown(handler.dispose);

      handler.updateSettings(
        settings: NotifierSettings(
          definitions: [],
          onGesture: (_) {},
        ),
        spanData: createSpanData(index: 10),
        hoverState: hoverState,
      );

      expect(handler.onEnter, isNotNull);
      expect(handler.onExit, isNotNull);
    });

    test('Enter/exit handlers are available if hover is enabled.', () {
      final handler = GestureHandler();
      addTearDown(handler.dispose);

      handler.updateSettings(
        settings: NotifierSettings(
          definitions: [],
          hoverStyle: const TextStyle(),
        ),
        spanData: createSpanData(index: 10),
        hoverState: hoverState,
      );

      expect(handler.onEnter, isNotNull);
      expect(handler.onExit, isNotNull);
    });
  });

  group('_onHover()', () {
    group('Updates of state and calls to gesture/hover handlers', () {
      final hoverIndexes = <int>[];
      final gestureKinds = <GestureKind>[];

      tearDown(() {
        hoverIndexes.clear();
        gestureKinds.clear();
      });

      final settings = NotifierSettings(
        definitions: [],
        hoverStyle: const TextStyle(),
        onGesture: (details) => gestureKinds.add(details.gestureKind),
      );

      void onMouseEvent(PointerEvent event, SpanData spanData) {
        hoverIndexes.add(spanData.index);
      }

      test(
        'State is updated and handlers are called in an instant '
        'after _onHover() is called on mouse enter',
        () async {
          final handler = GestureHandler();
          addTearDown(handler.dispose);

          handler.updateSettings(
            settings: settings,
            spanData: createSpanData(index: 10, onMouseEvent: onMouseEvent),
            hoverState: hoverState,
          );
          expect(hoverState.index, isNull);

          handler.onEnter?.call(
            const PointerEnterEvent(kind: PointerDeviceKind.mouse),
          );
          expect(hoverState.index, isNull);
          expect(hoverState.gestureKind, isNull);
          expect(hoverIndexes, isEmpty);
          expect(gestureKinds, isEmpty);

          await Future<void>.delayed(Duration.zero);
          expect(hoverState.index, 10);
          expect(hoverState.gestureKind, GestureKind.enter);
          expect(hoverIndexes, [10]);
          expect(gestureKinds, [GestureKind.enter]);
        },
      );

      test(
        'State is updated with last index as null and handlers are '
        'called in an instant after _onHover() is called on mouse exit',
        () async {
          final handler = GestureHandler();
          addTearDown(handler.dispose);

          handler.updateSettings(
            settings: settings,
            spanData: createSpanData(index: 10, onMouseEvent: onMouseEvent),
            hoverState: hoverState
              ..index = 10
              ..gestureKind = GestureKind.enter,
          );

          handler.onExit?.call(
            const PointerExitEvent(kind: PointerDeviceKind.mouse),
          );
          expect(hoverState.index, 10);
          expect(hoverState.gestureKind, GestureKind.enter);
          expect(hoverIndexes, isEmpty);
          expect(gestureKinds, isEmpty);

          await Future<void>.delayed(Duration.zero);
          expect(hoverState.index, isNull);
          expect(hoverState.gestureKind, GestureKind.exit);
          expect(hoverIndexes, [10]);
          expect(gestureKinds, [GestureKind.exit]);
        },
      );

      test(
        'No change in state and no calls to handlers if _onHover is called '
        'by sequence of exit and enter without wait when last kind is enter',
        () async {
          final handler = GestureHandler();
          addTearDown(handler.dispose);

          handler.updateSettings(
            settings: settings,
            spanData: createSpanData(index: 10, onMouseEvent: onMouseEvent),
            hoverState: hoverState
              ..index = 10
              ..gestureKind = GestureKind.enter,
          );

          handler.onExit?.call(
            const PointerExitEvent(kind: PointerDeviceKind.mouse),
          );
          expect(hoverState.index, 10);
          expect(hoverState.gestureKind, GestureKind.enter);
          expect(hoverIndexes, isEmpty);
          expect(gestureKinds, isEmpty);

          handler.onEnter?.call(
            const PointerEnterEvent(kind: PointerDeviceKind.mouse),
          );
          expect(hoverState.index, 10);
          expect(hoverState.gestureKind, GestureKind.enter);
          expect(hoverIndexes, isEmpty);
          expect(gestureKinds, isEmpty);

          await Future<void>.delayed(Duration.zero);
          expect(hoverState.index, 10);
          expect(hoverState.gestureKind, GestureKind.enter);
          expect(hoverIndexes, isEmpty);
          expect(gestureKinds, isEmpty);
        },
      );

      test(
        'No change in state and no calls to handlers if _onHover is called '
        'by sequence of enter and exit without wait when last kind is exit',
        () async {
          final handler = GestureHandler();
          addTearDown(handler.dispose);

          handler.updateSettings(
            settings: settings,
            spanData: createSpanData(index: 10, onMouseEvent: onMouseEvent),
            hoverState: hoverState
              ..index = 10
              ..gestureKind = GestureKind.exit,
          );

          handler.onEnter?.call(
            const PointerEnterEvent(kind: PointerDeviceKind.mouse),
          );
          expect(hoverState.index, 10);
          expect(hoverState.gestureKind, GestureKind.exit);
          expect(hoverIndexes, isEmpty);
          expect(gestureKinds, isEmpty);

          handler.onExit?.call(
            const PointerExitEvent(kind: PointerDeviceKind.mouse),
          );
          expect(hoverState.index, 10);
          expect(hoverState.gestureKind, GestureKind.exit);
          expect(hoverIndexes, isEmpty);
          expect(gestureKinds, isEmpty);

          await Future<void>.delayed(Duration.zero);
          expect(hoverState.index, 10);
          expect(hoverState.gestureKind, GestureKind.exit);
          expect(hoverIndexes, isEmpty);
          expect(gestureKinds, isEmpty);
        },
      );

      test(
        'Handlers are called due to both previous and current events if '
        'two sequential events occur and their indexes are different',
        () async {
          final handler1 = GestureHandler();
          final handler2 = GestureHandler();
          addTearDown(handler1.dispose);
          addTearDown(handler2.dispose);

          handler1.updateSettings(
            settings: settings,
            spanData: createSpanData(index: 10, onMouseEvent: onMouseEvent),
            hoverState: hoverState,
          );
          handler2.updateSettings(
            settings: settings,
            spanData: createSpanData(index: 20, onMouseEvent: onMouseEvent),
            hoverState: hoverState,
          );

          handler1.onExit?.call(
            const PointerExitEvent(kind: PointerDeviceKind.mouse),
          );
          expect(hoverState.index, isNull);
          expect(hoverState.gestureKind, isNull);
          expect(hoverIndexes, isEmpty);
          expect(gestureKinds, isEmpty);

          handler2.onEnter?.call(
            const PointerEnterEvent(kind: PointerDeviceKind.mouse),
          );
          expect(hoverState.index, isNull);
          expect(hoverState.gestureKind, isNull);
          expect(hoverIndexes, isEmpty);
          expect(gestureKinds, isEmpty);

          await Future<void>.delayed(Duration.zero);
          expect(hoverState.index, 20);
          expect(hoverState.gestureKind, GestureKind.enter);
          expect(hoverIndexes, [10, 20]);
          expect(gestureKinds, [GestureKind.exit, GestureKind.enter]);
        },
      );
    });

    group('Timers to debounce handling of hover events', () {
      final settings = NotifierSettings(
        definitions: [],
        hoverStyle: const TextStyle(),
      );

      test(
        'Timer is restarted when _onHover() for is consecutively called '
        'for same index without wait while last index is null',
        () {
          final handler = GestureHandler();
          addTearDown(handler.dispose);

          handler.updateSettings(
            settings: settings,
            spanData: createSpanData(index: 10),
            hoverState: hoverState,
          );

          // Enter
          handler.onEnter?.call(
            const PointerEnterEvent(kind: PointerDeviceKind.mouse),
          );

          final timer1 = hoverState.debounceTimers[10];
          expect(timer1?.isActive, isTrue);

          // Enter (same as previous)
          handler.onEnter?.call(
            const PointerEnterEvent(kind: PointerDeviceKind.mouse),
          );

          final timer2 = hoverState.debounceTimers[10];
          expect(timer1?.isActive, isFalse);
          expect(timer2?.isActive, isTrue);

          // Exit (different from previous)
          handler.onExit?.call(
            const PointerExitEvent(kind: PointerDeviceKind.mouse),
          );

          final timer3 = hoverState.debounceTimers[10];
          expect(timer2?.isActive, isFalse);
          expect(timer3?.isActive, isTrue);
        },
      );

      test(
        'Timer is not cancelled when _onHover() is consecutively called '
        'for different indexes without wait',
        () {
          final handler1 = GestureHandler();
          final handler2 = GestureHandler();
          addTearDown(handler1.dispose);
          addTearDown(handler2.dispose);

          handler1
            ..updateSettings(
              settings: settings,
              spanData: createSpanData(index: 10),
              hoverState: hoverState,
            )
            ..onEnter?.call(
              const PointerEnterEvent(kind: PointerDeviceKind.mouse),
            );

          handler2
            ..updateSettings(
              settings: settings,
              spanData: createSpanData(index: 20),
              hoverState: hoverState,
            )
            ..onEnter?.call(
              const PointerEnterEvent(kind: PointerDeviceKind.mouse),
            );

          final timer1 = hoverState.debounceTimers[10];
          final timer2 = hoverState.debounceTimers[20];
          expect(timer1?.isActive, isTrue);
          expect(timer2?.isActive, isTrue);
        },
      );

      test(
        'Timer is cancelled and not restarted when _onHover() is called '
        'on mouse enter while timer for last enter event is active',
        () {
          final handler = GestureHandler();
          addTearDown(handler.dispose);

          handler.updateSettings(
            settings: settings,
            spanData: createSpanData(index: 10),
            hoverState: hoverState
              ..index = 10
              ..gestureKind = GestureKind.enter
              ..debounceTimers[10] = Timer(const Duration(hours: 10), () {}),
          );

          handler.onEnter?.call(
            const PointerEnterEvent(kind: PointerDeviceKind.mouse),
          );
          expect(hoverState.debounceTimers[10], isNull);
        },
      );

      test(
        'Timer is cancelled and not restarted when _onHover() is called '
        'on mouse exit while timer for last exit event is active',
        () {
          final handler = GestureHandler();
          addTearDown(handler.dispose);

          handler.updateSettings(
            settings: settings,
            spanData: createSpanData(index: 10),
            hoverState: hoverState
              ..index = 10
              ..gestureKind = GestureKind.exit
              ..debounceTimers[10] = Timer(const Duration(hours: 10), () {}),
          );

          handler.onExit?.call(
            const PointerExitEvent(kind: PointerDeviceKind.mouse),
          );
          expect(hoverState.debounceTimers[10], isNull);
        },
      );

      test(
        'Timer is restarted when _onHover() is called on mouse exit '
        'while timer for last enter event is active',
        () {
          final handler = GestureHandler();
          addTearDown(handler.dispose);

          handler.updateSettings(
            settings: settings,
            spanData: createSpanData(index: 10),
            hoverState: hoverState
              ..index = 10
              ..gestureKind = GestureKind.enter
              ..debounceTimers[10] = Timer(const Duration(hours: 10), () {}),
          );

          final timer1 = hoverState.debounceTimers[10];

          handler.onExit?.call(
            const PointerExitEvent(kind: PointerDeviceKind.mouse),
          );

          final timer2 = hoverState.debounceTimers[10];

          expect(timer1?.isActive, isFalse);
          expect(timer2?.isActive, isTrue);
        },
      );

      test(
        'Timer is restarted when _onHover() is called on mouse enter '
        'while timer for last exit event is active',
        () {
          final handler = GestureHandler();
          addTearDown(handler.dispose);

          handler.updateSettings(
            settings: settings,
            spanData: createSpanData(index: 10),
            hoverState: hoverState
              ..index = 10
              ..gestureKind = GestureKind.exit
              ..debounceTimers[10] = Timer(const Duration(hours: 10), () {}),
          );

          final timer1 = hoverState.debounceTimers[10];

          handler.onEnter?.call(
            const PointerEnterEvent(kind: PointerDeviceKind.mouse),
          );

          final timer2 = hoverState.debounceTimers[10];

          expect(timer1?.isActive, isFalse);
          expect(timer2?.isActive, isTrue);
        },
      );
    });
  });
}
