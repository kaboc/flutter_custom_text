import 'package:flutter/painting.dart';

import 'package:custom_text/custom_text.dart';

import 'package:custom_text_example/utils/highlight/language_parser.dart';

List<TextDefinition> jsonDefinitions({GestureCallback? onUrlTap}) {
  return [
    const TextDefinition(
      matcher: LiteralMatcher(),
      matchStyle: TextStyle(color: Color(0xFF66AAFF)),
    ),
    const TextDefinition(
      matcher: AttrMatcher(),
      matchStyle: TextStyle(color: Color(0xFFDD6699)),
    ),
    const TextDefinition(
      matcher: NumberMatcher(),
      matchStyle: TextStyle(color: Color(0xFF77AA33)),
    ),
    const TextDefinition(
      matcher: StringMatcher(),
      matchStyle: TextStyle(color: Color(0xFFCC8833)),
    ),
    TextDefinition(
      matcher: const UrlMatcher(),
      matchStyle: const TextStyle(
        color: Color(0xFFCC8833),
        decoration: TextDecoration.underline,
      ),
      hoverStyle: const TextStyle(
        color: Color(0xFFCC8833),
        backgroundColor: Color(0x22CC8833),
        decoration: TextDecoration.underline,
      ),
      onTap: onUrlTap,
    ),
  ];
}
