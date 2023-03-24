import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:custom_text_example/utils/example10/settings.dart';

class Buttons extends StatelessWidget {
  const Buttons({required this.selected, required this.onChanged});

  final LanguageType selected;
  final ValueChanged<LanguageType> onChanged;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(fontSize: 14.0),
      child: CupertinoSegmentedControl(
        groupValue: selected,
        padding: EdgeInsets.zero,
        selectedColor: Theme.of(context).colorScheme.secondary,
        borderColor: Theme.of(context).colorScheme.secondary,
        onValueChanged: onChanged,
        children: {
          for (final type in LanguageType.values)
            type: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(type.label),
            ),
        },
      ),
    );
  }
}
