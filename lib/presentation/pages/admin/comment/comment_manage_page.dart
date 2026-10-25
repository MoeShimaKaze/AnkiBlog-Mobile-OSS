import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentManagePage extends ConsumerStatefulWidget {
  const CommentManagePage({super.key});

  @override
  ConsumerState<CommentManagePage> createState() => _CommentManagePageState();
}

class _CommentManagePageState extends ConsumerState<CommentManagePage> {
  final List<AdminComment> _items = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int _page = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _error;
  String? _statusFilter;
  String? _keyword;

  static const _statusOptions = [
    (null, '全部'),
    ('PENDING', '待审核'),
    ('APPROVED', '已通过'),
    ('REJECTED', '已拒绝'),
    ('SPAM', '垃圾'),
    ('DELETED', '回收站'),
  ];

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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
          .getComments(
            status: _statusFilter,
            keyword: _keyword,
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

  Future<void> _approve(AdminComment comment) async {
    try {
      await ref.read(adminRepositoryProvider).approveComment(comment.id);
      _resetAndReload();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已通过')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
      }
    }
  }

  Future<void> _reject(AdminComment comment) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('拒绝评论'),
        content: TextField(
          controller: reasonController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入拒绝原因（可选）',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('拒绝'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final reason = reasonController.text.trim();
      await ref
          .read(adminRepositoryProvider)
          .rejectComment(comment.id, reason: reason.isNotEmpty ? reason : null);
      _resetAndReload();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已拒绝')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
      }
    }
  }

  Future<void> _markSpam(AdminComment comment) async {
    try {
      await ref.read(adminRepositoryProvider).spamComment(comment.id);
      _resetAndReload();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已标记为垃圾')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
      }
    }
  }

  Future<void> _delete(AdminComment comment) async {
    try {
      await ref.read(adminRepositoryProvider).deleteComment(comment.id);
      _resetAndReload();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已删除')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
      }
    }
  }

  Future<void> _showReplyDialog(AdminComment comment) async {
    if (comment.articleId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('无法回复：缺少文章ID')));
      return;
    }
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('回复 ${comment.authorName ?? '匿名'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                comment.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '输入回复内容...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('回复'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      try {
        await ref
            .read(adminRepositoryProvider)
            .replyToComment(comment.articleId!, result, parentId: comment.id);
        _resetAndReload();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('回复成功')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('回复失败: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('评论管理')),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatusFilter(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索评论内容...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _keyword != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _keyword = null;
                    _resetAndReload();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        onSubmitted: (v) {
          _keyword = v.trim().isEmpty ? null : v.trim();
          _resetAndReload();
        },
      ),
    );
  }

  Widget _buildStatusFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _statusOptions.map((opt) {
          final selected = _statusFilter == opt.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(opt.$2),
              selected: selected,
              onSelected: (_) {
                setState(() => _statusFilter = selected ? null : opt.$1);
                _resetAndReload();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            FilledButton(onPressed: _resetAndReload, child: const Text('重试')),
          ],
        ),
      );
    }
    if (_items.isEmpty) {
      return const Center(child: Text('暂无评论'));
    }

    return RefreshIndicator(
      onRefresh: () async => _resetAndReload(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _items.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _CommentCard(
            comment: _items[index],
            onApprove: () => _approve(_items[index]),
            onReject: () => _reject(_items[index]),
            onSpam: () => _markSpam(_items[index]),
            onDelete: () => _delete(_items[index]),
            onReply: () => _showReplyDialog(_items[index]),
          );
        },
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({
    required this.comment,
    required this.onApprove,
    required this.onReject,
    required this.onSpam,
    required this.onDelete,
    required this.onReply,
  });

  final AdminComment comment;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onSpam;
  final VoidCallback onDelete;
  final VoidCallback onReply;

  Color _statusColor(String status, ColorScheme cs) {
    return switch (status) {
      'PENDING' => cs.tertiary,
      'APPROVED' => cs.primary,
      'REJECTED' => cs.error,
      'SPAM' => cs.error,
      'DELETED' => cs.onSurfaceVariant,
      _ => cs.onSurfaceVariant,
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'PENDING' => '待审核',
      'APPROVED' => '已通过',
      'REJECTED' => '已拒绝',
      'SPAM' => '垃圾',
      'DELETED' => '回收站',
      _ => status,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final authorName = comment.authorName ?? '匿名';

    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage:
                    comment.authorAvatar != null &&
                        comment.authorAvatar!.isNotEmpty
                    ? NetworkImage(comment.authorAvatar!)
                    : null,
                child:
                    comment.authorAvatar == null ||
                        comment.authorAvatar!.isEmpty
                    ? Text(
                        authorName.isNotEmpty
                            ? authorName[0].toUpperCase()
                            : '?',
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (comment.articleTitle != null)
                      Text(
                        'on ${comment.articleTitle}',
                        style: textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor(
                    comment.status,
                    cs,
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _statusLabel(comment.status),
                  style: textTheme.bodySmall?.copyWith(
                    color: _statusColor(comment.status, cs),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.content, maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            children: [
              if (comment.createdAt != null)
                Text(
                  comment.createdAt!.length >= 10
                      ? comment.createdAt!.substring(0, 16)
                      : comment.createdAt!,
                  style: textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              if (comment.ipAddress != null &&
                  comment.ipAddress!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Icon(Icons.language, size: 12, color: cs.onSurfaceVariant),
                const SizedBox(width: 2),
                Text(
                  comment.ipAddress!,
                  style: textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
              if (comment.likeCount > 0) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.thumb_up_outlined,
                  size: 12,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 2),
                Text('${comment.likeCount}', style: textTheme.bodySmall),
              ],
              if (comment.replyCount > 0) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.reply_outlined,
                  size: 12,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 2),
                Text('${comment.replyCount}', style: textTheme.bodySmall),
              ],
              const Spacer(),
              _ActionBtn(
                icon: Icons.reply_outlined,
                color: cs.primary,
                tooltip: '回复',
                onTap: onReply,
              ),
              if (comment.status == 'PENDING') ...[
                _ActionBtn(
                  icon: Icons.check,
                  color: cs.primary,
                  tooltip: '通过',
                  onTap: onApprove,
                ),
                _ActionBtn(
                  icon: Icons.close,
                  color: cs.error,
                  tooltip: '拒绝',
                  onTap: onReject,
                ),
                _ActionBtn(
                  icon: Icons.report_outlined,
                  color: cs.error,
                  tooltip: '垃圾',
                  onTap: onSpam,
                ),
              ],
              _ActionBtn(
                icon: Icons.delete_outline,
                color: cs.error,
                tooltip: '删除',
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
