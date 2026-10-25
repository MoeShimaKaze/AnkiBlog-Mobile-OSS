import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductCategoryManagePage extends ConsumerStatefulWidget {
  const ProductCategoryManagePage({super.key});

  @override
  ConsumerState<ProductCategoryManagePage> createState() =>
      _ProductCategoryManagePageState();
}

class _ProductCategoryManagePageState
    extends ConsumerState<ProductCategoryManagePage> {
  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryTreeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('产品分类管理')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(null),
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('加载失败: $e'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(categoryTreeProvider),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('暂无分类'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(categoryTreeProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  _buildCategoryTile(categories[index], 0),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTile(Map<String, dynamic> cat, int depth) {
    final id = cat['id']?.toString() ?? '';
    final name = cat['name']?.toString() ?? '';
    final productCount = cat['productCount'] ?? cat['product_count'] ?? 0;
    final active = cat['active'] == true;
    final children = cat['children'];
    final hasChildren = children is List && children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          opacity: active ? 1.0 : 0.5,
          child: GlassContainer(
            padding: EdgeInsets.only(
              left: 16.0 * depth,
              right: 12,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              children: [
                if (hasChildren)
                  Icon(
                    Icons.folder_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  )
                else
                  Icon(
                    Icons.label_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '$productCount 个产品',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          if (!active) ...[
                            const SizedBox(width: 8),
                            Text(
                              '已禁用',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'add-child') _showEditDialog(null, parentId: id);
                    if (v == 'edit') _showEditDialog(cat);
                    if (v == 'delete') _deleteCategory(id, name);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'add-child',
                      child: Text('添加子分类'),
                    ),
                    const PopupMenuItem(value: 'edit', child: Text('编辑')),
                    const PopupMenuItem(value: 'delete', child: Text('删除')),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (hasChildren) ...[
          const SizedBox(height: 4),
          ...children.whereType<Map<String, dynamic>>().map(
            (child) => _buildCategoryTile(child, depth + 1),
          ),
        ],
      ],
    );
  }

  Future<void> _deleteCategory(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除分类'),
        content: Text('确定要删除「$name」吗？子分类和关联产品不会被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ref.read(adminRepositoryProvider).deleteCategory(id);
        ref.invalidate(categoryTreeProvider);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('分类已删除')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
        }
      }
    }
  }

  void _showEditDialog(Map<String, dynamic>? cat, {String? parentId}) {
    final nameCtrl = TextEditingController(
      text: cat?['name']?.toString() ?? '',
    );
    final slugCtrl = TextEditingController(
      text: cat?['slug']?.toString() ?? '',
    );
    final descCtrl = TextEditingController(
      text: cat?['description']?.toString() ?? '',
    );
    final iconCtrl = TextEditingController(
      text: cat?['icon']?.toString() ?? '',
    );
    final colorCtrl = TextEditingController(
      text: cat?['color']?.toString() ?? '',
    );
    final sortOrderCtrl = TextEditingController(
      text: '${cat?['sortOrder'] ?? cat?['sort_order'] ?? 0}',
    );
    bool active = cat?['active'] ?? true;
    bool featured = cat?['featured'] ?? false;
    bool showInMenu = cat?['showInMenu'] ?? cat?['show_in_menu'] ?? true;
    bool showOnHomepage =
        cat?['showOnHomepage'] ?? cat?['show_on_homepage'] ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(cat == null ? '添加分类' : '编辑分类'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: '分类名称 *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: slugCtrl,
                  decoration: const InputDecoration(
                    labelText: '路径标识',
                    border: OutlineInputBorder(),
                    hintText: 'e.g. skincare',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: '描述（可选）',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: iconCtrl,
                        decoration: const InputDecoration(
                          labelText: '图标（可选）',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: colorCtrl,
                        decoration: const InputDecoration(
                          labelText: '颜色（可选）',
                          border: OutlineInputBorder(),
                          hintText: '#ff6b6b',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: sortOrderCtrl,
                  decoration: const InputDecoration(
                    labelText: '排序',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  title: const Text('启用'),
                  value: active,
                  onChanged: (v) => setDialogState(() => active = v),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('精选'),
                  value: featured,
                  onChanged: (v) => setDialogState(() => featured = v),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('显示在菜单'),
                  value: showInMenu,
                  onChanged: (v) => setDialogState(() => showInMenu = v),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('首页展示'),
                  value: showOnHomepage,
                  onChanged: (v) => setDialogState(() => showOnHomepage = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(
                    ctx,
                  ).showSnackBar(const SnackBar(content: Text('请输入分类名称')));
                  return;
                }
                final body = <String, dynamic>{
                  'name': nameCtrl.text.trim(),
                  'active': active,
                  'featured': featured,
                  'showInMenu': showInMenu,
                  'showOnHomepage': showOnHomepage,
                };
                if (slugCtrl.text.trim().isNotEmpty) {
                  body['slug'] = slugCtrl.text.trim();
                }
                if (descCtrl.text.trim().isNotEmpty) {
                  body['description'] = descCtrl.text.trim();
                }
                if (iconCtrl.text.trim().isNotEmpty) {
                  body['icon'] = iconCtrl.text.trim();
                }
                if (colorCtrl.text.trim().isNotEmpty) {
                  body['color'] = colorCtrl.text.trim();
                }
                final sortOrder = int.tryParse(sortOrderCtrl.text.trim());
                if (sortOrder != null) body['sortOrder'] = sortOrder;
                if (parentId != null) body['parentId'] = parentId;
                if (cat?['parentId'] != null && parentId == null) {
                  body['parentId'] = cat!['parentId'];
                }

                try {
                  final repo = ref.read(adminRepositoryProvider);
                  if (cat == null) {
                    await repo.createCategory(body);
                  } else {
                    await repo.updateCategory(cat['id'].toString(), body);
                  }
                  Navigator.pop(ctx);
                  ref.invalidate(categoryTreeProvider);
                } catch (e) {
                  ScaffoldMessenger.of(
                    ctx,
                  ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
