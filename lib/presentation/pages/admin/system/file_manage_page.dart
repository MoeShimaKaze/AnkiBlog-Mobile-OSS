import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class FileManagePage extends ConsumerStatefulWidget {
  const FileManagePage({super.key});

  @override
  ConsumerState<FileManagePage> createState() => _FileManagePageState();
}

class _FileManagePageState extends ConsumerState<FileManagePage> {
  String? _selectedBucket;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedBucket == null ? '文件管理' : '文件: $_selectedBucket'),
        leading: _selectedBucket != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedBucket = null),
              )
            : null,
      ),
      body: _selectedBucket == null
          ? _BucketList(
              onBucketSelected: (name) =>
                  setState(() => _selectedBucket = name),
            )
          : _FileList(bucketName: _selectedBucket!),
    );
  }
}

class _BucketList extends ConsumerWidget {
  const _BucketList({required this.onBucketSelected});

  final ValueChanged<String> onBucketSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bucketsAsync = ref.watch(bucketsProvider);

    return bucketsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('加载失败: $e'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.invalidate(bucketsProvider),
              child: const Text('重试'),
            ),
          ],
        ),
      ),
      data: (buckets) {
        if (buckets.isEmpty) {
          return const Center(child: Text('暂无存储桶'));
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(bucketsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: buckets.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final bucket = buckets[index];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onBucketSelected(bucket.name),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.folder_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bucket.name,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              bucket.creationDate != null
                                  ? bucket.creationDate!.substring(0, 10)
                                  : '',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _FileList extends ConsumerStatefulWidget {
  const _FileList({required this.bucketName});

  final String bucketName;

  @override
  ConsumerState<_FileList> createState() => _FileListState();
}

class _FileListState extends ConsumerState<_FileList> {
  List<AdminFileItem> _files = [];
  bool _loading = true;
  String? _error;
  final Set<String> _selectedFiles = {};

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
      final files = await ref
          .read(adminRepositoryProvider)
          .getFiles(widget.bucketName);
      setState(() {
        _files = files;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteFile(AdminFileItem file) async {
    try {
      await ref
          .read(adminRepositoryProvider)
          .deleteFileDirect(widget.bucketName, file.objectName);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
      }
    }
  }

  Future<void> _uploadFile() async {
    final picker = ImagePicker();
    final picked = await picker.pickMedia();
    if (picked == null) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(adminRepositoryProvider)
          .uploadFile(picked.path, bucketName: widget.bucketName);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('上传成功')));
      }
      _load();
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('上传失败: $e')));
      }
    }
  }

  Future<void> _copyUrl(AdminFileItem file) async {
    try {
      final url = await ref
          .read(adminRepositoryProvider)
          .getFileUrl(widget.bucketName, file.objectName);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('URL: $url')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('获取URL失败: $e')));
      }
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedFiles.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('批量删除'),
        content: Text('确定要删除 ${_selectedFiles.length} 个文件吗？'),
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
        for (final objectName in _selectedFiles) {
          await ref
              .read(adminRepositoryProvider)
              .deleteFileDirect(widget.bucketName, objectName);
        }
        setState(() => _selectedFiles.clear());
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

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
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

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadFile,
        child: const Icon(Icons.upload_file),
      ),
      body: Column(
        children: [
          if (_selectedFiles.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text('已选择 ${_selectedFiles.length} 个文件'),
                  const Spacer(),
                  FilledButton(
                    onPressed: _deleteSelected,
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: const Text('批量删除'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _files.isEmpty
                ? const Center(child: Text('暂无文件'))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _files.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final file = _files[index];
                        final isSelected = _selectedFiles.contains(
                          file.objectName,
                        );

                        return GlassContainer(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (v) {
                                  setState(() {
                                    if (v == true) {
                                      _selectedFiles.add(file.objectName);
                                    } else {
                                      _selectedFiles.remove(file.objectName);
                                    }
                                  });
                                },
                              ),
                              Icon(
                                _fileIcon(file.objectName, file.isDir),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file.objectName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          _formatSize(file.size),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                        if (file.lastModified != null) ...[
                                          const SizedBox(width: 8),
                                          Text(
                                            file.lastModified!.length >= 10
                                                ? file.lastModified!.substring(
                                                    0,
                                                    10,
                                                  )
                                                : file.lastModified!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.link, size: 18),
                                tooltip: '复制链接',
                                onPressed: () => _copyUrl(file),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                ),
                                tooltip: '删除',
                                onPressed: () => _deleteFile(file),
                              ),
                            ],
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

  IconData _fileIcon(String objectName, bool isDir) {
    if (isDir) return Icons.folder_outlined;
    final ext = objectName.contains('.')
        ? objectName.split('.').last.toLowerCase()
        : '';
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'bmp'].contains(ext)) {
      return Icons.image_outlined;
    }
    if (['mp4', 'avi', 'mov', 'mkv', 'webm'].contains(ext)) {
      return Icons.videocam_outlined;
    }
    if (['mp3', 'wav', 'ogg', 'flac', 'aac'].contains(ext)) {
      return Icons.audiotrack_outlined;
    }
    if (ext == 'pdf') return Icons.picture_as_pdf_outlined;
    if (['zip', 'rar', '7z', 'tar', 'gz'].contains(ext)) {
      return Icons.archive_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }
}
