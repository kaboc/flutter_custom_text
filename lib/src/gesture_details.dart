import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/gestures.dart' show Offset, PointerDeviceKind;

import 'package:text_parser/text_parser.dart' show TextElement;

/// The kind of a gesture event.
enum GestureKind {
  /// A tap/short press of the primary button.
  tap,

  /// A long press of the primary button.
  longPress,

  /// A tap/press of the secondary button.
  secondaryTap,

  /// A tap/press of the tertiary button.
  tertiaryTap,

  /// An enter of the mouse pointer to a region.
  enter,

  /// An exit of the mouse pointer from a region.
  exit,
}

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
    required this.shownText,
    required this.actionText,
    this.globalPosition = Offset.zero,
    this.localPosition = Offset.zero,
  });

  /// The kind of the gesture that this details information is about.
  final GestureKind gestureKind;

  /// The kind of pointer.
  final PointerDeviceKind pointerDeviceKind;

  /// The text element where the gesture happened.
  final TextElement element;

  /// The string to display.
  final String shownText;

  /// The string to be passed to gesture callbacks and used basically
  /// for some action.
  final String actionText;

  /// The global position where a gesture was detected.
  final Offset globalPosition;

  /// The local position where a gesture was detected.
  final Offset localPosition;
}
