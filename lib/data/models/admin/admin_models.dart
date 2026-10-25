import 'package:ankiblog_mobile/data/models/common/json_helpers.dart';

// ==================== Outfit ====================

class AdminOutfit {
  const AdminOutfit({
    required this.id,
    this.outfitDate,
    this.note,
    this.outfitImage,
    this.items = const [],
    this.createdAt,
  });

  final String id;
  final String? outfitDate;
  final String? note;
  final String? outfitImage;
  final List<AdminOutfitItem> items;
  final String? createdAt;

  factory AdminOutfit.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(AdminOutfitItem.fromJson)
              .toList(growable: false)
        : <AdminOutfitItem>[];

    return AdminOutfit(
      id: stringValue(json, 'id'),
      outfitDate:
          nullableString(json, 'outfit_date') ??
          nullableString(json, 'outfitDate'),
      note: nullableString(json, 'note'),
      outfitImage:
          nullableString(json, 'outfit_image') ??
          nullableString(json, 'outfitImage'),
      items: items,
      createdAt:
          nullableString(json, 'created_at') ??
          nullableString(json, 'createdAt'),
    );
  }
}

class AdminOutfitItem {
  const AdminOutfitItem({
    required this.productId,
    this.productSlug,
    this.productName,
    this.productMainImage,
    this.brand,
    this.itemType,
  });

  final String productId;
  final String? productSlug;
  final String? productName;
  final String? productMainImage;
  final String? brand;
  final String? itemType;

  factory AdminOutfitItem.fromJson(Map<String, dynamic> json) {
    return AdminOutfitItem(
      productId: stringValue(
        json,
        'product_id',
        stringValue(json, 'productId'),
      ),
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
      itemType:
          nullableString(json, 'item_type') ?? nullableString(json, 'itemType'),
    );
  }
}

// ==================== Makeup ====================

class AdminMakeup {
  const AdminMakeup({
    required this.id,
    this.makeupDate,
    this.lookName,
    this.referenceUrl,
    this.makeupImage,
    this.note,
    this.items = const [],
    this.createdAt,
  });

  final String id;
  final String? makeupDate;
  final String? lookName;
  final String? referenceUrl;
  final String? makeupImage;
  final String? note;
  final List<AdminMakeupItem> items;
  final String? createdAt;

  factory AdminMakeup.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(AdminMakeupItem.fromJson)
              .toList(growable: false)
        : <AdminMakeupItem>[];

    return AdminMakeup(
      id: stringValue(json, 'id'),
      makeupDate:
          nullableString(json, 'makeup_date') ??
          nullableString(json, 'makeupDate'),
      lookName:
          nullableString(json, 'look_name') ?? nullableString(json, 'lookName'),
      referenceUrl:
          nullableString(json, 'reference_url') ??
          nullableString(json, 'referenceUrl'),
      makeupImage:
          nullableString(json, 'makeup_image') ??
          nullableString(json, 'makeupImage'),
      note: nullableString(json, 'note'),
      items: items,
      createdAt:
          nullableString(json, 'created_at') ??
          nullableString(json, 'createdAt'),
    );
  }
}

class AdminMakeupItem {
  const AdminMakeupItem({
    required this.productId,
    this.productSlug,
    this.productName,
    this.productMainImage,
    this.brand,
    this.usageTypeId,
    this.usageTypeName,
  });

  final String productId;
  final String? productSlug;
  final String? productName;
  final String? productMainImage;
  final String? brand;
  final String? usageTypeId;
  final String? usageTypeName;

  factory AdminMakeupItem.fromJson(Map<String, dynamic> json) {
    return AdminMakeupItem(
      productId: stringValue(
        json,
        'product_id',
        stringValue(json, 'productId'),
      ),
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
      usageTypeId:
          nullableString(json, 'usage_type_id') ??
          nullableString(json, 'usageTypeId'),
      usageTypeName:
          nullableString(json, 'usage_type_name') ??
          nullableString(json, 'usageTypeName'),
    );
  }
}

// ==================== Todo ====================

class AdminTodoList {
  const AdminTodoList({
    required this.id,
    required this.name,
    this.icon,
    this.sortOrder = 0,
    this.itemCount = 0,
  });

  final String id;
  final String name;
  final String? icon;
  final int sortOrder;
  final int itemCount;

  factory AdminTodoList.fromJson(Map<String, dynamic> json) {
    return AdminTodoList(
      id: stringValue(json, 'id'),
      name: stringValue(json, 'name'),
      icon: nullableString(json, 'icon'),
      sortOrder: intOr(json, 'sort_order', 'sortOrder'),
      itemCount: intOr(json, 'item_count', 'itemCount'),
    );
  }
}

class AdminTodoItem {
  const AdminTodoItem({
    required this.id,
    required this.title,
    this.note,
    this.listId,
    this.listName,
    this.completed = false,
    this.important = false,
    this.myDay = false,
    this.dueDate,
    this.priority,
    this.steps = const [],
    this.createdAt,
  });

  final String id;
  final String title;
  final String? note;
  final String? listId;
  final String? listName;
  final bool completed;
  final bool important;
  final bool myDay;
  final String? dueDate;
  final String? priority;
  final List<AdminTodoStep> steps;
  final String? createdAt;

  factory AdminTodoItem.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['steps'];
    final steps = rawSteps is List
        ? rawSteps
              .whereType<Map<String, dynamic>>()
              .map(AdminTodoStep.fromJson)
              .toList(growable: false)
        : <AdminTodoStep>[];

    return AdminTodoItem(
      id: stringValue(json, 'id'),
      title: stringValue(json, 'title'),
      note: nullableString(json, 'note'),
      listId: nullableString(json, 'list_id') ?? nullableString(json, 'listId'),
      listName:
          nullableString(json, 'list_name') ?? nullableString(json, 'listName'),
      completed:
          boolValue(json, 'completed') || boolValue(json, 'is_completed'),
      important:
          boolValue(json, 'important') || boolValue(json, 'is_important'),
      myDay:
          boolValue(json, 'my_day') ||
          boolValue(json, 'myDay') ||
          boolValue(json, 'is_my_day'),
      dueDate:
          nullableString(json, 'due_date') ?? nullableString(json, 'dueDate'),
      priority: nullableString(json, 'priority'),
      steps: steps,
      createdAt:
          nullableString(json, 'created_at') ??
          nullableString(json, 'createdAt'),
    );
  }
}

