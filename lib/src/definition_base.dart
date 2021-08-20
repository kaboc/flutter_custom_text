import 'package:meta/meta.dart';

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import 'package:text_parser/text_parser.dart';

@immutable
abstract class Definition {
  const Definition({
    required this.matcher,
    this.labelSelector,
    this.tapSelector,
    this.builder,
    this.matchStyle,
    this.tapStyle,
    this.hoverStyle,
    this.onTap,
    this.onLongPress,
    this.mouseCursor,
  });

  final TextMatcher matcher;
  final String Function(List<String?>)? labelSelector;
  final String Function(List<String?>)? tapSelector;
  final InlineSpan Function(String, List<String?>)? builder;
  final TextStyle? matchStyle;
  final TextStyle? tapStyle;
  final TextStyle? hoverStyle;
  final void Function(String)? onTap;
  final void Function(String)? onLongPress;
  final MouseCursor? mouseCursor;
}
