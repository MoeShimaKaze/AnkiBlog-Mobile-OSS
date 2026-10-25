import 'dart:async';

import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/data/sources/local/draft_local_source.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/article_cover_image_selector.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/markdown_editor.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/tag_fuzzy_selector.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArticleEditPage extends ConsumerStatefulWidget {
  const ArticleEditPage({super.key, this.articleId});

  final String? articleId;

  bool get isEdit => articleId != null;

  @override
  ConsumerState<ArticleEditPage> createState() => _ArticleEditPageState();
}

class _ArticleEditPageState extends ConsumerState<ArticleEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  String _content = '';
  String? _coverImage;
  List<String> _tags = [];
  bool _loading = false;
  bool _initialLoading = true;
  String? _error;
  String _status = 'DRAFT';
  String _visibility = 'PUBLIC';
  bool _commentsEnabled = true;
  bool _pinned = false;
  Timer? _draftTimer;
  bool _draftReady = false;

  String get _draftKey => 'article:${widget.articleId ?? 'new'}';

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_scheduleDraftSave);
    _summaryController.addListener(_scheduleDraftSave);
    _initialize();
  }

  Future<void> _initialize() async {
    if (widget.isEdit) {
      await _loadArticle(setReady: false);
    }
    await _restoreDraft();
    _draftReady = true;
    if (mounted) {
      setState(() => _initialLoading = false);
    }
  }

  Future<void> _loadArticle({bool setReady = true}) async {
    try {
      final article = await ref
          .read(adminRepositoryProvider)
          .getArticle(widget.articleId!);
      setState(() {
        _titleController.text = article.title;
        _summaryController.text = article.excerpt ?? '';
        _content = article.content ?? '';
        _coverImage = article.coverImage;
        _tags = List.from(article.tags);
        _status = article.status;
        _visibility = article.visibility;
        _commentsEnabled = article.commentsEnabled;
        _pinned = article.pinned;
        if (setReady) _initialLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        if (setReady) _initialLoading = false;
      });
    }
  }

  Future<void> _restoreDraft() async {
    final draft = await ref.read(draftLocalSourceProvider).getDraft(_draftKey);
    if (draft == null || !mounted) return;
    final data = draft.payload;
    setState(() {
      _titleController.text =
          data['title']?.toString() ?? _titleController.text;
      _summaryController.text =
          data['excerpt']?.toString() ?? _summaryController.text;
      _content = data['content']?.toString() ?? _content;
      _coverImage = data['coverImage']?.toString().isNotEmpty == true
          ? data['coverImage'].toString()
          : _coverImage;
      _tags = (data['tags'] is List)
          ? (data['tags'] as List).map((item) => item.toString()).toList()
          : _tags;
      _status = data['status']?.toString() ?? _status;
      _visibility = data['visibility']?.toString() ?? _visibility;
      _commentsEnabled = data.containsKey('commentsEnabled')
          ? data['commentsEnabled'] == true
          : _commentsEnabled;
      _pinned = data.containsKey('pinned') ? data['pinned'] == true : _pinned;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已恢复本地草稿')));
  }

  void _scheduleDraftSave() {
    if (!_draftReady) return;
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 800), _saveDraft);
  }

  Future<void> _saveDraft() async {
    await ref.read(draftLocalSourceProvider).saveDraft(_draftKey, {
      'title': _titleController.text,
      'excerpt': _summaryController.text,
      'content': _content,
      'coverImage': _coverImage,
      'tags': _tags,
      'status': _status,
      'visibility': _visibility,
      'commentsEnabled': _commentsEnabled,
      'pinned': _pinned,
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final body = <String, dynamic>{
        'title': _titleController.text.trim(),
        'content': _content,
        'status': _status,
        'visibility': _visibility,
        'commentsEnabled': _commentsEnabled,
        'pinned': _pinned,
      };
      if (_summaryController.text.trim().isNotEmpty) {
        body['excerpt'] = _summaryController.text.trim();
      }
      if (_coverImage != null && _coverImage!.isNotEmpty) {
        body['coverImage'] = _coverImage;
      }
      if (_tags.isNotEmpty) {
        body['tags'] = _tags;
      }

      final repo = ref.read(adminRepositoryProvider);
      if (widget.isEdit) {
        await repo.updateArticle(widget.articleId!, body);
      } else {
        await repo.createArticle(body);
      }
      await ref.read(draftLocalSourceProvider).clearDraft(_draftKey);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isEdit ? '文章已更新' : '文章已创建')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _showSnapshotSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (ctx, scrollController) => _SnapshotList(
          articleId: widget.articleId!,
          scrollController: scrollController,
          onRestore: (content) {
            setState(() => _content = content);
            Navigator.pop(ctx);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('已恢复快照内容')));
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    _titleController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? '编辑文章' : '新建文章'),
        actions: [
          if (widget.isEdit && !_initialLoading)
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: '版本历史',
              onPressed: () => _showSnapshotSheet(),
            ),
          if (!_initialLoading)
            TextButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存'),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_initialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _titleController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadArticle, child: const Text('重试')),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '标题',
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? '请输入标题' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _summaryController,
            decoration: const InputDecoration(
              labelText: '摘要（可选）',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Text('封面图片', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          ArticleCoverImageSelector(
            initialUrl: _coverImage,
            height: 160,
            onChanged: (url) {
              setState(() => _coverImage = url);
              _scheduleDraftSave();
            },
          ),
          const SizedBox(height: 16),
          Text('标签', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          _buildTagInput(),
          const SizedBox(height: 16),
          Text('状态', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'DRAFT', label: Text('草稿')),
              ButtonSegment(value: 'PUBLISHED', label: Text('发布')),
            ],
            selected: {_status},
            onSelectionChanged: (v) {
              setState(() => _status = v.first);
              _scheduleDraftSave();
            },
          ),
          const SizedBox(height: 16),
          Text('可见性', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'PUBLIC', label: Text('公开')),
              ButtonSegment(value: 'LOGIN_REQUIRED', label: Text('登录可见')),
              ButtonSegment(value: 'ADMIN_ONLY', label: Text('仅管理员')),
            ],
            selected: {_visibility},
            onSelectionChanged: (v) {
              setState(() => _visibility = v.first);
              _scheduleDraftSave();
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  title: const Text('允许评论'),
                  value: _commentsEnabled,
                  onChanged: (v) {
                    setState(() => _commentsEnabled = v);
                    _scheduleDraftSave();
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: SwitchListTile(
                  title: const Text('置顶'),
                  value: _pinned,
                  onChanged: (v) {
                    setState(() => _pinned = v);
                    _scheduleDraftSave();
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('正文内容', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: MarkdownEditor(
              initialContent: _content,
              onChanged: (v) {
                _content = v;
                _scheduleDraftSave();
              },
              minLines: 15,
              onImageUpload: (filePath) async {
                final repo = ref.read(adminRepositoryProvider);
                return repo.uploadImage(filePath, type: 'article');
              },
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTagInput() {
    final existingTags = ref.watch(tagsProvider);
    final suggestions =
        existingTags.whenOrNull(
          data: (tags) => tags
              .map((t) => t['name']?.toString() ?? '')
              .where((n) => n.isNotEmpty)
              .toList(),
        ) ??
        [];

    return TagFuzzySelector(
      selectedTags: _tags,
      suggestions: suggestions,
      onChanged: (tags) {
        setState(() => _tags = tags);
        _scheduleDraftSave();
      },
    );
  }
}

class _SnapshotList extends ConsumerStatefulWidget {
  const _SnapshotList({
    required this.articleId,
    required this.scrollController,
    required this.onRestore,
  });

  final String articleId;
  final ScrollController scrollController;
  final ValueChanged<String> onRestore;

  @override
  ConsumerState<_SnapshotList> createState() => _SnapshotListState();
}

class _SnapshotListState extends ConsumerState<_SnapshotList> {
  List<AdminArticleSnapshot> _items = [];
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
          .getArticleSnapshots(widget.articleId, size: 50);
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

  Future<void> _createSnapshot() async {
    final controller = TextEditingController();
    final desc = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('创建快照'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '快照描述（可选）',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    if (desc != null) {
      try {
        await ref
            .read(adminRepositoryProvider)
            .createArticleSnapshot(widget.articleId, desc);
        _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('创建失败: $e')));
        }
      }
    }
  }

  Future<void> _delete(AdminArticleSnapshot snapshot) async {
    try {
      await ref
          .read(adminRepositoryProvider)
          .deleteArticleSnapshot(widget.articleId, snapshot.id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '版本历史',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _createSnapshot,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('创建快照'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _buildBody()),
      ],
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
    if (_items.isEmpty) {
      return const Center(child: Text('暂无快照'));
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final snapshot = _items[index];
        return ListTile(
          leading: CircleAvatar(child: Text('v${snapshot.versionNumber}')),
          title: Text(snapshot.title ?? '无标题'),
          subtitle: Text(
            [
              if (snapshot.description != null &&
                  snapshot.description!.isNotEmpty)
                snapshot.description!,
              if (snapshot.snapshotType != null) snapshot.snapshotType!,
              if (snapshot.createdAt != null)
                snapshot.createdAt!.substring(0, 16),
              if (snapshot.createdByName != null)
                'by ${snapshot.createdByName}',
            ].join(' · '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (snapshot.content != null && snapshot.content!.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.restore),
                  tooltip: '恢复内容',
                  onPressed: () => widget.onRestore(snapshot.content!),
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: '删除',
                onPressed: () => _delete(snapshot),
              ),
            ],
          ),
        );
      },
    );
  }
}
