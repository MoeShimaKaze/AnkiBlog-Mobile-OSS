import 'package:ankiblog_mobile/data/models/common/api_response.dart';
import 'package:ankiblog_mobile/data/models/common/page_response.dart';
import 'package:ankiblog_mobile/data/models/admin/admin_models.dart';
import 'package:ankiblog_mobile/data/models/daily_outfit.dart';
import 'package:dio/dio.dart';

class AdminApi {
  const AdminApi(this._dio);

  final Dio _dio;

  // ==================== Upload ====================

  Future<String> uploadImage(String filePath, {String type = 'general'}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'type': type,
    });
    final response = await _dio.post<Object?>(
      '/admin/upload/image',
      data: formData,
    );
    return ApiResponse.unwrap(response.data, (data) => data as String);
  }

  Future<String> uploadFile(
    String filePath, {
    required String bucketName,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'bucket': bucketName,
    });
    final response = await _dio.post<Object?>(
      '/admin/upload/to-bucket',
      data: formData,
    );
    return ApiResponse.unwrap(response.data, (data) => data.toString());
  }

  // ==================== Outfits ====================

  Future<PageResponse<AdminOutfit>> getOutfits({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Object?>(
      '/admin/outfits',
      queryParameters: {'page': page, 'size': size, 'sort': 'createdAt,desc'},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, AdminOutfit.fromJson),
    );
  }

  Future<AdminOutfit> getOutfit(String id) async {
    final response = await _dio.get<Object?>('/admin/outfits/$id');
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminOutfit.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AdminOutfit> createOutfit({
    required List<String> productIds,
    Map<String, String>? itemTypes,
    String? note,
    String? outfitImage,
    String? outfitDate,
  }) async {
    final body = <String, dynamic>{'productIds': productIds};
    if (itemTypes != null && itemTypes.isNotEmpty) {
      body['itemTypes'] = itemTypes;
    }
    if (note != null) body['note'] = note;
    if (outfitImage != null) body['outfitImage'] = outfitImage;
    if (outfitDate != null) body['outfitDate'] = outfitDate;

    final response = await _dio.post<Object?>('/admin/outfits', data: body);
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminOutfit.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteOutfit(String id) async {
    await _dio.delete<Object?>('/admin/outfits/$id');
  }

  // ==================== Daily Outfit Suggestions ====================

  Future<DailyOutfitSuggestion> generateDailyOutfit({
    String? suggestionDate,
    int? itemCount,
    bool? onlyPurchased,
    bool? isPublic,
    String? note,
  }) async {
    final body = <String, dynamic>{};
    if (suggestionDate != null) body['suggestion_date'] = suggestionDate;
    if (itemCount != null) body['item_count'] = itemCount;
    if (onlyPurchased != null) body['only_purchased'] = onlyPurchased;
    if (isPublic != null) body['is_public'] = isPublic;
    if (note != null && note.trim().isNotEmpty) body['note'] = note.trim();
    final response = await _dio.post<Object?>(
      '/admin/daily-outfit/generate',
      data: body,
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => DailyOutfitSuggestion.fromJson(
        data as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  Future<DailyOutfitSuggestion> regenerateDailyOutfit({
    String? suggestionDate,
    int? itemCount,
    bool? onlyPurchased,
    bool? isPublic,
    String? note,
  }) async {
    final body = <String, dynamic>{};
    if (suggestionDate != null) body['suggestion_date'] = suggestionDate;
    if (itemCount != null) body['item_count'] = itemCount;
    if (onlyPurchased != null) body['only_purchased'] = onlyPurchased;
    if (isPublic != null) body['is_public'] = isPublic;
    if (note != null && note.trim().isNotEmpty) body['note'] = note.trim();
    final response = await _dio.post<Object?>(
      '/admin/daily-outfit/regenerate',
      data: body,
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => DailyOutfitSuggestion.fromJson(
        data as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  Future<PageResponse<DailyOutfitSuggestion>> getDailyOutfits({
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': 'createdAt,desc',
    };
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    final response = await _dio.get<Object?>(
      '/admin/daily-outfit',
      queryParameters: queryParams,
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, DailyOutfitSuggestion.fromJson),
    );
  }

  Future<DailyOutfitSuggestion> getDailyOutfit(String id) async {
    final response = await _dio.get<Object?>('/admin/daily-outfit/$id');
    return ApiResponse.unwrap(
      response.data,
      (data) => DailyOutfitSuggestion.fromJson(
        data as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  Future<DailyOutfitSuggestion> acceptDailyOutfit(String id) async {
    final response = await _dio.post<Object?>(
      '/admin/daily-outfit/$id/accept',
      data: const <String, dynamic>{},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => DailyOutfitSuggestion.fromJson(
        data as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  Future<DailyOutfitSuggestion> rejectDailyOutfit(String id) async {
    final response = await _dio.post<Object?>('/admin/daily-outfit/$id/reject');
    return ApiResponse.unwrap(
      response.data,
      (data) => DailyOutfitSuggestion.fromJson(
        data as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  Future<void> deleteDailyOutfit(String id) async {
    await _dio.delete<Object?>('/admin/daily-outfit/$id');
  }

  Future<AdminCalendarData> getOutfitCalendar(int year, int month) async {
    final response = await _dio.get<Object?>(
      '/admin/outfits/calendar',
      queryParameters: {'year': year, 'month': month},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminCalendarData.fromJson(data as Map<String, dynamic>),
    );
  }

  // ==================== Makeups ====================

  Future<PageResponse<AdminMakeup>> getMakeups({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Object?>(
      '/admin/makeups',
      queryParameters: {'page': page, 'size': size, 'sort': 'createdAt,desc'},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, AdminMakeup.fromJson),
    );
  }

  Future<AdminMakeup> getMakeup(String id) async {
    final response = await _dio.get<Object?>('/admin/makeups/$id');
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminMakeup.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AdminMakeup> createMakeup({
    required List<String> productIds,
    Map<String, String>? usageTypes,
    String? lookName,
    String? referenceUrl,
    String? makeupImage,
    String? makeupDate,
    String? note,
  }) async {
    final body = <String, dynamic>{'product_ids': productIds};
    if (usageTypes != null && usageTypes.isNotEmpty) {
      body['usage_types'] = usageTypes;
    }
    if (lookName != null) body['look_name'] = lookName;
    if (referenceUrl != null) body['reference_url'] = referenceUrl;
    if (makeupImage != null) body['makeup_image'] = makeupImage;
    if (makeupDate != null) body['makeup_date'] = makeupDate;
    if (note != null) body['note'] = note;

    final response = await _dio.post<Object?>('/admin/makeups', data: body);
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminMakeup.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteMakeup(String id) async {
    await _dio.delete<Object?>('/admin/makeups/$id');
  }

  Future<List<AdminMakeup>> getMakeupCalendar(int year, int month) async {
    final response = await _dio.get<Object?>(
      '/admin/makeups/calendar',
      queryParameters: {'year': year, 'month': month},
    );
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(AdminMakeup.fromJson)
            .toList(growable: false);
      }
      return const <AdminMakeup>[];
    });
  }

  // ==================== Makeup Usage Types ====================

  Future<List<Map<String, dynamic>>> getUsageTypes() async {
    final response = await _dio.get<Object?>('/admin/makeup-usage-types');
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList(growable: false);
      }
      return const <Map<String, dynamic>>[];
    });
  }

  Future<Map<String, dynamic>> getMakeupSettings() async {
    final response = await _dio.get<Object?>('/admin/makeup-settings');
    return ApiResponse.unwrap(
      response.data,
      (data) => data as Map<String, dynamic>,
    );
  }

  // ==================== Todo Lists ====================

  Future<List<AdminTodoList>> getTodoLists() async {
    final response = await _dio.get<Object?>('/admin/todos/lists');
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(AdminTodoList.fromJson)
            .toList(growable: false);
      }
      return const <AdminTodoList>[];
    });
  }

  Future<AdminTodoList> createTodoList({
    required String name,
    String? icon,
  }) async {
    final body = <String, dynamic>{'name': name};
    if (icon != null) body['icon'] = icon;
    final response = await _dio.post<Object?>('/admin/todos/lists', data: body);
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminTodoList.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteTodoList(String id) async {
    await _dio.delete<Object?>('/admin/todos/lists/$id');
  }

  // ==================== Todo Items ====================

  Future<List<AdminTodoItem>> getMyDayItems() async {
    final response = await _dio.get<Object?>('/admin/todos/my-day');
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(AdminTodoItem.fromJson)
            .toList(growable: false);
      }
      return const <AdminTodoItem>[];
    });
  }

  Future<List<AdminTodoItem>> getImportantItems() async {
    final response = await _dio.get<Object?>('/admin/todos/important');
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(AdminTodoItem.fromJson)
            .toList(growable: false);
      }
      return const <AdminTodoItem>[];
    });
  }

  Future<List<AdminTodoItem>> getPlannedItems() async {
    final response = await _dio.get<Object?>('/admin/todos/planned');
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(AdminTodoItem.fromJson)
            .toList(growable: false);
      }
      return const <AdminTodoItem>[];
    });
  }

  Future<List<AdminTodoItem>> getAllActiveItems() async {
    final response = await _dio.get<Object?>('/admin/todos/all');
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(AdminTodoItem.fromJson)
            .toList(growable: false);
      }
      return const <AdminTodoItem>[];
    });
  }

  Future<PageResponse<AdminTodoItem>> getListItems(
    String listId, {
    int page = 0,
    int size = 50,
  }) async {
    final response = await _dio.get<Object?>(
      '/admin/todos/lists/$listId/items',
      queryParameters: {'page': page, 'size': size, 'sort': 'sortOrder,asc'},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, AdminTodoItem.fromJson),
    );
  }

  Future<AdminTodoItem> createTodoItem({
    required String title,
    String? listId,
    String? note,
    String? dueDate,
    bool isMyDay = false,
    bool isImportant = false,
    List<String> steps = const [],
  }) async {
    final body = <String, dynamic>{'title': title};
    if (listId != null) body['list_id'] = listId;
    if (note != null) body['note'] = note;
    if (dueDate != null) body['due_date'] = dueDate;
    body['is_my_day'] = isMyDay;
    body['is_important'] = isImportant;
    if (steps.isNotEmpty) body['steps'] = steps;

    final response = await _dio.post<Object?>('/admin/todos/items', data: body);
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminTodoItem.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteTodoItem(String id) async {
    await _dio.delete<Object?>('/admin/todos/items/$id');
  }

  Future<AdminTodoItem> completeTodoItem(String id) async {
    final response = await _dio.post<Object?>(
      '/admin/todos/items/$id/complete',
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminTodoItem.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AdminTodoItem> uncompleteTodoItem(String id) async {
    final response = await _dio.post<Object?>(
      '/admin/todos/items/$id/uncomplete',
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminTodoItem.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AdminTodoItem> toggleImportant(String id) async {
    final response = await _dio.post<Object?>(
      '/admin/todos/items/$id/toggle-important',
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminTodoItem.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AdminTodoItem> toggleMyDay(String id) async {
    final response = await _dio.post<Object?>(
      '/admin/todos/items/$id/toggle-my-day',
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminTodoItem.fromJson(data as Map<String, dynamic>),
    );
  }

  // ==================== Todo Steps ====================

  Future<void> addStep(String itemId, String title, {int sortOrder = 0}) async {
    await _dio.post<Object?>(
      '/admin/todos/items/$itemId/steps',
      data: {'title': title, 'sort_order': sortOrder},
    );
  }

  Future<void> toggleStep(String stepId) async {
    await _dio.post<Object?>('/admin/todos/steps/$stepId/toggle');
  }

  Future<void> deleteStep(String stepId) async {
    await _dio.delete<Object?>('/admin/todos/steps/$stepId');
  }

  // ==================== Goals ====================

  Future<List<AdminGoal>> getGoals({String? status, String? categoryId}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    if (categoryId != null) queryParams['categoryId'] = categoryId;

    final response = await _dio.get<Object?>(
      '/admin/goals',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(AdminGoal.fromJson)
            .toList(growable: false);
      }
      return const <AdminGoal>[];
    });
  }

  Future<AdminGoal> getGoal(String id) async {
    final response = await _dio.get<Object?>('/admin/goals/$id');
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminGoal.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AdminGoal> createGoal({
    required String name,
    String? description,
    String? categoryId,
  }) async {
    final body = <String, dynamic>{'name': name};
    if (description != null) body['description'] = description;
    if (categoryId != null) body['category_id'] = categoryId;
    final response = await _dio.post<Object?>('/admin/goals', data: body);
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminGoal.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteGoal(String id) async {
    await _dio.delete<Object?>('/admin/goals/$id');
  }

  Future<void> checkIn(String goalId, {String? note, String? mood}) async {
    final body = <String, dynamic>{};
    if (note != null) body['note'] = note;
    if (mood != null) body['mood'] = mood;
    await _dio.post<Object?>('/admin/goals/$goalId/check-in', data: body);
  }

  Future<void> pauseGoal(String id) async {
    await _dio.post<Object?>('/admin/goals/$id/pause');
  }

  Future<void> resumeGoal(String id) async {
    await _dio.post<Object?>('/admin/goals/$id/resume');
  }

  Future<void> archiveGoal(String id) async {
    await _dio.post<Object?>('/admin/goals/$id/archive');
  }

  // ==================== Goal Milestones ====================

  Future<List<AdminMilestone>> getMilestones(String goalId) async {
    final response = await _dio.get<Object?>('/admin/goals/$goalId/milestones');
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(AdminMilestone.fromJson)
            .toList(growable: false);
      }
      return const <AdminMilestone>[];
    });
  }

  // ==================== Purchases ====================

  Future<PageResponse<Map<String, dynamic>>> getPurchases({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Object?>(
      '/admin/purchases',
      queryParameters: {'page': page, 'size': size},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, (json) => json),
    );
  }

  Future<Map<String, dynamic>> createPurchase({
    required String productId,
    double? price,
    int quantity = 1,
    String? purchaseDate,
    String? colorCode,
    String? purchaseChannel,
    String? note,
  }) async {
    final body = <String, dynamic>{
      'product_id': productId,
      'quantity': quantity,
    };
    if (price != null) body['price'] = price;
    if (purchaseDate != null) body['purchase_date'] = purchaseDate;
    if (colorCode != null) body['color_code'] = colorCode;
    if (purchaseChannel != null) body['purchase_channel'] = purchaseChannel;
    if (note != null) body['note'] = note;

    final response = await _dio.post<Object?>('/admin/purchases', data: body);
    return ApiResponse.unwrap(
      response.data,
      (data) => data as Map<String, dynamic>,
    );
  }

  Future<void> deletePurchase(String id) async {
    await _dio.delete<Object?>('/admin/purchases/$id');
  }

  // ==================== Purchased Products (public) ====================

  Future<PageResponse<Map<String, dynamic>>> getPurchasedProducts({
    int page = 0,
    int size = 20,
    String? keyword,
    String? categoryId,
    List<String> tags = const [],
    double? minPrice,
    double? maxPrice,
  }) async {
    final queryParams = <String, dynamic>{
      'isPurchased': true,
      'page': page,
      'size': size,
      'sort': 'createdAt,desc',
    };
    if (keyword != null && keyword.trim().isNotEmpty) {
      queryParams['keyword'] = keyword.trim();
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['categoryId'] = categoryId;
    }
    if (tags.isNotEmpty) queryParams['tags'] = tags;
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;

    final response = await _dio.get<Object?>(
      '/public/products',
      queryParameters: queryParams,
      options: Options(listFormat: ListFormat.multi),
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, (json) => json),
    );
  }

  // ==================== Accounting ====================

  Future<PageResponse<Map<String, dynamic>>> getAccountingRecords({
    int page = 0,
    int size = 20,
    String? category,
    String? type,
    String? startTime,
    String? endTime,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'size': size};
    if (category != null) queryParams['category'] = category;
    if (type != null) queryParams['type'] = type;
    if (startTime != null) queryParams['startTime'] = startTime;
    if (endTime != null) queryParams['endTime'] = endTime;

    final response = await _dio.get<Object?>(
      '/admin/accounting',
      queryParameters: queryParams,
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, (json) => json),
    );
  }

  Future<List<String>> getAccountingCategories() async {
    final response = await _dio.get<Object?>('/admin/accounting/categories');
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data.map((e) => e.toString()).toList(growable: false);
      }
      return const <String>[];
    });
  }

  Future<Map<String, dynamic>> createAccountingRecord({
    required double amount,
    required String category,
    required String type,
    String? remark,
  }) async {
    final body = <String, dynamic>{
      'amount': amount,
      'category': category,
      'type': type,
      'record_time': DateTime.now().toIso8601String(),
    };
    if (remark != null) body['remark'] = remark;

    final response = await _dio.post<Object?>('/admin/accounting', data: body);
    return ApiResponse.unwrap(
      response.data,
      (data) => data as Map<String, dynamic>,
    );
  }

  Future<void> deleteAccountingRecord(String id) async {
    await _dio.delete<Object?>('/admin/accounting/$id');
  }

  // ==================== Wardrobe ====================

  Future<Map<String, dynamic>> getWardrobeOverview() async {
    final response = await _dio.get<Object?>('/admin/wardrobe/overview');
    return ApiResponse.unwrap(
      response.data,
      (data) => data as Map<String, dynamic>,
    );
  }

  Future<PageResponse<Map<String, dynamic>>> getWardrobeProducts({
    int page = 0,
    int size = 20,
    String? keyword,
    List<String> categoryIds = const [],
    bool? onlyPurchased,
    bool useDefaultSettings = true,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'useDefaultSettings': useDefaultSettings,
    };
    if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;
    if (categoryIds.isNotEmpty) queryParams['categoryIds'] = categoryIds;
    if (onlyPurchased != null) queryParams['onlyPurchased'] = onlyPurchased;
    final response = await _dio.get<Object?>(
      '/admin/wardrobe',
      queryParameters: queryParams,
      options: Options(listFormat: ListFormat.multi),
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, (json) => json),
    );
  }

  Future<PageResponse<Map<String, dynamic>>> getWardrobeIdleItems({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Object?>(
      '/admin/wardrobe/idle',
      queryParameters: {'page': page, 'size': size},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, (json) => json),
    );
  }

  Future<List<Map<String, dynamic>>> getWardrobeStyleStats() async {
    final response = await _dio.get<Object?>('/admin/wardrobe/style-stats');
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList(growable: false);
      }
      return const <Map<String, dynamic>>[];
    });
  }

  Future<List<Map<String, dynamic>>> getWardrobeMostWorn() async {
    final response = await _dio.get<Object?>('/admin/wardrobe/most-worn');
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList(growable: false);
      }
      return const <Map<String, dynamic>>[];
    });
  }

  // ==================== Cosmetics ====================

  Future<Map<String, dynamic>> getCosmeticOverview() async {
    final response = await _dio.get<Object?>('/admin/cosmetics/overview');
    return ApiResponse.unwrap(
      response.data,
      (data) => data as Map<String, dynamic>,
    );
  }

  Future<PageResponse<Map<String, dynamic>>> getCosmetics({
    int page = 0,
    int size = 20,
    List<String> categoryIds = const [],
    bool onlyPurchased = true,
    bool useDefaultSettings = true,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'onlyPurchased': onlyPurchased,
      'useDefaultSettings': useDefaultSettings,
    };
    if (categoryIds.isNotEmpty) queryParams['categoryIds'] = categoryIds;
    final response = await _dio.get<Object?>(
      '/admin/cosmetics',
      queryParameters: queryParams,
      options: Options(listFormat: ListFormat.multi),
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, (json) => json),
    );
  }

  Future<PageResponse<Map<String, dynamic>>> getCosmeticIdleItems({
    int page = 0,
    int size = 20,
    List<String> categoryIds = const [],
    bool onlyPurchased = true,
    int? days,
    bool useDefaultSettings = true,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'onlyPurchased': onlyPurchased,
      'useDefaultSettings': useDefaultSettings,
    };
    if (categoryIds.isNotEmpty) queryParams['categoryIds'] = categoryIds;
    if (days != null) queryParams['days'] = days;
    final response = await _dio.get<Object?>(
      '/admin/cosmetics/idle',
      queryParameters: queryParams,
      options: Options(listFormat: ListFormat.multi),
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, (json) => json),
    );
  }

  Future<List<Map<String, dynamic>>> getCosmeticStyleStats({
    List<String> categoryIds = const [],
    bool onlyPurchased = true,
    bool useDefaultSettings = true,
  }) async {
    final queryParams = <String, dynamic>{
      'onlyPurchased': onlyPurchased,
      'useDefaultSettings': useDefaultSettings,
    };
    if (categoryIds.isNotEmpty) queryParams['categoryIds'] = categoryIds;
    final response = await _dio.get<Object?>(
      '/admin/cosmetics/style-stats',
      queryParameters: queryParams,
      options: Options(listFormat: ListFormat.multi),
    );
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList(growable: false);
      }
      return const <Map<String, dynamic>>[];
    });
  }

  Future<List<Map<String, dynamic>>> getMostUsedCosmetics({
    List<String> categoryIds = const [],
    bool onlyPurchased = true,
    bool useDefaultSettings = true,
  }) async {
    final queryParams = <String, dynamic>{
      'onlyPurchased': onlyPurchased,
      'useDefaultSettings': useDefaultSettings,
    };
    if (categoryIds.isNotEmpty) queryParams['categoryIds'] = categoryIds;
    final response = await _dio.get<Object?>(
      '/admin/cosmetics/most-used',
      queryParameters: queryParams,
      options: Options(listFormat: ListFormat.multi),
    );
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList(growable: false);
      }
      return const <Map<String, dynamic>>[];
    });
  }

  // ==================== Products (for selection) ====================

  Future<PageResponse<Map<String, dynamic>>> getProductsForSelect({
    String? keyword,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'size': size};
    if (keyword != null) queryParams['keyword'] = keyword;

    final response = await _dio.get<Object?>(
      '/admin/accounting/products',
      queryParameters: queryParams,
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, (json) => json),
    );
  }

  // ==================== Articles ====================

  Future<PageResponse<AdminArticle>> getArticles({
    String? keyword,
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': 'createdAt,desc',
    };
    if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    final response = await _dio.get<Object?>(
      '/admin/articles',
      queryParameters: queryParams,
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, AdminArticle.fromJson),
    );
  }

  Future<AdminArticle> getArticle(String id) async {
    final response = await _dio.get<Object?>('/admin/articles/$id');
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminArticle.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AdminArticle> createArticle(Map<String, dynamic> body) async {
    final response = await _dio.post<Object?>('/admin/articles', data: body);
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminArticle.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AdminArticle> updateArticle(
    String id,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.put<Object?>('/admin/articles/$id', data: body);
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminArticle.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> sendArticleDeleteCode(String id) async {
    await _dio.post<Object?>('/admin/articles/$id/send-delete-code');
  }

  Future<void> deleteArticle(String id, String verificationCode) async {
    await _dio.delete<Object?>(
      '/admin/articles/$id',
      data: {'verification_code': verificationCode},
    );
  }

  // ==================== Products (Admin CRUD) ====================

  Future<PageResponse<AdminProduct>> getAdminProducts({
    String? keyword,
    String? status,
    bool? featured,
    String? categoryId,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': 'createdAt,desc',
    };
    if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;
    if (status != null) queryParams['status'] = status;
    if (featured != null) queryParams['featured'] = featured;
    if (categoryId != null) queryParams['categoryId'] = categoryId;
    final response = await _dio.get<Object?>(
      '/admin/products',
      queryParameters: queryParams,
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, AdminProduct.fromJson),
    );
  }

  Future<AdminProduct> getAdminProduct(String id) async {
    final response = await _dio.get<Object?>('/admin/products/$id');
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminProduct.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AdminProduct> createProduct(Map<String, dynamic> body) async {
    final response = await _dio.post<Object?>('/admin/products', data: body);
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminProduct.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AdminProduct> updateProduct(
    String id,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.put<Object?>('/admin/products/$id', data: body);
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminProduct.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> patchProductStatus(String id, String status) async {
    await _dio.patch<Object?>(
      '/admin/products/$id/status',
      queryParameters: {'status': status},
    );
  }

  Future<void> patchProductFeatured(String id) async {
    await _dio.patch<Object?>('/admin/products/$id/featured');
  }

  Future<void> sendProductDeleteCode(String id) async {
    await _dio.post<Object?>('/admin/products/$id/send-delete-code');
  }

  Future<void> deleteProduct(String id, String verificationCode) async {
    await _dio.delete<Object?>(
      '/admin/products/$id',
      data: {'verification_code': verificationCode},
    );
  }

  // ==================== Product Snapshots ====================

  Future<PageResponse<AdminProductSnapshot>> getProductSnapshots(
    String productId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Object?>(
      '/admin/products/$productId/snapshots',
      queryParameters: {'page': page, 'size': size, 'sort': 'createdAt,desc'},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, AdminProductSnapshot.fromJson),
    );
  }

  Future<AdminProductSnapshot> createProductSnapshot(
    String productId,
    String description,
  ) async {
    final response = await _dio.post<Object?>(
      '/admin/products/$productId/snapshots',
      data: {'description': description},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminProductSnapshot.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteProductSnapshot(
    String productId,
    String snapshotId,
  ) async {
    await _dio.delete<Object?>(
      '/admin/products/$productId/snapshots/$snapshotId',
    );
  }

  // ==================== Comments ====================

  Future<PageResponse<AdminComment>> getComments({
    String? status,
    String? keyword,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': 'createdAt,desc',
    };
    if (status != null) queryParams['status'] = status;
    if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;
    final response = await _dio.get<Object?>(
      '/admin/comments',
      queryParameters: queryParams,
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, AdminComment.fromJson),
    );
  }

  Future<void> approveComment(String id) async {
    await _dio.post<Object?>('/admin/comments/$id/approve');
  }

  Future<void> rejectComment(String id, {String? reason}) async {
    await _dio.post<Object?>('/admin/comments/$id/reject', data: reason);
  }

  Future<void> spamComment(String id) async {
    await _dio.post<Object?>('/admin/comments/$id/spam');
  }

  Future<void> deleteComment(String id) async {
    await _dio.delete<Object?>('/admin/comments/$id');
  }

  Future<void> replyToComment(
    String articleId,
    String content, {
    String? parentId,
  }) async {
    final body = <String, dynamic>{'content': content};
    if (parentId != null) body['parentId'] = parentId;
    await _dio.post<Object?>('/public/comments/article/$articleId', data: body);
  }

  // ==================== Article Snapshots ====================

  Future<PageResponse<AdminArticleSnapshot>> getArticleSnapshots(
    String articleId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Object?>(
      '/admin/articles/$articleId/snapshots',
      queryParameters: {'page': page, 'size': size, 'sort': 'createdAt,desc'},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, AdminArticleSnapshot.fromJson),
    );
  }

  Future<AdminArticleSnapshot> createArticleSnapshot(
    String articleId,
    String description,
  ) async {
    final response = await _dio.post<Object?>(
      '/admin/articles/$articleId/snapshots',
      data: {'description': description},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminArticleSnapshot.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteArticleSnapshot(
    String articleId,
    String snapshotId,
  ) async {
    await _dio.delete<Object?>(
      '/admin/articles/$articleId/snapshots/$snapshotId',
    );
  }

  // ==================== Users ====================

  Future<PageResponse<AdminUser>> getUsers({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Object?>(
      '/admin/users',
      queryParameters: {'page': page, 'size': size, 'sort': 'createdAt,desc'},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, AdminUser.fromJson),
    );
  }

  Future<PageResponse<AdminUser>> getPendingUsers({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Object?>(
      '/admin/users/pending',
      queryParameters: {'page': page, 'size': size},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, AdminUser.fromJson),
    );
  }

  Future<PageResponse<AdminUser>> searchUsers({
    required String keyword,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get<Object?>(
      '/admin/users/search',
      queryParameters: {'keyword': keyword, 'page': page, 'size': size},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, AdminUser.fromJson),
    );
  }

  Future<AdminUser> getUser(String id) async {
    final response = await _dio.get<Object?>('/admin/users/$id');
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminUser.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> approveUser(String id, {bool approved = true}) async {
    await _dio.post<Object?>(
      '/admin/users/$id/approve',
      data: {'approved': approved},
    );
  }

  Future<void> sendUserDeleteCode(String id) async {
    await _dio.post<Object?>('/admin/users/$id/send-delete-code');
  }

  Future<void> deleteUser(String id, String verificationCode) async {
    await _dio.delete<Object?>(
      '/admin/users/$id',
      data: {'verification_code': verificationCode},
    );
  }

  // ==================== Site Profile ====================

  Future<AdminSiteProfile> getSiteProfile() async {
    final response = await _dio.get<Object?>('/admin/site/profile');
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminSiteProfile.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> sendSiteUpdateCode() async {
    await _dio.post<Object?>('/admin/site/send-update-code');
  }

  Future<void> updateSiteProfile(Map<String, dynamic> body) async {
    await _dio.put<Object?>('/admin/site/profile', data: body);
  }

  // ==================== Backgrounds ====================

  Future<PageResponse<AdminBackground>> getBackgrounds({
    int page = 0,
    int size = 50,
  }) async {
    final response = await _dio.get<Object?>(
      '/admin/backgrounds',
      queryParameters: {'page': page, 'size': size},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, AdminBackground.fromJson),
    );
  }

  Future<List<AdminBackground>> getActiveBackgroundApis() async {
    final response = await _dio.get<Object?>('/admin/backgrounds/active-apis');
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(AdminBackground.fromJson)
            .toList(growable: false);
      }
      return const <AdminBackground>[];
    });
  }

  Future<String> refreshBackgroundImage({String? apiId}) async {
    final response = await _dio.post<Object?>(
      '/admin/backgrounds/refresh-image',
      queryParameters: apiId == null || apiId.isEmpty ? null : {'apiId': apiId},
    );
    return ApiResponse.unwrap(response.data, (data) => data?.toString() ?? '');
  }

  Future<void> createBackground(Map<String, dynamic> body) async {
    await _dio.post<Object?>('/admin/backgrounds', data: body);
  }

  Future<void> updateBackground(String id, Map<String, dynamic> body) async {
    await _dio.put<Object?>('/admin/backgrounds/$id', data: body);
  }

  Future<void> activateBackground(String id) async {
    await _dio.post<Object?>('/admin/backgrounds/$id/activate');
  }

  Future<void> deactivateBackground(String id) async {
    await _dio.post<Object?>('/admin/backgrounds/$id/deactivate');
  }

  Future<void> toggleBackground(String id) async {
    await _dio.post<Object?>('/admin/backgrounds/$id/toggle');
  }

  Future<void> deleteBackground(String id) async {
    await _dio.delete<Object?>('/admin/backgrounds/$id');
  }

  // ==================== Friend Links ====================

  Future<List<AdminFriendLink>> getFriendLinks() async {
    final response = await _dio.get<Object?>('/admin/friend-links');
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(AdminFriendLink.fromJson)
            .toList(growable: false);
      }
      return const <AdminFriendLink>[];
    });
  }

  Future<void> createFriendLink(Map<String, dynamic> body) async {
    await _dio.post<Object?>('/admin/friend-links', data: body);
  }

  Future<void> updateFriendLink(String id, Map<String, dynamic> body) async {
    await _dio.put<Object?>('/admin/friend-links/$id', data: body);
  }

  Future<void> approveFriendLink(String id) async {
    await _dio.post<Object?>('/admin/friend-links/$id/approve');
  }

  Future<void> rejectFriendLink(String id) async {
    await _dio.post<Object?>('/admin/friend-links/$id/reject');
  }

  Future<void> deleteFriendLink(String id) async {
    await _dio.delete<Object?>('/admin/friend-links/$id');
  }

  // ==================== Social Links ====================

  Future<List<AdminSocialLink>> getSocialLinks() async {
    final response = await _dio.get<Object?>('/admin/social-links');
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(AdminSocialLink.fromJson)
            .toList(growable: false);
      }
      return const <AdminSocialLink>[];
    });
  }

  Future<void> createSocialLink(Map<String, dynamic> body) async {
    await _dio.post<Object?>('/admin/social-links', data: body);
  }

  Future<void> updateSocialLink(String id, Map<String, dynamic> body) async {
    await _dio.put<Object?>('/admin/social-links/$id', data: body);
  }

  Future<void> deleteSocialLink(String id) async {
    await _dio.delete<Object?>('/admin/social-links/$id');
  }

  // ==================== Tags ====================

  Future<PageResponse<Map<String, dynamic>>> getTags({
    String? keyword,
    int page = 0,
    int size = 50,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'size': size};
    if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;
    final response = await _dio.get<Object?>(
      '/admin/tags',
      queryParameters: queryParams,
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, (json) => json),
    );
  }

  Future<void> createTag(Map<String, dynamic> body) async {
    await _dio.post<Object?>('/admin/tags', data: body);
  }

  Future<void> updateTag(String id, Map<String, dynamic> body) async {
    await _dio.put<Object?>('/admin/tags/$id', data: body);
  }

  Future<void> deleteTag(String id) async {
    await _dio.delete<Object?>('/admin/tags/$id');
  }

  // ==================== Product Categories ====================

  Future<List<Map<String, dynamic>>> getCategoryTree() async {
    final response = await _dio.get<Object?>('/admin/product-categories/tree');
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList(growable: false);
      }
      return const <Map<String, dynamic>>[];
    });
  }

  Future<void> createCategory(Map<String, dynamic> body) async {
    await _dio.post<Object?>('/admin/product-categories', data: body);
  }

  Future<void> updateCategory(String id, Map<String, dynamic> body) async {
    await _dio.put<Object?>('/admin/product-categories/$id', data: body);
  }

  Future<void> deleteCategory(String id) async {
    await _dio.delete<Object?>('/admin/product-categories/$id');
  }

  // ==================== Notifications ====================

  Future<List<Map<String, dynamic>>> getNotificationChannels() async {
    final response = await _dio.get<Object?>('/admin/notification/channels');
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList(growable: false);
      }
      return const <Map<String, dynamic>>[];
    });
  }

  Future<Map<String, dynamic>> getNotificationChannel(String type) async {
    final response = await _dio.get<Object?>(
      '/admin/notification/channels/$type',
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => data as Map<String, dynamic>,
    );
  }

  Future<void> updateNotificationChannel(
    String type,
    Map<String, dynamic> body,
  ) async {
    await _dio.put<Object?>('/admin/notification/channels/$type', data: body);
  }

  Future<Map<String, dynamic>> getDingtalkConfig() async {
    final response = await _dio.get<Object?>(
      '/admin/notification/dingtalk/config',
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => data as Map<String, dynamic>,
    );
  }

  Future<void> updateDingtalkConfig(Map<String, dynamic> body) async {
    await _dio.put<Object?>('/admin/notification/dingtalk/config', data: body);
  }

  Future<void> testDingtalk() async {
    await _dio.post<Object?>('/admin/notification/dingtalk/test');
  }

  Future<PageResponse<AdminNotificationLog>> getNotificationLogs({
    String? type,
    String? channel,
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': 'sentAt,desc',
    };
    if (type != null) queryParams['type'] = type;
    if (channel != null) queryParams['channel'] = channel;
    if (status != null) queryParams['status'] = status;
    final response = await _dio.get<Object?>(
      '/admin/notification/logs',
      queryParameters: queryParams,
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, AdminNotificationLog.fromJson),
    );
  }

  // ==================== Subscriptions ====================

  Future<PageResponse<AdminSubscription>> getSubscriptions({
    String? keyword,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'size': size};
    if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;
    final response = await _dio.get<Object?>(
      '/admin/subscriptions',
      queryParameters: queryParams,
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, AdminSubscription.fromJson),
    );
  }

  Future<void> updateSubscription(String id, Map<String, dynamic> body) async {
    await _dio.put<Object?>('/admin/subscriptions/$id', data: body);
  }

  Future<void> deleteSubscription(String id) async {
    await _dio.delete<Object?>('/admin/subscriptions/$id');
  }

  Future<Map<String, dynamic>> getSubscriptionStats() async {
    final response = await _dio.get<Object?>('/admin/subscriptions/stats');
    return ApiResponse.unwrap(
      response.data,
      (data) => data as Map<String, dynamic>,
    );
  }

  // ==================== Cache ====================

  Future<List<AdminCacheStats>> getCacheStats() async {
    final response = await _dio.get<Object?>('/admin/cache/stats');
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(AdminCacheStats.fromJson)
            .toList(growable: false);
      }
      return const <AdminCacheStats>[];
    });
  }

  Future<void> clearCache(String cacheName) async {
    await _dio.post<Object?>('/admin/cache/clear/$cacheName');
  }

  Future<void> clearAllCaches() async {
    await _dio.post<Object?>('/admin/cache/clear-all');
  }

  Future<void> warmupCache(String cacheName) async {
    await _dio.post<Object?>('/admin/cache/warmup/$cacheName');
  }

  Future<Map<String, dynamic>> getRedisInfo() async {
    final response = await _dio.get<Object?>('/admin/cache/redis-info');
    return ApiResponse.unwrap(
      response.data,
      (data) => data as Map<String, dynamic>,
    );
  }

  // ==================== Files ====================

  Future<List<AdminBucket>> getBuckets() async {
    final response = await _dio.get<Object?>('/admin/files/buckets');
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(AdminBucket.fromJson)
            .toList(growable: false);
      }
      return const <AdminBucket>[];
    });
  }

  Future<List<AdminFileItem>> getFiles(String bucketName) async {
    final response = await _dio.get<Object?>(
      '/admin/files/list',
      queryParameters: {'bucketName': bucketName},
    );
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(AdminFileItem.fromJson)
            .toList(growable: false);
      }
      return const <AdminFileItem>[];
    });
  }

  Future<void> deleteFile(String fileUrl) async {
    await _dio.delete<Object?>(
      '/admin/files/delete',
      queryParameters: {'fileUrl': fileUrl},
    );
  }

  Future<void> deleteFileDirect(String bucketName, String objectName) async {
    await _dio.delete<Object?>(
      '/admin/files/delete-direct',
      queryParameters: {'bucketName': bucketName, 'objectName': objectName},
    );
  }

  Future<void> deleteFilesBatch(List<String> fileUrls) async {
    await _dio.post<Object?>('/admin/files/delete-batch', data: fileUrls);
  }

  Future<String> getFileUrl(String bucketName, String objectName) async {
    final response = await _dio.get<Object?>(
      '/admin/files/url',
      queryParameters: {'bucketName': bucketName, 'objectName': objectName},
    );
    return ApiResponse.unwrap(response.data, (data) => data as String);
  }

  // ==================== Dashboard ====================

  Future<AdminDashboardOverview> getDashboardOverview() async {
    final response = await _dio.get<Object?>('/dashboard/overview');
    return ApiResponse.unwrap(
      response.data,
      (data) => AdminDashboardOverview.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<Map<String, dynamic>>> getDashboardTrends({int days = 30}) async {
    final response = await _dio.get<Object?>(
      '/dashboard/stats/trends',
      queryParameters: {'days': days},
    );
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList(growable: false);
      }
      return const <Map<String, dynamic>>[];
    });
  }

  // ==================== Custom Pages ====================

  Future<PageResponse<Map<String, dynamic>>> getCustomPages({
    String? keyword,
    int page = 0,
    int size = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'size': size,
      'sort': 'updatedAt',
      'direction': 'DESC',
    };
    if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;
    final response = await _dio.get<Object?>(
      '/admin/pages',
      queryParameters: queryParams,
    );
    return ApiResponse.unwrap(
      response.data,
      (data) => PageResponse.fromJson(data, (json) => json),
    );
  }

  Future<Map<String, dynamic>> getCustomPage(String id) async {
    final response = await _dio.get<Object?>('/admin/pages/$id');
    return ApiResponse.unwrap(
      response.data,
      (data) => data as Map<String, dynamic>,
    );
  }

  Future<void> createCustomPage(Map<String, dynamic> body) async {
    await _dio.post<Object?>('/admin/pages', data: body);
  }

  Future<void> updateCustomPage(String id, Map<String, dynamic> body) async {
    await _dio.put<Object?>('/admin/pages/$id', data: body);
  }

  Future<void> publishPage(String id) async {
    await _dio.post<Object?>('/admin/pages/$id/publish');
  }

  Future<void> unpublishPage(String id) async {
    await _dio.post<Object?>('/admin/pages/$id/unpublish');
  }

  Future<void> deleteCustomPage(String id) async {
    await _dio.delete<Object?>('/admin/pages/$id');
  }

  // ==================== Page Type Configs ====================

  Future<List<Map<String, dynamic>>> getPageTypeConfigs() async {
    final response = await _dio.get<Object?>('/admin/site/page-types');
    return ApiResponse.unwrap(response.data, (data) {
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList(growable: false);
      }
      return const <Map<String, dynamic>>[];
    });
  }

  Future<void> createPageTypeConfig(Map<String, dynamic> body) async {
    await _dio.post<Object?>('/admin/site/page-types', data: body);
  }

  Future<void> updatePageTypeConfig(
    String pageType,
    Map<String, dynamic> body,
  ) async {
    await _dio.put<Object?>('/admin/site/page-types/$pageType', data: body);
  }

  Future<void> deletePageTypeConfig(String pageType) async {
    await _dio.delete<Object?>('/admin/site/page-types/$pageType');
  }
}
