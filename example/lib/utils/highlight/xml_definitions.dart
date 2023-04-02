import 'package:flutter/painting.dart';

import 'package:custom_text/custom_text.dart';

import 'package:custom_text_example/utils/highlight/language_parser.dart';

const xmlDefinitions = [
  TextDefinition(
    matcher: TagMatcher(),
    matchStyle: TextStyle(color: Color(0xFF66AAFF)),
  ),
  TextDefinition(
    matcher: NameMatcher(),
    matchStyle: TextStyle(color: Color(0xFF77AA33)),
  ),
  TextDefinition(
    matcher: AttrMatcher(),
    matchStyle: TextStyle(color: Color(0xFFDD6699)),
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
  TextDefinition(
    matcher: CommentMatcher(),
    matchStyle: TextStyle(color: Color(0xFFBBBBBB)),
  ),
];
