import 'package:ankiblog_mobile/data/models/article.dart';
import 'package:ankiblog_mobile/data/models/product.dart';
import 'package:ankiblog_mobile/data/models/search_result.dart';
import 'package:ankiblog_mobile/data/repositories/public_repository.dart';
import 'package:ankiblog_mobile/data/sources/local/search_history_local_source.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/remote_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultProvider = FutureProvider<SearchResult?>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return null;
  return ref.watch(publicRepositoryProvider).search(query: query.trim());
});

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _controller;
  List<String> _history = const [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() => setState(() {}));
    _loadHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final history = await ref
        .read(searchHistoryLocalSourceProvider)
        .getHistory();
    if (mounted) setState(() => _history = history);
  }

  Future<void> _onSearch(String value) async {
    final query = value.trim();
    if (query.isEmpty) return;
    final history = await ref.read(searchHistoryLocalSourceProvider).add(query);
    if (mounted) setState(() => _history = history);
    ref.read(searchQueryProvider.notifier).state = query;
  }

  Future<void> _clearHistory() async {
    await ref.read(searchHistoryLocalSourceProvider).clear();
    if (mounted) setState(() => _history = const []);
  }

  void _selectSuggestion(String query) {
    _controller.text = query;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: _controller.text.length),
    );
    _onSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(searchResultProvider);
    final keyword = _controller.text.trim().toLowerCase();
    final suggestions = keyword.isEmpty
        ? _history
        : _history
              .where((item) => item.toLowerCase().contains(keyword))
              .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: _onSearch,
          decoration: InputDecoration(
            hintText: '搜索文章、产品、页面...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _onSearch(_controller.text),
            ),
          ),
        ),
      ),
      body: result.when(
        data: (data) {
          if (data == null) {
            return _SearchSuggestions(
              suggestions: suggestions,
              onSelected: _selectSuggestion,
              onClear: _clearHistory,
            );
          }
          if (data.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 80),
                const Center(child: Text('未找到相关内容')),
                const SizedBox(height: 24),
                _SearchSuggestions(
                  suggestions: suggestions,
                  onSelected: _selectSuggestion,
                  onClear: _clearHistory,
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (suggestions.isNotEmpty) ...[
                _SearchSuggestions(
                  suggestions: suggestions.take(6).toList(growable: false),
                  onSelected: _selectSuggestion,
                  onClear: _clearHistory,
                  compact: true,
                ),
                const SizedBox(height: 16),
              ],
              if (data.matchedTags.isNotEmpty) ...[
                Text('标签', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: data.matchedTags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                      ),
                      child: Text(
                        '${tag.name} (${tag.articleCount + tag.productCount})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
              if (data.articles.isNotEmpty) ...[
                Text(
                  '文章 (${data.summary?.totalArticles ?? data.articles.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...data.articles.map(
                  (article) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ArticleTile(item: article),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (data.products.isNotEmpty) ...[
                Text(
                  '产品 (${data.summary?.totalProducts ?? data.products.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...data.products.map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ProductTile(item: product),
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('搜索出错: $e')),
      ),
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  const _SearchSuggestions({
    required this.suggestions,
    required this.onSelected,
    required this.onClear,
    this.compact = false,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSelected;
  final VoidCallback onClear;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: compact ? 0 : 120),
          child: const Text('输入关键词开始搜索'),
        ),
      );
    }

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('最近搜索', style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              TextButton(onPressed: onClear, child: const Text('清空')),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions
                .map(
                  (query) => ActionChip(
                    avatar: const Icon(Icons.history, size: 16),
                    label: Text(query),
                    onPressed: () => onSelected(query),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.item});

  final Article item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/articles/${item.slug}'),
      child: GlassContainer(
        child: Row(
          children: [
            RemoteImage(url: item.coverImage, width: 80, height: 72),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.excerpt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.item});

  final Product item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/products/${item.slug}'),
      child: GlassContainer(
        child: Row(
          children: [
            RemoteImage(url: item.mainImage, width: 80, height: 72),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    '${item.currency} ${item.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
