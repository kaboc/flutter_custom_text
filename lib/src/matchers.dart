import 'package:text_parser/text_parser.dart';

import 'definitions.dart';

/// A variant of [TextMatcher] for parsing Markdown link format.
///
/// {@template customText.LinkMatcher}
/// This matcher is basically used with [SelectiveDefinition].
///
/// The preset pattern is overwritten if a custom pattern is provided.
/// {@endtemplate}
class LinkMatcher extends TextMatcher {
  /// Creates a [LinkMatcher] for parsing Markdown link format.
  ///
  /// {@macro customText.LinkMatcher}
  const LinkMatcher([super.pattern = r'\[(.+?)\]\((.*?)\)']);
}
