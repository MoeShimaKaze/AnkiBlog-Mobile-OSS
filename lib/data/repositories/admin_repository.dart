import 'package:ankiblog_mobile/data/api/admin_api.dart';
import 'package:ankiblog_mobile/data/api/api_client.dart';
import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/data/models/common/page_response.dart';
import 'package:ankiblog_mobile/data/models/daily_outfit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminApiProvider = Provider<AdminApi>((ref) {
  return AdminApi(ref.watch(dioProvider));
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(adminApiProvider));
});

class AdminRepository {
  const AdminRepository(this._api);

  final AdminApi _api;

  // Upload
  Future<String> uploadImage(String filePath, {String type = 'general'}) {
    return _api.uploadImage(filePath, type: type);
  }

  // Outfits
  Future<PageResponse<AdminOutfit>> getOutfits({int page = 0, int size = 20}) {
    return _api.getOutfits(page: page, size: size);
  }

  Future<AdminOutfit> getOutfit(String id) => _api.getOutfit(id);

  Future<AdminOutfit> createOutfit({
    required List<String> productIds,
    Map<String, String>? itemTypes,
    String? note,
    String? outfitImage,
    String? outfitDate,
  }) {
    return _api.createOutfit(
      productIds: productIds,
      itemTypes: itemTypes,
      note: note,
      outfitImage: outfitImage,
      outfitDate: outfitDate,
    );
  }

  Future<void> deleteOutfit(String id) => _api.deleteOutfit(id);

  // Daily Outfit Suggestions
  Future<DailyOutfitSuggestion> generateDailyOutfit({
    String? suggestionDate,
    int? itemCount,
    bool? onlyPurchased,
    bool? isPublic,
    String? note,
  }) {
    return _api.generateDailyOutfit(
      suggestionDate: suggestionDate,
      itemCount: itemCount,
      onlyPurchased: onlyPurchased,
      isPublic: isPublic,
      note: note,
    );
  }

  Future<DailyOutfitSuggestion> regenerateDailyOutfit({
    String? suggestionDate,
    int? itemCount,
    bool? onlyPurchased,
    bool? isPublic,
    String? note,
  }) {
    return _api.regenerateDailyOutfit(
      suggestionDate: suggestionDate,
      itemCount: itemCount,
      onlyPurchased: onlyPurchased,
      isPublic: isPublic,
      note: note,
    );
  }

  Future<PageResponse<DailyOutfitSuggestion>> getDailyOutfits({
    String? status,
    int page = 0,
    int size = 20,
  }) {
    return _api.getDailyOutfits(status: status, page: page, size: size);
  }

  Future<DailyOutfitSuggestion> getDailyOutfit(String id) {
    return _api.getDailyOutfit(id);
  }

  Future<DailyOutfitSuggestion> acceptDailyOutfit(String id) {
    return _api.acceptDailyOutfit(id);
  }

  Future<DailyOutfitSuggestion> rejectDailyOutfit(String id) {
    return _api.rejectDailyOutfit(id);
  }

  Future<void> deleteDailyOutfit(String id) => _api.deleteDailyOutfit(id);

  Future<AdminCalendarData> getOutfitCalendar(int year, int month) {
    return _api.getOutfitCalendar(year, month);
  }

  // Makeups
  Future<PageResponse<AdminMakeup>> getMakeups({int page = 0, int size = 20}) {
    return _api.getMakeups(page: page, size: size);
  }

  Future<AdminMakeup> getMakeup(String id) => _api.getMakeup(id);

  Future<AdminMakeup> createMakeup({
    required List<String> productIds,
    Map<String, String>? usageTypes,
    String? lookName,
    String? referenceUrl,
    String? makeupImage,
    String? makeupDate,
    String? note,
  }) {
    return _api.createMakeup(
      productIds: productIds,
      usageTypes: usageTypes,
      lookName: lookName,
      referenceUrl: referenceUrl,
      makeupImage: makeupImage,
      makeupDate: makeupDate,
      note: note,
    );
  }

  Future<void> deleteMakeup(String id) => _api.deleteMakeup(id);

  Future<List<AdminMakeup>> getMakeupCalendar(int year, int month) {
    return _api.getMakeupCalendar(year, month);
  }

  Future<List<Map<String, dynamic>>> getUsageTypes() {
    return _api.getUsageTypes();
  }

