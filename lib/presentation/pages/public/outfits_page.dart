import 'package:ankiblog_mobile/data/models/public_content.dart';
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

class OutfitsPage extends ConsumerWidget {
  const OutfitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outfits = ref.watch(publicOutfitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('穿搭记录')),
      body: AsyncStateView(
        value: outfits,
        builder: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('暂无穿搭记录'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _OutfitCard(item: items[index]),
          );
        },
      ),
    );
  }
}

class _OutfitCard extends StatelessWidget {
  const _OutfitCard({required this.item});

  final PublicOutfit item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/outfits/${item.id}'),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.outfitImage != null && item.outfitImage!.isNotEmpty)
              GestureDetector(
                onTap: () => showImageViewer(context, item.outfitImage!),
                child: RemoteImage(
                  url: item.outfitImage,
                  height: 200,
                  width: double.infinity,
                ),
              ),
            if (item.outfitDate != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(item.outfitDate),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            if (item.note != null && item.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(item.note!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            if (item.items.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: item.items.map((oi) {
                  final hasSlug =
                      oi.productSlug != null && oi.productSlug!.isNotEmpty;
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: hasSlug
                        ? () => context.push('/products/${oi.productSlug}')
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (oi.productMainImage != null &&
                              oi.productMainImage!.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                oi.productMainImage!,
                                width: 20,
                                height: 20,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.checkroom, size: 16),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            oi.productName ?? oi.itemType ?? '',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
