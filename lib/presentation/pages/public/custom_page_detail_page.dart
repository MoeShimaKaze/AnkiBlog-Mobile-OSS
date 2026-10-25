import 'package:ankiblog_mobile/data/models/custom_page.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/async_state_view.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/custom_page_html_view.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/markdown_viewer.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:ankiblog_mobile/presentation/providers/public_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomPageDetailPage extends ConsumerStatefulWidget {
  const CustomPageDetailPage({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<CustomPageDetailPage> createState() =>
      _CustomPageDetailPageState();
}

class _CustomPageDetailPageState extends ConsumerState<CustomPageDetailPage> {
  CustomPageRenderMode _renderMode = CustomPageRenderMode.adaptiveMobile;

  @override
  void didUpdateWidget(covariant CustomPageDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      _renderMode = CustomPageRenderMode.adaptiveMobile;
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = ref.watch(customPageDetailProvider(widget.slug));
    return Scaffold(
      appBar: AppBar(title: const Text('自定义页面')),
      body: AsyncStateView(
        value: page,
        builder: (data) {
          final renderHtml = _shouldRenderHtml(data);
          final standaloneLayout = _hasStandaloneLayout(data);
          final immersiveToolPage = renderHtml && _isImmersiveToolPage(data);
          if (immersiveToolPage) {
            return CustomPageHtmlView(
              page: data,
              standaloneLayout: true,
              renderMode: CustomPageRenderMode.adaptiveMobile,
              fillViewport: true,
            );
          }

          final htmlRenderMode = standaloneLayout
              ? _renderMode
              : CustomPageRenderMode.adaptiveMobile;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (data.coverImage?.isNotEmpty == true) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: RemoteImage(
                    url: data.coverImage,
                    width: double.infinity,
                    height: 190,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _PageHeader(page: data),
              const SizedBox(height: 16),
              if (renderHtml && standaloneLayout) ...[
                _RenderModeSwitch(
                  value: _renderMode,
                  onChanged: (value) => setState(() => _renderMode = value),
                ),
                const SizedBox(height: 12),
              ],
              if (renderHtml)
                standaloneLayout
                    ? CustomPageHtmlView(
                        page: data,
                        standaloneLayout: standaloneLayout,
                        renderMode: htmlRenderMode,
                      )
                    : GlassContainer(
                        child: CustomPageHtmlView(
                          page: data,
                          standaloneLayout: standaloneLayout,
                          renderMode: htmlRenderMode,
                        ),
                      )
              else
                GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '正文',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      MarkdownViewer(data: data.content),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  bool _shouldRenderHtml(CustomPage page) {
    return _containsHtml(page.content) ||
        page.hasCustomCode ||
        page.customCss?.isNotEmpty == true ||
        page.customJs?.isNotEmpty == true ||
        (page.template != null && page.template != 'default');
  }

  bool _hasStandaloneLayout(CustomPage page) {
    final content = page.content;
    return page.customCss?.isNotEmpty == true ||
        page.customJs?.isNotEmpty == true ||
        page.hasCustomCode ||
        (page.template != null && page.template != 'default') ||
        RegExp(
          r'<(style|main|section|article|header|footer)\b',
          caseSensitive: false,
        ).hasMatch(content) ||
        RegExp(
          r'''\s(class|id)=["'][^"']+["']''',
          caseSensitive: false,
        ).hasMatch(content);
  }

  bool _containsHtml(String content) {
    return RegExp(r'<[a-z][\s\S]*>', caseSensitive: false).hasMatch(content);
  }

  bool _isImmersiveToolPage(CustomPage page) {
    final slug = page.slug.toLowerCase();
    final title = page.title.toLowerCase();
    final content = page.content.toLowerCase();
    return slug == 'jirai-editor' ||
        slug.contains('jirai') ||
        title.contains('jirai') ||
        title.contains('地雷系') ||
        content.contains('jirai-editor-custom-page') ||
        content.contains('jirai-editor-frame') ||
        content.contains('data-anki-embedded-tool="jirai-editor"');
  }
}

class _RenderModeSwitch extends StatelessWidget {
  const _RenderModeSwitch({required this.value, required this.onChanged});

  final CustomPageRenderMode value;
  final ValueChanged<CustomPageRenderMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SegmentedButton<CustomPageRenderMode>(
        showSelectedIcon: false,
        selected: {value},
        onSelectionChanged: (selection) => onChanged(selection.first),
        segments: const [
          ButtonSegment(
            value: CustomPageRenderMode.adaptiveMobile,
            icon: Icon(Icons.fit_screen, size: 18),
            label: Text('适配'),
          ),
          ButtonSegment(
            value: CustomPageRenderMode.originalDesktop,
            icon: Icon(Icons.desktop_windows_outlined, size: 18),
            label: Text('原版'),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.page});

  final CustomPage page;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (page.pageIcon?.isNotEmpty == true) ...[
                Text(
                  page.pageIcon!,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  page.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (page.subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(page.subtitle),
          ],
          if (page.summary.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              page.summary,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.78),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.visibility, size: 16),
                label: Text('${page.viewCount} 次浏览'),
                visualDensity: VisualDensity.compact,
              ),
              if (page.updatedAt?.isNotEmpty == true)
                Chip(
                  avatar: const Icon(Icons.update, size: 16),
                  label: Text('更新于 ${page.updatedAt}'),
                  visualDensity: VisualDensity.compact,
                ),
              if (page.featured)
                const Chip(
                  avatar: Icon(Icons.star, size: 16),
                  label: Text('精选'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
