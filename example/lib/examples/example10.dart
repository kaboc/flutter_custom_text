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
  CustomTextEditingController? _controller;

  LanguageType _languageType = LanguageType.values.first;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _changeLanguage(LanguageType.values.first);
    });
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
          onChanged: _changeLanguage,
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: _controller,
          maxLines: null,
        ),
      ],
    );
  }

  void _changeLanguage(LanguageType type) {
    _controller?.dispose();

    setState(() {
      _languageType = type;

      _controller = CustomTextEditingController(
        text: type.sourceText,
        parserOptions: ParserOptions.external(
          (text) => parseLanguage(text, language: type.name),
        ),
        definitions: type.definitions,
        style: GoogleFonts.inconsolata(
          height: 1.4,
          color: DefaultTextStyle.of(context).style.color,
        ),
      );
    });
  }
}
