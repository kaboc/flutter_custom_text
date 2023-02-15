part of 'text_span_notifier.dart';

extension on CustomTextSpanNotifier {
  void _configureRecognizer({
    required SpanData spanData,
    required TextStyle? style,
  }) {
    // Reuses the tap recognizer instead of discarding
    // the previous one and creating a new one.
    _tapRecognizers[spanData.index] ??= TapGestureRecognizer();

    if (_settings.onTap != null ||
        spanData.definition.onTap != null ||
        _settings.onLongPress != null ||
        spanData.definition.onLongPress != null) {
      _tapRecognizers[spanData.index]
        ?..onTapDown = (details) {
          _onTapDown(
            spanData: spanData,
            globalPosition: details.globalPosition,
            localPosition: details.localPosition,
          );
        }
        ..onTapUp = (details) {
          _onTapUp(
            spanData: spanData,
            globalPosition: details.globalPosition,
            localPosition: details.localPosition,
          );
        }
        ..onTapCancel = () {
          _longPressTimer?.cancel();
          _longPressTimer = null;

          _updateTapIndex(
            spanData: spanData,
            tapped: false,
          );
        };
    }

    if (_settings.onGesture != null || spanData.definition.onGesture != null) {
      _tapRecognizers[spanData.index]
        ?..onSecondaryTapUp = (details) {
          _onGesture(
            spanData: spanData,
            gestureType: GestureType.secondaryTap,
            globalPosition: details.globalPosition,
            localPosition: details.localPosition,
          );
        }
        ..onTertiaryTapUp = (details) {
          _onGesture(
            spanData: spanData,
            gestureType: GestureType.tertiaryTap,
            globalPosition: details.globalPosition,
            localPosition: details.localPosition,
          );
        };
    }
  }

  void _onTapDown({
    required SpanData spanData,
    required Offset globalPosition,
    required Offset localPosition,
  }) {
    final details = GestureDetails(
      gestureType: GestureType.longPress,
      matcherType: spanData.definition.matcher.runtimeType,
      text: spanData.link,
      label: spanData.label,
      globalPosition: globalPosition,
      localPosition: localPosition,
    );

    if (spanData.definition.onLongPress != null) {
      _longPressTimer = Timer(
        _settings.longPressDuration,
        () => spanData.definition.onLongPress!(details),
      );
    } else if (_settings.onLongPress != null) {
      _longPressTimer = Timer(
        _settings.longPressDuration,
        () => _settings.onLongPress?.call(details),
      );
    }

    _updateTapIndex(spanData: spanData, tapped: true);
  }

  void _onTapUp({
    required SpanData spanData,
    required Offset globalPosition,
    required Offset localPosition,
  }) {
    final timer = _longPressTimer;

    // A tap is valid if long presses are not enabled
    // or if the press was shorter than a long press and
    // therefore the timer is still active.
    if (timer == null || timer.isActive) {
      final details = GestureDetails(
        gestureType: GestureType.tap,
        matcherType: spanData.definition.matcher.runtimeType,
        text: spanData.link,
        label: spanData.label,
        globalPosition: globalPosition,
        localPosition: localPosition,
      );

      if (spanData.definition.onTap != null) {
        spanData.definition.onTap!(details);
      } else if (_settings.onTap != null) {
        _settings.onTap?.call(details);
      }
    }

    _tapRecognizers[spanData.index]?.onTapCancel!();
  }

  void _onGesture({
    required SpanData spanData,
    required GestureType gestureType,
    required Offset globalPosition,
    required Offset localPosition,
  }) {
    final details = GestureDetails(
      gestureType: gestureType,
      matcherType: spanData.definition.matcher.runtimeType,
      text: spanData.link,
      label: spanData.label,
      globalPosition: globalPosition,
      localPosition: localPosition,
    );

    if (spanData.definition.onGesture != null) {
      spanData.definition.onGesture?.call(details);
    } else if (_settings.onGesture != null) {
      _settings.onGesture?.call(details);
    }
  }

  void _onHover({
    required SpanData spanData,
    required GestureType gestureType,
    required Offset globalPosition,
    required Offset localPosition,
    required bool styling,
  }) {
    if (styling) {
      _updateHoverIndex(
        spanData: spanData,
        hovered: gestureType == GestureType.enter,
        globalPosition: globalPosition,
      );
    }

    if (_tapIndex == null) {
      _onGesture(
        spanData: spanData,
        gestureType: gestureType,
        globalPosition: globalPosition,
        localPosition: localPosition,
      );
    }
  }
}
