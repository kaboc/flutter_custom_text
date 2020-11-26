import 'package:flutter/material.dart';

import 'package:custom_text_example/code_view_page.dart';

PreferredSizeWidget appBar(
  BuildContext context, {
  String title,
  String filename,
}) {
  return AppBar(
    title: Text(title),
    actions: [
      IconButton(
        icon: const Icon(Icons.article),
        onPressed: () => Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => CodeViewPage(filename: filename),
          ),
        ),
      ),
    ],
  );
}