class AdminTodoStep {
  const AdminTodoStep({
    required this.id,
    required this.title,
    this.completed = false,
    this.sortOrder = 0,
  });

  final String id;
  final String title;
  final bool completed;
  final int sortOrder;

  factory AdminTodoStep.fromJson(Map<String, dynamic> json) {
    return AdminTodoStep(
      id: stringValue(json, 'id'),
      title: stringValue(json, 'title'),
      completed:
          boolValue(json, 'completed') || boolValue(json, 'is_completed'),
      sortOrder: intOr(json, 'sort_order', 'sortOrder'),
    );
  }
}

// ==================== Goals ====================

class AdminGoal {
  const AdminGoal({
    required this.id,
    required this.name,
    this.description,
    this.status,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCheckIns = 0,
    this.thisMonthCheckIns = 0,
    this.milestones = const [],
    this.createdAt,
  });

  final String id;
  final String name;
  final String? description;
  final String? status;
  final int currentStreak;
  final int longestStreak;
  final int totalCheckIns;
  final int thisMonthCheckIns;
  final List<AdminMilestone> milestones;
  final String? createdAt;

  factory AdminGoal.fromJson(Map<String, dynamic> json) {
    final rawMilestones = json['milestones'];
    final milestones = rawMilestones is List
        ? rawMilestones
              .whereType<Map<String, dynamic>>()
              .map(AdminMilestone.fromJson)
              .toList(growable: false)
        : <AdminMilestone>[];

    return AdminGoal(
      id: stringValue(json, 'id'),
      name: stringValue(json, 'name'),
      description: nullableString(json, 'description'),
      status: nullableString(json, 'status'),
      currentStreak: intOr(json, 'current_streak', 'currentStreak'),
      longestStreak: intOr(json, 'longest_streak', 'longestStreak'),
      totalCheckIns: intOr(json, 'total_check_ins', 'totalCheckIns'),
      thisMonthCheckIns: intOr(
        json,
        'this_month_check_ins',
        'thisMonthCheckIns',
      ),
      milestones: milestones,
      createdAt:
          nullableString(json, 'created_at') ??
          nullableString(json, 'createdAt'),
    );
  }
}

class AdminMilestone {
  const AdminMilestone({
    required this.id,
    required this.name,
    this.description,
    this.targetValue = 0,
    this.currentValue = 0,
    this.unlocked = false,
    this.unlockedAt,
  });

  final String id;
  final String name;
  final String? description;
  final int targetValue;
  final int currentValue;
  final bool unlocked;
  final String? unlockedAt;

  factory AdminMilestone.fromJson(Map<String, dynamic> json) {
    return AdminMilestone(
      id: stringValue(json, 'id'),
      name: stringValue(json, 'name'),
      description: nullableString(json, 'description'),
      targetValue: intOr(json, 'target_value', 'targetValue'),
      currentValue: intOr(json, 'current_value', 'currentValue'),
      unlocked: boolValue(json, 'unlocked') || boolValue(json, 'is_unlocked'),
      unlockedAt:
          nullableString(json, 'unlocked_at') ??
          nullableString(json, 'unlockedAt'),
    );
  }
}

// ==================== Calendar ====================

class AdminCalendarData {
  const AdminCalendarData({
    required this.year,
    required this.month,
    this.dailyOutfits = const {},
    this.totalInMonth = 0,
  });

  final int year;
  final int month;
  final Map<int, List<AdminOutfit>> dailyOutfits;
  final int totalInMonth;

  factory AdminCalendarData.fromJson(Map<String, dynamic> json) {
    final rawDaily = json['daily_outfits'] ?? json['dailyOutfits'];
    final Map<int, List<AdminOutfit>> dailyOutfits = {};

    if (rawDaily is Map) {
      for (final entry in rawDaily.entries) {
        final day = int.tryParse(entry.key.toString()) ?? 0;
        if (entry.value is List) {
          dailyOutfits[day] = (entry.value as List)
              .whereType<Map<String, dynamic>>()
              .map(AdminOutfit.fromJson)
              .toList(growable: false);
        }
      }
    }

    return AdminCalendarData(
      year: intValue(json, 'year'),
      month: intValue(json, 'month'),
      dailyOutfits: dailyOutfits,
      totalInMonth: intOr(json, 'total_outfits_in_month', 'totalInMonth'),
    );
  }
}

// ==================== Phase 4 Models ====================

class AdminArticle {
  const AdminArticle({
    required this.id,
    required this.title,
    this.slug,
    this.excerpt,
    this.content,
    this.coverImage,
    this.status = 'DRAFT',
    this.visibility = 'PUBLIC',
    this.featured = false,
    this.pinned = false,
    this.commentsEnabled = true,
    this.authorName,
    this.authorAvatar,
    this.tags = const [],
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.readingTime = 0,
    this.publishedAt,
    this.createdAt,
    this.seoTitle,
    this.seoDescription,
    this.seoKeywords,
  });

  final String id;
  final String title;
  final String? slug;
  final String? excerpt;
  final String? content;
  final String? coverImage;
  final String status;
  final String visibility;
  final bool featured;
  final bool pinned;
  final bool commentsEnabled;
  final String? authorName;
  final String? authorAvatar;
  final List<String> tags;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int readingTime;
  final String? publishedAt;
  final String? createdAt;
  final String? seoTitle;
  final String? seoDescription;
  final String? seoKeywords;

