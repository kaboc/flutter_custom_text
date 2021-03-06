import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:custom_text/custom_text.dart';
import 'package:google_fonts/google_fonts.dart';

class CodeViewPage extends StatelessWidget {
  const CodeViewPage({required this.filename});

  final String filename;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(filename),
      ),
      body: FutureBuilder<String>(
        future: _loadCode(),
        initialData: '',
        builder: (context, snapshot) {
          return snapshot.connectionState != ConnectionState.done
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SizedBox.expand(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _View(snapshot.data!),
                        ),
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }

  Future<String> _loadCode() async {
    return rootBundle.loadString('lib/examples/$filename');
  }
}

class _View extends StatelessWidget {
  const _View(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      code,
      definitions: const [
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
      ],
      style: GoogleFonts.inconsolata(
        fontSize: 15.0,
        height: 1.2,
      ),
    );
  }
}

class _DartCommentMatcher extends TextMatcher {
  const _DartCommentMatcher()
      : super(
          r'//.*',
        );
}

class _DartKeywordMatcher extends TextMatcher {
  const _DartKeywordMatcher()
      : super(
          // Avoid lookbehind assertion for Safari
          // r'(?<=\s|^)'
          r'(\s|^)'
          r'(?:import|part|const|var|final|class|extends|super|'
          r'assert|@override|@required|return|if|else|for|in|switch|do|while|'
          r'continue|break|is|async|await|static|get|set|print)(?=[\s(.;]|$)',
        );
}

class _DartTypeMatcher extends TextMatcher {
  const _DartTypeMatcher()
      : super(
          // Avoid lookbehind assertion for Safari
          // r'(?<=\s|^)'
          r'(\s|^)'
          r'(?:Type|void|bool|int|double|String|Map|List|Set|Future)'
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
          r'(?:true|false|\d+\.\d+|\d)(?![a-zA-Z])',
        );
}

class _DartStringMatcher extends TextMatcher {
  const _DartStringMatcher() : super(r"r?'.*'");
}

class _ClassMatcher extends TextMatcher {
  const _ClassMatcher()
      : super(
          r'(?:CustomText|UrlMatcher|EmailMatcher|TelMatcher|TextDefinition|'
          r'SelectiveDefinition|SpanDefinition|HashTagMatcher|LinkMatcher|'
          r'TextMatcher)',
        );
}

class _ParameterMatcher extends TextMatcher {
  const _ParameterMatcher() : super(r'[a-zA-Z]+(?=:)');
}
