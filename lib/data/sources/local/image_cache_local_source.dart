import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final imageCacheLocalSourceProvider = Provider<ImageCacheLocalSource>((ref) {
  return const ImageCacheLocalSource();
});

class ImageCacheLocalSource {
  const ImageCacheLocalSource();

  static const maxBytes = 500 * 1024 * 1024;

  Future<File?> getCachedFile(String url) async {
    final file = await _fileFor(url);
    if (!await file.exists()) return null;
    unawaitedFileTouch(file);
    return file;
  }

  Future<File?> cacheImage(String url, Dio dio) async {
    if (url.trim().isEmpty) return null;
    final target = await _fileFor(url);
    if (await target.exists()) return target;
    final temp = File('${target.path}.download');
    try {
      await target.parent.create(recursive: true);
      await dio.download(
        url,
        temp.path,
        options: Options(responseType: ResponseType.bytes),
      );
      if (await temp.exists()) {
        if (await target.exists()) await target.delete();
        await temp.rename(target.path);
        await _pruneIfNeeded();
        return target;
      }
    } catch (_) {
      if (await temp.exists()) await temp.delete();
    }
    return null;
  }

  Future<int> sizeBytes() async {
    final dir = await _cacheDir();
    if (!await dir.exists()) return 0;
    var total = 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  Future<void> clear() async {
    final dir = await _cacheDir();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<File> _fileFor(String url) async {
    final dir = await _cacheDir();
    final extension = _extensionFor(url);
    return File('${dir.path}/${_fnv1a(url)}$extension');
  }

  Future<Directory> _cacheDir() async {
    final base = await getTemporaryDirectory();
    return Directory('${base.path}/ankiblog_image_cache');
  }

  String _extensionFor(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
    for (final extension in const ['.jpg', '.jpeg', '.png', '.webp', '.gif']) {
      if (path.endsWith(extension)) return extension;
    }
    return '.img';
  }

  Future<void> _pruneIfNeeded() async {
    final dir = await _cacheDir();
    if (!await dir.exists()) return;
    final files = <File>[];
    var total = 0;
    await for (final entity in dir.list(recursive: false, followLinks: false)) {
      if (entity is File && !entity.path.endsWith('.download')) {
        files.add(entity);
        total += await entity.length();
      }
    }
    if (total <= maxBytes) return;
    files.sort((a, b) {
      return a.lastModifiedSync().compareTo(b.lastModifiedSync());
    });
    for (final file in files) {
      if (total <= maxBytes) break;
      final length = await file.length();
      await file.delete();
      total -= length;
    }
  }
}

void unawaitedFileTouch(File file) {
  file.setLastModified(DateTime.now()).ignore();
}

String _fnv1a(String input) {
  var hash = 0x811c9dc5;
  for (final codeUnit in input.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}
