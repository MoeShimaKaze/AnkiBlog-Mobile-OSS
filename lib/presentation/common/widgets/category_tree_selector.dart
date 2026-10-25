import 'package:ankiblog_mobile/data/models/product.dart';
import 'package:flutter/material.dart';

class CategoryTreeSelector extends StatelessWidget {
  const CategoryTreeSelector({
    super.key,
    required this.categories,
    required this.selectedIds,
    required this.onChanged,
    this.multiSelect = false,
    this.labelText = '商品分类',
    this.emptyText = '全部分类',
  });

  final List<ProductCategory> categories;
  final List<String> selectedIds;
  final ValueChanged<List<String>> onChanged;
  final bool multiSelect;
  final String labelText;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final selectedNames = _selectedNames(categories, selectedIds);
    final displayText = selectedNames.isEmpty
        ? emptyText
        : multiSelect
        ? '已选择 ${selectedNames.length} 个分类'
        : selectedNames.first;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: categories.isEmpty
          ? null
          : () async {
              final result = await showModalBottomSheet<List<String>>(
                context: context,
                isScrollControlled: true,
                builder: (context) => _CategoryTreeSheet(
                  categories: categories,
                  selectedIds: selectedIds,
                  multiSelect: multiSelect,
                  emptyText: emptyText,
                ),
              );
              if (result != null) {
                onChanged(result);
              }
            },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: const Icon(Icons.category_outlined),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                categories.isEmpty ? '暂无分类' : displayText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}

class _CategoryTreeSheet extends StatefulWidget {
  const _CategoryTreeSheet({
    required this.categories,
    required this.selectedIds,
    required this.multiSelect,
    required this.emptyText,
  });

  final List<ProductCategory> categories;
  final List<String> selectedIds;
  final bool multiSelect;
  final String emptyText;

  @override
  State<_CategoryTreeSheet> createState() => _CategoryTreeSheetState();
}

class _CategoryTreeSheetState extends State<_CategoryTreeSheet> {
  late final Set<String> _selectedIds = widget.selectedIds.toSet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.72,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Text('选择分类', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: widget.multiSelect
                        ? Checkbox(
                            value: _selectedIds.isEmpty,
                            onChanged: (_) => setState(_selectedIds.clear),
                          )
                        : _selectedIds.isEmpty
                        ? const Icon(Icons.check)
                        : const SizedBox(width: 24),
                    title: Text(widget.emptyText),
                    onTap: () {
                      if (widget.multiSelect) {
                        setState(_selectedIds.clear);
                      } else {
                        Navigator.pop(context, const <String>[]);
                      }
                    },
                  ),
                  ...widget.categories.expand((category) {
                    return _buildCategoryTiles(category, 0);
                  }),
                ],
              ),
            ),
            if (widget.multiSelect)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () => setState(_selectedIds.clear),
                      child: const Text('清空'),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(
                        context,
                        _selectedIds.toList(growable: false),
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('确定'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Iterable<Widget> _buildCategoryTiles(ProductCategory category, int depth) {
    final checked = _selectedIds.contains(category.id);
    final tile = ListTile(
      contentPadding: EdgeInsets.only(left: 16.0 + depth * 20.0, right: 16),
      leading: widget.multiSelect
          ? Checkbox(
              value: checked,
              onChanged: (_) => _toggleCategory(category.id),
            )
          : checked
          ? const Icon(Icons.check)
          : const SizedBox(width: 24),
      title: Text(category.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: category.children.isEmpty
          ? null
          : Text('${category.children.length} 个子分类'),
      onTap: () {
        if (widget.multiSelect) {
          _toggleCategory(category.id);
        } else {
          Navigator.pop(context, [category.id]);
        }
      },
    );

    return [
      tile,
      ...category.children.expand(
        (child) => _buildCategoryTiles(child, depth + 1),
      ),
    ];
  }

  void _toggleCategory(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }
}

List<String> _selectedNames(
  List<ProductCategory> categories,
  List<String> selectedIds,
) {
  final idSet = selectedIds.toSet();
  final names = <String>[];

  void visit(ProductCategory category) {
    if (idSet.contains(category.id)) {
      names.add(category.name);
    }
    for (final child in category.children) {
      visit(child);
    }
  }

  for (final category in categories) {
    visit(category);
  }
  return names;
}
