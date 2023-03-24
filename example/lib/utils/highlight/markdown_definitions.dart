import 'package:custom_text/custom_text.dart';
import 'package:custom_text_example/utils/highlight/language_parser.dart';
import 'package:flutter/painting.dart';

List<TextDefinition> markdownDefinitions({GestureCallback? onUrlTap}) {
  return [
    const TextDefinition(
      matcher: SectionMatcher(),
      matchStyle: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    const TextDefinition(
      matcher: StrongMatcher(),
      matchStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
    const TextDefinition(
      matcher: EmphasisMatcher(),
      matchStyle: TextStyle(fontStyle: FontStyle.italic),
    ),
    const TextDefinition(
      matcher: BulletMatcher(),
      matchStyle: TextStyle(
        color: Color(0xFFDD6699),
        fontWeight: FontWeight.bold,
      ),
    ),
    const TextDefinition(
      matcher: SymbolMatcher(),
      matchStyle: TextStyle(color: Color(0xFFE91E63)),
    ),
    const TextDefinition(
      matcher: StringMatcher(),
      matchStyle: TextStyle(color: Color(0xFF6CA332)),
    ),
    const TextDefinition(
      matcher: QuoteMatcher(),
      matchStyle: TextStyle(color: Color(0xFF009688)),
    ),
    const TextDefinition(
      matcher: CodeMatcher(),
      matchStyle: TextStyle(color: Color(0xFF795548)),
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
