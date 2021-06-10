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
  final _resultNotifier = ValueNotifier<String>('');
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _resultNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final description = Description(
      widget.description,
      filename: widget.filename,
    );

    final example = _Example(
      builder: widget.builder,
      additionalInfo: widget.additionalInfo,
      resultNotifier: _resultNotifier,
    );
    final output = _Output(
      hasOutput: widget.hasOutput,
      resultNotifier: _resultNotifier,
      scrollController: _scrollController,
    );

    return Scaffold(
      appBar: appBar(context, title: widget.title, filename: widget.filename),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth > constraints.maxHeight
              ? _HorizontalLayout(
                  maxWidth: constraints.maxWidth,
                  description: description,
                  example: example,
                  output: output,
                )
              : _VerticalLayout(
                  maxHeight: constraints.maxHeight,
                  description: description,
                  example: example,
                  output: output,
                );
        },
      ),
    );
  }
}

class _Example extends StatelessWidget {
  const _Example({
    required this.builder,
    required this.additionalInfo,
    required this.resultNotifier,
  });

  final Widget Function(void Function(String)) builder;
  final String? additionalInfo;
  final ValueNotifier<String> resultNotifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          builder((v) {
            final value = resultNotifier.value;
            resultNotifier.value += value.isEmpty ? v : '\n$v';
          }),
          if (additionalInfo != null) ...[
            const SizedBox(height: 32.0),
            Text(
              additionalInfo!,
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
}

class _Output extends StatelessWidget {
  const _Output({
    required this.hasOutput,
    required this.resultNotifier,
    required this.scrollController,
  });

  final bool hasOutput;
  final ValueNotifier<String> resultNotifier;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyText1!,
      child: ColoredBox(
        color: Colors.grey.shade300,
        child: Scrollbar(
          controller: scrollController,
          isAlwaysShown: true,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: hasOutput
                  ? ValueListenableBuilder<String>(
                      valueListenable: resultNotifier,
                      builder: (_, result, __) {
                        WidgetsBinding.instance!
                            .addPostFrameCallback((_) => _scroll());
                        return Text(result);
                      },
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

  void _scroll() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      curve: Curves.linear,
      duration: const Duration(milliseconds: 80),
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
