import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:custom_text_example/widgets/description.dart';
import 'package:custom_text_example/widgets/layouts.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({
    required this.page,
    required this.title,
    required this.description,
    required this.builder,
    this.hasOutput = true,
    this.additionalInfo,
  });

  final int page;
  final String title;
  final String description;
  final Widget Function(void Function(String)) builder;
  final bool hasOutput;
  final String? additionalInfo;

  @override
  State<ExamplePage> createState() => _ExamplePageState();
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
      page: widget.page,
      description: widget.description,
    );
    final example = _Example(
      builder: widget.builder,
      additionalInfo: widget.additionalInfo,
      resultNotifier: _resultNotifier,
    );
    final output = _Output(
      resultNotifier: _resultNotifier,
      scrollController: _scrollController,
    );

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.article),
            onPressed: () => context.go('/${widget.page}/code'),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: SafeArea(
          child: widget.hasOutput
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return isLandscape
                        ? HorizontalLayout(
                            maxWidth: constraints.maxWidth,
                            description: description,
                            example: example,
                            output: output,
                          )
                        : VerticalLayout(
                            maxHeight: constraints.maxHeight,
                            description: description,
                            example: example,
                            output: output,
                          );
                  },
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      description,
                      example,
                    ],
                  ),
                ),
        ),
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
    required this.resultNotifier,
    required this.scrollController,
  });

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
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ValueListenableBuilder<String>(
                valueListenable: resultNotifier,
                builder: (_, result, __) {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _scroll());
                  return Text(result);
                },
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
