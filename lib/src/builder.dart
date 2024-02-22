import 'package:flutter/painting.dart' show InlineSpan, TextSpan, TextStyle;
import 'package:meta/meta.dart' show internal, visibleForTesting;

import 'package:text_parser/text_parser.dart';

import 'definitions.dart';
import 'parser_options.dart';
import 'text.dart';
import 'utils.dart';
import 'span/data.dart';
import 'span/spans_builder.dart';

/// A class that builds a [TextSpan] based on [definitions].
///
/// {@template customText.CustomSpanBuilder}
/// This builder is basically used with [CustomText], although it is
/// also possible to use it independently. The example below makes
/// "KISS" and "Keep It Simple, Stupid!" bold, and additionally
/// applies a colour to capital letters contained in them.
///
/// ```dart
/// CustomText(
///   'KISS is an acronym for "Keep It Simple, Stupid!".',
///   preBuilder: CustomSpanBuilder(
///     definitions: [
///       const TextDefinition(
///         matcher: PatternMatcher('KISS|Keep.+Stupid!'),
///         matchStyle: TextStyle(fontWeight: FontWeight.bold),
///       ),
///     ],
///   ),
///   definitions: const [
///     TextDefinition(
///       matcher: PatternMatcher('[A-Z]'),
///       matchStyle: TextStyle(color: Colors.red),
///     ),
///   ],
/// )
/// ```
///
/// The usage is similar to [CustomText]. However, there is an important
/// difference that gesture actions specified in definitions are
/// deactivated in this builder. Exceptionally, `mouseCursor` is not
/// deactivated if the builder is used independently without being used
/// with `CustomText`.
/// {@endtemplate}
class CustomSpanBuilder {
  /// Creates a [CustomSpanBuilder] that builds a [TextSpan] based
  /// on [definitions].
  ///
  /// {@macro customText.CustomSpanBuilder}
  CustomSpanBuilder({
    required this.definitions,
    this.parserOptions = const ParserOptions(),
    this.style,
    this.matchStyle,
    this.preventBlocking = false,
  }) : _spansBuilder = SpansBuilder(
          settings: SpansBuilderSettings(
            definitions: definitions,
            style: style,
            matchStyle: matchStyle,
          ),
        );

  /// Definitions that specify rules for parsing, appearance and actions.
  ///
  /// Note that gesture actions are deactivated. Exceptionally,
  /// `mouseCursor` is not deactivated if the builder is used
  /// independently without being used with [CustomText].
  final List<Definition> definitions;

  /// The options for [RegExp] that configure how regular expressions
  /// are treated.
  final ParserOptions parserOptions;

  /// The text style for strings that did not match any match patterns.
  final TextStyle? style;

  /// The default text style for matched strings.
  final TextStyle? matchStyle;

  /// Whether to use an isolate for parsing to avoid blocking of the UI.
  ///
  /// When [CustomSpanBuilder] is used with [CustomText], it is
  /// recommended that this flag is omitted or set to `false`.
  /// Setting it otherwise adds an overhead to the parsing that occurs
  /// in the builder before another parsing occurs in `CustomText`.
  final bool preventBlocking;

  final SpansBuilder _spansBuilder;

  String _text = '';
  TextSpan _span = const TextSpan();

  @internal
  // ignore: public_member_api_docs
  String spanText() {
    return _span.toPlainText();
  }

  bool _parsed = false;
  bool _built = false;

  @visibleForTesting
  // ignore: public_member_api_docs
  TextSpan get span => _span;

  /// Whether the most recent call to [build] caused text parsing.
  @visibleForTesting
  bool get parsed => _parsed;

  /// Whether the most recent call to [build] caused a build of spans.
  @internal
  bool get built => _built;

  /// Builds a [TextSpan] based on [definitions].
  ///
  /// [oldBuilder] is used to decide whether to suppress unnecessary
  /// text parsing and building of spans by comparing old and new
  /// configurations. If not specified, every call to this method
  /// newly parses text and builds spans.
  Future<TextSpan> build({
    required String text,
    CustomSpanBuilder? oldBuilder,
  }) async {
    _parsed = false;
    _built = false;
    _text = text;
    _span = oldBuilder?._span ?? const TextSpan();

    final needsParse =
        definitions.hasUpdatedMatchers(oldBuilder?.definitions) ||
            parserOptions != oldBuilder?.parserOptions ||
            text != oldBuilder?._text;

    if (needsParse) {
      _spansBuilder.elements = await _parse(text);
      return _span = await _build(
        currentSpans: _span.children ?? [],
        updatedDefinitionIndexes: [],
      );
    }
    _spansBuilder.elements = oldBuilder?._spansBuilder.elements ?? [];

    final updatedDefIndexes =
        definitions.findUpdatedDefinitions(oldBuilder?.definitions);

    final needsBuild = updatedDefIndexes.isNotEmpty ||
        style != oldBuilder?.style ||
        matchStyle != oldBuilder?.matchStyle;

    if (needsBuild) {
      return _span = await _build(
        currentSpans: _span.children ?? [],
        updatedDefinitionIndexes: updatedDefIndexes,
      );
    }

    return _span;
  }

  Future<List<TextElement>> _parse(String text) async {
    final externalParser = parserOptions.parser;

    final elements = externalParser == null
        ? await TextParser(
            matchers: definitions.map((def) => def.matcher),
            multiLine: parserOptions.multiLine,
            caseSensitive: parserOptions.caseSensitive,
            unicode: parserOptions.unicode,
            dotAll: parserOptions.dotAll,
          ).parse(
            text,
            useIsolate: preventBlocking,
          )
        : await externalParser(text);

    _parsed = true;

    return elements;
  }

  Future<TextSpan> _build({
    required List<InlineSpan> currentSpans,
    required List<int> updatedDefinitionIndexes,
  }) async {
    final spans = _spansBuilder.elements.isEmpty
        ? null
        : _spansBuilder.buildSpans(
            style: style,
            currentSpans: currentSpans,
            updatedDefinitionIndexes: updatedDefinitionIndexes,
          );

    _built = true;

    return TextSpan(children: spans);
  }
}
