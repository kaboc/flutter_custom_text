import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:custom_text/custom_text.dart';
import 'package:google_fonts/google_fonts.dart';

class CodeViewPage extends StatelessWidget {
  const CodeViewPage({@required this.filename});

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
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: DefaultTextStyle(
                            style: GoogleFonts.inconsolata(
                              color: DefaultTextStyle.of(context).style.color,
                              fontSize: 15.0,
                            ),
                            child: _View(snapshot.data),
                          ),
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
    return await rootBundle.loadString('lib/examples/$filename');
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
          matcher: DartCommentMatcher(),
          matchStyle: TextStyle(color: Color(0xFFBDBDBD)),
        ),
        TextDefinition(
          matcher: DartKeywordMatcher(),
          matchStyle: TextStyle(color: Colors.orange),
        ),
        TextDefinition(
          matcher: DartTypeMatcher(),
          matchStyle: TextStyle(color: Colors.lightBlue),
        ),
        TextDefinition(
          matcher: DartSymbolMatcher(),
          matchStyle: TextStyle(color: Colors.green),
        ),
        TextDefinition(
          matcher: DartVariableMatcher(),
          matchStyle: TextStyle(color: Colors.indigo),
        ),
        TextDefinition(
          matcher: DartValueMatcher(),
          matchStyle: TextStyle(color: Colors.pink),
        ),
        TextDefinition(
          matcher: DartStringMatcher(),
          matchStyle: TextStyle(color: Colors.teal),
        ),
        TextDefinition(
          matcher: ClassMatcher(),
          matchStyle: TextStyle(
            color: Color(0xFF7CB342),
            fontWeight: FontWeight.bold,
          ),
        ),
        TextDefinition(
          matcher: ParameterMatcher(),
          matchStyle: TextStyle(color: Color(0xFFA1887F)),
        ),
      ],
    );
  }
}

class DartCommentMatcher extends TextMatcher {
  const DartCommentMatcher()
      : super(
          r'//.*',
        );
}

class DartKeywordMatcher extends TextMatcher {
  const DartKeywordMatcher()
      : super(
          r'(?<=\s|^)(?:import|part|const|var|final|class|extends|super|'
          r'assert|@override|@required|return|if|else|for|in|switch|do|while|'
          r'continue|break|is|async|await|static|get|set|print)(?=[\s(.;]|$)',
        );
}

class DartTypeMatcher extends TextMatcher {
  const DartTypeMatcher()
      : super(
          r'(?<=\s|^)(?:Type|void|bool|int|double|String|Map|List|Set|Future)'
          r'(?=[\s<]|$)',
        );
}

class DartSymbolMatcher extends TextMatcher {
  const DartSymbolMatcher() : super(r'[?:[.,;:<>(){}\[\]=+\-*/!&|]');
}

class DartVariableMatcher extends TextMatcher {
  const DartVariableMatcher()
      : super(r'(?<=\s|^)(?:super|this|widget)(?=[\s.]|$)');
}

class DartValueMatcher extends TextMatcher {
  const DartValueMatcher()
      : super(r'(?<![a-zA-Z])(?:true|false|\d+\.\d+|\d)(?![a-zA-Z])');
}

class DartStringMatcher extends TextMatcher {
  const DartStringMatcher() : super(r"r?'.*'");
}

class ClassMatcher extends TextMatcher {
  const ClassMatcher()
      : super(
          r'(?:CustomText|UrlMatcher|EmailMatcher|TelMatcher|TextDefinition|'
          r'SelectiveDefinition|SpanDefinition|HashTagMatcher|MdLinkMatcher)',
        );
}

class ParameterMatcher extends TextMatcher {
  const ParameterMatcher()
      : super(
          r'(?:definitions|style|matchStyle|tapStyle|onTap|onLongTap|'
          r'labelSelector|tapSelector)(?=:)',
        );
}
