import 'package:ankiblog_mobile/data/models/common/json_helpers.dart';

class DailyOutfitSuggestion {
  const DailyOutfitSuggestion({
    required this.id,
    required this.suggestionDate,
    required this.status,
    required this.statusDisplayName,
    required this.isPublic,
    this.note,
    this.outfitLogId,
    this.items = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String suggestionDate;
  final String status;
  final String statusDisplayName;
  final bool isPublic;
  final String? note;
  final String? outfitLogId;
  final List<DailyOutfitItem> items;
  final String? createdAt;
  final String? updatedAt;

  bool get isPending => status == 'PENDING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isRejected => status == 'REJECTED';

  factory DailyOutfitSuggestion.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(DailyOutfitItem.fromJson)
              .toList(growable: false)
        : const <DailyOutfitItem>[];

    return DailyOutfitSuggestion(
      id: stringValue(json, 'id'),
      suggestionDate:
          nullableString(json, 'suggestion_date') ??
          nullableString(json, 'suggestionDate') ??
          '',
      status: stringValue(json, 'status', 'PENDING'),
      statusDisplayName:
          nullableString(json, 'status_display_name') ??
          nullableString(json, 'statusDisplayName') ??
          stringValue(json, 'status', 'PENDING'),
      isPublic: boolValue(json, 'is_public') || boolValue(json, 'isPublic'),
      note: nullableString(json, 'note'),
      outfitLogId:
          nullableString(json, 'outfit_log_id') ??
          nullableString(json, 'outfitLogId'),
      items: items,
      createdAt:
          nullableString(json, 'created_at') ??
          nullableString(json, 'createdAt'),
      updatedAt:
          nullableString(json, 'updated_at') ??
          nullableString(json, 'updatedAt'),
    );
  }
}

class DailyOutfitItem {
  const DailyOutfitItem({
    required this.productId,
    this.productSlug,
    this.productName,
    this.productMainImage,
    this.brand,
    this.categoryId,
    this.categoryName,
    this.accepted,
  });

  final String productId;
  final String? productSlug;
  final String? productName;
  final String? productMainImage;
  final String? brand;
  final String? categoryId;
  final String? categoryName;
  final bool? accepted;

  factory DailyOutfitItem.fromJson(Map<String, dynamic> json) {
    final rawAccepted = json['accepted'];
    return DailyOutfitItem(
      productId:
          nullableString(json, 'product_id') ??
          nullableString(json, 'productId') ??
          '',
      productSlug:
          nullableString(json, 'product_slug') ??
          nullableString(json, 'productSlug'),
      productName:
          nullableString(json, 'product_name') ??
          nullableString(json, 'productName'),
      productMainImage:
          nullableString(json, 'product_main_image') ??
          nullableString(json, 'productMainImage'),
      brand: nullableString(json, 'brand'),
      categoryId:
          nullableString(json, 'category_id') ??
          nullableString(json, 'categoryId'),
      categoryName:
          nullableString(json, 'category_name') ??
          nullableString(json, 'categoryName'),
      accepted: rawAccepted is bool ? rawAccepted : null,
    );
  }
}