  Future<Map<String, dynamic>> getMakeupSettings() {
    return _api.getMakeupSettings();
  }

  // Todos
  Future<List<AdminTodoList>> getTodoLists() => _api.getTodoLists();

  Future<AdminTodoList> createTodoList({required String name, String? icon}) {
    return _api.createTodoList(name: name, icon: icon);
  }

  Future<void> deleteTodoList(String id) => _api.deleteTodoList(id);

  Future<List<AdminTodoItem>> getMyDayItems() => _api.getMyDayItems();

  Future<List<AdminTodoItem>> getImportantItems() => _api.getImportantItems();

  Future<List<AdminTodoItem>> getPlannedItems() => _api.getPlannedItems();

  Future<List<AdminTodoItem>> getAllActiveItems() => _api.getAllActiveItems();

  Future<PageResponse<AdminTodoItem>> getListItems(
    String listId, {
    int page = 0,
    int size = 50,
  }) {
    return _api.getListItems(listId, page: page, size: size);
  }

  Future<AdminTodoItem> createTodoItem({
    required String title,
    String? listId,
    String? note,
    String? dueDate,
    bool isMyDay = false,
    bool isImportant = false,
    List<String> steps = const [],
  }) {
    return _api.createTodoItem(
      title: title,
      listId: listId,
      note: note,
      dueDate: dueDate,
      isMyDay: isMyDay,
      isImportant: isImportant,
      steps: steps,
    );
  }

  Future<void> deleteTodoItem(String id) => _api.deleteTodoItem(id);

  Future<AdminTodoItem> completeTodoItem(String id) {
    return _api.completeTodoItem(id);
  }

  Future<AdminTodoItem> uncompleteTodoItem(String id) {
    return _api.uncompleteTodoItem(id);
  }

  Future<AdminTodoItem> toggleImportant(String id) {
    return _api.toggleImportant(id);
  }

  Future<AdminTodoItem> toggleMyDay(String id) {
    return _api.toggleMyDay(id);
  }

  // Steps
  Future<void> addStep(String itemId, String title, {int sortOrder = 0}) {
    return _api.addStep(itemId, title, sortOrder: sortOrder);
  }

  Future<void> toggleStep(String stepId) => _api.toggleStep(stepId);

  Future<void> deleteStep(String stepId) => _api.deleteStep(stepId);

  // Goals
  Future<List<AdminGoal>> getGoals({String? status, String? categoryId}) {
    return _api.getGoals(status: status, categoryId: categoryId);
  }

  Future<AdminGoal> getGoal(String id) => _api.getGoal(id);

  Future<AdminGoal> createGoal({
    required String name,
    String? description,
    String? categoryId,
  }) {
    return _api.createGoal(
      name: name,
      description: description,
      categoryId: categoryId,
    );
  }

  Future<void> deleteGoal(String id) => _api.deleteGoal(id);

  Future<void> checkIn(String goalId, {String? note, String? mood}) {
    return _api.checkIn(goalId, note: note, mood: mood);
  }

  Future<void> pauseGoal(String id) => _api.pauseGoal(id);

  Future<void> resumeGoal(String id) => _api.resumeGoal(id);

  Future<void> archiveGoal(String id) => _api.archiveGoal(id);

  // Milestones
  Future<List<AdminMilestone>> getMilestones(String goalId) {
    return _api.getMilestones(goalId);
  }

  // Purchases
  Future<PageResponse<Map<String, dynamic>>> getPurchases({
    int page = 0,
    int size = 20,
  }) {
    return _api.getPurchases(page: page, size: size);
  }

  Future<Map<String, dynamic>> createPurchase({
    required String productId,
    double? price,
    int quantity = 1,
    String? purchaseDate,
    String? colorCode,
    String? purchaseChannel,
    String? note,
  }) {
    return _api.createPurchase(
      productId: productId,
      price: price,
      quantity: quantity,
      purchaseDate: purchaseDate,
      colorCode: colorCode,
      purchaseChannel: purchaseChannel,
      note: note,
    );
  }

  Future<void> deletePurchase(String id) => _api.deletePurchase(id);

