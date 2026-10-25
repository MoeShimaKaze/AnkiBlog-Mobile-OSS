import 'dart:io';

import 'package:ankiblog_mobile/data/api/api_client.dart';
import 'package:ankiblog_mobile/data/sources/local/image_cache_local_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemoteImage extends ConsumerStatefulWidget {
  const RemoteImage({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.borderRadius = 12,
    this.fit,
  });

  final String? url;
  final double? height;
  final double? width;
  final double borderRadius;
  final BoxFit? fit;

  @override
  ConsumerState<RemoteImage> createState() => _RemoteImageState();
}

class _RemoteImageState extends ConsumerState<RemoteImage> {
  File? _file;
  String? _loadedUrl;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant RemoteImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _file = null;
      _loadedUrl = null;
      _load();
    }
  }

  Future<void> _load() async {
    final imageUrl = widget.url;
    if (imageUrl == null || imageUrl.isEmpty) return;
    final cache = ref.read(imageCacheLocalSourceProvider);
    final cached = await cache.getCachedFile(imageUrl);
    if (!mounted || widget.url != imageUrl) return;
    if (cached != null) {
      setState(() {
        _file = cached;
        _loadedUrl = imageUrl;
      });
      return;
    }

    final downloaded = await cache.cacheImage(imageUrl, ref.read(dioProvider));
    if (!mounted || widget.url != imageUrl || downloaded == null) return;
    setState(() {
      _file = downloaded;
      _loadedUrl = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.url;
    final placeholder = SizedBox(
      height: widget.height,
      width: widget.width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: const Center(child: Icon(Icons.image_outlined)),
      ),
    );

    if (imageUrl == null || imageUrl.isEmpty) {
      return placeholder;
    }

    final file = _loadedUrl == imageUrl ? _file : null;
    if (file == null) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Image.file(
        file,
        height: widget.height,
        width: widget.width,
        fit: widget.fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return placeholder;
        },
      ),
    );
  }
}
