import 'dart:async' show Timer;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart'
    show PointerEnterEventListener, PointerEvent, PointerExitEventListener;

import '../gesture_details.dart';
import 'data.dart';

class GestureHandlers {
  final Map<int, GestureHandler> _handlers = {};
  HoverState _hoverState = HoverState();

  @visibleForTesting
  Map<int, GestureHandler> get map => Map.unmodifiable(_handlers);

  @visibleForTesting
  HoverState get hoverState => _hoverState;

  @visibleForTesting
  set hoverState(HoverState state) => _hoverState = state;

  void dispose() {
    _handlers
      ..forEach((_, handler) => handler.dispose())
      ..clear();
    _hoverState.reset();
  }

  void removeHandler({required int index}) {
    _handlers
      ..[index]?.dispose()
      ..remove(index);
  }

  // ignore: library_private_types_in_public_api
  GestureHandler prepareHandler({
    required SpansBuilderSettings settings,
    required SpanData spanData,
  }) {
    // This method is called frequently, so the existing handler
    // should be reused instead of created every time.
    return (_handlers[spanData.index] ??= GestureHandler())
      ..updateSettings(
        settings: settings,
        spanData: spanData,
        hoverState: _hoverState,
      );
  }
}

class GestureHandler {
  late SpansBuilderSettings _settings;
  late SpanData _spanData;
  late HoverState _hoverState;

  bool _disposed = false;
  bool _isPressEnabled = false;
  bool _isGestureEnabled = false;
  bool _isHoverEnabled = false;

  TapGestureRecognizer? _recognizer;
  Timer? _longPressTimer;

  TapGestureRecognizer? get recognizer => _recognizer;

  void dispose() {
    _disposed = true;
    _disposeRecognizer();
    _longPressTimer?.cancel();
  }

  void updateSettings({
    required SpansBuilderSettings settings,
    required SpanData spanData,
    required HoverState hoverState,
  }) {
    _settings = settings;
    _spanData = spanData;
    _hoverState = hoverState;

    _isPressEnabled = settings.onTap != null ||
        spanData.definition.onTap != null ||
        settings.onLongPress != null ||
        spanData.definition.onLongPress != null;

    _isGestureEnabled =
        settings.onGesture != null || spanData.definition.onGesture != null;

    _isHoverEnabled = _isGestureEnabled ||
        spanData.definition.hoverStyle != null ||
        settings.hoverStyle != null;

    if (_isPressEnabled || _isGestureEnabled) {
      _configureRecognizer();
    } else {
      _disposeRecognizer();
    }
  }

  void _disposeRecognizer() {
    _recognizer?.dispose();
    _recognizer = null;
  }

  void _configureRecognizer() {
    // This method is called frequently, so the existing recognizer
    // should be reused instead of created each time.
    _recognizer ??= TapGestureRecognizer();

    _recognizer
      ?..onTapDown = _onTapDown
      ..onTapUp = _onTapUp
      ..onTapCancel = _onTapCancel
      ..onSecondaryTapUp = _onSecondaryTapUp
      ..onTertiaryTapUp = _onTertiaryTapUp;
  }

  GestureTapDownCallback? get _onTapDown => _isPressEnabled
      ? (tapDownDetails) {
          final details = GestureDetails(
            gestureKind: GestureKind.longPress,
            pointerDeviceKind: tapDownDetails.kind ?? PointerDeviceKind.unknown,
            element: _spanData.element,
            shownText: _spanData.shownText ?? _spanData.text,
            actionText: _spanData.actionText ?? _spanData.text,
            globalPosition: tapDownDetails.globalPosition,
            localPosition: tapDownDetails.localPosition,
          );

          if (_spanData.definition.onLongPress != null) {
            _longPressTimer = Timer(
              _settings.longPressDuration,
              () => _spanData.definition.onLongPress!(details),
            );
          } else if (_settings.onLongPress != null) {
            _longPressTimer = Timer(
              _settings.longPressDuration,
              () => _settings.onLongPress?.call(details),
            );
          }

          _spanData.onTapDown?.call(_spanData);
        }
      : null;

