import 'package:text_parser/text_parser.dart';

/// A variant of [TextMatcher] that is useful for parsing Markdown link
/// format.
class LinkMatcher extends TextMatcher {
  /// Creates a [LinkMatcher] that is useful for parsing Markdown link
  /// format.
  ///
  /// The preset pattern is overwritten if a custom pattern is provided.
  const LinkMatcher([super.pattern = r'\[(.+?)\]\((.*?)\)']);
}
