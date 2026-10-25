import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/presentation/common/utils/image_picker_helper.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ArticleCoverImageSelector extends ConsumerStatefulWidget {
  const ArticleCoverImageSelector({
    super.key,
    this.initialUrl,
    required this.onChanged,
    this.height = 160,
  });

  final String? initialUrl;
  final ValueChanged<String?> onChanged;
  final double height;

  @override
  ConsumerState<ArticleCoverImageSelector> createState() =>
      _ArticleCoverImageSelectorState();
}

class _ArticleCoverImageSelectorState
    extends ConsumerState<ArticleCoverImageSelector> {
  final _externalUrlController = TextEditingController();
  String? _url;
  String? _randomPreviewUrl;
  String? _selectedApiId;
  List<AdminBackground> _activeApis = const [];
  bool _uploading = false;
  bool _loadingApis = false;
  bool _refreshingRandom = false;
  String? _apiError;

  @override
  void initState() {
    super.initState();
    _url = widget.initialUrl;
    if (_url != null && _url!.isNotEmpty) {
      _externalUrlController.text = _url!;
    }
  }

  @override
  void didUpdateWidget(covariant ArticleCoverImageSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialUrl != widget.initialUrl &&
        widget.initialUrl != _url) {
      _url = widget.initialUrl;
      _externalUrlController.text = widget.initialUrl ?? '';
    }
  }

  @override
  void dispose() {
    _externalUrlController.dispose();
    super.dispose();
  }

  void _setUrl(String? value) {
    setState(() => _url = value);
    widget.onChanged(value);
  }

  Future<void> _openSelector() async {
    await _loadActiveApis();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: DefaultTabController(
            length: 3,
            child: StatefulBuilder(
              builder: (context, setSheetState) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.72,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '选择封面图片',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: '关闭',
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const TabBar(
                        tabs: [
                          Tab(text: '本地上传'),
                          Tab(text: '外部链接'),
                          Tab(text: '随机图片'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _LocalUploadTab(
                              uploading: _uploading,
                              onPick: (source) async {
                                await _pickAndUpload(
                                  source,
                                  sheetContext,
                                  setSheetState,
                                );
                              },
                            ),
                            _ExternalUrlTab(
                              controller: _externalUrlController,
                              onUse: () => _useExternalUrl(sheetContext),
                            ),
                            _RandomImageTab(
                              activeApis: _activeApis,
                              selectedApiId: _selectedApiId,
                              previewUrl: _randomPreviewUrl,
                              loadingApis: _loadingApis,
                              refreshing: _refreshingRandom,
                              error: _apiError,
                              onApiChanged: (value) {
                                setState(() => _selectedApiId = value);
                                setSheetState(() {});
                              },
                              onRefresh: () async {
                                await _refreshRandomImage(setSheetState);
                              },
                              onUse: _randomPreviewUrl == null
                                  ? null
                                  : () {
                                      _setUrl(_randomPreviewUrl);
                                      Navigator.pop(sheetContext);
                                    },
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
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(
    ImageSource source,
    BuildContext sheetContext,
    StateSetter setSheetState,
  ) async {
    final picked = await pickImageWithConfirmation(
      context,
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    setState(() => _uploading = true);
    setSheetState(() {});
    try {
      final url = await ref
          .read(adminRepositoryProvider)
          .uploadImage(picked.path, type: 'article');
      if (!mounted) return;
      _setUrl(url);
      setState(() => _uploading = false);
      setSheetState(() {});
      if (sheetContext.mounted) Navigator.pop(sheetContext);
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      setSheetState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('上传失败: $e')));
    }
  }

  void _useExternalUrl(BuildContext sheetContext) {
    final value = _externalUrlController.text.trim();
    final uri = Uri.tryParse(value);
    final valid =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (!valid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入有效的图片链接')));
      return;
    }
    _setUrl(value);
    Navigator.pop(sheetContext);
  }

  Future<void> _loadActiveApis() async {
    if (_activeApis.isNotEmpty || _loadingApis) return;
    setState(() {
      _loadingApis = true;
      _apiError = null;
    });
    try {
      final apis = await ref
          .read(adminRepositoryProvider)
          .getActiveBackgroundApis();
      if (!mounted) return;
      setState(() {
        _activeApis = apis;
        _loadingApis = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError = e.toString();
        _loadingApis = false;
      });
    }
  }

  Future<void> _refreshRandomImage(StateSetter setSheetState) async {
    setState(() {
      _refreshingRandom = true;
      _apiError = null;
    });
    setSheetState(() {});
    try {
      final url = await ref
          .read(adminRepositoryProvider)
          .refreshBackgroundImage(apiId: _selectedApiId);
      if (!mounted) return;
      setState(() {
        _randomPreviewUrl = url;
        _refreshingRandom = false;
      });
      setSheetState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError = e.toString();
        _refreshingRandom = false;
      });
      setSheetState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _uploading ? null : _openSelector,
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: _uploading
            ? const Center(child: CircularProgressIndicator())
            : _url != null && _url!.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  RemoteImage(url: _url!, fit: BoxFit.cover),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: FilledButton.tonalIcon(
                      onPressed: _openSelector,
                      icon: const Icon(Icons.image_search, size: 18),
                      label: const Text('更换封面'),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: IconButton.filledTonal(
                      tooltip: '清除封面',
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => _setUrl(null),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 32,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 4),
                  Text('选择封面图片', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 2),
                  Text(
                    '本地上传 / 外部链接 / 随机图片',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _LocalUploadTab extends StatelessWidget {
  const _LocalUploadTab({required this.uploading, required this.onPick});

  final bool uploading;
  final ValueChanged<ImageSource> onPick;

  @override
  Widget build(BuildContext context) {
    if (uploading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.photo_library_outlined),
          title: const Text('从相册选择'),
          onTap: () => onPick(ImageSource.gallery),
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.camera_alt_outlined),
          title: const Text('拍照上传'),
          onTap: () => onPick(ImageSource.camera),
        ),
      ],
    );
  }
}

class _ExternalUrlTab extends StatelessWidget {
  const _ExternalUrlTab({required this.controller, required this.onUse});

  final TextEditingController controller;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '图片链接',
            hintText: 'https://example.com/cover.jpg',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final url = controller.text.trim();
            if (url.isEmpty) return const SizedBox.shrink();
            return RemoteImage(url: url, height: 160, fit: BoxFit.cover);
          },
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onUse,
          icon: const Icon(Icons.check),
          label: const Text('使用链接'),
        ),
      ],
    );
  }
}

