import 'dart:async';

import 'package:flutter/material.dart';

import 'searchable_multi_select_theme.dart';

/// Label builder for an item.
///
/// The [item] is the data object to get the label from.
typedef SearchableMultiSelectItemLabel<T> = String Function(T item);

/// Custom item builder.
typedef SearchableMultiSelectItemBuilder<T> =
    Widget Function(BuildContext context, T item, bool selected);

/// Async search function.
typedef SearchableMultiSelectSearch<T> = Future<List<T>> Function(String query);

/// Load more function.
typedef SearchableMultiSelectLoadMore<T> =
    Future<List<T>> Function(String query, int page);

/// A generic, responsive, Material 3 searchable multi-select field.
class SearchableMultiSelect<T> extends StatefulWidget {
  /// Creates a [SearchableMultiSelect].
  const SearchableMultiSelect({
    super.key,
    required this.items,
    required this.itemLabel,
    required this.values,
    required this.onChanged,
    this.label,
    this.hintText = 'Select items',
    this.searchHintText = 'Search...',
    this.prefixIcon,
    this.clearable = true,
    this.enabled = true,
    this.searchable = true,
    this.selectAllEnabled = true,
    this.selectAllText = 'Select All',
    this.clearAllText = 'Clear All',
    this.doneText = 'Done',
    this.emptyText = 'No items found',
    this.loadingText = 'Loading...',
    this.errorText = 'Something went wrong',
    this.validator,
    this.itemBuilder,
    this.selectedTextBuilder,
    this.theme,
    this.maxHeight,
    this.maxSelection,
    this.debounceDuration = const Duration(milliseconds: 350),
    this.onSearchChanged,
    this.semanticLabel,
  }) : search = null,
       loadMore = null;

  /// Creates a [SearchableMultiSelect] with asynchronous search support.
  const SearchableMultiSelect.async({
    super.key,
    this.items = const <Never>[],
    required this.itemLabel,
    required this.values,
    required this.onChanged,
    this.label,
    this.hintText = 'Select items',
    this.searchHintText = 'Search...',
    this.prefixIcon,
    this.clearable = true,
    this.enabled = true,
    this.searchable = true,
    this.selectAllEnabled = true,
    this.selectAllText = 'Select All',
    this.clearAllText = 'Clear All',
    this.doneText = 'Done',
    this.emptyText = 'No items found',
    this.loadingText = 'Loading...',
    this.errorText = 'Something went wrong',
    this.validator,
    this.itemBuilder,
    this.selectedTextBuilder,
    this.theme,
    this.maxHeight,
    this.maxSelection,
    this.debounceDuration = const Duration(milliseconds: 350),
    this.onSearchChanged,
    this.semanticLabel,
    required this.search,
    this.loadMore,
  }) : assert(search != null);

  /// The list of items to display.
  final List<T> items;

  /// The currently selected values.
  final List<T> values;

  /// Callback when the selection changes.
  final ValueChanged<List<T>> onChanged;

  /// Function to get the label for an item.
  final SearchableMultiSelectItemLabel<T> itemLabel;

  /// Asynchronous search function.
  final SearchableMultiSelectSearch<T>? search;

  /// Function to load more items.
  final SearchableMultiSelectLoadMore<T>? loadMore;

  /// Label for the field.
  final String? label;

  /// Hint text for the field.
  final String hintText;

  /// Hint text for the search field.
  final String searchHintText;

  /// Text for the "Select All" button.
  final String selectAllText;

  /// Text for the "Clear All" button.
  final String clearAllText;

  /// Text for the "Done" button.
  final String doneText;

  /// Text to show when no items are found.
  final String emptyText;

  /// Text to show while loading items.
  final String loadingText;

  /// Text to show when an error occurs.
  final String errorText;

  /// Prefix icon for the field.
  final IconData? prefixIcon;

  /// Whether the field is clearable.
  final bool clearable;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether searching is enabled.
  final bool searchable;

  /// Whether "Select All" is enabled.
  final bool selectAllEnabled;

