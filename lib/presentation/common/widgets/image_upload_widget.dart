import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/presentation/common/utils/image_picker_helper.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MultiImageUploadWidget extends ConsumerStatefulWidget {
  const MultiImageUploadWidget({
    super.key,
    this.initialUrls = const [],
    this.onChanged,
    this.maxImages = 5,
  });

  final List<String> initialUrls;
  final ValueChanged<List<String>>? onChanged;
  final int maxImages;

  @override
  ConsumerState<MultiImageUploadWidget> createState() =>
      _MultiImageUploadWidgetState();
}

class _MultiImageUploadWidgetState
    extends ConsumerState<MultiImageUploadWidget> {
  late List<String> _urls;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _urls = List.from(widget.initialUrls);
  }

  Future<void> _pickAndUpload() async {
    if (_urls.length >= widget.maxImages) return;

    final source = await showImageSourceSheet(context);
    if (source == null || !mounted) return;

    final picked = await pickImageWithConfirmation(
      context,
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _uploading = true);
    try {
      final url = await ref
          .read(adminRepositoryProvider)
          .uploadImage(picked.path, type: 'general');
      setState(() {
        _urls.add(url);
        _uploading = false;
      });
      widget.onChanged?.call(_urls);
    } catch (e) {
      setState(() => _uploading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('上传失败: $e')));
      }
    }
  }

  void _remove(int index) {
    setState(() => _urls.removeAt(index));
    widget.onChanged?.call(_urls);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _urls.length; i++)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: RemoteImage(url: _urls[i], width: 80, height: 80),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => _remove(i),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (_urls.length < widget.maxImages)
              GestureDetector(
                onTap: _uploading ? null : _pickAndUpload,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _uploading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
