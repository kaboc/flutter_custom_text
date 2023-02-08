import 'package:flutter/foundation.dart' show immutable;

/// A class that configures how a regular expressions are treated.
@immutable
class ParserOptions {
  /// Creates a [ParserOptions] that configures how regular expressions
  /// are treated.
  const ParserOptions({
    this.multiLine = false,
    this.caseSensitive = true,
    this.unicode = false,
    this.dotAll = false,
  });

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