  GestureTapUpCallback? get _onTapUp => _isPressEnabled
      ? (tapUpDetails) {
          final timer = _longPressTimer;

          // A tap is valid if long presses are not enabled or
          // if the press was shorter than longPressDuration
          // and thus the timer is still active.
          if (timer == null || timer.isActive) {
            final details = GestureDetails(
              gestureKind: GestureKind.tap,
              pointerDeviceKind: tapUpDetails.kind,
              element: _spanData.element,
              shownText: _spanData.shownText ?? _spanData.text,
              actionText: _spanData.actionText ?? _spanData.text,
              globalPosition: tapUpDetails.globalPosition,
              localPosition: tapUpDetails.localPosition,
            );

            if (_spanData.definition.onTap != null) {
              _spanData.definition.onTap!(details);
            } else {
              _settings.onTap?.call(details);
            }
          }

          _recognizer?.onTapCancel?.call();
        }
      : null;

  GestureTapCancelCallback? get _onTapCancel => _isPressEnabled
      ? () {
          _longPressTimer?.cancel();
          _longPressTimer = null;

          _spanData.onTapCancel?.call(_spanData);
        }
      : null;

  GestureTapUpCallback? get _onSecondaryTapUp => _isGestureEnabled
      ? (details) => _onGesture(
            gestureKind: GestureKind.secondaryTap,
            pointerDeviceKind: details.kind,
            globalPosition: details.globalPosition,
            localPosition: details.localPosition,
          )
      : null;

  GestureTapUpCallback? get _onTertiaryTapUp => _isGestureEnabled
      ? (details) => _onGesture(
            gestureKind: GestureKind.tertiaryTap,
            pointerDeviceKind: details.kind,
            globalPosition: details.globalPosition,
            localPosition: details.localPosition,
          )
      : null;

  PointerEnterEventListener? get onEnter => _isHoverEnabled
      ? (event) => _onHover(
            event: event,
            gestureKind: GestureKind.enter,
          )
      : null;

  PointerExitEventListener? get onExit => _isHoverEnabled
      ? (event) => _onHover(
            event: event,
            gestureKind: GestureKind.exit,
          )
      : null;

  void _onGesture({
    required GestureKind gestureKind,
    required PointerDeviceKind pointerDeviceKind,
    required Offset globalPosition,
    required Offset localPosition,
  }) {
    final details = GestureDetails(
      gestureKind: gestureKind,
      pointerDeviceKind: pointerDeviceKind,
      element: _spanData.element,
      shownText: _spanData.shownText ?? _spanData.text,
      actionText: _spanData.actionText ?? _spanData.text,
      globalPosition: globalPosition,
      localPosition: localPosition,
    );

    if (_spanData.definition.onGesture != null) {
      _spanData.definition.onGesture?.call(details);
    } else {
      _settings.onGesture?.call(details);
    }
  }

  void _onHover({
    required PointerEvent event,
    required GestureKind gestureKind,
  }) {
    if (_disposed) {
      return;
    }

    final index = _spanData.index;

    // This method is called for various reasons. A sequence of
    // exit and enter events or even of the same events happens
    // once or more within a very short period of time. Therefore
    // handling of events needs to be debounced.
    _hoverState.debounceTimers
      ..[index]?.cancel()
      ..remove(index);

    if (index == _hoverState.index && gestureKind == _hoverState.gestureKind) {
      // A new timer must not be started after the cancel above
      // if the gesture kind has not changed because the handler
      // for the same gesture kind was already executed and thus
      // duplicate executions need be prevented.
      // (`lastGestureKind` is updated in the timer callback,
      // so having the same gesture kind indicates that a timer
      // for that kind has already been completed.)
      return;
    }

    _hoverState.debounceTimers[index] = Timer(
      // Duration of zero time does not mean this timer is meaningless.
      Duration.zero,
      () {
        _hoverState
          ..debounceTimers.remove(index)
          ..index = gestureKind == GestureKind.exit ? null : index
          ..gestureKind = gestureKind;

        if (_isHoverEnabled) {
          gestureKind == GestureKind.enter
              ? _spanData.onMouseEnter?.call(event, _spanData)
              : _spanData.onMouseExit?.call(event, _spanData);
        }

        _onGesture(
          gestureKind: gestureKind,
          pointerDeviceKind: event.kind,
          globalPosition: event.position,
          localPosition: event.localPosition,
        );
      },
    );
  }
}
