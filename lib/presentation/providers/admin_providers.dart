import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/data/repositories/admin_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ==================== Outfit ====================

final adminOutfitListProvider = FutureProvider<List<AdminOutfit>>((ref) async {
  final page = await ref.watch(adminRepositoryProvider).getOutfits(size: 50);
  return page.content;
});

final adminOutfitDetailProvider = FutureProvider.family<AdminOutfit, String>((
  ref,
  id,
) {
  return ref.watch(adminRepositoryProvider).getOutfit(id);
});

final adminOutfitCalendarProvider =
    FutureProvider.family<AdminCalendarData, ({int year, int month})>((
      ref,
      params,
    ) {
      return ref
          .watch(adminRepositoryProvider)
          .getOutfitCalendar(params.year, params.month);
    });

// ==================== Makeup ====================

final adminMakeupListProvider = FutureProvider<List<AdminMakeup>>((ref) async {
  final page = await ref.watch(adminRepositoryProvider).getMakeups(size: 50);
  return page.content;
});

final adminMakeupDetailProvider = FutureProvider.family<AdminMakeup, String>((
  ref,
  id,
) {
  return ref.watch(adminRepositoryProvider).getMakeup(id);
});

final adminMakeupCalendarProvider =
    FutureProvider.family<List<AdminMakeup>, ({int year, int month})>((
      ref,
      params,
    ) {
      return ref
          .watch(adminRepositoryProvider)
          .getMakeupCalendar(params.year, params.month);
    });

// ==================== Usage Types ====================

final usageTypesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).getUsageTypes();
});

// ==================== Todo ====================

final todoListsProvider = FutureProvider<List<AdminTodoList>>((ref) {
  return ref.watch(adminRepositoryProvider).getTodoLists();
});

final myDayItemsProvider = FutureProvider<List<AdminTodoItem>>((ref) {
  return ref.watch(adminRepositoryProvider).getMyDayItems();
});

final importantItemsProvider = FutureProvider<List<AdminTodoItem>>((ref) {
  return ref.watch(adminRepositoryProvider).getImportantItems();
});

final plannedItemsProvider = FutureProvider<List<AdminTodoItem>>((ref) {
  return ref.watch(adminRepositoryProvider).getPlannedItems();
});

final allActiveItemsProvider = FutureProvider<List<AdminTodoItem>>((ref) {
  return ref.watch(adminRepositoryProvider).getAllActiveItems();
});

final todoListItemsProvider =
    FutureProvider.family<List<AdminTodoItem>, String>((ref, listId) async {
      final page = await ref
          .watch(adminRepositoryProvider)
          .getListItems(listId, size: 100);
      return page.content;
    });

// ==================== Goal ====================

final adminGoalsProvider = FutureProvider.family<List<AdminGoal>, String?>((
  ref,
  status,
) {
  return ref.watch(adminRepositoryProvider).getGoals(status: status);
});

final adminGoalDetailProvider = FutureProvider.family<AdminGoal, String>((
  ref,
  id,
) {
  return ref.watch(adminRepositoryProvider).getGoal(id);
});

final goalMilestonesProvider =
    FutureProvider.family<List<AdminMilestone>, String>((ref, goalId) {
      return ref.watch(adminRepositoryProvider).getMilestones(goalId);
    });

// ==================== Wardrobe / Cosmetics ====================

final wardrobeOverviewProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(adminRepositoryProvider).getWardrobeOverview();
});

final cosmeticOverviewProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(adminRepositoryProvider).getCosmeticOverview();
});

// ==================== Accounting ====================

final accountingCategoriesProvider = FutureProvider<List<String>>((ref) {
  return ref.watch(adminRepositoryProvider).getAccountingCategories();
});

// ==================== Products for selection ====================

final productSearchProvider = FutureProvider.family<PageResult, String>((
  ref,
  keyword,
) async {
  final page = await ref
      .watch(adminRepositoryProvider)
      .getProductsForSelect(keyword: keyword.isEmpty ? null : keyword);
  return PageResult(
    items: page.content
        .map(
          (e) => ProductSelectItem(
            id: e['id']?.toString() ?? '',
            name: e['name']?.toString() ?? '',
            mainImage:
                e['main_image']?.toString() ?? e['mainImage']?.toString(),
            brand: e['brand']?.toString(),
          ),
        )
        .toList(growable: false),
    hasNext: page.hasNext,
  );
});

final outfitProductSearchProvider = FutureProvider.family<PageResult, String>((
  ref,
  keyword,
) async {
  final page = await ref
      .watch(adminRepositoryProvider)
      .getWardrobeProducts(
        keyword: keyword.isEmpty ? null : keyword,
        onlyPurchased: true,
      );
  return PageResult(
    items: page.content
        .map(
          (e) => ProductSelectItem(
            id: e['id']?.toString() ?? '',
            name: e['name']?.toString() ?? '',
            mainImage:
                e['main_image']?.toString() ?? e['mainImage']?.toString(),
            brand: e['brand']?.toString(),
          ),
        )
        .toList(growable: false),
    hasNext: page.hasNext,
  );
});

class PageResult {
  const PageResult({required this.items, required this.hasNext});
  final List<ProductSelectItem> items;
  final bool hasNext;
}

class ProductSelectItem {
  const ProductSelectItem({
    required this.id,
    required this.name,
    this.mainImage,
    this.brand,
  });
  final String id;
  final String name;
  final String? mainImage;
  final String? brand;
}

// ==================== Dashboard ====================

final dashboardOverviewProvider = FutureProvider<AdminDashboardOverview>((ref) {
  return ref.watch(adminRepositoryProvider).getDashboardOverview();
});

final dashboardTrendsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, days) {
      return ref.watch(adminRepositoryProvider).getDashboardTrends(days: days);
    });

// ==================== Site Profile ====================

final siteProfileProvider = FutureProvider<AdminSiteProfile>((ref) {
  return ref.watch(adminRepositoryProvider).getSiteProfile();
});

// ==================== Tags ====================

final tagsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final page = await ref.watch(adminRepositoryProvider).getTags(size: 100);
  return page.content;
});

// ==================== Category Tree ====================

final categoryTreeProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).getCategoryTree();
});

// ==================== Notification Channels ====================

final notificationChannelsProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) {
    return ref.watch(adminRepositoryProvider).getNotificationChannels();
  },
);

// ==================== Subscription Stats ====================

final subscriptionStatsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(adminRepositoryProvider).getSubscriptionStats();
});

// ==================== Cache ====================

final cacheStatsProvider = FutureProvider<List<AdminCacheStats>>((ref) {
  return ref.watch(adminRepositoryProvider).getCacheStats();
});

final redisInfoProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(adminRepositoryProvider).getRedisInfo();
});

// ==================== Files ====================

final bucketsProvider = FutureProvider<List<AdminBucket>>((ref) {
  return ref.watch(adminRepositoryProvider).getBuckets();
});

final filesProvider = FutureProvider.family<List<AdminFileItem>, String>((
  ref,
  bucketName,
) {
  return ref.watch(adminRepositoryProvider).getFiles(bucketName);
});

// ==================== Friend Links ====================

final friendLinksProvider = FutureProvider<List<AdminFriendLink>>((ref) {
  return ref.watch(adminRepositoryProvider).getFriendLinks();
});

// ==================== Social Links ====================

final socialLinksProvider = FutureProvider<List<AdminSocialLink>>((ref) {
  return ref.watch(adminRepositoryProvider).getSocialLinks();
});
