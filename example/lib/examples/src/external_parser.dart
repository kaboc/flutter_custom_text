import 'package:flutter/material.dart';
import 'package:custom_text/custom_text.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:custom_text_example/common/highlight/language_parser.dart';
import 'package:custom_text_example/examples/utils/external_parser/segmented_buttons.dart';
import 'package:custom_text_example/examples/utils/external_parser/settings.dart';

class ExternalParserExample extends StatefulWidget {
  const ExternalParserExample();

  @override
  State<ExternalParserExample> createState() => _ExternalParserExampleState();
}

class _ExternalParserExampleState extends State<ExternalParserExample> {
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
          style: GoogleFonts.inconsolata(height: 1.4),
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
