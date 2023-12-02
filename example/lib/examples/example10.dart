import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:custom_text_example/utils/highlight/language_parser.dart';
import 'package:custom_text_example/utils/example10/segmented_buttons.dart';
import 'package:custom_text_example/utils/example10/settings.dart';

class Example10 extends StatefulWidget {
  const Example10();

  @override
  State<Example10> createState() => _Example10State();
}

class _Example10State extends State<Example10> {
  late LanguageType _languageType;
  CustomTextEditingController? _controller;

  @override
  void initState() {
    super.initState();
    _onLanguageChanged(LanguageType.values.first);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Buttons(
          selected: _languageType,
          onChanged: (type) {
            setState(() => _onLanguageChanged(type));
          },
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: _controller,
          maxLines: null,
          style: GoogleFonts.inconsolata(
            height: 1.4,
            color: DefaultTextStyle.of(context).style.color,
          ),
        ),
      ],
    );
  }

  void _onLanguageChanged(LanguageType type) {
    _languageType = type;

    _controller?.dispose();
    _controller = CustomTextEditingController(
      text: type.sourceText,
      definitions: type.definitions,
      parserOptions: ParserOptions.external(
        (text) => parseLanguage(text, language: type.name),
      ),
    );
  }
}
