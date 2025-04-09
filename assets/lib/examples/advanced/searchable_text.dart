import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:custom_text/custom_text.dart';

class SearchableTextExample extends StatefulWidget {
  const SearchableTextExample();

  @override
  State<SearchableTextExample> createState() => _SearchableTextExampleState();
}

class _SearchableTextExampleState extends State<SearchableTextExample> {
  late final TextEditingController _keywordController;
  late final SearchableTextController _searchController;

  String _text = '';

  @override
  void initState() {
    super.initState();

    _keywordController = TextEditingController(text: 'search');
    _searchController = SearchableTextController();

    rootBundle
        .loadString('lib/examples/advanced/searchable_text.dart')
        .then((text) => setState(() => _text = text));
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_keywordController, _searchController]),
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: SearchableText(
                  _text,
                  controller: _searchController,
                  keyword: _keywordController.text,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _keywordController,
                    decoration: InputDecoration(
                      hintText: 'Search keyword',
                      suffixIcon: _keywordController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _keywordController.text = '',
                            ),
                    ),
                  ),
                ),
                if (_searchController.count > 0) ...[
                  const SizedBox(width: 12.0),
                  Text(
                    '${_searchController.index + 1}/${_searchController.count}',
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: const Icon(Icons.navigate_before),
                    onPressed: _searchController.hasPrev
                        ? _searchController.prev
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.navigate_next),
                    onPressed: _searchController.hasNext
                        ? _searchController.next
                        : null,
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class SearchableTextController extends ChangeNotifier {
  final Set<GlobalKey> _matchKeys = {};
  int _index = 0;

  int get count => _matchKeys.length;
  int get index => _index;
  bool get hasPrev => _index > 0;
  bool get hasNext => _index < _matchKeys.length - 1;
  GlobalKey? get _currentKey => _matchKeys.elementAtOrNull(_index);

  @override
  void dispose() {
    _matchKeys.clear();
    super.dispose();
  }

  void _addKey(GlobalKey key) {
    _matchKeys.add(key);
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureVisible());
  }

  void _clearKey() {
    _matchKeys.clear();
    _index = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  void _ensureVisible() {
    if (_currentKey case GlobalKey(:final currentContext?)) {
      Scrollable.ensureVisible(
        currentContext,
        duration: const Duration(milliseconds: 200),
        alignment: 0.5,
      );
    }
  }

  void prev() {
    if (hasPrev) {
      _index--;
      notifyListeners();
      _ensureVisible();
    }
  }

  void next() {
    if (hasNext) {
      _index++;
      notifyListeners();
      _ensureVisible();
    }
  }
}

class SearchableText extends StatefulWidget {
  const SearchableText(
    this.text, {
    super.key,
    required this.controller,
    required this.keyword,
  });

  final String text;
  final SearchableTextController controller;
  final String keyword;

  @override
  State<SearchableText> createState() => _SearchableTextState();
}

class _SearchableTextState extends State<SearchableText> {
  @override
  void didUpdateWidget(SearchableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text || widget.keyword != oldWidget.keyword) {
      widget.controller._clearKey();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomText(
      widget.text,
      parserOptions: const ParserOptions(caseSensitive: false),
      definitions: [
        SpanDefinition(
          matcher: ExactMatcher([widget.keyword]),
          rebuildKey: widget.controller._currentKey,
          builder: (element) {
            final key = GlobalObjectKey(element);
            widget.controller._addKey(key);

            return WidgetSpan(
              baseline: TextBaseline.alphabetic,
              alignment: PlaceholderAlignment.baseline,
              child: Text(
                element.text,
                key: key,
                style: key == widget.controller._currentKey
                    ? const TextStyle(
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.yellow,
                      )
                    : TextStyle(
                        backgroundColor: Colors.yellow.shade100,
                      ),
              ),
            );
          },
        ),
      ],
    );
  }
}
