import 'package:text_parser/text_parser.dart' show TextMatcher;

import 'definitions.dart';

/// A variant of [TextMatcher] for parsing Markdown link format.
///
/// {@template customText.LinkMatcher}
/// This is useful if used together with [SelectiveDefinition].
///
/// Note that this matcher does not treat nested brackets or braces
/// in the same way as real Markdown parsers do.
///
/// The preset pattern is overwritten if a custom pattern is provided.
/// {@endtemplate}
class LinkMatcher extends TextMatcher {
  /// Creates a [LinkMatcher] for parsing Markdown link format.
  ///
  /// {@macro customText.LinkMatcher}
  const LinkMatcher([super.pattern = r'\[(.+?)\]\((.*?)\)']);
}
