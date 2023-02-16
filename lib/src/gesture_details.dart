import 'dart:ui';

import 'package:meta/meta.dart';

enum GestureType { tap, longPress, secondaryTap, tertiaryTap, enter, exit }

/// A class with details on a gesture and the element where
/// the gesture was detected.
@immutable
class GestureDetails {
  /// Creates a [GestureDetails] containing details on a gesture
  /// and the element where the gesture was detected.
  const GestureDetails({
    required this.gestureType,
    required this.matcherType,
    required this.label,
    required this.text,
    this.globalPosition = Offset.zero,
    this.localPosition = Offset.zero,
  });

  /// The type of the gesture that this details information is about.
  final GestureType gestureType;

  /// The text matcher type of a text element.
  final Type matcherType;

  /// The text to display.
  final String label;

  /// The text to be passed to gesture callbacks.
  final String text;

  /// The global position where a gesture was detected.
  final Offset globalPosition;

  /// The local position where a gesture was detected.
  final Offset localPosition;
}
