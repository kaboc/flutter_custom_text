import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:custom_text/custom_text.dart';
import 'package:go_router/go_router.dart';
import 'package:positioned_popup/positioned_popup.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:custom_text_example/routes.dart';
import 'package:custom_text_example/widgets/description.dart';
import 'package:custom_text_example/widgets/layouts.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({
    required this.title,
    required this.description,
    required this.builder,
    this.hasOutput = true,
    this.additionalInfo,
  });

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

  late final Uri _uri;

  @override
  void initState() {
    super.initState();
    _uri = GoRouter.of(context).uri;
  }

  @override
  void dispose() {
    _resultNotifier.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final description = Description(
      uri: _uri,
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
          if (!kIsWeb) ...[
            IconButton(
              tooltip: 'View in browser',
              icon: const Icon(Icons.open_in_browser),
              onPressed: () => launchUrlString(
                'https://kaboc.github.io/'
                'flutter_custom_text/#${_uri.path}',
              ),
            ),
            const SizedBox(width: 4.0),
          ],
          IconButton(
            tooltip: 'View code',
            icon: const Icon(Icons.article),
            onPressed: () => context.go('${_uri.path}/code'),
          ),
        ],
      ),
      body: PopupArea(
        child: GestureDetector(
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
          builder((text) {
            final value = resultNotifier.value;
            resultNotifier.value += value.isEmpty ? text : '\n$text';
          }),
          if (additionalInfo != null) ...[
            const SizedBox(height: 32.0),
            CustomText(
              additionalInfo!,
              definitions: [
                TextDefinition(
                  matcher: const UrlMatcher(r'https?://.+\)?'),
                  matchStyle: const TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                  onTap: (details) => launchUrlString(details.actionText),
                ),
              ],
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.black38),
            ),
          ],
        ],
      ),
    );
  }
}

class _Output extends StatefulWidget {
  const _Output({
    required this.resultNotifier,
    required this.scrollController,
  });

  final ValueNotifier<String> resultNotifier;
  final ScrollController scrollController;

  @override
  State<_Output> createState() => _OutputState();
}

class _OutputState extends State<_Output> {
  @override
  void initState() {
    super.initState();
    widget.resultNotifier.addListener(_scroll);
  }

  @override
  void dispose() {
    widget.resultNotifier.removeListener(_scroll);
    super.dispose();
  }

  void _scroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent,
        curve: Curves.linear,
        duration: const Duration(milliseconds: 80),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade300,
      child: Scrollbar(
        controller: widget.scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: widget.scrollController,
          padding: const EdgeInsets.all(16.0),
          child: ValueListenableBuilder(
            valueListenable: widget.resultNotifier,
            builder: (_, result, __) => Text(
              result,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
      ),
    );
  }
}
