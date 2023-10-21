import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import '../gesture_details.dart';
import 'data.dart';

class GestureHandler {
  late NotifierSettings _settings;
  late SpanData _spanData;
  TextStyle? _hoverStyle;
  VoidCallback? _onTapDown;
  VoidCallback? _onTapCancel;
  ValueChanged<PointerEvent>? _onMouseEnter;
  ValueChanged<PointerEvent>? _onMouseExit;

  bool _disposed = false;
  bool _pressEnabled = false;
  bool _gestureEnabled = false;
  bool _hoverEnabled = false;

  TapGestureRecognizer? _recognizer;
  Timer? _longPressTimer;

  // For workaround to skip unwanted events in _onHover()
  Timer? _hoverHandlerDebounceTimer;
  int? _enterOrExitIndex;
  GestureKind? _lastHoverGestureKind;

  TapGestureRecognizer? get recognizer => _recognizer;

  void dispose() {
    _disposed = true;

    _disposeRecognizer();
    _longPressTimer?.cancel();
    _hoverHandlerDebounceTimer?.cancel();
  }

  void updateSettings({
    required NotifierSettings settings,
    required SpanData spanData,
    required TextStyle? hoverStyle,
    VoidCallback? onTapDown,
    VoidCallback? onTapCancel,
    ValueChanged<PointerEvent>? onMouseEnter,
    ValueChanged<PointerEvent>? onMouseExit,
  }) {
    _settings = settings;
    _spanData = spanData;
    _hoverStyle = hoverStyle;
    _onTapDown = onTapDown;
    _onTapCancel = onTapCancel;
    _onMouseEnter = onMouseEnter;
    _onMouseExit = onMouseExit;

    _pressEnabled = settings.onTap != null ||
        spanData.definition.onTap != null ||
        settings.onLongPress != null ||
        spanData.definition.onLongPress != null;

    _gestureEnabled =
        settings.onGesture != null || spanData.definition.onGesture != null;

    _hoverEnabled = hoverStyle != null ||
        settings.onGesture != null ||
        spanData.definition.onGesture != null;

    if (_pressEnabled || _gestureEnabled) {
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
    // should be reused instead of created every time.
    _recognizer ??= TapGestureRecognizer();

    _recognizer
      ?..onTapDown = onTapDown
      ..onTapUp = onTapUp
      ..onTapCancel = onTapCancel
      ..onSecondaryTapUp = onSecondaryTapUp
      ..onTertiaryTapUp = onTertiaryTapUp;
  }

  GestureTapDownCallback? get onTapDown {
    return _pressEnabled
        ? (tapDownDetails) {
            final details = GestureDetails(
              gestureKind: GestureKind.longPress,
              pointerDeviceKind:
                  tapDownDetails.kind ?? PointerDeviceKind.unknown,
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

            _onTapDown?.call();
          }
        : null;
  }

  GestureTapUpCallback? get onTapUp => _pressEnabled
      ? (tapUpDetails) {
          final timer = _longPressTimer;

          // A tap is valid if long presses are not enabled
          // or if the press was shorter than a long press and
          // therefore the timer is still active.
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
            } else if (_settings.onTap != null) {
              _settings.onTap?.call(details);
            }
          }

          _recognizer?.onTapCancel?.call();
        }
      : null;

  GestureTapCancelCallback? get onTapCancel => _pressEnabled
      ? () {
          _longPressTimer?.cancel();
          _longPressTimer = null;

          _onTapCancel?.call();
        }
      : null;

  GestureTapUpCallback? get onSecondaryTapUp => _gestureEnabled
      ? (details) => _onGesture(
            gestureKind: GestureKind.secondaryTap,
            pointerDeviceKind: details.kind,
            globalPosition: details.globalPosition,
            localPosition: details.localPosition,
          )
      : null;

  GestureTapUpCallback? get onTertiaryTapUp => _gestureEnabled
      ? (details) => _onGesture(
            gestureKind: GestureKind.tertiaryTap,
            pointerDeviceKind: details.kind,
            globalPosition: details.globalPosition,
            localPosition: details.localPosition,
          )
      : null;

  PointerEnterEventListener? get onEnter => _hoverEnabled
      ? (event) => _onHover(
            event: event,
            gestureKind: GestureKind.enter,
          )
      : null;

  PointerExitEventListener? get onExit => _hoverEnabled
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
    } else if (_settings.onGesture != null) {
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

    void handleHover({required bool force}) {
      if (_hoverStyle != null) {
        gestureKind == GestureKind.enter
            ? _onMouseEnter?.call(event)
            : _onMouseExit?.call(event);
      }

      if (!force && gestureKind == _lastHoverGestureKind) {
        return;
      }
      _lastHoverGestureKind = gestureKind;
      _enterOrExitIndex = null;

      _onGesture(
        gestureKind: gestureKind,
        pointerDeviceKind: event.kind,
        globalPosition: event.position,
        localPosition: event.localPosition,
      );
    }

    // This method is called not only when the mouse pointer entered
    // and exited but also when the text span was rebuilt to update
    // the text style by a tap while the pointer was still on it.
    // In the latter case, a sequence of exit and enter happens once
    // or more within a very short period of time, causing unnecessary
    // calls to _updateHoverIndex() and _onGesture(). To avoid it,
    // those calls are debounced (i.e. the existing timer is cancelled
    // and a new timer is started), and also a call to _onGesture()
    // is skipped if the gesture kind is same as the last.
    //
    // As an exception, however, if an enter or exit event happens at
    // a different index, it is necessary to keep the existing timer
    // running to complete the scheduled operation for the previous
    // index (e.g. removing hoverStyle), and force a call to _onGesture()
    // as it is an event at the new index.
    final force = _spanData.index != _enterOrExitIndex;
    _enterOrExitIndex = _spanData.index;

    if (!force) {
      _hoverHandlerDebounceTimer?.cancel();
    }

    _hoverHandlerDebounceTimer = Timer(const Duration(microseconds: 1), () {
      handleHover(force: force);
    });
  }
}
