import 'package:flutter/painting.dart';

import 'package:custom_text/custom_text.dart';

import 'package:custom_text_example/common/highlight/language_parser.dart';

const jsonDefinitions = [
  TextDefinition(
    matcher: LiteralMatcher(),
    matchStyle: TextStyle(color: Color(0xFF66AAFF)),
  ),
  TextDefinition(
    matcher: AttrMatcher(),
    matchStyle: TextStyle(color: Color(0xFFDD6699)),
  ),
  TextDefinition(
    matcher: NumberMatcher(),
    matchStyle: TextStyle(color: Color(0xFF77AA33)),
  ),
  TextDefinition(
    matcher: StringMatcher(),
    matchStyle: TextStyle(color: Color(0xFFCC8833)),
  ),
  TextDefinition(
    matcher: UrlMatcher(),
    matchStyle: TextStyle(
      color: Color(0xFFCC8833),
      decoration: TextDecoration.underline,
    ),
    hoverStyle: TextStyle(
      color: Color(0xFFCC8833),
      backgroundColor: Color(0x22CC8833),
      decoration: TextDecoration.underline,
    ),
  ),
];
