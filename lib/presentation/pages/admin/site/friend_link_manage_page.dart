import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class FriendLinkManagePage extends ConsumerStatefulWidget {
  const FriendLinkManagePage({super.key});

  @override
  ConsumerState<FriendLinkManagePage> createState() =>
      _FriendLinkManagePageState();
}

class _FriendLinkManagePageState extends ConsumerState<FriendLinkManagePage> {
  List<AdminFriendLink> _items = [];
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
      final links = await ref.read(adminRepositoryProvider).getFriendLinks();
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

  Future<void> _approve(AdminFriendLink link) async {
    try {
      await ref.read(adminRepositoryProvider).approveFriendLink(link.id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
      }
    }
  }

  Future<void> _reject(AdminFriendLink link) async {
    try {
      await ref.read(adminRepositoryProvider).rejectFriendLink(link.id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
      }
    }
  }

  Future<void> _delete(AdminFriendLink link) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除友链'),
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
        await ref.read(adminRepositoryProvider).deleteFriendLink(link.id);
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
      appBar: AppBar(title: const Text('友情链接')),
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
    if (_items.isEmpty) return const Center(child: Text('暂无友链'));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) => _FriendLinkCard(
          link: _items[index],
          onApprove: () => _approve(_items[index]),
          onReject: () => _reject(_items[index]),
          onEdit: () => _showEditDialog(_items[index]),
          onDelete: () => _delete(_items[index]),
        ),
      ),
    );
  }

  void _showEditDialog(AdminFriendLink? link) {
    final nameCtrl = TextEditingController(text: link?.name ?? '');
    final urlCtrl = TextEditingController(text: link?.url ?? '');
    final logoCtrl = TextEditingController(text: link?.logo ?? '');
    final descCtrl = TextEditingController(text: link?.description ?? '');
    final avatarUrlCtrl = TextEditingController(text: link?.avatarUrl ?? '');
    final ownerNameCtrl = TextEditingController(text: link?.ownerName ?? '');
    final ownerEmailCtrl = TextEditingController(text: link?.ownerEmail ?? '');
    final sortOrderCtrl = TextEditingController(
      text: link != null ? '${link.sortOrder}' : '0',
    );
    final categoryCtrl = TextEditingController(text: link?.category ?? '');
    final adminNoteCtrl = TextEditingController(text: link?.adminNote ?? '');
    bool reciprocal = link?.reciprocal ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(link == null ? '添加友链' : '编辑友链'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: '名称 *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: logoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Logo URL（可选）',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: avatarUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: '头像 URL（可选）',
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
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ownerNameCtrl,
                  decoration: const InputDecoration(
                    labelText: '站长名称（可选）',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ownerEmailCtrl,
                  decoration: const InputDecoration(
                    labelText: '站长邮箱（可选）',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: categoryCtrl,
                        decoration: const InputDecoration(
                          labelText: '分类（可选）',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('互惠链接'),
                  subtitle: const Text('需要对方也添加本站链接'),
                  value: reciprocal,
                  onChanged: (v) => setDialogState(() => reciprocal = v),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: adminNoteCtrl,
                  decoration: const InputDecoration(
                    labelText: '管理员备注（可选）',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
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
                  'name': nameCtrl.text.trim(),
                  'url': urlCtrl.text.trim(),
                  'sortOrder': int.tryParse(sortOrderCtrl.text.trim()) ?? 0,
                  'reciprocal': reciprocal,
                };
                if (logoCtrl.text.trim().isNotEmpty) {
                  body['logo'] = logoCtrl.text.trim();
                }
                if (avatarUrlCtrl.text.trim().isNotEmpty) {
                  body['avatarUrl'] = avatarUrlCtrl.text.trim();
                }
                if (descCtrl.text.trim().isNotEmpty) {
                  body['description'] = descCtrl.text.trim();
                }
                if (ownerNameCtrl.text.trim().isNotEmpty) {
                  body['ownerName'] = ownerNameCtrl.text.trim();
                }
                if (ownerEmailCtrl.text.trim().isNotEmpty) {
                  body['ownerEmail'] = ownerEmailCtrl.text.trim();
                }
                if (categoryCtrl.text.trim().isNotEmpty) {
                  body['category'] = categoryCtrl.text.trim();
                }
                if (adminNoteCtrl.text.trim().isNotEmpty) {
                  body['adminNote'] = adminNoteCtrl.text.trim();
                }
                try {
                  final repo = ref.read(adminRepositoryProvider);
                  if (link == null) {
                    await repo.createFriendLink(body);
                  } else {
                    await repo.updateFriendLink(link.id, body);
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

class _FriendLinkCard extends StatelessWidget {
  const _FriendLinkCard({
    required this.link,
    required this.onApprove,
    required this.onReject,
    required this.onEdit,
    required this.onDelete,
  });

  final AdminFriendLink link;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  ImageProvider? _avatarImage(AdminFriendLink link) {
    if (link.avatarUrl != null && link.avatarUrl!.isNotEmpty) {
      return NetworkImage(link.avatarUrl!);
    }
    if (link.logo != null && link.logo!.isNotEmpty) {
      return NetworkImage(link.logo!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isPending = link.status == 'PENDING';

    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: _avatarImage(link),
            child: _avatarImage(link) == null
                ? const Icon(Icons.link, size: 20)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: link.url != null && link.url!.isNotEmpty
                  ? () => launchUrl(
                      Uri.parse(link.url!),
                      mode: LaunchMode.externalApplication,
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    link.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    link.url ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.primary,
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      if (link.ownerName != null &&
                          link.ownerName!.isNotEmpty) ...[
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          link.ownerName!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontSize: 11,
                              ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (link.category != null &&
                          link.category!.isNotEmpty) ...[
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
                            link.category!,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(fontSize: 11),
                          ),
                        ),
                      ],
                      if (link.reciprocal) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.swap_horiz,
                          size: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                  if (isPending)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: cs.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '待审核',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onTertiaryContainer,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isPending) ...[
            IconButton(
              icon: Icon(Icons.check, color: cs.primary),
              tooltip: '批准',
              onPressed: onApprove,
            ),
            IconButton(
              icon: Icon(Icons.close, color: cs.error),
              tooltip: '拒绝',
              onPressed: onReject,
            ),
          ],
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
    );
  }
}
