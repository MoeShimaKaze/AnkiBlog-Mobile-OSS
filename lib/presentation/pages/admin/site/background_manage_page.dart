import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _bgDisplayName(AdminBackground bg) {
  if (bg.name != null && bg.name!.isNotEmpty) return bg.name!;
  switch (bg.type) {
    case 'COLOR':
      return '纯色背景 ${bg.value ?? ''}';
    case 'GRADIENT':
      return '渐变背景';
    case 'IMAGE':
      return '图片背景';
    case 'API':
      return 'API 背景';
    default:
      return '背景 #${bg.id.substring(0, 8)}';
  }
}

String _bgTypeLabel(String? type) {
  switch (type) {
    case 'COLOR':
      return '纯色';
    case 'GRADIENT':
      return '渐变';
    case 'IMAGE':
      return '图片';
    case 'API':
      return 'API';
    default:
      return type ?? '未知';
  }
}

class BackgroundManagePage extends ConsumerStatefulWidget {
  const BackgroundManagePage({super.key});

  @override
  ConsumerState<BackgroundManagePage> createState() =>
      _BackgroundManagePageState();
}

class _BackgroundManagePageState extends ConsumerState<BackgroundManagePage> {
  List<AdminBackground> _items = [];
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
      final page = await ref
          .read(adminRepositoryProvider)
          .getBackgrounds(size: 100);
      setState(() {
        _items = page.content;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _toggle(AdminBackground bg) async {
    try {
      await ref.read(adminRepositoryProvider).toggleBackground(bg.id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
      }
    }
  }

  Future<void> _delete(AdminBackground bg) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除背景'),
        content: Text('确定要删除「${_bgDisplayName(bg)}」吗？'),
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
        await ref.read(adminRepositoryProvider).deleteBackground(bg.id);
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
      appBar: AppBar(title: const Text('背景管理')),
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
    if (_items.isEmpty) return const Center(child: Text('暂无背景'));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) => _BackgroundCard(
          background: _items[index],
          onToggle: () => _toggle(_items[index]),
          onEdit: () => _showEditDialog(_items[index]),
          onDelete: () => _delete(_items[index]),
        ),
      ),
    );
  }

  String _valueLabel(String type) {
    switch (type) {
      case 'COLOR':
        return '颜色值';
      case 'GRADIENT':
        return 'CSS 渐变';
      case 'IMAGE':
        return '图片 URL';
      case 'API':
        return 'API URL';
      default:
        return '值';
    }
  }

  String _valueHint(String type) {
    switch (type) {
      case 'COLOR':
        return '#1a1a2e';
      case 'GRADIENT':
        return 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)';
      case 'IMAGE':
        return 'https://...';
      case 'API':
        return 'https://api.example.com/background';
      default:
        return '';
    }
  }

  void _showEditDialog(AdminBackground? bg) {
    final nameCtrl = TextEditingController(text: bg?.name ?? '');
    final valueCtrl = TextEditingController(text: bg?.value ?? '');
    String type = bg?.type ?? 'IMAGE';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(bg == null ? '添加背景' : '编辑背景'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: '名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(
                    labelText: '类型',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'IMAGE', child: Text('图片')),
                    DropdownMenuItem(value: 'API', child: Text('API')),
                    DropdownMenuItem(value: 'COLOR', child: Text('纯色')),
                    DropdownMenuItem(value: 'GRADIENT', child: Text('渐变')),
                  ],
                  onChanged: (v) => setDialogState(() => type = v ?? 'IMAGE'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valueCtrl,
                  decoration: InputDecoration(
                    labelText: _valueLabel(type),
                    hintText: _valueHint(type),
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: type == 'GRADIENT' ? 3 : 1,
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
                  'type': type,
                  'value': valueCtrl.text.trim(),
                };
                try {
                  final repo = ref.read(adminRepositoryProvider);
                  if (bg == null) {
                    await repo.createBackground(body);
                  } else {
                    await repo.updateBackground(bg.id, body);
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

class _BackgroundCard extends StatelessWidget {
  const _BackgroundCard({
    required this.background,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final AdminBackground background;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (background.type == 'IMAGE' &&
              background.value != null &&
              background.value!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: RemoteImage(
                url: background.value!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.wallpaper_outlined),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _bgDisplayName(background),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  _bgTypeLabel(background.type),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Switch(value: background.active, onChanged: (_) => onToggle()),
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
