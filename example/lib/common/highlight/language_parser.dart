import 'package:custom_text/custom_text.dart';
import 'package:highlight/highlight.dart';

Future<List<TextElement>> parseLanguage(
  String text, {
  required String language,
}) async {
  final result = highlight.parse(text, language: language);
  return _buildElements(result.nodes);
}

Future<List<TextElement>> _buildElements(
  List<Node>? nodes, [
  int offset = 0,
  String? className,
]) async {
  if (nodes == null) {
    return [];
  }

  final elements = <TextElement>[];
  var currentOffset = offset;

  for (final node in nodes) {
    if (node.children == null) {
      final value = node.value;
      if (value != null && value.isNotEmpty) {
        if (className != 'code' || value.startsWith('```')) {
          elements.addAll(
            await _buildValueElements(
              value,
              currentOffset,
              className == 'code' ? 'code_block' : className,
            ),
          );
        } else {
          elements.add(
            TextElement(
              value,
              matcherType: CodeMatcher,
              offset: currentOffset,
            ),
          );
        }
      }
    } else {
      elements.addAll(
        await _buildElements(node.children, currentOffset, node.className),
      );
    }
    if (elements.isNotEmpty) {
      currentOffset = elements.last.offset + elements.last.text.length;
    }
  }

  return elements;
}

Future<List<TextElement>> _buildValueElements(
  String text,
  int offset,
  String? className,
) async {
  final parser = TextParser(matchers: const [UrlMatcher()]);
  var elements = await parser.parse(text, useIsolate: false);

  final matcherType = _mappings[className] ?? TextMatcher;
  if (!elements.containsMatcherType<UrlMatcher>()) {
    return [TextElement(text, matcherType: matcherType, offset: offset)];
  }

  elements = elements.reassignOffsets(startingOffset: offset).toList();
  return [
    for (final elm in elements)
      if (elm.matcherType == UrlMatcher)
        elm
      else
        elm.copyWith(matcherType: matcherType),
  ];
}

const _mappings = {
  'keyword': KeywordMatcher,
  'built_in': BuiltInMatcher,
  'meta': MetaMatcher,
  'title': TitleMatcher,
  'literal': LiteralMatcher,
  'number': NumberMatcher,
  'string': StringMatcher,
  'subst': SubstMatcher,
  'comment': CommentMatcher,
  'doctag': DocTagMatcher,
  'params': ParamsMatcher,
  'tag': TagMatcher,
  'name': NameMatcher,
  'attr': AttrMatcher,
  'section': SectionMatcher,
  'strong': StrongMatcher,
  'emphasis': EmphasisMatcher,
  'bullet': BulletMatcher,
  'symbol': SymbolMatcher,
  'link': UrlMatcher,
  'quote': QuoteMatcher,
  'code': CodeMatcher,
  'code_block': CodeBlockMatcher,
};

class KeywordMatcher extends TextMatcher {
  const KeywordMatcher() : super('');
}

class BuiltInMatcher extends TextMatcher {
  const BuiltInMatcher() : super('');
}

class MetaMatcher extends TextMatcher {
  const MetaMatcher() : super('');
}

class TitleMatcher extends TextMatcher {
  const TitleMatcher() : super('');
}

class LiteralMatcher extends TextMatcher {
  const LiteralMatcher() : super('');
}

class NumberMatcher extends TextMatcher {
  const NumberMatcher() : super('');
}

class StringMatcher extends TextMatcher {
  const StringMatcher() : super('');
}

class SubstMatcher extends TextMatcher {
  const SubstMatcher() : super('');
}

class CommentMatcher extends TextMatcher {
  const CommentMatcher() : super('');
}

class DocTagMatcher extends TextMatcher {
  const DocTagMatcher() : super('');
}

class ParamsMatcher extends TextMatcher {
  const ParamsMatcher() : super('');
}

class TagMatcher extends TextMatcher {
  const TagMatcher() : super('');
}

class NameMatcher extends TextMatcher {
  const NameMatcher() : super('');
}

class AttrMatcher extends TextMatcher {
  const AttrMatcher() : super('');
}

class SectionMatcher extends TextMatcher {
  const SectionMatcher() : super('');
}

class StrongMatcher extends TextMatcher {
  const StrongMatcher() : super('');
}

class EmphasisMatcher extends TextMatcher {
  const EmphasisMatcher() : super('');
}

class BulletMatcher extends TextMatcher {
  const BulletMatcher() : super('');
}

class SymbolMatcher extends TextMatcher {
  const SymbolMatcher() : super('');
}

class LinkMatcher extends TextMatcher {
  const LinkMatcher() : super('');
}

class QuoteMatcher extends TextMatcher {
  const QuoteMatcher() : super('');
}

class CodeMatcher extends TextMatcher {
  const CodeMatcher() : super('');
}

class CodeBlockMatcher extends TextMatcher {
  const CodeBlockMatcher() : super('');
}
