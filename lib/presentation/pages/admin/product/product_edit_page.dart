import 'dart:async';

import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/data/sources/local/draft_local_source.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/image_upload_field.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/markdown_editor.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/tag_fuzzy_selector.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductEditPage extends ConsumerStatefulWidget {
  const ProductEditPage({super.key, this.productId});

  final String? productId;

  bool get isEdit => productId != null;

  @override
  ConsumerState<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends ConsumerState<ProductEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _summaryController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _purchaseUrlController = TextEditingController();
  String _description = '';
  String? _mainImage;
  String? _categoryId;
  final List<String> _tags = [];
  bool _featured = false;
  bool _isPurchased = false;
  String _status = 'DRAFT';
  bool _publishImmediately = false;
  bool _loading = false;
  bool _initialLoading = true;
  String? _error;
  Timer? _draftTimer;
  bool _draftReady = false;

  String get _draftKey => 'product:${widget.productId ?? 'new'}';

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _nameController,
      _summaryController,
      _priceController,
      _originalPriceController,
      _purchaseUrlController,
    ]) {
      controller.addListener(_scheduleDraftSave);
    }
    _initialize();
  }

  Future<void> _initialize() async {
    if (widget.isEdit) {
      await _loadProduct(setReady: false);
    }
    await _restoreDraft();
    _draftReady = true;
    if (mounted) {
      setState(() => _initialLoading = false);
    }
  }

  Future<void> _loadProduct({bool setReady = true}) async {
    try {
      final product = await ref
          .read(adminRepositoryProvider)
          .getAdminProduct(widget.productId!);
      setState(() {
        _nameController.text = product.name;
        _summaryController.text = product.summary ?? '';
        _priceController.text = product.price != null
            ? product.price!.toStringAsFixed(2)
            : '';
        _originalPriceController.text = product.originalPrice != null
            ? product.originalPrice!.toStringAsFixed(2)
            : '';
        _purchaseUrlController.text = product.purchaseUrl ?? '';
        _description = product.description ?? '';
        _mainImage = product.mainImage;
        _featured = product.featured;
        _isPurchased = product.isPurchased;
        _status = product.status;
        _publishImmediately = _status == 'ACTIVE';
        _categoryId = product.categoryId;
        _tags.clear();
        _tags.addAll(product.tags);
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
      _nameController.text = data['name']?.toString() ?? _nameController.text;
      _summaryController.text =
          data['summary']?.toString() ?? _summaryController.text;
      _priceController.text =
          data['price']?.toString() ?? _priceController.text;
      _originalPriceController.text =
          data['originalPrice']?.toString() ?? _originalPriceController.text;
      _purchaseUrlController.text =
          data['purchaseUrl']?.toString() ?? _purchaseUrlController.text;
      _description = data['description']?.toString() ?? _description;
      _mainImage = data['mainImage']?.toString().isNotEmpty == true
          ? data['mainImage'].toString()
          : _mainImage;
      _categoryId = data['categoryId']?.toString().isNotEmpty == true
          ? data['categoryId'].toString()
          : _categoryId;
      _tags
        ..clear()
        ..addAll(
          data['tags'] is List
              ? (data['tags'] as List).map((item) => item.toString())
              : const <String>[],
        );
      _featured = data.containsKey('featured')
          ? data['featured'] == true
          : _featured;
      _isPurchased = data.containsKey('isPurchased')
          ? data['isPurchased'] == true
          : _isPurchased;
      _status = data['status']?.toString() ?? _status;
      _publishImmediately = data.containsKey('publishImmediately')
          ? data['publishImmediately'] == true
          : _status == 'ACTIVE';
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
      'name': _nameController.text,
      'summary': _summaryController.text,
      'price': _priceController.text,
      'originalPrice': _originalPriceController.text,
      'purchaseUrl': _purchaseUrlController.text,
      'description': _description,
      'mainImage': _mainImage,
      'categoryId': _categoryId,
      'tags': _tags,
      'featured': _featured,
      'isPurchased': _isPurchased,
      'status': _status,
      'publishImmediately': _publishImmediately,
    });
  }

  String _extractUrlFromText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '';
    if (RegExp(r'^https?://[^\s]+$').hasMatch(trimmed)) {
      return trimmed;
    }

    final match = RegExp(
      r"""https?://[^\s\u4e00-\u9fa5「」【】《》"']+""",
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (match == null) return trimmed;

    return match
        .group(0)!
        .replaceFirst(RegExp(r'''[,，。.!！?？;；:：)）\]】}>」』"']+$'''), '');
  }

  void _normalizePurchaseUrl({bool showMessage = true}) {
    final input = _purchaseUrlController.text;
    final extracted = _extractUrlFromText(input);
    if (extracted == input || !extracted.startsWith(RegExp(r'https?://'))) {
      return;
    }
    _purchaseUrlController.text = extracted;
    _scheduleDraftSave();
    if (showMessage && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已自动提取购买链接')));
    }
  }

  String? _validatePurchaseUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    if (uri == null ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return '请输入有效的购买链接';
    }
    return null;
  }

  Future<void> _save() async {
    _normalizePurchaseUrl(showMessage: false);
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final body = <String, dynamic>{
        'name': _nameController.text.trim(),
        'description': _description,
        'status': _status,
        'featured': _featured,
        'isPurchased': _isPurchased,
      };
      body['summary'] = _summaryController.text.trim();
      if (_priceController.text.trim().isNotEmpty) {
        body['price'] = double.tryParse(_priceController.text.trim());
      }
      if (_originalPriceController.text.trim().isNotEmpty) {
        body['originalPrice'] = double.tryParse(
          _originalPriceController.text.trim(),
        );
      }
      if (_purchaseUrlController.text.trim().isNotEmpty) {
        body['purchaseUrl'] = _purchaseUrlController.text.trim();
      }
      if (_mainImage != null && _mainImage!.isNotEmpty) {
        body['mainImage'] = _mainImage;
      }
      if (_categoryId != null) {
        body['categoryId'] = _categoryId;
      }
      if (_tags.isNotEmpty) {
        body['tags'] = _tags;
      }

      final repo = ref.read(adminRepositoryProvider);
      if (widget.isEdit) {
        await repo.updateProduct(widget.productId!, body);
      } else {
        await repo.createProduct(body);
      }
      await ref.read(draftLocalSourceProvider).clearDraft(_draftKey);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isEdit ? '产品已更新' : '产品已创建')),
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

  @override
  void dispose() {
    _draftTimer?.cancel();
    _nameController.dispose();
    _summaryController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _purchaseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? '编辑产品' : '新建产品'),
        actions: [
          if (widget.isEdit && !_initialLoading)
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: '产品快照',
              onPressed: _showSnapshotSheet,
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

  void _showSnapshotSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (context, scrollController) => _ProductSnapshotSheet(
          productId: widget.productId!,
          scrollController: scrollController,
          onRestore: _restoreSnapshot,
        ),
      ),
    );
  }

  void _restoreSnapshot(AdminProductSnapshot snapshot) {
    setState(() {
      if (snapshot.name != null) _nameController.text = snapshot.name!;
      _summaryController.text = snapshot.summary ?? '';
      _priceController.text = snapshot.price != null
          ? snapshot.price!.toStringAsFixed(2)
          : '';
      _originalPriceController.text = snapshot.originalPrice != null
          ? snapshot.originalPrice!.toStringAsFixed(2)
          : '';
      _purchaseUrlController.text = snapshot.purchaseUrl ?? '';
      _description = snapshot.description ?? '';
      _mainImage = snapshot.mainImage;
      _featured = snapshot.featured;
      _status = snapshot.status ?? 'DRAFT';
      _publishImmediately = _status == 'ACTIVE';
      _categoryId = snapshot.categoryId;
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已恢复快照内容，请保存以生效')));
  }

  Widget _buildBody() {
    if (_initialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _nameController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(_error!, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadProduct, child: const Text('重试')),
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
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '产品名称',
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? '请输入产品名称' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: '价格',
                    border: OutlineInputBorder(),
                    prefixText: '¥ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _originalPriceController,
                  decoration: const InputDecoration(
                    labelText: '原价（可选）',
                    border: OutlineInputBorder(),
                    prefixText: '¥ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _purchaseUrlController,
            decoration: const InputDecoration(
              labelText: '购买链接',
              helperText: '支持粘贴淘宝/天猫/京东等分享文本，会自动提取链接',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
            validator: _validatePurchaseUrl,
            onEditingComplete: _normalizePurchaseUrl,
            onFieldSubmitted: (_) => _normalizePurchaseUrl(),
            onTapOutside: (_) => _normalizePurchaseUrl(),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _summaryController,
            decoration: const InputDecoration(
              labelText: '商品简短描述',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            maxLength: 300,
            validator: (v) =>
                v == null || v.trim().isEmpty ? '请输入商品简短描述' : null,
          ),
          const SizedBox(height: 16),
          Text('主图', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          SingleImageUploadField(
            initialUrl: _mainImage,
            height: 160,
            label: '上传产品图片',
            onChanged: (url) {
              setState(() => _mainImage = url);
              _scheduleDraftSave();
            },
          ),
          const SizedBox(height: 16),
          _buildCategorySelector(),
          const SizedBox(height: 16),
          _buildTagInput(),
          const SizedBox(height: 16),
          Text('状态', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('立即上架'),
            subtitle: Text(_publishImmediately ? '保存后直接公开展示' : '保存为草稿'),
            secondary: Icon(
              _publishImmediately ? Icons.public : Icons.public_off,
              color: _publishImmediately
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            value: _publishImmediately,
            onChanged: (v) {
              setState(() {
                _publishImmediately = v;
                _status = v ? 'ACTIVE' : 'DRAFT';
              });
              _scheduleDraftSave();
            },
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'DRAFT', label: Text('草稿')),
              ButtonSegment(value: 'ACTIVE', label: Text('上架')),
              ButtonSegment(value: 'OUT_OF_STOCK', label: Text('缺货')),
              ButtonSegment(value: 'DISCONTINUED', label: Text('停售')),
            ],
            selected: {_status},
            onSelectionChanged: (v) {
              setState(() {
                _status = v.first;
                _publishImmediately = _status == 'ACTIVE';
              });
              _scheduleDraftSave();
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(_featured ? '设为推荐' : '普通商品'),
            subtitle: const Text('推荐产品将在首页优先展示'),
            secondary: Icon(
              _featured ? Icons.star : Icons.star_border,
              color: _featured ? Theme.of(context).colorScheme.primary : null,
            ),
            value: _featured,
            onChanged: (v) {
              setState(() => _featured = v);
              _scheduleDraftSave();
            },
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: const Text('衣橱管理'),
            subtitle: Text(_isPurchased ? '已购买' : '未购买'),
            secondary: Icon(
              _isPurchased ? Icons.shopping_cart : Icons.shopping_cart_outlined,
              color: _isPurchased
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            value: _isPurchased,
            onChanged: (v) {
              setState(() => _isPurchased = v);
              _scheduleDraftSave();
            },
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          Text('商品详细描述', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: MarkdownEditor(
              initialContent: _description,
              onChanged: (v) {
                _description = v;
                _scheduleDraftSave();
              },
              minLines: 10,
              onImageUpload: (filePath) async {
                final repo = ref.read(adminRepositoryProvider);
                return repo.uploadImage(filePath, type: 'product');
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

  Widget _buildCategorySelector() {
    final categoriesAsync = ref.watch(categoryTreeProvider);
    return categoriesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('分类加载失败: $e'),
      data: (categories) {
        return DropdownButtonFormField<String>(
          initialValue: _categoryId,
          decoration: const InputDecoration(
            labelText: '分类（可选）',
            border: OutlineInputBorder(),
          ),
          items: _buildCategoryItems(categories),
          onChanged: (v) {
            setState(() => _categoryId = v);
            _scheduleDraftSave();
          },
        );
      },
    );
  }

  List<DropdownMenuItem<String>> _buildCategoryItems(
    List<Map<String, dynamic>> categories, [
    String prefix = '',
  ]) {
    final items = <DropdownMenuItem<String>>[];
    for (final cat in categories) {
      final id = cat['id']?.toString();
      final name = cat['name']?.toString() ?? '';
      if (id != null) {
        items.add(DropdownMenuItem(value: id, child: Text('$prefix$name')));
      }
      final children = cat['children'];
      if (children is List && children.isNotEmpty) {
        items.addAll(
          _buildCategoryItems(
            children.whereType<Map<String, dynamic>>().toList(),
            '$prefix  ',
          ),
        );
      }
    }
    return items;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('标签', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        TagFuzzySelector(
          selectedTags: _tags,
          suggestions: suggestions,
          onChanged: (tags) {
            setState(() {
              _tags
                ..clear()
                ..addAll(tags);
            });
            _scheduleDraftSave();
          },
        ),
      ],
    );
  }
}

class _ProductSnapshotSheet extends ConsumerStatefulWidget {
  const _ProductSnapshotSheet({
    required this.productId,
    required this.scrollController,
    required this.onRestore,
  });

  final String productId;
  final ScrollController scrollController;
  final ValueChanged<AdminProductSnapshot> onRestore;

  @override
  ConsumerState<_ProductSnapshotSheet> createState() =>
      _ProductSnapshotSheetState();
}

class _ProductSnapshotSheetState extends ConsumerState<_ProductSnapshotSheet> {
  List<AdminProductSnapshot> _items = [];
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
          .getProductSnapshots(widget.productId, size: 50);
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
        title: const Text('创建产品快照'),
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
    controller.dispose();
    if (desc == null) return;
    try {
      await ref
          .read(adminRepositoryProvider)
          .createProductSnapshot(widget.productId, desc);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('创建失败: $e')));
      }
    }
  }

  Future<void> _delete(AdminProductSnapshot snapshot) async {
    try {
      await ref
          .read(adminRepositoryProvider)
          .deleteProductSnapshot(widget.productId, snapshot.id);
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
                '产品快照',
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
    if (_items.isEmpty) return const Center(child: Text('暂无产品快照'));

    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final snapshot = _items[index];
        return ListTile(
          leading: CircleAvatar(child: Text('v${snapshot.versionNumber}')),
          title: Text(snapshot.name ?? '未命名产品'),
          subtitle: Text(
            [
              if (snapshot.snapshotDescription != null &&
                  snapshot.snapshotDescription!.isNotEmpty)
                snapshot.snapshotDescription!,
              if (snapshot.snapshotType != null) snapshot.snapshotType!,
              if (snapshot.status != null) snapshot.status!,
              if (snapshot.createdAt != null &&
                  snapshot.createdAt!.length >= 16)
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
              IconButton(
                icon: const Icon(Icons.restore),
                tooltip: '恢复到表单',
                onPressed: () => widget.onRestore(snapshot),
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
