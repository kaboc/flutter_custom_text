import 'dart:async';
import 'package:flutter/material.dart';

import 'package:custom_text_example/widgets/appbar.dart';
import 'package:custom_text_example/widgets/description.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage(
    this.title,
    this.filename,
    this.description,
    this.builder, {
    this.hasOutput = true,
    this.additionalInfo,
  });

  final String title;
  final String filename;
  final String description;
  final Widget Function(void Function(String)) builder;
  final bool hasOutput;
  final String? additionalInfo;

  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final _result = <String>[];

  late final StreamController<String> _controller = StreamController<String>()
    ..stream.listen((v) => _updateOutput(v));

  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateOutput(String value) {
    setState(() => _result.add(value));
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        curve: Curves.linear,
        duration: const Duration(milliseconds: 80),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final description = Description(
      widget.description,
      filename: widget.filename,
    );

    return Scaffold(
      appBar: appBar(context, title: widget.title, filename: widget.filename),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth > constraints.maxHeight
              ? _HorizontalLayout(
                  maxWidth: constraints.maxWidth,
                  description: description,
                  example: _example(),
                  output: _output(),
                )
              : _VerticalLayout(
                  maxHeight: constraints.maxHeight,
                  description: description,
                  example: _example(),
                  output: _output(),
                );
        },
      ),
    );
  }

  Widget _example() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.builder((v) => _controller.sink.add(v)),
          if (widget.additionalInfo != null) ...[
            const SizedBox(height: 32.0),
            Text(
              widget.additionalInfo!,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.black38),
            )
          ],
        ],
      ),
    );
  }

  Widget _output() {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyText1!,
      child: ColoredBox(
        color: Colors.grey.shade300,
        child: Scrollbar(
          controller: _scrollController,
          isAlwaysShown: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: widget.hasOutput
                  ? Text(
                      _result.join('\n'),
                    )
                  : const Text(
                      'Tapping on text in this example '
                      'does not print anything here.',
                      style: TextStyle(color: Colors.black38),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HorizontalLayout extends StatelessWidget {
  const _HorizontalLayout({
    required this.maxWidth,
    required this.description,
    required this.example,
    required this.output,
  });

  final double maxWidth;
  final Description description;
  final Widget example;
  final Widget output;

  @override
  Widget build(BuildContext context) {
    final paneWidth = (maxWidth ~/ 2).toDouble();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: paneWidth - 1.0,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                description,
                example,
              ],
            ),
          ),
        ),
        const VerticalDivider(
          width: 1.0,
          thickness: 1.0,
          color: Colors.black26,
        ),
        SizedBox(
          width: paneWidth,
          height: double.infinity,
          child: output,
        ),
      ],
    );
  }
}

class _VerticalLayout extends StatelessWidget {
  const _VerticalLayout({
    required this.maxHeight,
    required this.description,
    required this.example,
    required this.output,
  });

  final double maxHeight;
  final Description description;
  final Widget example;
  final Widget output;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: maxHeight,
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              description,
              Expanded(
                child: example,
              ),
              const Divider(
                height: 1.0,
                thickness: 1.0,
                color: Colors.black26,
              ),
              SizedBox(
                width: double.infinity,
                height: 150.0,
                child: output,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
