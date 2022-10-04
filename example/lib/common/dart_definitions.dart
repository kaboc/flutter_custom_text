import 'package:custom_text/custom_text.dart';
import 'package:flutter/material.dart';

const dartDefinitions = [
  TextDefinition(
    matcher: _DartCommentMatcher(),
    matchStyle: TextStyle(color: Color(0xFFBDBDBD)),
  ),
  TextDefinition(
    matcher: _DartKeywordMatcher(),
    matchStyle: TextStyle(color: Colors.orange),
  ),
  TextDefinition(
    matcher: _DartTypeMatcher(),
    matchStyle: TextStyle(color: Colors.lightBlue),
  ),
  TextDefinition(
    matcher: _DartSymbolMatcher(),
    matchStyle: TextStyle(color: Colors.green),
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
    matcher: _ClassMatcher(),
    matchStyle: TextStyle(
      color: Color(0xFF7CB342),
      fontWeight: FontWeight.bold,
    ),
  ),
  TextDefinition(
    matcher: _ParameterMatcher(),
    matchStyle: TextStyle(color: Color(0xFFA1887F)),
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
          '(?:import|part|const|var|final|class|mixin|extends|implements|'
          'with|super|assert|@override|required|return|if|else|for|in|'
          'switch|do|while|continue|break|is|async|await|static|get|set|'
          'late|covariant|print)'
          r'(?=[\s(.;]|$)',
        );
}

class _DartTypeMatcher extends TextMatcher {
  const _DartTypeMatcher()
      : super(
          // Avoid lookbehind assertion for Safari
          // r'(?<=\s|^)'
          r'(\s|^)'
          '(?:Type|void|bool|int|double|String|Map|List|Set|Future)'
          r'(?=[\s<]|$)',
        );
}

class _DartSymbolMatcher extends TextMatcher {
  const _DartSymbolMatcher() : super(r'[?:[.,;:<>(){}\[\]=+\-*/!&|]');
}

class _DartVariableMatcher extends TextMatcher {
  const _DartVariableMatcher()
      : super(
          // Avoid lookbehind assertion for Safari
          // r'(?<=\s|^)'
          r'(\s|^)'
          r'(?:super|this|widget)(?=[\s.]|$)',
        );
}

class _DartValueMatcher extends TextMatcher {
  const _DartValueMatcher()
      : super(
          // Avoid lookbehind assertion for Safari
          // r'(?<![a-zA-Z])'
          r'(\s|^)'
          r'(?:true|false|\d+\.\d+|\d|0x[0-9a-fA-F]+)(?![a-zA-Z])',
        );
}

class _DartStringMatcher extends TextMatcher {
  const _DartStringMatcher() : super("r?'.*'");
}

class _ClassMatcher extends TextMatcher {
  const _ClassMatcher()
      : super(
          '(?:CustomText|UrlMatcher|EmailMatcher|TelMatcher|TextDefinition|'
          'SelectiveDefinition|SpanDefinition|HashTagMatcher|LinkMatcher|'
          'TextMatcher)',
        );
}

class _ParameterMatcher extends TextMatcher {
  const _ParameterMatcher() : super('[a-zA-Z]+(?=:)');
}
