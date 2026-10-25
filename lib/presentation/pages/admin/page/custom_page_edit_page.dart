import 'dart:async';

import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/data/sources/local/draft_local_source.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/markdown_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomPageEditPage extends ConsumerStatefulWidget {
  const CustomPageEditPage({super.key, this.pageId});

  final String? pageId;

  bool get isEdit => pageId != null;

  @override
  ConsumerState<CustomPageEditPage> createState() => _CustomPageEditPageState();
}

class _CustomPageEditPageState extends ConsumerState<CustomPageEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _menuTitleController = TextEditingController();
  final _redirectUrlController = TextEditingController();
  final _seoTitleController = TextEditingController();
  final _seoDescController = TextEditingController();
  final _seoKeywordsController = TextEditingController();
  final _ogImageController = TextEditingController();
  final _customCssController = TextEditingController();
  final _customJsController = TextEditingController();

  String _content = '';
  String _pageType = 'STATIC';
  String _template = 'default';
  String _accessLevel = 'public';
  int _redirectType = 301;
  int _menuOrder = 0;
  int _sortOrder = 0;
  bool _published = false;
  bool _featured = false;
  bool _showInMenu = true;
  bool _commentsEnabled = false;
  bool _loading = false;
  bool _initialLoading = true;
  String? _error;
  Timer? _draftTimer;
  bool _draftReady = false;

  String get _draftKey => 'custom_page:${widget.pageId ?? 'new'}';

  static const _pageTypes = [
    ('STATIC', '静态页面'),
    ('REDIRECT', '重定向'),
    ('CUSTOM', '自定义'),
  ];

  static const _accessLevels = [
    ('public', '公开'),
    ('login', '登录可见'),
    ('admin', '管理员可见'),
  ];

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _titleController,
      _slugController,
      _subtitleController,
      _menuTitleController,
      _redirectUrlController,
      _seoTitleController,
      _seoDescController,
      _seoKeywordsController,
      _ogImageController,
      _customCssController,
      _customJsController,
    ]) {
      controller.addListener(_scheduleDraftSave);
    }
    _initialize();
  }

  Future<void> _initialize() async {
    if (widget.isEdit) {
      await _loadPage(setReady: false);
    }
    await _restoreDraft();
    _draftReady = true;
    if (mounted) {
      setState(() => _initialLoading = false);
    }
  }

  Future<void> _loadPage({bool setReady = true}) async {
    try {
      final page = await ref
          .read(adminRepositoryProvider)
          .getCustomPage(widget.pageId!);
      setState(() {
        _titleController.text = page['title']?.toString() ?? '';
        _slugController.text = page['slug']?.toString() ?? '';
        _subtitleController.text = page['subtitle']?.toString() ?? '';
        _menuTitleController.text =
            page['menuTitle']?.toString() ??
            page['menu_title']?.toString() ??
            '';
        _redirectUrlController.text =
            page['redirectUrl']?.toString() ??
            page['redirect_url']?.toString() ??
            '';
        _seoTitleController.text =
            page['seoTitle']?.toString() ?? page['seo_title']?.toString() ?? '';
        _seoDescController.text =
            page['seoDescription']?.toString() ??
            page['seo_description']?.toString() ??
            '';
        _seoKeywordsController.text =
            page['seoKeywords']?.toString() ??
            page['seo_keywords']?.toString() ??
            '';
        _ogImageController.text =
            page['ogImage']?.toString() ?? page['og_image']?.toString() ?? '';
        _customCssController.text =
            page['customCss']?.toString() ??
            page['custom_css']?.toString() ??
            '';
        _customJsController.text =
            page['customJs']?.toString() ?? page['custom_js']?.toString() ?? '';
        _content = page['content']?.toString() ?? '';
        _pageType =
            page['pageType']?.toString() ??
            page['page_type']?.toString() ??
            'STATIC';
        _template = page['template']?.toString() ?? 'default';
        _accessLevel =
            page['accessLevel']?.toString() ??
            page['access_level']?.toString() ??
            'public';
        _redirectType = page['redirectType'] is int
            ? page['redirectType']
            : page['redirect_type'] is int
            ? page['redirect_type']
            : 301;
        _menuOrder = page['menuOrder'] is int
            ? page['menuOrder']
            : page['menu_order'] is int
            ? page['menu_order']
            : 0;
        _sortOrder = page['sortOrder'] is int
            ? page['sortOrder']
            : page['sort_order'] is int
            ? page['sort_order']
            : 0;
        _published = page['published'] == true;
        _featured = page['featured'] == true;
        _showInMenu =
            page['showInMenu'] == true || page['show_in_menu'] == true;
        _commentsEnabled =
            page['commentsEnabled'] == true || page['comments_enabled'] == true;
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
      _slugController.text = data['slug']?.toString() ?? _slugController.text;
      _subtitleController.text =
          data['subtitle']?.toString() ?? _subtitleController.text;
      _menuTitleController.text =
          data['menuTitle']?.toString() ?? _menuTitleController.text;
      _redirectUrlController.text =
          data['redirectUrl']?.toString() ?? _redirectUrlController.text;
      _seoTitleController.text =
          data['seoTitle']?.toString() ?? _seoTitleController.text;
      _seoDescController.text =
          data['seoDescription']?.toString() ?? _seoDescController.text;
      _seoKeywordsController.text =
          data['seoKeywords']?.toString() ?? _seoKeywordsController.text;
      _ogImageController.text =
          data['ogImage']?.toString() ?? _ogImageController.text;
      _customCssController.text =
          data['customCss']?.toString() ?? _customCssController.text;
      _customJsController.text =
          data['customJs']?.toString() ?? _customJsController.text;
      _content = data['content']?.toString() ?? _content;
      _pageType = data['pageType']?.toString() ?? _pageType;
      _template = data['template']?.toString() ?? _template;
      _accessLevel = data['accessLevel']?.toString() ?? _accessLevel;
      _redirectType = _asInt(data['redirectType'], _redirectType);
      _menuOrder = _asInt(data['menuOrder'], _menuOrder);
      _sortOrder = _asInt(data['sortOrder'], _sortOrder);
      _published = data.containsKey('published')
          ? data['published'] == true
          : _published;
      _featured = data.containsKey('featured')
          ? data['featured'] == true
          : _featured;
      _showInMenu = data.containsKey('showInMenu')
          ? data['showInMenu'] == true
          : _showInMenu;
      _commentsEnabled = data.containsKey('commentsEnabled')
          ? data['commentsEnabled'] == true
          : _commentsEnabled;
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
      'slug': _slugController.text,
      'subtitle': _subtitleController.text,
      'menuTitle': _menuTitleController.text,
      'redirectUrl': _redirectUrlController.text,
      'seoTitle': _seoTitleController.text,
      'seoDescription': _seoDescController.text,
      'seoKeywords': _seoKeywordsController.text,
      'ogImage': _ogImageController.text,
      'customCss': _customCssController.text,
      'customJs': _customJsController.text,
      'content': _content,
      'pageType': _pageType,
      'template': _template,
      'accessLevel': _accessLevel,
      'redirectType': _redirectType,
      'menuOrder': _menuOrder,
      'sortOrder': _sortOrder,
      'published': _published,
      'featured': _featured,
      'showInMenu': _showInMenu,
      'commentsEnabled': _commentsEnabled,
    });
  }

  int _asInt(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
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
        'slug': _slugController.text.trim(),
        'pageType': _pageType,
        'content': _content,
        'template': _template,
        'published': _published,
        'featured': _featured,
        'showInMenu': _showInMenu,
        'menuOrder': _menuOrder,
        'sortOrder': _sortOrder,
        'commentsEnabled': _commentsEnabled,
        'accessLevel': _accessLevel,
        'redirectType': _redirectType,
      };
      if (_subtitleController.text.trim().isNotEmpty) {
        body['subtitle'] = _subtitleController.text.trim();
      }
      if (_menuTitleController.text.trim().isNotEmpty) {
        body['menuTitle'] = _menuTitleController.text.trim();
      }
      if (_redirectUrlController.text.trim().isNotEmpty) {
        body['redirectUrl'] = _redirectUrlController.text.trim();
      }
      if (_seoTitleController.text.trim().isNotEmpty) {
        body['seoTitle'] = _seoTitleController.text.trim();
      }
      if (_seoDescController.text.trim().isNotEmpty) {
        body['seoDescription'] = _seoDescController.text.trim();
      }
      if (_seoKeywordsController.text.trim().isNotEmpty) {
        body['seoKeywords'] = _seoKeywordsController.text.trim();
      }
      if (_ogImageController.text.trim().isNotEmpty) {
        body['ogImage'] = _ogImageController.text.trim();
      }
      if (_customCssController.text.trim().isNotEmpty) {
        body['customCss'] = _customCssController.text.trim();
      }
      if (_customJsController.text.trim().isNotEmpty) {
        body['customJs'] = _customJsController.text.trim();
      }

      final repo = ref.read(adminRepositoryProvider);
      if (widget.isEdit) {
        await repo.updateCustomPage(widget.pageId!, body);
      } else {
        await repo.createCustomPage(body);
      }
      await ref.read(draftLocalSourceProvider).clearDraft(_draftKey);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isEdit ? '页面已更新' : '页面已创建')),
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
    _titleController.dispose();
    _slugController.dispose();
    _subtitleController.dispose();
    _menuTitleController.dispose();
    _redirectUrlController.dispose();
    _seoTitleController.dispose();
    _seoDescController.dispose();
    _seoKeywordsController.dispose();
    _ogImageController.dispose();
    _customCssController.dispose();
    _customJsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? '编辑页面' : '新建页面'),
        actions: [
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
            FilledButton(onPressed: _loadPage, child: const Text('重试')),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Basic info
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '页面标题 *',
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.trim().isEmpty ? '请输入页面标题' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _slugController,
            decoration: const InputDecoration(
              labelText: '页面路径 *',
              border: OutlineInputBorder(),
              prefixText: '/pages/',
              hintText: 'about-me',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return '请输入页面路径';
              if (!RegExp(r'^[a-z0-9-]+$').hasMatch(v.trim())) {
                return '只能包含小写字母、数字和连字符';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _subtitleController,
            decoration: const InputDecoration(
              labelText: '副标题（可选）',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Page type & access
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _pageType,
                  decoration: const InputDecoration(
                    labelText: '页面类型',
                    border: OutlineInputBorder(),
                  ),
                  items: _pageTypes
                      .map(
                        (t) => DropdownMenuItem(value: t.$1, child: Text(t.$2)),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() => _pageType = v ?? 'STATIC');
                    _scheduleDraftSave();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _accessLevel,
                  decoration: const InputDecoration(
                    labelText: '访问级别',
                    border: OutlineInputBorder(),
                  ),
                  items: _accessLevels
                      .map(
                        (a) => DropdownMenuItem(value: a.$1, child: Text(a.$2)),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() => _accessLevel = v ?? 'public');
                    _scheduleDraftSave();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Redirect fields (conditional)
          if (_pageType == 'REDIRECT') ...[
            TextFormField(
              controller: _redirectUrlController,
              decoration: const InputDecoration(
                labelText: '重定向 URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _redirectType,
                    decoration: const InputDecoration(
                      labelText: '重定向类型',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 301, child: Text('301 永久')),
                      DropdownMenuItem(value: 302, child: Text('302 临时')),
                    ],
                    onChanged: (v) {
                      setState(() => _redirectType = v ?? 301);
                      _scheduleDraftSave();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Content editor
          Text('页面内容', style: Theme.of(context).textTheme.bodySmall),
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
              minLines: 12,
              onImageUpload: (filePath) async {
                final repo = ref.read(adminRepositoryProvider);
                return repo.uploadImage(filePath, type: 'page');
              },
            ),
          ),
          const SizedBox(height: 16),

          // Menu settings
          Text('菜单设置', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('显示在导航菜单'),
            value: _showInMenu,
            onChanged: (v) {
              setState(() => _showInMenu = v);
              _scheduleDraftSave();
            },
            contentPadding: EdgeInsets.zero,
          ),
          if (_showInMenu) ...[
            TextFormField(
              controller: _menuTitleController,
              decoration: const InputDecoration(
                labelText: '菜单标题（留空则使用页面标题）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: '菜单排序',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: '$_menuOrder',
                    onChanged: (v) {
                      _menuOrder = int.tryParse(v) ?? 0;
                      _scheduleDraftSave();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: '页面排序',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: '$_sortOrder',
                    onChanged: (v) {
                      _sortOrder = int.tryParse(v) ?? 0;
                      _scheduleDraftSave();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Status toggles
          Text('状态', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text(_published ? '已发布' : '草稿'),
            subtitle: const Text('发布后页面对访问者可见'),
            secondary: Icon(
              _published ? Icons.public : Icons.public_off,
              color: _published ? Theme.of(context).colorScheme.primary : null,
            ),
            value: _published,
            onChanged: (v) {
              setState(() => _published = v);
              _scheduleDraftSave();
            },
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            title: Text(_featured ? '已精选' : '普通页面'),
            subtitle: const Text('精选页面优先展示'),
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
            title: const Text('允许评论'),
            value: _commentsEnabled,
            onChanged: (v) {
              setState(() => _commentsEnabled = v);
              _scheduleDraftSave();
            },
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),

          // SEO settings
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              'SEO 设置',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            children: [
              TextFormField(
                controller: _seoTitleController,
                decoration: const InputDecoration(
                  labelText: 'SEO 标题（留空则使用页面标题）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _seoDescController,
                decoration: const InputDecoration(
                  labelText: 'SEO 描述',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _seoKeywordsController,
                decoration: const InputDecoration(
                  labelText: 'SEO 关键词（逗号分隔）',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ogImageController,
                decoration: const InputDecoration(
                  labelText: 'OG 图片 URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),

          // Advanced settings
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              '高级设置',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            children: [
              TextFormField(
                controller: _customCssController,
                decoration: const InputDecoration(
                  labelText: '自定义 CSS',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _customJsController,
                decoration: const InputDecoration(
                  labelText: '自定义 JavaScript',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '模板名称',
                  border: OutlineInputBorder(),
                ),
                initialValue: _template,
                onChanged: (v) {
                  _template = v.trim().isEmpty ? 'default' : v.trim();
                  _scheduleDraftSave();
                },
              ),
              const SizedBox(height: 16),
            ],
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
}
