import 'package:custom_text/custom_text.dart';
import 'package:custom_text_example/utils/highlight/language_parser.dart';
import 'package:flutter/painting.dart';

const markdownDefinitions = [
  TextDefinition(
    matcher: SectionMatcher(),
    matchStyle: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
    ),
  ),
  TextDefinition(
    matcher: StrongMatcher(),
    matchStyle: TextStyle(fontWeight: FontWeight.bold),
  ),
  TextDefinition(
    matcher: EmphasisMatcher(),
    matchStyle: TextStyle(fontStyle: FontStyle.italic),
  ),
  TextDefinition(
    matcher: BulletMatcher(),
    matchStyle: TextStyle(
      color: Color(0xFFDD6699),
      fontWeight: FontWeight.bold,
    ),
  ),
  TextDefinition(
    matcher: SymbolMatcher(),
    matchStyle: TextStyle(color: Color(0xFFE91E63)),
  ),
  TextDefinition(
    matcher: StringMatcher(),
    matchStyle: TextStyle(color: Color(0xFF6CA332)),
  ),
  TextDefinition(
    matcher: QuoteMatcher(),
    matchStyle: TextStyle(color: Color(0xFF009688)),
  ),
  TextDefinition(
    matcher: CodeMatcher(),
    matchStyle: TextStyle(color: Color(0xFF795548)),
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