class _RandomImageTab extends StatelessWidget {
  const _RandomImageTab({
    required this.activeApis,
    required this.selectedApiId,
    required this.previewUrl,
    required this.loadingApis,
    required this.refreshing,
    required this.error,
    required this.onApiChanged,
    required this.onRefresh,
    required this.onUse,
  });

  final List<AdminBackground> activeApis;
  final String? selectedApiId;
  final String? previewUrl;
  final bool loadingApis;
  final bool refreshing;
  final String? error;
  final ValueChanged<String?> onApiChanged;
  final VoidCallback onRefresh;
  final VoidCallback? onUse;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (loadingApis)
          const LinearProgressIndicator()
        else
          DropdownButtonFormField<String?>(
            initialValue: selectedApiId,
            decoration: const InputDecoration(
              labelText: '随机图片源',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String?>(value: null, child: Text('默认随机')),
              ...activeApis.map(
                (api) => DropdownMenuItem<String?>(
                  value: api.id,
                  child: Text(_apiName(api)),
                ),
              ),
            ],
            onChanged: onApiChanged,
          ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: refreshing ? null : onRefresh,
          icon: refreshing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          label: const Text('获取随机图片'),
        ),
        if (previewUrl != null && previewUrl!.isNotEmpty) ...[
          const SizedBox(height: 12),
          RemoteImage(url: previewUrl, height: 180, fit: BoxFit.cover),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onUse,
            icon: const Icon(Icons.check),
            label: const Text('使用这张'),
          ),
        ],
      ],
    );
  }

  static String _apiName(AdminBackground api) {
    final name = api.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    final value = api.value ?? '';
    if (value.contains('loliapi.com')) return 'LoliAPI';
    if (value.contains('dmoe.cc')) return 'Dmoe';
    if (value.contains('vvhan.com')) return 'Vvhan';
    if (value.isNotEmpty) return 'API: $value';
    return '随机图片源';
  }
}
