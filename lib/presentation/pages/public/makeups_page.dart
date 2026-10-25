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
import 'package:url_launcher/url_launcher.dart';

String _formatDate(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  try {
    final dt = DateTime.parse(raw);
    return DateFormat('yy/MM/dd HH:mm').format(dt);
  } catch (_) {
    return raw;
  }
}

class MakeupsPage extends ConsumerWidget {
  const MakeupsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final makeups = ref.watch(publicMakeupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('妆容记录')),
      body: AsyncStateView(
        value: makeups,
        builder: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('暂无妆容记录'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _MakeupCard(item: items[index]),
          );
        },
      ),
    );
  }
}

class _MakeupCard extends StatelessWidget {
  const _MakeupCard({required this.item});

  final PublicMakeup item;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.makeupImage != null && item.makeupImage!.isNotEmpty)
            GestureDetector(
              onTap: () => showImageViewer(context, item.makeupImage!),
              child: RemoteImage(
                url: item.makeupImage,
                height: 200,
                width: double.infinity,
              ),
            ),
          if (item.lookName != null && item.lookName!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              item.lookName!,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
          if (item.makeupDate != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(item.makeupDate),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
          if (item.note != null && item.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(item.note!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          if (item.referenceUrl != null && item.referenceUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => launchUrl(
                Uri.parse(item.referenceUrl!),
                mode: LaunchMode.externalApplication,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.link,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '参考链接',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (item.items.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: item.items.map((mi) {
                final hasSlug =
                    mi.productSlug != null && mi.productSlug!.isNotEmpty;
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: hasSlug
                      ? () => context.push('/products/${mi.productSlug}')
                      : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.tertiaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (mi.productMainImage != null &&
                            mi.productMainImage!.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              mi.productMainImage!,
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.brush, size: 16),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          [
                            mi.productName,
                            mi.brand,
                            mi.usageTypeName,
                          ].where((s) => s != null && s.isNotEmpty).join(' · '),
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
    );
  }
}