  factory AdminArticle.fromJson(Map<String, dynamic> json) {
    return AdminArticle(
      id: stringValue(json, 'id'),
      title: stringValue(json, 'title'),
      slug: nullableString(json, 'slug'),
      excerpt: nullableString(json, 'excerpt'),
      content: nullableString(json, 'content'),
      coverImage:
          nullableString(json, 'cover_image') ??
          nullableString(json, 'coverImage'),
      status: stringValue(json, 'status', 'DRAFT'),
      visibility: stringValue(json, 'visibility', 'PUBLIC'),
      featured: boolValue(json, 'featured'),
      pinned: boolValue(json, 'pinned'),
      commentsEnabled:
          json['commentsEnabled'] ?? json['comments_enabled'] ?? true,
      authorName:
          nullableString(json, 'authorName') ??
          nullableString(json, 'author_name'),
      authorAvatar:
          nullableString(json, 'authorAvatar') ??
          nullableString(json, 'author_avatar'),
      tags: tagList(json, 'tags'),
      viewCount: intOr(json, 'view_count', 'viewCount'),
      likeCount: intOr(json, 'like_count', 'likeCount'),
      commentCount: intOr(json, 'comment_count', 'commentCount'),
      shareCount: intOr(json, 'share_count', 'shareCount'),
      readingTime: intOr(json, 'reading_time', 'readingTime'),
      publishedAt:
          nullableString(json, 'published_at') ??
          nullableString(json, 'publishedAt'),
      createdAt:
          nullableString(json, 'created_at') ??
          nullableString(json, 'createdAt'),
      seoTitle:
          nullableString(json, 'seoTitle') ?? nullableString(json, 'seo_title'),
      seoDescription:
          nullableString(json, 'seoDescription') ??
          nullableString(json, 'seo_description'),
      seoKeywords:
          nullableString(json, 'seoKeywords') ??
          nullableString(json, 'seo_keywords'),
    );
  }
}

class AdminProduct {
  const AdminProduct({
    required this.id,
    required this.name,
    this.slug,
    this.summary,
    this.description,
    this.mainImage,
    this.brand,
    this.price,
    this.originalPrice,
    this.currency,
    this.status = 'DRAFT',
    this.categoryId,
    this.categoryName,
    this.tags = const [],
    this.isPurchased = false,
    this.featured = false,
    this.viewCount = 0,
    this.clickCount = 0,
    this.favoriteCount = 0,
    this.wearCount = 0,
    this.purchaseUrl,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? slug;
  final String? summary;
  final String? description;
  final String? mainImage;
  final String? brand;
  final double? price;
  final double? originalPrice;
  final String? currency;
  final String status;
  final String? categoryId;
  final String? categoryName;
  final List<String> tags;
  final bool isPurchased;
  final bool featured;
  final int viewCount;
  final int clickCount;
  final int favoriteCount;
  final int wearCount;
  final String? purchaseUrl;
  final String? createdAt;

  factory AdminProduct.fromJson(Map<String, dynamic> json) {
    final cat = json['category'];
    String? catId;
    String? catName;
    if (cat is Map) {
      catId = cat['id']?.toString();
      catName = cat['name']?.toString();
    }
    catName ??=
        nullableString(json, 'category_name') ??
        nullableString(json, 'categoryName');

    return AdminProduct(
      id: stringValue(json, 'id'),
      name: stringValue(json, 'name'),
      slug: nullableString(json, 'slug'),
      summary: nullableString(json, 'summary'),
      description: nullableString(json, 'description'),
      mainImage:
          nullableString(json, 'main_image') ??
          nullableString(json, 'mainImage'),
      brand: nullableString(json, 'brand'),
      price: json['price'] != null ? doubleValue(json, 'price') : null,
      originalPrice: json['originalPrice'] != null
          ? doubleValue(json, 'originalPrice')
          : json['original_price'] != null
          ? doubleValue(json, 'original_price')
          : null,
      currency: nullableString(json, 'currency'),
      status: stringValue(json, 'status', 'DRAFT'),
      categoryId: catId,
      categoryName: catName,
      tags: tagList(json, 'tags'),
      isPurchased:
          boolValue(json, 'is_purchased') || boolValue(json, 'isPurchased'),
      featured: boolValue(json, 'featured'),
      viewCount: intOr(json, 'view_count', 'viewCount'),
      clickCount: intOr(json, 'click_count', 'clickCount'),
      favoriteCount: intOr(json, 'favorite_count', 'favoriteCount'),
      wearCount: intOr(json, 'wear_count', 'wearCount'),
      purchaseUrl:
          nullableString(json, 'purchaseUrl') ??
          nullableString(json, 'purchase_url'),
      createdAt:
          nullableString(json, 'created_at') ??
          nullableString(json, 'createdAt'),
    );
  }
}

class AdminComment {
  const AdminComment({
    required this.id,
    required this.content,
    this.authorId,
    this.authorName,
    this.authorAvatar,
    this.articleId,
    this.articleTitle,
    this.articleSlug,
    this.status = 'PENDING',
    this.ipAddress,
    this.likeCount = 0,
    this.replyCount = 0,
    this.createdAt,
  });

  final String id;
  final String content;
  final String? authorId;
  final String? authorName;
  final String? authorAvatar;
  final String? articleId;
  final String? articleTitle;
  final String? articleSlug;
  final String status;
  final String? ipAddress;
  final int likeCount;
  final int replyCount;
  final String? createdAt;

  factory AdminComment.fromJson(Map<String, dynamic> json) {
    return AdminComment(
      id: stringValue(json, 'id'),
      content: stringValue(json, 'content'),
      authorId:
          nullableString(json, 'authorId') ?? nullableString(json, 'author_id'),
      authorName:
          nullableString(json, 'author_name') ??
          nullableString(json, 'authorName'),
      authorAvatar:
          nullableString(json, 'authorAvatar') ??
          nullableString(json, 'author_avatar'),
      articleId:
          nullableString(json, 'articleId') ??
          nullableString(json, 'article_id'),
      articleTitle:
          nullableString(json, 'article_title') ??
          nullableString(json, 'articleTitle'),
      articleSlug:
          nullableString(json, 'articleSlug') ??
          nullableString(json, 'article_slug'),
      status: stringValue(json, 'status', 'PENDING'),
      ipAddress:
          nullableString(json, 'ipAddress') ??
          nullableString(json, 'ip_address'),
      likeCount: intOr(json, 'like_count', 'likeCount'),
      replyCount: intOr(json, 'reply_count', 'replyCount'),
      createdAt:
          nullableString(json, 'created_at') ??
          nullableString(json, 'createdAt'),
    );
  }
}

class AdminUser {
  const AdminUser({
    required this.id,
    required this.username,
    this.email,
    this.displayName,
    this.avatarUrl,
    this.role = 'USER',
    this.status = 'PENDING',
    this.emailVerified = false,
    this.lastLoginAt,
    this.createdAt,
  });

  final String id;
  final String username;
  final String? email;
  final String? displayName;
  final String? avatarUrl;
  final String role;
  final String status;
  final bool emailVerified;
  final String? lastLoginAt;
  final String? createdAt;

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: stringValue(json, 'id'),
      username: stringValue(json, 'username'),
      email: nullableString(json, 'email'),
      displayName:
          nullableString(json, 'display_name') ??
          nullableString(json, 'displayName'),
      avatarUrl:
          nullableString(json, 'avatar_url') ??
          nullableString(json, 'avatarUrl'),
      role: stringValue(json, 'role', 'USER'),
      status: stringValue(json, 'status', 'PENDING'),
      emailVerified:
          boolValue(json, 'email_verified') || boolValue(json, 'emailVerified'),
      lastLoginAt:
          nullableString(json, 'last_login_at') ??
          nullableString(json, 'lastLoginAt'),
      createdAt:
          nullableString(json, 'created_at') ??
          nullableString(json, 'createdAt'),
    );
  }
}

