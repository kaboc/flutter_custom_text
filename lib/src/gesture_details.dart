import 'dart:ui';

import 'package:meta/meta.dart';
import 'package:text_parser/text_parser.dart' show TextElement;

enum GestureKind { tap, longPress, secondaryTap, tertiaryTap, enter, exit }

/// A class with details on a gesture and the element where
/// the gesture was detected.
@immutable
class GestureDetails {
  /// Creates a [GestureDetails] containing details on a gesture
  /// and the element where the gesture was detected.
  const GestureDetails({
    required this.gestureKind,
    required this.pointerDeviceKind,
    required this.element,
    required this.label,
    required this.text,
    this.globalPosition = Offset.zero,
    this.localPosition = Offset.zero,
  });

  /// The kind of the gesture that this details information is about.
  final GestureKind gestureKind;

  /// The kind of pointer.
  final PointerDeviceKind pointerDeviceKind;

  /// The text element where the gesture happened.
  final TextElement element;

  /// The text to display.
  final String label;

  /// The text to be passed to gesture callbacks.
  final String text;

  /// The global position where a gesture was detected.
  final Offset globalPosition;

  /// The local position where a gesture was detected.
  final Offset localPosition;
}