  /// Validator for the field.
  final FormFieldValidator<List<T>>? validator;

  /// Custom builder for items.
  final SearchableMultiSelectItemBuilder<T>? itemBuilder;

  /// Custom builder for the selected text.
  final String Function(List<T> values)? selectedTextBuilder;

  /// Theme data for the widget.
  final SearchableMultiSelectThemeData? theme;

  /// Maximum height of the dialog.
  final double? maxHeight;

  /// Maximum number of items that can be selected.
  final int? maxSelection;

  /// Debounce duration for search.
  final Duration debounceDuration;

  /// Callback when search query changes.
  final ValueChanged<String>? onSearchChanged;

  /// Semantic label for the field.
  final String? semanticLabel;

  @override
  State<SearchableMultiSelect<T>> createState() =>
      _SearchableMultiSelectState<T>();
}

class _SearchableMultiSelectState<T> extends State<SearchableMultiSelect<T>> {
  final GlobalKey<FormFieldState<List<T>>> _formKey =
      GlobalKey<FormFieldState<List<T>>>();

  @override
  Widget build(BuildContext context) {
    final data = widget.values;
    final label =
        widget.selectedTextBuilder?.call(data) ??
        (data.isEmpty ? widget.hintText : '${data.length} selected');

    return FormField<List<T>>(
      key: _formKey,
      initialValue: List<T>.of(data),
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) {
        return Semantics(
          label: widget.semanticLabel ?? widget.label ?? widget.hintText,
          button: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.label != null) ...[
                Text(
                  widget.label!,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 7),
              ],
              InkWell(
                onTap: widget.enabled ? () => _open(context) : null,
                borderRadius: BorderRadius.circular(
                  widget.theme?.borderRadius ?? 14,
                ),
                child: InputDecorator(
                  isEmpty: data.isEmpty,
                  decoration: InputDecoration(
                    hintText: data.isEmpty ? widget.hintText : null,
                    prefixIcon: widget.prefixIcon == null
                        ? null
                        : Icon(widget.prefixIcon),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.clearable && data.isNotEmpty)
                          IconButton(
                            tooltip: widget.clearAllText,
                            onPressed: widget.enabled
                                ? () {
                                    widget.onChanged([]);
                                    field.didChange([]);
                                  }
                                : null,
                            icon: const Icon(Icons.clear),
                          ),
                        const Icon(Icons.keyboard_arrow_down),
                        const SizedBox(width: 8),
                      ],
                    ),
                    errorText: field.errorText,
                    enabled: widget.enabled,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        widget.theme?.borderRadius ?? 14,
                      ),
                    ),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _open(BuildContext context) async {
    final selected = await showDialog<List<T>>(
      context: context,
      builder: (_) => _SearchDialog<T>(widget: widget),
    );

    if (!mounted || selected == null) return;
    widget.onChanged(selected);
    _formKey.currentState?.didChange(selected);
  }
}

class _SearchDialog<T> extends StatefulWidget {
  const _SearchDialog({required this.widget});

  final SearchableMultiSelect<T> widget;

  @override
  State<_SearchDialog<T>> createState() => _SearchDialogState<T>();
}

class _SearchDialogState<T> extends State<_SearchDialog<T>> {
  late List<T> _selected;
  late List<T> _results;
  final _controller = TextEditingController();
  Timer? _debounce;
  bool _loading = false;
  String? _error;
  int _page = 1;
  int _requestId = 0;
  bool _loadingMore = false;

  SearchableMultiSelect<T> get config => widget.widget;

  @override
  void initState() {
    super.initState();
    _selected = List<T>.of(config.values);
    _results = List<T>.of(config.items);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  List<T> get _filtered {
    if (config.search != null) return _results;
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) return _results;
    return _results
        .where((e) => config.itemLabel(e).toLowerCase().contains(query))
        .toList();
  }

  bool _contains(T item) => _selected.contains(item);

  void _emit() => config.onChanged(List<T>.unmodifiable(_selected));