class AdminSiteProfile {
  const AdminSiteProfile({
    this.siteName,
    this.siteTagline,
    this.siteDescription,
    this.siteUrl,
    this.domain,
    this.siteKeywords,
    this.siteLanguage,
    this.timezone,
    this.logoUrl,
    this.faviconUrl,
    this.defaultShareImage,
    this.themeColor,
    this.heroTitle,
    this.heroSubtitle,
    this.ownerName,
    this.ownerAvatar,
    this.ownerBio,
    this.ownerProfession,
    this.ownerCompany,
    this.ownerLocation,
    this.contactEmail,
    this.commentsEnabled = true,
    this.commentModeration = false,
    this.allowGuestComments = false,
    this.excerptLength,
    this.homepagePostCount,
    this.enableSubscriptionService = false,
    this.enableUserSubscriptions = false,
    this.enableGuestSubscriptions = false,
  });

  final String? siteName;
  final String? siteTagline;
  final String? siteDescription;
  final String? siteUrl;
  final String? domain;
  final String? siteKeywords;
  final String? siteLanguage;
  final String? timezone;
  final String? logoUrl;
  final String? faviconUrl;
  final String? defaultShareImage;
  final String? themeColor;
  final String? heroTitle;
  final String? heroSubtitle;
  final String? ownerName;
  final String? ownerAvatar;
  final String? ownerBio;
  final String? ownerProfession;
  final String? ownerCompany;
  final String? ownerLocation;
  final String? contactEmail;
  final bool commentsEnabled;
  final bool commentModeration;
  final bool allowGuestComments;
  final int? excerptLength;
  final int? homepagePostCount;
  final bool enableSubscriptionService;
  final bool enableUserSubscriptions;
  final bool enableGuestSubscriptions;

  factory AdminSiteProfile.fromJson(Map<String, dynamic> json) {
    return AdminSiteProfile(
      siteName:
          nullableString(json, 'siteName') ?? nullableString(json, 'site_name'),
      siteTagline:
          nullableString(json, 'siteTagline') ??
          nullableString(json, 'site_tagline'),
      siteDescription:
          nullableString(json, 'siteDescription') ??
          nullableString(json, 'site_description'),
      siteUrl:
          nullableString(json, 'siteUrl') ?? nullableString(json, 'site_url'),
      domain: nullableString(json, 'domain'),
      siteKeywords:
          nullableString(json, 'siteKeywords') ??
          nullableString(json, 'site_keywords'),
      siteLanguage:
          nullableString(json, 'siteLanguage') ??
          nullableString(json, 'site_language'),
      timezone: nullableString(json, 'timezone'),
      logoUrl:
          nullableString(json, 'logoUrl') ?? nullableString(json, 'logo_url'),
      faviconUrl:
          nullableString(json, 'faviconUrl') ??
          nullableString(json, 'favicon_url'),
      defaultShareImage:
          nullableString(json, 'defaultShareImage') ??
          nullableString(json, 'default_share_image'),
      themeColor:
          nullableString(json, 'themeColor') ??
          nullableString(json, 'theme_color'),
      heroTitle:
          nullableString(json, 'heroTitle') ??
          nullableString(json, 'hero_title'),
      heroSubtitle:
          nullableString(json, 'heroSubtitle') ??
          nullableString(json, 'hero_subtitle'),
      ownerName:
          nullableString(json, 'ownerName') ??
          nullableString(json, 'owner_name'),
      ownerAvatar:
          nullableString(json, 'ownerAvatar') ??
          nullableString(json, 'owner_avatar'),
      ownerBio:
          nullableString(json, 'ownerBio') ?? nullableString(json, 'owner_bio'),
      ownerProfession:
          nullableString(json, 'ownerProfession') ??
          nullableString(json, 'owner_profession'),
      ownerCompany:
          nullableString(json, 'ownerCompany') ??
          nullableString(json, 'owner_company'),
      ownerLocation:
          nullableString(json, 'ownerLocation') ??
          nullableString(json, 'owner_location'),
      contactEmail:
          nullableString(json, 'contactEmail') ??
          nullableString(json, 'contact_email'),
      commentsEnabled:
          boolValue(json, 'commentsEnabled') ||
          boolValue(json, 'comments_enabled'),
      commentModeration:
          boolValue(json, 'commentModeration') ||
          boolValue(json, 'comment_moderation'),
      allowGuestComments:
          boolValue(json, 'allowGuestComments') ||
          boolValue(json, 'allow_guest_comments'),
      excerptLength:
          json['excerptLength'] != null || json['excerpt_length'] != null
          ? intOr(json, 'excerpt_length', 'excerptLength')
          : null,
      homepagePostCount:
          json['homepagePostCount'] != null ||
              json['homepage_post_count'] != null
          ? intOr(json, 'homepage_post_count', 'homepagePostCount')
          : null,
      enableSubscriptionService:
          boolValue(json, 'enableSubscriptionService') ||
          boolValue(json, 'enable_subscription_service'),
      enableUserSubscriptions:
          boolValue(json, 'enableUserSubscriptions') ||
          boolValue(json, 'enable_user_subscriptions'),
      enableGuestSubscriptions:
          boolValue(json, 'enableGuestSubscriptions') ||
          boolValue(json, 'enable_guest_subscriptions'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'siteName': siteName,
      'siteTagline': siteTagline,
      'siteDescription': siteDescription,
      'siteUrl': siteUrl,
      'domain': domain,
      'siteKeywords': siteKeywords,
      'siteLanguage': siteLanguage,
      'timezone': timezone,
      'logoUrl': logoUrl,
      'faviconUrl': faviconUrl,
      'defaultShareImage': defaultShareImage,
      'themeColor': themeColor,
      'heroTitle': heroTitle,
      'heroSubtitle': heroSubtitle,
      'ownerName': ownerName,
      'ownerAvatar': ownerAvatar,
      'ownerBio': ownerBio,
      'ownerProfession': ownerProfession,
      'ownerCompany': ownerCompany,
      'ownerLocation': ownerLocation,
      'contactEmail': contactEmail,
      'commentsEnabled': commentsEnabled,
      'commentModeration': commentModeration,
      'allowGuestComments': allowGuestComments,
      'excerptLength': excerptLength,
      'homepagePostCount': homepagePostCount,
      'enableSubscriptionService': enableSubscriptionService,
      'enableUserSubscriptions': enableUserSubscriptions,
      'enableGuestSubscriptions': enableGuestSubscriptions,
    };
  }
}

class AdminBackground {
  const AdminBackground({
    required this.id,
    this.name,
    this.type,
    this.value,
    this.active = false,
    this.createdAt,
  });

