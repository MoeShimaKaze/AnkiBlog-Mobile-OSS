import 'package:ankiblog_mobile/presentation/common/widgets/image_upload_field.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AdminMakeupFormPage extends ConsumerStatefulWidget {
  const AdminMakeupFormPage({super.key});

  @override
  ConsumerState<AdminMakeupFormPage> createState() =>
      _AdminMakeupFormPageState();
}

class _AdminMakeupFormPageState extends ConsumerState<AdminMakeupFormPage> {
  final _lookNameController = TextEditingController();
  final _noteController = TextEditingController();
  final _referenceUrlController = TextEditingController();
  String? _imageUrl;
  DateTime? _selectedDate;
  List<ProductSelectItem> _selectedProducts = [];
  final Map<String, String> _usageTypes = {};
  bool _submitting = false;

  @override
  void dispose() {
    _lookNameController.dispose();
    _noteController.dispose();
    _referenceUrlController.dispose();
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
      builder: (ctx) => _ProductPickerSheet(
        alreadySelected: _selectedProducts.map((p) => p.id).toSet(),
      ),
    );
    if (result != null) {
      setState(() => _selectedProducts = result);
    }
  }

  Future<void> _submit() async {
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请至少选择一个产品')));
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref
          .read(adminRepositoryProvider)
          .createMakeup(
            productIds: _selectedProducts.map((p) => p.id).toList(),
            usageTypes: _usageTypes.isEmpty ? null : _usageTypes,
            lookName: _lookNameController.text.isEmpty
                ? null
                : _lookNameController.text,
            referenceUrl: _referenceUrlController.text.isEmpty
                ? null
                : _referenceUrlController.text,
            makeupImage: _imageUrl,
            makeupDate: _selectedDate?.toIso8601String(),
            note: _noteController.text.isEmpty ? null : _noteController.text,
          );
      ref.invalidate(adminMakeupListProvider);
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
        title: const Text('新建妆容'),
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
              label: '妆容照片',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lookNameController,
              decoration: const InputDecoration(
                labelText: '妆容名称',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.face),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '妆容时间',
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
              controller: _referenceUrlController,
              decoration: const InputDecoration(
                labelText: '参考链接',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              keyboardType: TextInputType.url,
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
                    ? '选择使用产品'
                    : '已选 ${_selectedProducts.length} 件产品',
              ),
            ),
            if (_selectedProducts.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _selectedProducts
                    .map(
                      (p) => Chip(
                        avatar: p.mainImage != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(p.mainImage!),
                              )
                            : null,
                        label: Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onDeleted: () {
                          setState(() {
                            _selectedProducts = _selectedProducts
                                .where((s) => s.id != p.id)
                                .toList();
                            _usageTypes.remove(p.id);
                          });
                        },
                      ),
                    )
                    .toList(),
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

  final Set<String> alreadySelected;

  @override
  ConsumerState<_ProductPickerSheet> createState() =>
      _ProductPickerSheetState();
}

class _ProductPickerSheetState extends ConsumerState<_ProductPickerSheet> {
  final _searchController = TextEditingController();
  String _keyword = '';
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _selected.addAll(widget.alreadySelected);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productSearchProvider(_keyword));

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
                    final result =
                        products.valueOrNull?.items
                            .where((p) => _selected.contains(p.id))
                            .toList() ??
                        [];
                    Navigator.pop(ctx, result);
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
                    final selected = _selected.contains(p.id);
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
                            _selected.remove(p.id);
                          } else {
                            _selected.add(p.id);
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
