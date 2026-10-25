import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知管理'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '渠道', icon: Icon(Icons.notifications_outlined)),
            Tab(text: '钉钉', icon: Icon(Icons.chat_outlined)),
            Tab(text: '日志', icon: Icon(Icons.list_alt_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_ChannelsTab(), _DingtalkTab(), _LogsTab()],
      ),
    );
  }
}

class _ChannelsTab extends ConsumerWidget {
  const _ChannelsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(notificationChannelsProvider);

    return channelsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $e'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.invalidate(notificationChannelsProvider),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
      data: (channels) {
        if (channels.isEmpty) {
          return const Center(child: Text('暂无通知渠道'));
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(notificationChannelsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: channels.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final ch = channels[index];
              final name =
                  ch['typeDescription']?.toString() ??
                  ch['typeCode']?.toString() ??
                  '未知';
              final emailEnabled = ch['emailEnabled'] == true;
              final dingtalkEnabled = ch['dingtalkEnabled'] == true;
              final enabled = emailEnabled || dingtalkEnabled;
              final type = ch['typeCode']?.toString() ?? '';
              final category = ch['typeCategory']?.toString() ?? '';

              return GlassContainer(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      enabled
                          ? Icons.notifications_active
                          : Icons.notifications_off_outlined,
                      color: enabled
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Row(
                            children: [
                              if (category.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryContainer
                                        .withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    category,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(fontSize: 11),
                                  ),
                                ),
                              if (type.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Text(
                                  type,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 14,
                              color: emailEnabled
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '邮件',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chat_outlined,
                              size: 14,
                              color: dingtalkEnabled
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '钉钉',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _DingtalkTab extends ConsumerStatefulWidget {
  const _DingtalkTab();

  @override
  ConsumerState<_DingtalkTab> createState() => _DingtalkTabState();
}

class _DingtalkTabState extends ConsumerState<_DingtalkTab> {
  final _webhookCtrl = TextEditingController();
  final _secretCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final config = await ref
          .read(adminRepositoryProvider)
          .getDingtalkConfig();
      setState(() {
        _webhookCtrl.text =
            config['webhookUrl']?.toString() ??
            config['webhook_url']?.toString() ??
            '';
        _secretCtrl.text = config['secret']?.toString() ?? '';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).updateDingtalkConfig({
        'webhook_url': _webhookCtrl.text.trim(),
        'secret': _secretCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已保存')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<void> _test() async {
    try {
      await ref.read(adminRepositoryProvider).testDingtalk();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('测试消息已发送')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('测试失败: $e')));
      }
    }
  }

  @override
  void dispose() {
    _webhookCtrl.dispose();
    _secretCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('钉钉机器人配置', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 16),
              TextField(
                controller: _webhookCtrl,
                decoration: const InputDecoration(
                  labelText: 'Webhook URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _secretCtrl,
                decoration: const InputDecoration(
                  labelText: 'Secret',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('保存'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(onPressed: _test, child: const Text('发送测试')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LogsTab extends ConsumerStatefulWidget {
  const _LogsTab();

  @override
  ConsumerState<_LogsTab> createState() => _LogsTabState();
}

class _LogsTabState extends ConsumerState<_LogsTab> {
  final List<AdminNotificationLog> _items = [];
  final ScrollController _scrollController = ScrollController();
  int _page = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _error;
  String? _typeFilter;
  String? _channelFilter;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  void _resetAndReload() {
    setState(() {
      _items.clear();
      _page = 0;
      _hasMore = true;
      _isInitialLoading = true;
    });
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final page = await ref
          .read(adminRepositoryProvider)
          .getNotificationLogs(
            type: _typeFilter,
            channel: _channelFilter,
            status: _statusFilter,
            page: _page,
            size: 20,
          );
      setState(() {
        _items.addAll(page.content);
        _hasMore = page.hasNext;
        _page++;
        _isInitialLoading = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isInitialLoading = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                setState(() {
                  _items.clear();
                  _page = 0;
                  _hasMore = true;
                  _isInitialLoading = true;
                });
                _loadMore();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }
    if (_items.isEmpty) return const Center(child: Text('暂无通知日志'));

    return RefreshIndicator(
      onRefresh: () async => _resetAndReload(),
      child: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _items.length + (_hasMore ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                if (index == _items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final log = _items[index];
                final cs = Theme.of(context).colorScheme;
                final isSuccess =
                    log.status == 'SUCCESS' || log.status == 'SENT';

                return GlassContainer(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        isSuccess
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                        color: isSuccess ? cs.primary : cs.error,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.title ?? log.type ?? '通知',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            Row(
                              children: [
                                if (log.channel != null)
                                  Text(
                                    log.channel!,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                if (log.sentAt != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    log.sentAt!.length >= 16
                                        ? log.sentAt!.substring(0, 16)
                                        : log.sentAt!,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _filterDropdown(
            label: '类型',
            value: _typeFilter,
            options: const {
              null: '全部',
              'COMMENT': '评论',
              'SUBSCRIPTION': '订阅',
              'SYSTEM': '系统',
            },
            onChanged: (v) {
              setState(() => _typeFilter = v);
              _resetAndReload();
            },
          ),
          const SizedBox(width: 8),
          _filterDropdown(
            label: '渠道',
            value: _channelFilter,
            options: const {null: '全部', 'EMAIL': '邮件', 'DINGTALK': '钉钉'},
            onChanged: (v) {
              setState(() => _channelFilter = v);
              _resetAndReload();
            },
          ),
          const SizedBox(width: 8),
          _filterDropdown(
            label: '状态',
            value: _statusFilter,
            options: const {
              null: '全部',
              'SUCCESS': '成功',
              'SENT': '已发送',
              'FAILED': '失败',
            },
            onChanged: (v) {
              setState(() => _statusFilter = v);
              _resetAndReload();
            },
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown({
    required String label,
    required String? value,
    required Map<String?, String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: options.entries
            .map(
              (e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value, style: const TextStyle(fontSize: 13)),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