  final String id;
  final String? name;
  final String? type;
  final String? value;
  final bool active;
  final String? createdAt;

  factory AdminBackground.fromJson(Map<String, dynamic> json) {
    return AdminBackground(
      id: stringValue(json, 'id'),
      name: nullableString(json, 'name'),
      type: nullableString(json, 'type'),
      value: nullableString(json, 'value'),
      active: boolValue(json, 'active'),
      createdAt:
          nullableString(json, 'created_at') ??
          nullableString(json, 'createdAt'),
    );
  }
}

class AdminFriendLink {
  const AdminFriendLink({
    required this.id,
    required this.name,
    this.url,
    this.logo,
    this.avatarUrl,
    this.description,
    this.ownerName,
    this.ownerEmail,
    this.sortOrder = 0,
    this.category,
    this.reciprocal = false,
    this.adminNote,
    this.status = 'PENDING',
    this.clickCount = 0,
  });

  final String id;
  final String name;
  final String? url;
  final String? logo;
  final String? avatarUrl;
  final String? description;
  final String? ownerName;
  final String? ownerEmail;
  final int sortOrder;
  final String? category;
  final bool reciprocal;
  final String? adminNote;
  final String status;
  final int clickCount;

  factory AdminFriendLink.fromJson(Map<String, dynamic> json) {
    return AdminFriendLink(
      id: stringValue(json, 'id'),
      name:
          nullableString(json, 'siteName') ??
          nullableString(json, 'name') ??
          '',
      url: nullableString(json, 'siteUrl') ?? nullableString(json, 'url'),
      logo: nullableString(json, 'logo'),
      avatarUrl:
          nullableString(json, 'avatarUrl') ??
          nullableString(json, 'avatar_url'),
      description: nullableString(json, 'description'),
      ownerName:
          nullableString(json, 'ownerName') ??
          nullableString(json, 'owner_name'),
      ownerEmail:
          nullableString(json, 'ownerEmail') ??
          nullableString(json, 'owner_email'),
      sortOrder: intOr(json, 'sort_order', 'sortOrder'),
      category: nullableString(json, 'category'),
      reciprocal: boolValue(json, 'reciprocal'),
      adminNote:
          nullableString(json, 'adminNote') ??
          nullableString(json, 'admin_note'),
      status: stringValue(json, 'status', 'PENDING'),
      clickCount: intOr(json, 'click_count', 'clickCount'),
    );
  }
}

class AdminSocialLink {
  const AdminSocialLink({
    required this.id,
    required this.name,
    this.url,
    this.icon,
    this.platform,
    this.platformName,
    this.description,
    this.color,
    this.active = true,
    this.openInNewTab = true,
    this.featured = false,
    this.sortOrder = 0,
    this.groupName,
  });

  final String id;
  final String name;
  final String? url;
  final String? icon;
  final String? platform;
  final String? platformName;
  final String? description;
  final String? color;
  final bool active;
  final bool openInNewTab;
  final bool featured;
  final int sortOrder;
  final String? groupName;

  factory AdminSocialLink.fromJson(Map<String, dynamic> json) {
    return AdminSocialLink(
      id: stringValue(json, 'id'),
      name:
          nullableString(json, 'title') ??
          nullableString(json, 'platformName') ??
          stringValue(json, 'platform'),
      url: nullableString(json, 'url'),
      icon: nullableString(json, 'icon'),
      platform: nullableString(json, 'platform'),
      platformName: nullableString(json, 'platformName'),
      description: nullableString(json, 'description'),
      color: nullableString(json, 'color'),
      active: boolValue(json, 'active'),
      openInNewTab: boolValue(json, 'openInNewTab'),
      featured: boolValue(json, 'featured'),
      sortOrder: intOr(json, 'sortOrder', 'sort_order'),
      groupName: nullableString(json, 'groupName'),
    );
  }
}

class AdminNotificationLog {
  const AdminNotificationLog({
    required this.id,
    this.type,
    this.typeDescription,
    this.channel,
    this.status,
    this.title,
    this.contentSummary,
    this.errorMessage,
    this.sentAt,
    this.createdAt,
  });

