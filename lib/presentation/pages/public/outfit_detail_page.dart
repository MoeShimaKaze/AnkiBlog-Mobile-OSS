import 'package:ankiblog_mobile/presentation/common/widgets/async_state_view.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/image_viewer.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:ankiblog_mobile/presentation/providers/public_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

String _formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  try {
    final dt = DateTime.parse(raw);
    return DateFormat('yy/MM/dd HH:mm').format(dt);
  } catch (_) {
    return raw;
  }
}

class OutfitDetailPage extends ConsumerWidget {
  const OutfitDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outfit = ref.watch(outfitDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: const Text('穿搭详情')),
      body: AsyncStateView(
        value: outfit,
        builder: (data) {
          return ListView(
            padding: const EdgeInsets.all(16),
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
              if (data.outfitDate != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(data.outfitDate),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
              if (data.note != null && data.note!.isNotEmpty) ...[
                const SizedBox(height: 12),
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    data.note!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
              if (data.items.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '搭配单品 (${data.items.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...data.items.map((oi) {
                  final hasSlug =
                      oi.productSlug != null && oi.productSlug!.isNotEmpty;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: hasSlug
                          ? () => context.push('/products/${oi.productSlug}')
                          : null,
                      child: GlassContainer(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            if (oi.productMainImage != null &&
                                oi.productMainImage!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  oi.productMainImage!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.checkroom,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 56,
                                height: 56,
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
                                    oi.productName ?? '',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (oi.brand != null &&
                                      oi.brand!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      oi.brand!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
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
                                  color: oi.itemType == 'MAIN'
                                      ? Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer
                                      : Theme.of(
                                          context,
                                        ).colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  oi.itemType == 'MAIN' ? '主要' : '配饰',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: oi.itemType == 'MAIN'
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimaryContainer
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onTertiaryContainer,
                                  ),
                                ),
                              ),
                            if (hasSlug) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
