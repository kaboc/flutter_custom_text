// ignore_for_file: public_member_api_docs

import 'definitions.dart';

extension CompareDefinitions on List<Definition> {
  bool hasUpdatedMatchers(List<Definition>? other) {
    return length != other?.length ||
        indexed.any((e) => e.$2.matcher != other?[e.$1].matcher);
  }

  List<int> findUpdatedDefinitions(List<Definition>? other) {
    return [
      if (length == other?.length)
        for (final (i, def) in indexed)
          if (def != other?[i]) i,
    ];
  }
}