  final String id;
  final String? type;
  final String? typeDescription;
  final String? channel;
  final String? status;
  final String? title;
  final String? contentSummary;
  final String? errorMessage;
  final String? sentAt;
  final String? createdAt;

  factory AdminNotificationLog.fromJson(Map<String, dynamic> json) {
    return AdminNotificationLog(
      id: stringValue(json, 'id'),
      type:
          nullableString(json, 'notificationType') ??
          nullableString(json, 'type'),
      typeDescription:
          nullableString(json, 'typeDescription') ??
          nullableString(json, 'type_description'),
      channel: nullableString(json, 'channel'),
      status: nullableString(json, 'status'),
      title: nullableString(json, 'title'),
      contentSummary:
          nullableString(json, 'contentSummary') ??
          nullableString(json, 'content_summary'),
      errorMessage:
          nullableString(json, 'errorMessage') ??
          nullableString(json, 'error_message'),
      sentAt: nullableString(json, 'sent_at') ?? nullableString(json, 'sentAt'),
      createdAt:
          nullableString(json, 'created_at') ??
          nullableString(json, 'createdAt'),
    );
  }
}

class AdminSubscription {
  const AdminSubscription({
    required this.id,
    this.email,
    this.userId,
    this.subscriptionType,
    this.subscriptionTypeDescription,
    this.status,
    this.statusDescription,
    this.subscriberName,
    this.preferences,
    this.verifiedAt,
    this.lastNotificationAt,
    this.notificationCount = 0,
    this.source,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? email;
  final String? userId;
  final String? subscriptionType;
  final String? subscriptionTypeDescription;
  final String? status;
  final String? statusDescription;
  final String? subscriberName;
  final String? preferences;
  final String? verifiedAt;
  final String? lastNotificationAt;
  final int notificationCount;
  final String? source;
  final String? createdAt;
  final String? updatedAt;

  factory AdminSubscription.fromJson(Map<String, dynamic> json) {
    return AdminSubscription(
      id: stringValue(json, 'id'),
      email: nullableString(json, 'email'),
      userId: nullableString(json, 'userId') ?? nullableString(json, 'user_id'),
      subscriptionType:
          nullableString(json, 'subscriptionType') ??
          nullableString(json, 'subscription_type'),
      subscriptionTypeDescription:
          nullableString(json, 'subscriptionTypeDescription') ??
          nullableString(json, 'subscription_type_description'),
      status: nullableString(json, 'status'),
      statusDescription:
          nullableString(json, 'statusDescription') ??
          nullableString(json, 'status_description'),
      subscriberName:
          nullableString(json, 'subscriberName') ??
          nullableString(json, 'subscriber_name'),
      preferences: nullableString(json, 'preferences'),
      verifiedAt:
          nullableString(json, 'verifiedAt') ??
          nullableString(json, 'verified_at'),
      lastNotificationAt:
          nullableString(json, 'lastNotificationAt') ??
          nullableString(json, 'last_notification_at'),
      notificationCount: intOr(json, 'notificationCount', 'notification_count'),
      source: nullableString(json, 'source'),
      createdAt:
          nullableString(json, 'createdAt') ??
          nullableString(json, 'created_at'),
      updatedAt:
          nullableString(json, 'updatedAt') ??
          nullableString(json, 'updated_at'),
    );
  }
}

class AdminCacheStats {
  const AdminCacheStats({
    this.name,
    this.hitCount = 0,
    this.missCount = 0,
    this.size = 0,
  });

  final String? name;
  final int hitCount;
  final int missCount;
  final int size;

  factory AdminCacheStats.fromJson(Map<String, dynamic> json) {
    return AdminCacheStats(
      name: nullableString(json, 'name') ?? nullableString(json, 'cacheName'),
      hitCount: intOr(json, 'hit_count', 'hitCount'),
      missCount: intOr(json, 'miss_count', 'missCount'),
      size: intValue(json, 'size'),
    );
  }

  double get hitRate =>
      (hitCount + missCount) == 0 ? 0 : hitCount / (hitCount + missCount);
}

class AdminBucket {
  const AdminBucket({required this.name, this.creationDate});

  final String name;
  final String? creationDate;

  factory AdminBucket.fromJson(Map<String, dynamic> json) {
    return AdminBucket(
      name:
          nullableString(json, 'name') ??
          nullableString(json, 'bucketName') ??
          '',
      creationDate:
          nullableString(json, 'creationDate') ??
          nullableString(json, 'creation_date'),
    );
  }
}

class AdminFileItem {
  const AdminFileItem({
    required this.objectName,
    this.size = 0,
    this.lastModified,
    this.etag,
    this.isDir = false,
  });

  final String objectName;
  final int size;
  final String? lastModified;
  final String? etag;
  final bool isDir;

  factory AdminFileItem.fromJson(Map<String, dynamic> json) {
    return AdminFileItem(
      objectName:
          nullableString(json, 'objectName') ??
          nullableString(json, 'object_name') ??
          '',
      size: intValue(json, 'size'),
      lastModified:
          nullableString(json, 'lastModified') ??
          nullableString(json, 'last_modified'),
      etag: nullableString(json, 'etag'),
      isDir: boolValue(json, 'isDir') || boolValue(json, 'is_dir'),
    );
  }
}

class AdminDashboardOverview {
  const AdminDashboardOverview({
    this.articleCount = 0,
    this.productCount = 0,
    this.userCount = 0,
    this.commentCount = 0,
    this.todayViews = 0,
    this.totalViews = 0,
    this.activeUsers = 0,
    this.pendingComments = 0,
    this.recentArticles = const [],
    this.recentComments = const [],
    this.recentUsers = const [],
  });

  final int articleCount;
  final int productCount;
  final int userCount;
  final int commentCount;
  final int todayViews;
  final int totalViews;
  final int activeUsers;
  final int pendingComments;
  final List<AdminArticle> recentArticles;
  final List<AdminComment> recentComments;
  final List<AdminUser> recentUsers;

  factory AdminDashboardOverview.fromJson(Map<String, dynamic> json) {
    return AdminDashboardOverview(
      articleCount: json['totalArticles'] ?? json['total_articles'] ?? 0,
      productCount: json['totalProducts'] ?? json['total_products'] ?? 0,
      userCount: json['totalUsers'] ?? json['total_users'] ?? 0,
      commentCount: json['totalComments'] ?? json['total_comments'] ?? 0,
      todayViews: json['todayViews'] ?? json['today_views'] ?? 0,
      totalViews: json['totalViews'] ?? json['total_views'] ?? 0,
      activeUsers: json['activeUsers'] ?? json['active_users'] ?? 0,
      pendingComments: json['pendingComments'] ?? json['pending_comments'] ?? 0,
      recentArticles: _parseList(
        json,
        'recent_articles',
        'recentArticles',
        AdminArticle.fromJson,
      ),
      recentComments: _parseList(
        json,
        'recent_comments',
        'recentComments',
        AdminComment.fromJson,
      ),
      recentUsers: _parseList(
        json,
        'recent_users',
        'recentUsers',
        AdminUser.fromJson,
      ),
    );
  }
}

// ==================== Article Snapshot ====================

class AdminArticleSnapshot {
  const AdminArticleSnapshot({
    required this.id,
    this.articleId,
    this.title,
    this.slug,
    this.excerpt,
    this.content,
    this.coverImage,
    this.status,
    this.visibility,
    this.featured = false,
    this.pinned = false,
    this.commentsEnabled = true,
    this.tags,
    this.snapshotType,
    this.versionNumber = 0,
    this.description,
    this.createdById,
    this.createdByName,
    this.createdAt,
  });

  final String id;
  final String? articleId;
  final String? title;
  final String? slug;
  final String? excerpt;
  final String? content;
  final String? coverImage;
  final String? status;
  final String? visibility;
  final bool featured;
  final bool pinned;
  final bool commentsEnabled;
  final String? tags;
  final String? snapshotType;
  final int versionNumber;
  final String? description;
  final String? createdById;
  final String? createdByName;
  final String? createdAt;

  factory AdminArticleSnapshot.fromJson(Map<String, dynamic> json) {
    return AdminArticleSnapshot(
      id: stringValue(json, 'id'),
      articleId:
          nullableString(json, 'articleId') ??
          nullableString(json, 'article_id'),
      title: nullableString(json, 'title'),
      slug: nullableString(json, 'slug'),
      excerpt: nullableString(json, 'excerpt'),
      content: nullableString(json, 'content'),
      coverImage:
          nullableString(json, 'coverImage') ??
          nullableString(json, 'cover_image'),
      status: nullableString(json, 'status'),
      visibility: nullableString(json, 'visibility'),
      featured: boolValue(json, 'featured'),
      pinned: boolValue(json, 'pinned'),
      commentsEnabled:
          boolValue(json, 'commentsEnabled') ||
          boolValue(json, 'comments_enabled'),
      tags: nullableString(json, 'tags'),
      snapshotType:
          nullableString(json, 'snapshotType') ??
          nullableString(json, 'snapshot_type'),
      versionNumber: intOr(json, 'versionNumber', 'version_number'),
      description: nullableString(json, 'description'),
      createdById:
          nullableString(json, 'createdById') ??
          nullableString(json, 'created_by_id'),
      createdByName:
          nullableString(json, 'createdByName') ??
          nullableString(json, 'created_by_name'),
      createdAt:
          nullableString(json, 'createdAt') ??
          nullableString(json, 'created_at'),
    );
  }
}

// ==================== Product Snapshot ====================

class AdminProductSnapshot {
  const AdminProductSnapshot({
    required this.id,
    this.productId,
    this.name,
    this.slug,
    this.summary,
    this.description,
    this.mainImage,
    this.images = const [],
    this.brand,
    this.price,
    this.originalPrice,
    this.status,
    this.featured = false,
    this.categoryId,
    this.tags,
    this.purchaseUrl,
    this.snapshotType,
    this.versionNumber = 0,
    this.snapshotDescription,
    this.createdById,
    this.createdByName,
    this.createdAt,
  });

  final String id;
  final String? productId;
  final String? name;
  final String? slug;
  final String? summary;
  final String? description;
  final String? mainImage;
  final List<String> images;
  final String? brand;
  final double? price;
  final double? originalPrice;
  final String? status;
  final bool featured;
  final String? categoryId;
  final String? tags;
  final String? purchaseUrl;
  final String? snapshotType;
  final int versionNumber;
  final String? snapshotDescription;
  final String? createdById;
  final String? createdByName;
  final String? createdAt;

  factory AdminProductSnapshot.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    return AdminProductSnapshot(
      id: stringValue(json, 'id'),
      productId:
          nullableString(json, 'productId') ??
          nullableString(json, 'product_id'),
      name: nullableString(json, 'name'),
      slug: nullableString(json, 'slug'),
      summary: nullableString(json, 'summary'),
      description: nullableString(json, 'description'),
      mainImage:
          nullableString(json, 'mainImage') ??
          nullableString(json, 'main_image'),
      images: rawImages is List
          ? rawImages.map((e) => e.toString()).toList(growable: false)
          : const <String>[],
      brand: nullableString(json, 'brand'),
      price: doubleOrNull(json, 'price'),
      originalPrice:
          doubleOrNull(json, 'originalPrice') ??
          doubleOrNull(json, 'original_price'),
      status: nullableString(json, 'status'),
      featured: boolValue(json, 'featured'),
      categoryId:
          nullableString(json, 'categoryId') ??
          nullableString(json, 'category_id'),
      tags: nullableString(json, 'tags'),
      purchaseUrl:
          nullableString(json, 'purchaseUrl') ??
          nullableString(json, 'purchase_url'),
      snapshotType:
          nullableString(json, 'snapshotType') ??
          nullableString(json, 'snapshot_type'),
      versionNumber: intOr(json, 'versionNumber', 'version_number'),
      snapshotDescription:
          nullableString(json, 'snapshotDescription') ??
          nullableString(json, 'snapshot_description'),
      createdById:
          nullableString(json, 'createdById') ??
          nullableString(json, 'created_by_id'),
      createdByName:
          nullableString(json, 'createdByName') ??
          nullableString(json, 'created_by_name'),
      createdAt:
          nullableString(json, 'createdAt') ??
          nullableString(json, 'created_at'),
    );
  }
}

// ==================== Custom Page ====================

class AdminCustomPage {
  const AdminCustomPage({
    required this.id,
    required this.title,
    required this.slug,
    this.subtitle,
    this.pageType = 'STATIC',
    this.content,
    this.customCss,
    this.customJs,
    this.template = 'default',
    this.published = false,
    this.featured = false,
    this.showInMenu = true,
    this.menuTitle,
    this.menuOrder = 0,
    this.sortOrder = 0,
    this.commentsEnabled = false,
    this.accessLevel = 'public',
    this.redirectUrl,
    this.redirectType = 301,
    this.seoTitle,
    this.seoDescription,
    this.seoKeywords,
    this.ogImage,
    this.pageIcon,
    this.viewCount = 0,
    this.shareCount = 0,
    this.contentVersion = 0,
    this.publishedAt,
    this.lastEditedAt,
    this.createdAt,
    this.updatedAt,
    this.fullPath,
    this.summary,
  });

