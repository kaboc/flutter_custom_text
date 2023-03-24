import 'package:flutter/foundation.dart' show immutable;

import 'package:text_parser/text_parser.dart' show TextElement;

/// The signature for an external parser function.
typedef ExternalParser = Future<List<TextElement>> Function(String);

/// A class that configures how regular expressions are treated
/// in the default parser or specifies a different parser to use.
@immutable
class ParserOptions {
  /// Creates a [ParserOptions] that configures how regular expressions
  /// are treated.
  const ParserOptions({
    this.multiLine = false,
    this.caseSensitive = true,
    this.unicode = false,
    this.dotAll = false,
  }) : parser = null;

  /// Creates a [ParserOptions] for specifying an external parser that
  /// parses text into a list of [TextElement]s.
  const ParserOptions.external(ExternalParser this.parser)
      : multiLine = false,
        caseSensitive = false,
        unicode = false,
        dotAll = false;

  /// If this is enabled, then `^` and `$` will match the beginning and
  /// end of a _line_, in addition to matching beginning and end of input,
  /// respectively.
  final bool multiLine;

  /// If this is disabled, then case is ignored.
  final bool caseSensitive;

  /// If this is enabled, then the pattern is treated as a Unicode
  /// pattern as described by the ECMAScript standard.
  final bool unicode;

  /// If this is enabled, then the `.` pattern will match _all_ characters,
  /// including line terminators.
  final bool dotAll;

  /// An external parser function.
  final ExternalParser? parser;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParserOptions &&
          runtimeType == other.runtimeType &&
          multiLine == other.multiLine &&
          caseSensitive == other.caseSensitive &&
          unicode == other.unicode &&
          dotAll == other.dotAll;

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        multiLine,
        caseSensitive,
        unicode,
        dotAll,
      ]);
}
