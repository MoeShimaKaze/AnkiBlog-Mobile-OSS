import 'package:ankiblog_mobile/presentation/common/widgets/image_upload_field.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AdminOutfitFormPage extends ConsumerStatefulWidget {
  const AdminOutfitFormPage({super.key});

  @override
  ConsumerState<AdminOutfitFormPage> createState() =>
      _AdminOutfitFormPageState();
}

class _AdminOutfitFormPageState extends ConsumerState<AdminOutfitFormPage> {
  static const _mainItemType = 'MAIN';
  static const _accessoryItemType = 'ACCESSORY';

  final _noteController = TextEditingController();
  String? _imageUrl;
  DateTime? _selectedDate;
  List<ProductSelectItem> _selectedProducts = [];
  final Map<String, String> _itemTypes = {};
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 1)),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate ?? now),
    );
    if (time == null) return;
    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickProducts() async {
    final result = await showModalBottomSheet<List<ProductSelectItem>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ProductPickerSheet(alreadySelected: _selectedProducts),
    );
    if (result != null) {
      setState(() {
        _selectedProducts = result;
        final selectedIds = result.map((p) => p.id).toSet();
        _itemTypes.removeWhere(
          (productId, _) => !selectedIds.contains(productId),
        );
        for (final product in result) {
          _itemTypes.putIfAbsent(product.id, () => _mainItemType);
        }
      });
    }
  }

  String _formatRequestDate(DateTime value) {
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(value);
  }

  String _itemTypeOf(String productId) {
    return _itemTypes[productId] ?? _mainItemType;
  }

  void _removeProduct(String productId) {
    setState(() {
      _selectedProducts = _selectedProducts
          .where((product) => product.id != productId)
          .toList(growable: false);
      _itemTypes.remove(productId);
    });
  }

  Future<void> _submit() async {
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请至少选择一个单品')));
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref
          .read(adminRepositoryProvider)
          .createOutfit(
            productIds: _selectedProducts.map((p) => p.id).toList(),
            itemTypes: {
              for (final product in _selectedProducts)
                product.id: _itemTypeOf(product.id),
            },
            note: _noteController.text.isEmpty ? null : _noteController.text,
            outfitImage: _imageUrl,
            outfitDate: _selectedDate == null
                ? null
                : _formatRequestDate(_selectedDate!),
          );
      ref.invalidate(adminOutfitListProvider);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('创建失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新建穿搭'),
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleImageUploadField(
              initialUrl: _imageUrl,
              onChanged: (url) => setState(() => _imageUrl = url),
              label: '穿搭照片',
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '穿搭时间',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDate != null
                      ? DateFormat('yy/MM/dd HH:mm').format(_selectedDate!)
                      : '选择时间（默认当前）',
                  style: _selectedDate == null
                      ? TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: '备注',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_outlined),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickProducts,
              icon: const Icon(Icons.add_shopping_cart),
              label: Text(
                _selectedProducts.isEmpty
                    ? '选择搭配单品'
                    : '已选 ${_selectedProducts.length} 件单品',
              ),
            ),
            if (_selectedProducts.isNotEmpty) ...[
              const SizedBox(height: 8),
              Column(
                children: _selectedProducts
                    .map(
                      (p) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (p.mainImage != null)
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        p.mainImage!,
                                      ),
                                    )
                                  else
                                    const CircleAvatar(
                                      child: Icon(Icons.shopping_bag_outlined),
                                    ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall,
                                        ),
                                        if (p.brand != null &&
                                            p.brand!.isNotEmpty)
                                          Text(
                                            p.brand!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: '移除',
                                    onPressed: () => _removeProduct(p.id),
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SegmentedButton<String>(
                                segments: const [
                                  ButtonSegment<String>(
                                    value: _mainItemType,
                                    label: Text('主要单品'),
                                    icon: Icon(Icons.checkroom_outlined),
                                  ),
                                  ButtonSegment<String>(
                                    value: _accessoryItemType,
                                    label: Text('配饰'),
                                    icon: Icon(Icons.diamond_outlined),
                                  ),
                                ],
                                selected: {_itemTypeOf(p.id)},
                                onSelectionChanged: (values) {
                                  setState(() {
                                    _itemTypes[p.id] = values.first;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProductPickerSheet extends ConsumerStatefulWidget {
  const _ProductPickerSheet({required this.alreadySelected});

  final List<ProductSelectItem> alreadySelected;

  @override
  ConsumerState<_ProductPickerSheet> createState() =>
      _ProductPickerSheetState();
}

class _ProductPickerSheetState extends ConsumerState<_ProductPickerSheet> {
  final _searchController = TextEditingController();
  String _keyword = '';
  final Map<String, ProductSelectItem> _selectedById = {};

  @override
  void initState() {
    super.initState();
    for (final product in widget.alreadySelected) {
      _selectedById[product.id] = product;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(outfitProductSearchProvider(_keyword));

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      expand: false,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: '搜索产品...',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (v) => setState(() => _keyword = v.trim()),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      ctx,
                      _selectedById.values.toList(growable: false),
                    );
                  },
                  child: const Text('确定'),
                ),
              ],
            ),
          ),
          Expanded(
            child: products.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('搜索失败: $e')),
              data: (pageResult) {
                if (pageResult.items.isEmpty) {
                  return const Center(child: Text('无结果'));
                }
                return ListView.builder(
                  controller: scrollCtrl,
                  itemCount: pageResult.items.length,
                  itemBuilder: (ctx, i) {
                    final p = pageResult.items[i];
                    final selected = _selectedById.containsKey(p.id);
                    return ListTile(
                      leading: p.mainImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                p.mainImage!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.shopping_bag_outlined),
                      title: Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: p.brand != null ? Text(p.brand!) : null,
                      trailing: Icon(
                        selected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedById.remove(p.id);
                          } else {
                            _selectedById[p.id] = p;
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