  final String id;
  final String title;
  final String slug;
  final String? subtitle;
  final String pageType;
  final String? content;
  final String? customCss;
  final String? customJs;
  final String template;
  final bool published;
  final bool featured;
  final bool showInMenu;
  final String? menuTitle;
  final int menuOrder;
  final int sortOrder;
  final bool commentsEnabled;
  final String accessLevel;
  final String? redirectUrl;
  final int redirectType;
  final String? seoTitle;
  final String? seoDescription;
  final String? seoKeywords;
  final String? ogImage;
  final String? pageIcon;
  final int viewCount;
  final int shareCount;
  final int contentVersion;
  final String? publishedAt;
  final String? lastEditedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? fullPath;
  final String? summary;

  factory AdminCustomPage.fromJson(Map<String, dynamic> json) {
    return AdminCustomPage(
      id: stringValue(json, 'id'),
      title: stringValue(json, 'title'),
      slug: stringValue(json, 'slug'),
      subtitle: nullableString(json, 'subtitle'),
      pageType:
          nullableString(json, 'pageType') ??
          nullableString(json, 'page_type') ??
          'STATIC',
      content: nullableString(json, 'content'),
      customCss:
          nullableString(json, 'customCss') ??
          nullableString(json, 'custom_css'),
      customJs:
          nullableString(json, 'customJs') ?? nullableString(json, 'custom_js'),
      template: nullableString(json, 'template') ?? 'default',
      published: boolValue(json, 'published'),
      featured: boolValue(json, 'featured'),
      showInMenu:
          boolValue(json, 'showInMenu') || boolValue(json, 'show_in_menu'),
      menuTitle:
          nullableString(json, 'menuTitle') ??
          nullableString(json, 'menu_title'),
      menuOrder: intOr(json, 'menuOrder', 'menu_order'),
      sortOrder: intOr(json, 'sortOrder', 'sort_order'),
      commentsEnabled:
          boolValue(json, 'commentsEnabled') ||
          boolValue(json, 'comments_enabled'),
      accessLevel:
          nullableString(json, 'accessLevel') ??
          nullableString(json, 'access_level') ??
          'public',
      redirectUrl:
          nullableString(json, 'redirectUrl') ??
          nullableString(json, 'redirect_url'),
      redirectType: _parseInt(
        json['redirectType'] ?? json['redirect_type'],
        301,
      ),
      seoTitle:
          nullableString(json, 'seoTitle') ?? nullableString(json, 'seo_title'),
      seoDescription:
          nullableString(json, 'seoDescription') ??
          nullableString(json, 'seo_description'),
      seoKeywords:
          nullableString(json, 'seoKeywords') ??
          nullableString(json, 'seo_keywords'),
      ogImage:
          nullableString(json, 'ogImage') ?? nullableString(json, 'og_image'),
      pageIcon:
          nullableString(json, 'pageIcon') ?? nullableString(json, 'page_icon'),
      viewCount: intOr(json, 'viewCount', 'view_count'),
      shareCount: intOr(json, 'shareCount', 'share_count'),
      contentVersion: intOr(json, 'contentVersion', 'content_version'),
      publishedAt:
          nullableString(json, 'publishedAt') ??
          nullableString(json, 'published_at'),
      lastEditedAt:
          nullableString(json, 'lastEditedAt') ??
          nullableString(json, 'last_edited_at'),
      createdAt:
          nullableString(json, 'createdAt') ??
          nullableString(json, 'created_at'),
      updatedAt:
          nullableString(json, 'updatedAt') ??
          nullableString(json, 'updated_at'),
      fullPath:
          nullableString(json, 'fullPath') ?? nullableString(json, 'full_path'),
      summary: nullableString(json, 'summary'),
    );
  }
}

int _parseInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

List<T> _parseList<T>(
  Map<String, dynamic> json,
  String snakeKey,
  String camelKey,
  T Function(Map<String, dynamic>) fromJson,
) {
  final raw = json[snakeKey] ?? json[camelKey];
  if (raw is List) {
    return raw
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList(growable: false);
  }
  return const [];
}
