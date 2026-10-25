import 'package:ankiblog_mobile/data/models/daily_outfit.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DailyOutfitManagePage extends ConsumerStatefulWidget {
  const DailyOutfitManagePage({super.key});

  @override
  ConsumerState<DailyOutfitManagePage> createState() =>
      _DailyOutfitManagePageState();
}

class _DailyOutfitManagePageState extends ConsumerState<DailyOutfitManagePage> {
  final List<DailyOutfitSuggestion> _items = [];
  bool _loading = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final page = await ref
          .read(adminRepositoryProvider)
          .getDailyOutfits(status: _status, size: 50);
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(page.content);
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _generate({bool regenerate = false}) async {
    final settings = await showModalBottomSheet<_GenerateSettings>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _GenerateSheet(),
    );
    if (settings == null) return;

    setState(() => _loading = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      if (regenerate) {
        await repo.regenerateDailyOutfit(
          itemCount: settings.itemCount,
          onlyPurchased: settings.onlyPurchased,
          isPublic: settings.isPublic,
          note: settings.note,
        );
      } else {
        await repo.generateDailyOutfit(
          itemCount: settings.itemCount,
          onlyPurchased: settings.onlyPurchased,
          isPublic: settings.isPublic,
          note: settings.note,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(regenerate ? '已重新抽取' : '已抽取今日穿搭')));
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('操作失败：$error')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _runAction(
    DailyOutfitSuggestion item,
    String label,
    Future<void> Function() action,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        content: Text('确定要$label这条推荐吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await action();
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$label成功')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$label失败：$error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今天穿什么'),
        actions: [
          IconButton(
            tooltip: '重新抽取',
            icon: const Icon(Icons.shuffle),
            onPressed: _loading ? null : () => _generate(regenerate: true),
          ),
          IconButton(
            tooltip: '刷新',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : _generate,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('抽取'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 54,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _StatusFilterChip(
                  label: '全部',
                  selected: _status == null,
                  onSelected: () {
                    setState(() => _status = null);
                    _load();
                  },
                ),
                _StatusFilterChip(
                  label: '待处理',
                  selected: _status == 'PENDING',
                  onSelected: () {
                    setState(() => _status = 'PENDING');
                    _load();
                  },
                ),
                _StatusFilterChip(
                  label: '已接受',
                  selected: _status == 'ACCEPTED',
                  onSelected: () {
                    setState(() => _status = 'ACCEPTED');
                    _load();
                  },
                ),
                _StatusFilterChip(
                  label: '已拒绝',
                  selected: _status == 'REJECTED',
                  onSelected: () {
                    setState(() => _status = 'REJECTED');
                    _load();
                  },
                ),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: _items.isEmpty && !_loading
                ? const Center(child: Text('暂无推荐记录'))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                      itemCount: _items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return _AdminDailyOutfitCard(
                          suggestion: item,
                          onAccept: item.isPending
                              ? () => _runAction(
                                  item,
                                  '接受',
                                  () => ref
                                      .read(adminRepositoryProvider)
                                      .acceptDailyOutfit(item.id),
                                )
                              : null,
                          onReject: item.isPending
                              ? () => _runAction(
                                  item,
                                  '拒绝',
                                  () => ref
                                      .read(adminRepositoryProvider)
                                      .rejectDailyOutfit(item.id),
                                )
                              : null,
                          onDelete: () => _runAction(
                            item,
                            '删除',
                            () => ref
                                .read(adminRepositoryProvider)
                                .deleteDailyOutfit(item.id),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatusFilterChip extends StatelessWidget {
  const _StatusFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

class _AdminDailyOutfitCard extends StatelessWidget {
  const _AdminDailyOutfitCard({
    required this.suggestion,
    this.onAccept,
    this.onReject,
    required this.onDelete,
  });

  final DailyOutfitSuggestion suggestion;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  suggestion.suggestionDate,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Chip(
                label: Text(suggestion.statusDisplayName),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          if (suggestion.note?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(suggestion.note!),
          ],
          const SizedBox(height: 12),
          if (suggestion.items.isEmpty)
            const Text('暂无推荐单品')
          else
            Column(
              children: [
                for (final item in suggestion.items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: RemoteImage(
                        url: item.productMainImage,
                        width: 56,
                        height: 56,
                      ),
                    ),
                    title: Text(item.productName ?? '未命名单品'),
                    subtitle: Text(
                      [
                        if (item.brand?.isNotEmpty == true) item.brand!,
                        if (item.categoryName?.isNotEmpty == true)
                          item.categoryName!,
                      ].join(' / '),
                    ),
                    trailing: item.productSlug == null
                        ? null
                        : const Icon(Icons.chevron_right),
                    onTap: item.productSlug == null
                        ? null
                        : () => context.push('/products/${item.productSlug}'),
                  ),
              ],
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (onAccept != null)
                FilledButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check),
                  label: const Text('接受'),
                ),
              if (onReject != null)
                OutlinedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.close),
                  label: const Text('拒绝'),
                ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('删除'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenerateSettings {
  const _GenerateSettings({
    required this.itemCount,
    required this.onlyPurchased,
    required this.isPublic,
    required this.note,
  });

  final int itemCount;
  final bool onlyPurchased;
  final bool isPublic;
  final String? note;
}

class _GenerateSheet extends StatefulWidget {
  const _GenerateSheet();

  @override
  State<_GenerateSheet> createState() => _GenerateSheetState();
}

class _GenerateSheetState extends State<_GenerateSheet> {
  int _itemCount = 3;
  bool _onlyPurchased = true;
  bool _isPublic = true;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '抽取设置',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('单品数量'),
                Expanded(
                  child: Slider(
                    value: _itemCount.toDouble(),
                    min: 1,
                    max: 8,
                    divisions: 7,
                    label: _itemCount.toString(),
                    onChanged: (value) =>
                        setState(() => _itemCount = value.round()),
                  ),
                ),
                Text('$_itemCount'),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('只从已购商品中抽取'),
              value: _onlyPurchased,
              onChanged: (value) => setState(() => _onlyPurchased = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('公开展示'),
              value: _isPublic,
              onChanged: (value) => setState(() => _isPublic = value),
            ),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '备注',
                hintText: '记录天气、心情或场合',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(
                  context,
                  _GenerateSettings(
                    itemCount: _itemCount,
                    onlyPurchased: _onlyPurchased,
                    isPublic: _isPublic,
                    note: _noteController.text.trim().isEmpty
                        ? null
                        : _noteController.text.trim(),
                  ),
                ),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('开始抽取'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