  void _toggle(T item) {
    setState(() {
      if (_contains(item)) {
        _selected.remove(item);
      } else {
        final max = config.maxSelection;
        if (max != null && _selected.length >= max) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Maximum $max items can be selected.')),
          );
          return;
        }
        _selected.add(item);
      }
    });
    _emit();
  }

  void _selectAllVisible() {
    final visible = _filtered;
    setState(() {
      final max = config.maxSelection;
      for (final item in visible) {
        if (_contains(item)) continue;
        if (max != null && _selected.length >= max) break;
        _selected.add(item);
      }
    });
    _emit();
  }

  void _clearAll() {
    final visible = _filtered;
    setState(() {
      if (_controller.text.trim().isEmpty) {
        _selected.clear();
      } else {
        _selected.removeWhere(visible.contains);
      }
    });
    _emit();
  }

  void _onSearchChanged(String value) {
    config.onSearchChanged?.call(value);
    if (config.search == null) {
      setState(() {});
      return;
    }

    _debounce?.cancel();
    _debounce = Timer(config.debounceDuration, () => _runSearch(value));
  }

  Future<void> _runSearch(String query) async {
    final request = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
      _page = 1;
    });

    try {
      final result = await config.search!(query);
      if (!mounted || request != _requestId) return;
      setState(() {
        _results = result;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || request != _requestId) return;
      setState(() {
        _loading = false;
        _error = config.errorText;
      });
    }
  }

  Future<void> _loadMore() async {
    if (config.loadMore == null || _loadingMore || _loading) return;
    _loadingMore = true;
    final nextPage = _page + 1;
    try {
      final more = await config.loadMore!(_controller.text.trim(), nextPage);
      if (!mounted) return;
      setState(() {
        _page = nextPage;
        final existing = _results.toSet();
        _results = [..._results, ...more.where((e) => !existing.contains(e))];
      });
    } catch (_) {
      // Keep existing data; the next scroll can retry.
    } finally {
      _loadingMore = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = config.theme ?? const SearchableMultiSelectThemeData();
    final width = MediaQuery.sizeOf(context).width;
    final maxHeight =
        config.maxHeight ??
        MediaQuery.sizeOf(context).height * theme.maxDialogHeightFactor;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      title: Row(
        children: [
          const Expanded(child: Text('Select items')),
          Chip(label: Text('${_selected.length} selected')),
        ],
      ),
      content: SizedBox(
        width: width > 700 ? theme.dialogWidth : width * .82,
        height: maxHeight,
        child: Column(
          children: [
            if (config.searchable)
              TextField(
                controller: _controller,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: config.searchHintText,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      theme.searchFieldRadius,
                    ),
                  ),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _controller.clear();
                            _onSearchChanged('');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (config.selectAllEnabled)
                  TextButton.icon(
                    onPressed: _filtered.isEmpty ? null : _selectAllVisible,
                    icon: const Icon(Icons.select_all),
                    label: Text(config.selectAllText),
                  ),
                TextButton.icon(
                  onPressed: _selected.isEmpty ? null : _clearAll,
                  icon: const Icon(Icons.clear_all),
                  label: Text(config.clearAllText),
                ),
                const Spacer(),
                if (config.maxSelection != null)
                  Text(
                    'Max ${config.maxSelection}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? Center(child: Text(config.loadingText))
                  : _error != null
                  ? Center(child: Text(_error!))
                  : _filtered.isEmpty
                  ? Center(child: Text(config.emptyText))
                  : NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent - 120) {
                          _loadMore();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        itemCount: _filtered.length + (_loadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _filtered.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final item = _filtered[index];
                          final selected = _contains(item);
                          return CheckboxListTile(
                            value: selected,
                            onChanged: (_) => _toggle(item),
                            title:
                                config.itemBuilder?.call(
                                  context,
                                  item,
                                  selected,
                                ) ??
                                Text(config.itemLabel(item)),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(List<T>.of(_selected)),
          child: Text(config.doneText),
        ),
      ],
    );
  }
}
