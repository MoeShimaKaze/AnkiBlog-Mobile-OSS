import 'package:ankiblog_mobile/presentation/common/widgets/async_state_view.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/image_viewer.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:ankiblog_mobile/presentation/providers/admin_providers.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

String _formatDetailDate(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  try {
    return DateFormat('yy/MM/dd HH:mm').format(DateTime.parse(raw));
  } catch (_) {
    return raw;
  }
}

class AdminOutfitDetailPage extends ConsumerWidget {
  const AdminOutfitDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outfit = ref.watch(adminOutfitDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('穿搭详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: AsyncStateView(
        value: outfit,
        builder: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.outfitImage != null && data.outfitImage!.isNotEmpty)
                GestureDetector(
                  onTap: () => showImageViewer(context, data.outfitImage!),
                  child: RemoteImage(
                    url: data.outfitImage,
                    height: 260,
                    width: double.infinity,
                  ),
                ),
              const SizedBox(height: 16),
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDetailDate(data.outfitDate),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    if (data.note != null && data.note!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(data.note!),
                    ],
                  ],
                ),
              ),
              if (data.items.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '搭配单品 (${data.items.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...data.items.map(
                  (oi) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassContainer(
                      padding: const EdgeInsets.all(12),
                      child: InkWell(
                        onTap:
                            oi.productSlug != null && oi.productSlug!.isNotEmpty
                            ? () => context.push('/products/${oi.productSlug}')
                            : null,
                        child: Row(
                          children: [
                            if (oi.productMainImage != null &&
                                oi.productMainImage!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  oi.productMainImage!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      const Icon(Icons.checkroom, size: 24),
                                ),
                              )
                            else
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.checkroom, size: 24),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    oi.productName ?? '未知产品',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (oi.brand != null)
                                    Text(
                                      oi.brand!,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                            if (oi.itemType != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                      .withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _itemTypeLabel(oi.itemType),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            if (oi.productSlug != null &&
                                oi.productSlug!.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right, size: 20),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _itemTypeLabel(String? type) {
    switch (type) {
      case 'MAIN':
        return '主要单品';
      case 'ACCESSORY':
        return '配饰';
      default:
        return type ?? '';
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除穿搭'),
        content: const Text('确定要删除这条穿搭记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(adminRepositoryProvider).deleteOutfit(id);
      ref.invalidate(adminOutfitListProvider);
      if (context.mounted) context.pop();
    }
  }
}
