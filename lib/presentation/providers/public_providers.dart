import 'package:ankiblog_mobile/data/models/article.dart';
import 'package:ankiblog_mobile/data/models/custom_page.dart';
import 'package:ankiblog_mobile/data/models/daily_outfit.dart';
import 'package:ankiblog_mobile/data/models/link.dart';
import 'package:ankiblog_mobile/data/models/product.dart';
import 'package:ankiblog_mobile/data/models/public_content.dart';
import 'package:ankiblog_mobile/data/models/site_config.dart';
import 'package:ankiblog_mobile/data/repositories/public_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final siteConfigProvider = FutureProvider<SiteConfig>((ref) {
  return ref.watch(publicRepositoryProvider).getSiteBasicInfo();
});

final featuredArticlesProvider = FutureProvider<List<Article>>((ref) async {
  final page = await ref
      .watch(publicRepositoryProvider)
      .getArticles(size: 5, featured: true);
  return page.content;
});

final articleListProvider = FutureProvider<List<Article>>((ref) async {
  final page = await ref.watch(publicRepositoryProvider).getArticles();
  return page.content;
});

final articleDetailProvider = FutureProvider.family<Article, String>((
  ref,
  slug,
) {
  return ref.watch(publicRepositoryProvider).getArticle(slug);
});

final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final page = await ref
      .watch(publicRepositoryProvider)
      .getProducts(size: 5, featured: true);
  return page.content;
});

final productListProvider = FutureProvider<List<Product>>((ref) async {
  final page = await ref.watch(publicRepositoryProvider).getProducts();
  return page.content;
});

final productDetailProvider = FutureProvider.family<Product, String>((
  ref,
  slug,
) {
  return ref.watch(publicRepositoryProvider).getProduct(slug);
});

final customPageListProvider = FutureProvider<List<CustomPage>>((ref) async {
  final page = await ref.watch(publicRepositoryProvider).getCustomPages();
  return page.content;
});

final featuredCustomPagesProvider = FutureProvider<List<CustomPage>>((
  ref,
) async {
  return ref.watch(publicRepositoryProvider).getFeaturedCustomPages();
});

final customPageDetailProvider = FutureProvider.family<CustomPage, String>((
  ref,
  slug,
) {
  return ref.watch(publicRepositoryProvider).getCustomPage(slug);
});

final dailyOutfitSuggestionsProvider =
    FutureProvider<List<DailyOutfitSuggestion>>((ref) {
      return ref.watch(publicRepositoryProvider).getDailyOutfitSuggestions();
    });

final dailyOutfitDetailProvider =
    FutureProvider.family<DailyOutfitSuggestion, String>((ref, id) {
      return ref.watch(publicRepositoryProvider).getDailyOutfitSuggestion(id);
    });

final friendLinksProvider = FutureProvider<List<FriendLink>>((ref) {
  return ref.watch(publicRepositoryProvider).getFriendLinks();
});

final socialLinksProvider = FutureProvider<List<SocialLink>>((ref) {
  return ref.watch(publicRepositoryProvider).getSocialLinks();
});

final productCategoriesProvider = FutureProvider<List<ProductCategory>>((ref) {
  return ref.watch(publicRepositoryProvider).getProductCategories();
});

final productTagsProvider = FutureProvider<List<ProductTag>>((ref) {
  return ref.watch(publicRepositoryProvider).getProductTags();
});

final publicTodosProvider = FutureProvider<List<PublicTodo>>((ref) {
  return ref.watch(publicRepositoryProvider).getPublicTodos();
});

final publicOutfitsProvider = FutureProvider<List<PublicOutfit>>((ref) {
  return ref.watch(publicRepositoryProvider).getPublicOutfits();
});

final publicMakeupsProvider = FutureProvider<List<PublicMakeup>>((ref) {
  return ref.watch(publicRepositoryProvider).getPublicMakeups();
});

final goalsSummaryProvider = FutureProvider<GoalsSummary>((ref) {
  return ref.watch(publicRepositoryProvider).getGoalsSummary();
});

final outfitDetailProvider = FutureProvider.family<PublicOutfit, String>((
  ref,
  id,
) {
  return ref.watch(publicRepositoryProvider).getPublicOutfitById(id);
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final filteredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final page = await ref.watch(publicRepositoryProvider).getProducts(size: 50);
  if (selectedCategory == null) return page.content;
  return page.content.where((p) => p.categoryName == selectedCategory).toList();
});
