import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:custom_text/custom_text.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:custom_text_example/common/highlight/highlight.dart';
import 'package:custom_text_example/routes.dart';
import 'package:custom_text_example/widgets/hyperlink.dart';

class CodeViewPage extends StatefulWidget {
  const CodeViewPage({
    required this.viewType,
    required this.filename,
  });

  final ViewType viewType;
  final String filename;

  @override
  State<CodeViewPage> createState() => _CodeViewPageState();
}

class _CodeViewPageState extends State<CodeViewPage> {
  final _horizontalScrollController = ScrollController();

  String _code = '';

  @override
  void initState() {
    super.initState();
    _loadSourceCode();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSourceCode() async {
    final path = 'lib/examples/${widget.viewType.name}/${widget.filename}';
    final code = await rootBundle.loadString(path);
    setState(() => _code = code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filename),
        actions: [
          Center(
            child: Hyperlink(
              label: 'View on GitHub',
              url: 'https://github.com/kaboc/flutter_custom_text/'
                  'blob/main/example/lib/'
                  'examples/${widget.viewType.name}/${widget.filename}',
            ),
          ),
          const SizedBox(width: 16.0),
        ],
      ),
      body: SafeArea(
        // Placing SelectionArea as the child of SizedBox causes a layout issue.
        // https://github.com/flutter/flutter/issues/121053
        child: SelectionArea(
          child: SizedBox(
            width: double.infinity,
            child: Scrollbar(
              thickness: 8.0,
              child: SingleChildScrollView(
                primary: true,
                child: Scrollbar(
                  controller: _horizontalScrollController,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(16.0),
                    child: CustomText(
                      _code,
                      parserOptions: ParserOptions.external(
                        (text) => parseLanguage(text, language: 'dart'),
                      ),
                      definitions: dartDefinitions,
                      style: GoogleFonts.inconsolata(
                        fontSize: 15.0,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
