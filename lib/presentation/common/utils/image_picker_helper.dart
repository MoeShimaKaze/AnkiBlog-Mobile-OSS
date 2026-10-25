import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const int largeImageThresholdBytes = 10 * 1024 * 1024;

Future<XFile?> pickImageWithConfirmation(
  BuildContext context, {
  required ImageSource source,
  int? maxWidth,
  int? maxHeight,
  int? imageQuality,
}) async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: source,
    maxWidth: maxWidth?.toDouble(),
    maxHeight: maxHeight?.toDouble(),
    imageQuality: imageQuality,
  );
  if (picked == null) return null;

  final size = await File(picked.path).length();
  if (size <= largeImageThresholdBytes) return picked;
  if (!context.mounted) return null;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('大图上传确认'),
      content: const Text('图片超过 10MB，将由后端压缩处理，是否继续上传？'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('继续上传'),
        ),
      ],
    ),
  );

  return confirmed == true ? picked : null;
}

Future<ImageSource?> showImageSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('拍照'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('从相册选择'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
}