  Future<PageResponse<Map<String, dynamic>>> getPurchasedProducts({
    int page = 0,
    int size = 20,
    String? keyword,
    String? categoryId,
    List<String> tags = const [],
    double? minPrice,
    double? maxPrice,
  }) {
    return _api.getPurchasedProducts(
      page: page,
      size: size,
      keyword: keyword,
      categoryId: categoryId,
      tags: tags,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  // Accounting
  Future<PageResponse<Map<String, dynamic>>> getAccountingRecords({
    int page = 0,
    int size = 20,
    String? category,
    String? type,
    String? startTime,
    String? endTime,
  }) {
    return _api.getAccountingRecords(
      page: page,
      size: size,
      category: category,
      type: type,
      startTime: startTime,
      endTime: endTime,
    );
  }

  Future<List<String>> getAccountingCategories() {
    return _api.getAccountingCategories();
  }

  Future<Map<String, dynamic>> createAccountingRecord({
    required double amount,
    required String category,
    required String type,
    String? remark,
  }) {
    return _api.createAccountingRecord(
      amount: amount,
      category: category,
      type: type,
      remark: remark,
    );
  }

  Future<void> deleteAccountingRecord(String id) {
    return _api.deleteAccountingRecord(id);
  }

  // Wardrobe
  Future<Map<String, dynamic>> getWardrobeOverview() {
    return _api.getWardrobeOverview();
  }

  Future<PageResponse<Map<String, dynamic>>> getWardrobeProducts({
    int page = 0,
    int size = 20,
    String? keyword,
    List<String> categoryIds = const [],
    bool? onlyPurchased,
    bool useDefaultSettings = true,
  }) {
    return _api.getWardrobeProducts(
      page: page,
      size: size,
      keyword: keyword,
      categoryIds: categoryIds,
      onlyPurchased: onlyPurchased,
      useDefaultSettings: useDefaultSettings,
    );
  }

  Future<PageResponse<Map<String, dynamic>>> getWardrobeIdleItems({
    int page = 0,
    int size = 20,
  }) {
    return _api.getWardrobeIdleItems(page: page, size: size);
  }

  Future<List<Map<String, dynamic>>> getWardrobeStyleStats() {
    return _api.getWardrobeStyleStats();
  }

  Future<List<Map<String, dynamic>>> getWardrobeMostWorn() {
    return _api.getWardrobeMostWorn();
  }

  // Cosmetics
  Future<Map<String, dynamic>> getCosmeticOverview() {
    return _api.getCosmeticOverview();
  }

  Future<PageResponse<Map<String, dynamic>>> getCosmetics({
    int page = 0,
    int size = 20,
    List<String> categoryIds = const [],
    bool onlyPurchased = true,
    bool useDefaultSettings = true,
  }) {
    return _api.getCosmetics(
      page: page,
      size: size,
      categoryIds: categoryIds,
      onlyPurchased: onlyPurchased,
      useDefaultSettings: useDefaultSettings,
    );
  }

  Future<PageResponse<Map<String, dynamic>>> getCosmeticIdleItems({
    int page = 0,
    int size = 20,
    List<String> categoryIds = const [],
    bool onlyPurchased = true,
    int? days,
    bool useDefaultSettings = true,
  }) {
    return _api.getCosmeticIdleItems(
      page: page,
      size: size,
      categoryIds: categoryIds,
      onlyPurchased: onlyPurchased,
      days: days,
      useDefaultSettings: useDefaultSettings,
    );
  }

  Future<List<Map<String, dynamic>>> getCosmeticStyleStats({
    List<String> categoryIds = const [],
    bool onlyPurchased = true,
    bool useDefaultSettings = true,
  }) {
    return _api.getCosmeticStyleStats(
      categoryIds: categoryIds,
      onlyPurchased: onlyPurchased,
      useDefaultSettings: useDefaultSettings,
    );
  }

  Future<List<Map<String, dynamic>>> getMostUsedCosmetics({
    List<String> categoryIds = const [],
    bool onlyPurchased = true,
    bool useDefaultSettings = true,
  }) {
    return _api.getMostUsedCosmetics(
      categoryIds: categoryIds,
      onlyPurchased: onlyPurchased,
      useDefaultSettings: useDefaultSettings,
    );
  }

  // Products for selection
  Future<PageResponse<Map<String, dynamic>>> getProductsForSelect({
    String? keyword,
    int page = 0,
    int size = 20,
  }) {
    return _api.getProductsForSelect(keyword: keyword, page: page, size: size);
  }

  // Articles
  Future<PageResponse<AdminArticle>> getArticles({
    String? keyword,
    String? status,
    int page = 0,
    int size = 20,
  }) {
    return _api.getArticles(
      keyword: keyword,
      status: status,
      page: page,
      size: size,
    );
  }

  Future<AdminArticle> getArticle(String id) => _api.getArticle(id);

  Future<AdminArticle> createArticle(Map<String, dynamic> body) {
    return _api.createArticle(body);
  }

  Future<AdminArticle> updateArticle(String id, Map<String, dynamic> body) {
    return _api.updateArticle(id, body);
  }

  Future<void> sendArticleDeleteCode(String id) {
    return _api.sendArticleDeleteCode(id);
  }

  Future<void> deleteArticle(String id, String verificationCode) {
    return _api.deleteArticle(id, verificationCode);
  }

  // Products (Admin CRUD)
  Future<PageResponse<AdminProduct>> getAdminProducts({
    String? keyword,
    String? status,
    bool? featured,
    String? categoryId,
    int page = 0,
    int size = 20,
  }) {
    return _api.getAdminProducts(
      keyword: keyword,
      status: status,
      featured: featured,
      categoryId: categoryId,
      page: page,
      size: size,
    );
  }

  Future<AdminProduct> getAdminProduct(String id) => _api.getAdminProduct(id);

  Future<AdminProduct> createProduct(Map<String, dynamic> body) {
    return _api.createProduct(body);
  }

  Future<AdminProduct> updateProduct(String id, Map<String, dynamic> body) {
    return _api.updateProduct(id, body);
  }

  Future<void> patchProductStatus(String id, String status) {
    return _api.patchProductStatus(id, status);
  }

  Future<void> patchProductFeatured(String id) {
    return _api.patchProductFeatured(id);
  }

  Future<void> sendProductDeleteCode(String id) {
    return _api.sendProductDeleteCode(id);
  }

  Future<void> deleteProduct(String id, String verificationCode) {
    return _api.deleteProduct(id, verificationCode);
  }

  // Product Snapshots
  Future<PageResponse<AdminProductSnapshot>> getProductSnapshots(
    String productId, {
    int page = 0,
    int size = 20,
  }) {
    return _api.getProductSnapshots(productId, page: page, size: size);
  }

  Future<AdminProductSnapshot> createProductSnapshot(
    String productId,
    String description,
  ) {
    return _api.createProductSnapshot(productId, description);
  }

  Future<void> deleteProductSnapshot(String productId, String snapshotId) {
    return _api.deleteProductSnapshot(productId, snapshotId);
  }

  // Comments
  Future<PageResponse<AdminComment>> getComments({
    String? status,
    String? keyword,
    int page = 0,
    int size = 20,
  }) {
    return _api.getComments(
      status: status,
      keyword: keyword,
      page: page,
      size: size,
    );
  }

  Future<void> approveComment(String id) => _api.approveComment(id);

  Future<void> rejectComment(String id, {String? reason}) {
    return _api.rejectComment(id, reason: reason);
  }

  Future<void> spamComment(String id) => _api.spamComment(id);

  Future<void> deleteComment(String id) => _api.deleteComment(id);

  Future<void> replyToComment(
    String articleId,
    String content, {
    String? parentId,
  }) {
    return _api.replyToComment(articleId, content, parentId: parentId);
  }

  // Article Snapshots
  Future<PageResponse<AdminArticleSnapshot>> getArticleSnapshots(
    String articleId, {
    int page = 0,
    int size = 20,
  }) {
    return _api.getArticleSnapshots(articleId, page: page, size: size);
  }

  Future<AdminArticleSnapshot> createArticleSnapshot(
    String articleId,
    String description,
  ) {
    return _api.createArticleSnapshot(articleId, description);
  }

  Future<void> deleteArticleSnapshot(String articleId, String snapshotId) {
    return _api.deleteArticleSnapshot(articleId, snapshotId);
  }

  // Users
  Future<PageResponse<AdminUser>> getUsers({int page = 0, int size = 20}) {
    return _api.getUsers(page: page, size: size);
  }

  Future<PageResponse<AdminUser>> getPendingUsers({
    int page = 0,
    int size = 20,
  }) {
    return _api.getPendingUsers(page: page, size: size);
  }

  Future<PageResponse<AdminUser>> searchUsers({
    required String keyword,
    int page = 0,
    int size = 20,
  }) {
    return _api.searchUsers(keyword: keyword, page: page, size: size);
  }

  Future<AdminUser> getUser(String id) => _api.getUser(id);

  Future<void> approveUser(String id, {bool approved = true}) {
    return _api.approveUser(id, approved: approved);
  }

  Future<void> sendUserDeleteCode(String id) => _api.sendUserDeleteCode(id);

  Future<void> deleteUser(String id, String verificationCode) {
    return _api.deleteUser(id, verificationCode);
  }

  // Site Profile
  Future<AdminSiteProfile> getSiteProfile() => _api.getSiteProfile();

  Future<void> sendSiteUpdateCode() => _api.sendSiteUpdateCode();

  Future<void> updateSiteProfile(Map<String, dynamic> body) {
    return _api.updateSiteProfile(body);
  }

  // Backgrounds
  Future<PageResponse<AdminBackground>> getBackgrounds({
    int page = 0,
    int size = 50,
  }) {
    return _api.getBackgrounds(page: page, size: size);
  }

  Future<List<AdminBackground>> getActiveBackgroundApis() {
    return _api.getActiveBackgroundApis();
  }

  Future<String> refreshBackgroundImage({String? apiId}) {
    return _api.refreshBackgroundImage(apiId: apiId);
  }

  Future<void> createBackground(Map<String, dynamic> body) {
    return _api.createBackground(body);
  }

  Future<void> updateBackground(String id, Map<String, dynamic> body) {
    return _api.updateBackground(id, body);
  }

  Future<void> activateBackground(String id) => _api.activateBackground(id);

  Future<void> deactivateBackground(String id) => _api.deactivateBackground(id);

  Future<void> toggleBackground(String id) => _api.toggleBackground(id);

  Future<void> deleteBackground(String id) => _api.deleteBackground(id);

  // Friend Links
  Future<List<AdminFriendLink>> getFriendLinks() => _api.getFriendLinks();

  Future<void> createFriendLink(Map<String, dynamic> body) {
    return _api.createFriendLink(body);
  }

  Future<void> updateFriendLink(String id, Map<String, dynamic> body) {
    return _api.updateFriendLink(id, body);
  }

  Future<void> approveFriendLink(String id) => _api.approveFriendLink(id);

  Future<void> rejectFriendLink(String id) => _api.rejectFriendLink(id);

  Future<void> deleteFriendLink(String id) => _api.deleteFriendLink(id);

  // Social Links
  Future<List<AdminSocialLink>> getSocialLinks() => _api.getSocialLinks();

  Future<void> createSocialLink(Map<String, dynamic> body) {
    return _api.createSocialLink(body);
  }

  Future<void> updateSocialLink(String id, Map<String, dynamic> body) {
    return _api.updateSocialLink(id, body);
  }

  Future<void> deleteSocialLink(String id) => _api.deleteSocialLink(id);

  // Tags
  Future<PageResponse<Map<String, dynamic>>> getTags({
    String? keyword,
    int page = 0,
    int size = 50,
  }) {
    return _api.getTags(keyword: keyword, page: page, size: size);
  }

  Future<void> createTag(Map<String, dynamic> body) => _api.createTag(body);

  Future<void> updateTag(String id, Map<String, dynamic> body) {
    return _api.updateTag(id, body);
  }

  Future<void> deleteTag(String id) => _api.deleteTag(id);

  // Product Categories
  Future<List<Map<String, dynamic>>> getCategoryTree() =>
      _api.getCategoryTree();

  Future<void> createCategory(Map<String, dynamic> body) {
    return _api.createCategory(body);
  }

  Future<void> updateCategory(String id, Map<String, dynamic> body) {
    return _api.updateCategory(id, body);
  }

  Future<void> deleteCategory(String id) => _api.deleteCategory(id);

  // Notifications
  Future<List<Map<String, dynamic>>> getNotificationChannels() {
    return _api.getNotificationChannels();
  }

  Future<Map<String, dynamic>> getNotificationChannel(String type) {
    return _api.getNotificationChannel(type);
  }

  Future<void> updateNotificationChannel(
    String type,
    Map<String, dynamic> body,
  ) {
    return _api.updateNotificationChannel(type, body);
  }

  Future<Map<String, dynamic>> getDingtalkConfig() => _api.getDingtalkConfig();

  Future<void> updateDingtalkConfig(Map<String, dynamic> body) {
    return _api.updateDingtalkConfig(body);
  }

  Future<void> testDingtalk() => _api.testDingtalk();

  Future<PageResponse<AdminNotificationLog>> getNotificationLogs({
    String? type,
    String? channel,
    String? status,
    int page = 0,
    int size = 20,
  }) {
    return _api.getNotificationLogs(
      type: type,
      channel: channel,
      status: status,
      page: page,
      size: size,
    );
  }

  // Subscriptions
  Future<PageResponse<AdminSubscription>> getSubscriptions({
    String? keyword,
    int page = 0,
    int size = 20,
  }) {
    return _api.getSubscriptions(keyword: keyword, page: page, size: size);
  }

  Future<void> updateSubscription(String id, Map<String, dynamic> body) {
    return _api.updateSubscription(id, body);
  }

  Future<void> deleteSubscription(String id) => _api.deleteSubscription(id);

  Future<Map<String, dynamic>> getSubscriptionStats() {
    return _api.getSubscriptionStats();
  }

  // Cache
  Future<List<AdminCacheStats>> getCacheStats() => _api.getCacheStats();

  Future<void> clearCache(String cacheName) => _api.clearCache(cacheName);

  Future<void> clearAllCaches() => _api.clearAllCaches();

  Future<void> warmupCache(String cacheName) => _api.warmupCache(cacheName);

  Future<Map<String, dynamic>> getRedisInfo() => _api.getRedisInfo();

  // Files
  Future<List<AdminBucket>> getBuckets() => _api.getBuckets();

  Future<List<AdminFileItem>> getFiles(String bucketName) {
    return _api.getFiles(bucketName);
  }

  Future<void> deleteFile(String fileUrl) => _api.deleteFile(fileUrl);

  Future<void> deleteFileDirect(String bucketName, String objectName) {
    return _api.deleteFileDirect(bucketName, objectName);
  }

  Future<void> deleteFilesBatch(List<String> fileUrls) {
    return _api.deleteFilesBatch(fileUrls);
  }

  Future<String> getFileUrl(String bucketName, String objectName) {
    return _api.getFileUrl(bucketName, objectName);
  }

  Future<String> uploadFile(String filePath, {required String bucketName}) {
    return _api.uploadFile(filePath, bucketName: bucketName);
  }

  // Dashboard
  Future<AdminDashboardOverview> getDashboardOverview() {
    return _api.getDashboardOverview();
  }

  Future<List<Map<String, dynamic>>> getDashboardTrends({int days = 30}) {
    return _api.getDashboardTrends(days: days);
  }

  // Custom Pages
  Future<PageResponse<Map<String, dynamic>>> getCustomPages({
    String? keyword,
    int page = 0,
    int size = 20,
  }) {
    return _api.getCustomPages(keyword: keyword, page: page, size: size);
  }

  Future<Map<String, dynamic>> getCustomPage(String id) {
    return _api.getCustomPage(id);
  }

  Future<void> createCustomPage(Map<String, dynamic> body) {
    return _api.createCustomPage(body);
  }

  Future<void> updateCustomPage(String id, Map<String, dynamic> body) {
    return _api.updateCustomPage(id, body);
  }

  Future<void> publishPage(String id) => _api.publishPage(id);

  Future<void> unpublishPage(String id) => _api.unpublishPage(id);

  Future<void> deleteCustomPage(String id) => _api.deleteCustomPage(id);

  // Page Type Configs
  Future<List<Map<String, dynamic>>> getPageTypeConfigs() {
    return _api.getPageTypeConfigs();
  }

  Future<void> createPageTypeConfig(Map<String, dynamic> body) {
    return _api.createPageTypeConfig(body);
  }

  Future<void> updatePageTypeConfig(
    String pageType,
    Map<String, dynamic> body,
  ) {
    return _api.updatePageTypeConfig(pageType, body);
  }

  Future<void> deletePageTypeConfig(String pageType) {
    return _api.deletePageTypeConfig(pageType);
  }
}
