import 'package:flutter/painting.dart';

import 'package:custom_text/custom_text.dart';

import 'package:custom_text_example/utils/highlight/language_parser.dart';

const dartDefinitions = [
  TextDefinition(
    matcher: KeywordMatcher(),
    matchStyle: TextStyle(color: Color(0xFFCC8833)),
  ),
  TextDefinition(
    matcher: MetaMatcher(),
    matchStyle: TextStyle(color: Color(0xFFCC8833)),
  ),
  TextDefinition(
    matcher: BuiltInMatcher(),
    matchStyle: TextStyle(color: Color(0xFF6CA332)),
  ),
  TextDefinition(
    matcher: TitleMatcher(),
    matchStyle: TextStyle(color: Color(0xFF6CA332)),
  ),
  TextDefinition(
    matcher: NumberMatcher(),
    matchStyle: TextStyle(color: Color(0xFFE91E63)),
  ),
  TextDefinition(
    matcher: StringMatcher(),
    matchStyle: TextStyle(color: Color(0xFF009688)),
  ),
  TextDefinition(
    matcher: SubstMatcher(),
    matchStyle: TextStyle(color: Color(0xFF795548)),
  ),
  TextDefinition(
    matcher: UrlMatcher(),
    matchStyle: TextStyle(
      color: Color(0xFF009688),
      decoration: TextDecoration.underline,
    ),
    hoverStyle: TextStyle(
      color: Color(0xFF009688),
      backgroundColor: Color(0x22009688),
      decoration: TextDecoration.underline,
    ),
  ),
  TextDefinition(
    matcher: CommentMatcher(),
    matchStyle: TextStyle(color: Color(0xFFBBBBBB)),
  ),
  TextDefinition(
    matcher: DocTagMatcher(),
    matchStyle: TextStyle(color: Color(0xFFAAAA33)),
  ),
];
