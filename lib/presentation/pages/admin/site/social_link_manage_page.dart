import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SocialLinkManagePage extends ConsumerStatefulWidget {
  const SocialLinkManagePage({super.key});

  @override
  ConsumerState<SocialLinkManagePage> createState() =>
      _SocialLinkManagePageState();
}

class _SocialLinkManagePageState extends ConsumerState<SocialLinkManagePage> {
  List<AdminSocialLink> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final links = await ref.read(adminRepositoryProvider).getSocialLinks();
      setState(() {
        _items = links;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _delete(AdminSocialLink link) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除社交链接'),
        content: Text('确定要删除「${link.name}」吗？'),
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
        await ref.read(adminRepositoryProvider).deleteSocialLink(link.id);
        _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('社交链接')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(null),
        child: const Icon(Icons.add),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton(onPressed: _load, child: const Text('重试')),
          ],
        ),
      );
    }
    if (_items.isEmpty) return const Center(child: Text('暂无社交链接'));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) => _SocialLinkCard(
          link: _items[index],
          onEdit: () => _showEditDialog(_items[index]),
          onDelete: () => _delete(_items[index]),
        ),
      ),
    );
  }

  void _showEditDialog(AdminSocialLink? link) {
    final titleCtrl = TextEditingController(text: link?.name ?? '');
    final urlCtrl = TextEditingController(text: link?.url ?? '');
    final iconCtrl = TextEditingController(text: link?.icon ?? '');
    final platformCtrl = TextEditingController(text: link?.platform ?? '');
    final descCtrl = TextEditingController(text: link?.description ?? '');
    final colorCtrl = TextEditingController(text: link?.color ?? '');
    final sortOrderCtrl = TextEditingController(
      text: '${link?.sortOrder ?? 0}',
    );
    final groupCtrl = TextEditingController(text: link?.groupName ?? '');
    bool active = link?.active ?? true;
    bool openInNewTab = link?.openInNewTab ?? true;
    bool featured = link?.featured ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(link == null ? '添加社交链接' : '编辑社交链接'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: '标题 *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: platformCtrl,
                  decoration: const InputDecoration(
                    labelText: '平台标识（如 GITHUB, TWITTER）',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: iconCtrl,
                  decoration: const InputDecoration(
                    labelText: '图标名称（可选）',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: '描述（可选）',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: colorCtrl,
                        decoration: const InputDecoration(
                          labelText: '颜色（可选）',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: sortOrderCtrl,
                        decoration: const InputDecoration(
                          labelText: '排序',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: groupCtrl,
                  decoration: const InputDecoration(
                    labelText: '分组名（可选）',
                    border: OutlineInputBorder(),
                  ),
                ),
                SwitchListTile(
                  title: const Text('启用'),
                  value: active,
                  onChanged: (v) => setDialogState(() => active = v),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('新窗口打开'),
                  value: openInNewTab,
                  onChanged: (v) => setDialogState(() => openInNewTab = v),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('精选'),
                  value: featured,
                  onChanged: (v) => setDialogState(() => featured = v),
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
                final body = <String, dynamic>{
                  'title': titleCtrl.text.trim(),
                  'url': urlCtrl.text.trim(),
                  'active': active,
                  'openInNewTab': openInNewTab,
                  'featured': featured,
                };
                if (platformCtrl.text.trim().isNotEmpty) {
                  body['platform'] = platformCtrl.text.trim();
                }
                if (iconCtrl.text.trim().isNotEmpty) {
                  body['icon'] = iconCtrl.text.trim();
                }
                if (descCtrl.text.trim().isNotEmpty) {
                  body['description'] = descCtrl.text.trim();
                }
                if (colorCtrl.text.trim().isNotEmpty) {
                  body['color'] = colorCtrl.text.trim();
                }
                final sortOrder = int.tryParse(sortOrderCtrl.text.trim());
                if (sortOrder != null) {
                  body['sortOrder'] = sortOrder;
                }
                if (groupCtrl.text.trim().isNotEmpty) {
                  body['groupName'] = groupCtrl.text.trim();
                }
                try {
                  final repo = ref.read(adminRepositoryProvider);
                  if (link == null) {
                    await repo.createSocialLink(body);
                  } else {
                    await repo.updateSocialLink(link.id, body);
                  }
                  Navigator.pop(ctx);
                  _load();
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

class _SocialLinkCard extends StatelessWidget {
  const _SocialLinkCard({
    required this.link,
    required this.onEdit,
    required this.onDelete,
  });

  final AdminSocialLink link;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Opacity(
      opacity: link.active ? 1.0 : 0.5,
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  link.name.isNotEmpty ? link.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: cs.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          link.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (link.featured)
                        Icon(Icons.star, size: 14, color: cs.primary),
                    ],
                  ),
                  Text(
                    link.url ?? '',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      if (link.platformName != null &&
                          link.platformName!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            link.platformName!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(fontSize: 11),
                          ),
                        ),
                      ] else if (link.platform != null &&
                          link.platform!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            link.platform!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(fontSize: 11),
                          ),
                        ),
                      ],
                      if (!link.active) ...[
                        const SizedBox(width: 6),
                        Text(
                          '已禁用',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: cs.error, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('编辑')),
                const PopupMenuItem(value: 'delete', child: Text('删除')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
