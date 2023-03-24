import 'package:flutter/painting.dart';

import 'package:custom_text/custom_text.dart';

import 'package:custom_text_example/utils/highlight/language_parser.dart';

List<TextDefinition> dartDefinitions({GestureCallback? onUrlTap}) {
  return [
    const TextDefinition(
      matcher: KeywordMatcher(),
      matchStyle: TextStyle(color: Color(0xFFCC8833)),
    ),
    const TextDefinition(
      matcher: MetaMatcher(),
      matchStyle: TextStyle(color: Color(0xFFCC8833)),
    ),
    const TextDefinition(
      matcher: BuiltInMatcher(),
      matchStyle: TextStyle(color: Color(0xFF6CA332)),
    ),
    const TextDefinition(
      matcher: TitleMatcher(),
      matchStyle: TextStyle(color: Color(0xFF6CA332)),
    ),
    const TextDefinition(
      matcher: NumberMatcher(),
      matchStyle: TextStyle(color: Color(0xFFE91E63)),
    ),
    const TextDefinition(
      matcher: StringMatcher(),
      matchStyle: TextStyle(color: Color(0xFF009688)),
    ),
    const TextDefinition(
      matcher: SubstMatcher(),
      matchStyle: TextStyle(color: Color(0xFF795548)),
    ),
    TextDefinition(
      matcher: const UrlMatcher(),
      matchStyle: const TextStyle(
        color: Color(0xFF009688),
        decoration: TextDecoration.underline,
      ),
      hoverStyle: const TextStyle(
        color: Color(0xFF009688),
        backgroundColor: Color(0x22009688),
        decoration: TextDecoration.underline,
      ),
      onTap: onUrlTap,
    ),
    const TextDefinition(
      matcher: CommentMatcher(),
      matchStyle: TextStyle(color: Color(0xFFBBBBBB)),
    ),
    const TextDefinition(
      matcher: DocTagMatcher(),
      matchStyle: TextStyle(color: Color(0xFFAAAA33)),
    ),
  ];
}
