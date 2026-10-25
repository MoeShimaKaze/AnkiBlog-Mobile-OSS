import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:ankiblog_mobile/presentation/common/utils/image_picker_helper.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SingleImageUploadField extends ConsumerStatefulWidget {
  const SingleImageUploadField({
    super.key,
    this.initialUrl,
    this.onChanged,
    this.height = 160,
    this.label = '上传图片',
  });

  final String? initialUrl;
  final ValueChanged<String?>? onChanged;
  final double height;
  final String label;

  @override
  ConsumerState<SingleImageUploadField> createState() =>
      _SingleImageUploadFieldState();
}

class _SingleImageUploadFieldState
    extends ConsumerState<SingleImageUploadField> {
  String? _url;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _url = widget.initialUrl;
  }

  Future<void> _pickAndUpload() async {
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
        _url = url;
        _uploading = false;
      });
      widget.onChanged?.call(_url);
    } catch (e) {
      setState(() => _uploading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('上传失败: $e')));
      }
    }
  }

  void _clear() {
    setState(() => _url = null);
    widget.onChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _uploading ? null : _pickAndUpload,
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
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: _clear,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
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
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
      ),
    );
  }
}
