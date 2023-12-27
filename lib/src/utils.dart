// ignore_for_file: public_member_api_docs

import 'definition_base.dart';

extension CompareDefinitions on List<Definition> {
  bool hasUpdatedMatchers(List<Definition>? other) {
    final entries = asMap().entries;

    return length != other?.length ||
        entries.any((e) => e.value.matcher != other?[e.key].matcher);
  }

  List<int> findUpdatedDefinitions(List<Definition>? other) {
    return [
      if (length == other?.length)
        for (var i = 0; i < length; i++)
          if (this[i] != other?[i]) i,
    ];
  }
}
