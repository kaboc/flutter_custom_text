import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:custom_text/custom_text.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:custom_text_example/common/dart_definitions.dart';

class CodeViewPage extends StatefulWidget {
  const CodeViewPage({required int id}) : _filename = 'example$id.dart';

  final String _filename;

  @override
  State<CodeViewPage> createState() => _CodeViewPageState();
}

class _CodeViewPageState extends State<CodeViewPage> {
  late Future<String> _loadCode;

  @override
  void initState() {
    super.initState();
    _loadCode = rootBundle.loadString('lib/examples/${widget._filename}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget._filename),
      ),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: _loadCode,
          initialData: '',
          builder: (context, snapshot) {
            return SizedBox.expand(
              child: Scrollbar(
                thickness: 8.0,
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(16.0),
                    child: CustomText.selectable(
                      snapshot.data!,
                      definitions: dartDefinitions,
                      style: GoogleFonts.inconsolata(
                        fontSize: 15.0,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
