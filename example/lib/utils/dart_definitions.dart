import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';

const kDartDefinitions = [
  TextDefinition(
    matcher: _DartCommentMatcher(),
    matchStyle: TextStyle(color: Color(0xFFBDBDBD)),
  ),
  TextDefinition(
    matcher: _DartKeywordMatcher(),
    matchStyle: TextStyle(color: Color(0xFFED9716)),
  ),
  TextDefinition(
    matcher: _DartTypeMatcher(),
    matchStyle: TextStyle(color: Colors.lightBlue),
  ),
  TextDefinition(
    matcher: _DartSymbolMatcher(),
    matchStyle: TextStyle(color: Color(0xFF90A4AE)),
  ),
  TextDefinition(
    matcher: _DartVariableMatcher(),
    matchStyle: TextStyle(color: Colors.indigo),
  ),
  TextDefinition(
    matcher: _DartValueMatcher(),
    matchStyle: TextStyle(color: Colors.pink),
  ),
  TextDefinition(
    matcher: _DartStringMatcher(),
    matchStyle: TextStyle(color: Colors.teal),
  ),
  TextDefinition(
    matcher: _ParameterNameMatcher(),
    matchStyle: TextStyle(color: Color(0xFFB1887F)),
  ),
  TextDefinition(
    matcher: _CustomTextKeywordsMatcher(),
    matchStyle: TextStyle(color: Color(0xFF6CA332)),
  ),
];

class _DartCommentMatcher extends TextMatcher {
  const _DartCommentMatcher()
      : super(
          '//.*',
        );
}

class _DartKeywordMatcher extends TextMatcher {
  const _DartKeywordMatcher()
      : super(
          // Avoid lookbehind assertion for Safari
          // r'(?<=\s|^)'
          r'(\s|^)'
          '(?:library|import|export|part|as|show|hide|deferred|const|var|'
          'final|abstract|class|mixin|enum|typedef|extends|implements|with|'
          'on|assert|factory|return|if|else|for|in|switch|case|default|do|'
          'while|continue|break|is|async|sync|await|static|get|set|late|'
          'required|print|external|yield|rethrow|throw|Function|operator|'
          '@[a-zA-Z]+)'
          r'(?=[\s(.;]|$)',
        );
}

class _DartTypeMatcher extends TextMatcher {
  const _DartTypeMatcher()
      : super(
          // Avoid lookbehind assertion for Safari
          // r'(?<=\s|^)'
          r'(\s|^|)'
          '(?:Type|void|dynamic|covariant|bool|num|int|double|String|Map|'
          'List|Set|Iterable|FutureOr|Future|Error|Exception)'
          r'(?=[\s<)]|$)',
        );
}

class _DartSymbolMatcher extends TextMatcher {
  const _DartSymbolMatcher()
      : super(
          r'[?:[.,;:<>(){}\[\]=+\-*/!&|]',
        );
}

class _DartVariableMatcher extends TextMatcher {
  const _DartVariableMatcher()
      : super(
          // Avoid lookbehind assertion for Safari
          // r'(?<=\s|^)'
          r'(\s|^)'
          r'(?:super|this)(?=[\s.]|$)',
        );
}

class _DartValueMatcher extends TextMatcher {
  const _DartValueMatcher()
      : super(
          // Avoid lookbehind assertion for Safari
          // r'(?<![a-zA-Z])'
          r'(\s|^)'
          r'(?:true|false|null|\d+\.\d+|\d|0x[0-9a-fA-F]+)(?![a-zA-Z])',
        );
}

class _DartStringMatcher extends TextMatcher {
  const _DartStringMatcher()
      : super(
          "r?'.*'",
        );
}

class _ParameterNameMatcher extends TextMatcher {
  const _ParameterNameMatcher()
      : super(
          '[a-zA-Z]+(?=:)',
        );
}

class _CustomTextKeywordsMatcher extends TextMatcher {
  const _CustomTextKeywordsMatcher()
      : super(
          '(?:CustomTextEditingController|CustomText|TextMatcher|'
          'PatternMatcher|UrlMatcher|EmailMatcher|TelMatcher|LinkMatcher|'
          'HashTagMatcher|TextDefinition|SelectiveDefinition|SpanDefinition)',
        );
}
