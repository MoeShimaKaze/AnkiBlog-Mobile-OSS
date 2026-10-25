import 'package:ankiblog_mobile/data/models/common/json_helpers.dart';

class PublicTodo {
  const PublicTodo({
    required this.id,
    required this.title,
    this.listName,
    required this.completed,
    this.priority,
    this.dueDate,
    this.stepCount = 0,
    this.completedStepCount = 0,
  });

  final String id;
  final String title;
  final String? listName;
  final bool completed;
  final String? priority;
  final String? dueDate;
  final int stepCount;
  final int completedStepCount;

  factory PublicTodo.fromJson(Map<String, dynamic> json) {
    return PublicTodo(
      id: stringValue(json, 'id'),
      title: stringValue(json, 'title'),
      listName:
          nullableString(json, 'list_name') ?? nullableString(json, 'listName'),
      completed:
          boolValue(json, 'completed') || boolValue(json, 'is_completed'),
      priority: nullableString(json, 'priority'),
      dueDate:
          nullableString(json, 'due_date') ?? nullableString(json, 'dueDate'),
      stepCount: intValue(json, 'step_count') | intValue(json, 'stepCount'),
      completedStepCount:
          intValue(json, 'completed_step_count') |
          intValue(json, 'completedStepCount'),
    );
  }
}

class PublicOutfit {
  const PublicOutfit({
    required this.id,
    this.outfitDate,
    this.note,
    this.outfitImage,
    this.items = const [],
  });

  final String id;
  final String? outfitDate;
  final String? note;
  final String? outfitImage;
  final List<OutfitItem> items;

  factory PublicOutfit.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(OutfitItem.fromJson)
              .toList(growable: false)
        : <OutfitItem>[];

    return PublicOutfit(
      id: stringValue(json, 'id'),
      outfitDate:
          nullableString(json, 'outfit_date') ??
          nullableString(json, 'outfitDate'),
      note: nullableString(json, 'note'),
      outfitImage:
          nullableString(json, 'outfit_image') ??
          nullableString(json, 'outfitImage'),
      items: items,
    );
  }
}

class OutfitItem {
  const OutfitItem({
    this.productId,
    this.productSlug,
    this.productName,
    this.productMainImage,
    this.brand,
    this.itemType,
  });

  final String? productId;
  final String? productSlug;
  final String? productName;
  final String? productMainImage;
  final String? brand;
  final String? itemType;

  factory OutfitItem.fromJson(Map<String, dynamic> json) {
    return OutfitItem(
      productId:
          nullableString(json, 'product_id') ??
          nullableString(json, 'productId'),
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

class PublicMakeup {
  const PublicMakeup({
    required this.id,
    this.makeupDate,
    this.lookName,
    this.referenceUrl,
    this.makeupImage,
    this.note,
    this.items = const [],
  });

  final String id;
  final String? makeupDate;
  final String? lookName;
  final String? referenceUrl;
  final String? makeupImage;
  final String? note;
  final List<MakeupItem> items;

  factory PublicMakeup.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(MakeupItem.fromJson)
              .toList(growable: false)
        : <MakeupItem>[];

    return PublicMakeup(
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
    );
  }
}

class MakeupItem {
  const MakeupItem({
    this.productId,
    this.productSlug,
    this.productName,
    this.productMainImage,
    this.brand,
    this.usageTypeName,
  });

  final String? productId;
  final String? productSlug;
  final String? productName;
  final String? productMainImage;
  final String? brand;
  final String? usageTypeName;

  factory MakeupItem.fromJson(Map<String, dynamic> json) {
    return MakeupItem(
      productId:
          nullableString(json, 'product_id') ??
          nullableString(json, 'productId'),
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
      usageTypeName:
          nullableString(json, 'usage_type_name') ??
          nullableString(json, 'usageTypeName'),
    );
  }
}

class GoalsSummary {
  const GoalsSummary({
    required this.activeGoalCount,
    required this.totalCheckInDays,
    required this.maxCurrentStreak,
    required this.maxLongestStreak,
    required this.thisMonthCheckIns,
    required this.unlockedMilestoneCount,
    required this.totalMilestoneCount,
    this.recentActiveGoals = const [],
  });

  final int activeGoalCount;
  final int totalCheckInDays;
  final int maxCurrentStreak;
  final int maxLongestStreak;
  final int thisMonthCheckIns;
  final int unlockedMilestoneCount;
  final int totalMilestoneCount;
  final List<ActiveGoal> recentActiveGoals;

  factory GoalsSummary.fromJson(Map<String, dynamic> json) {
    final rawGoals = json['recent_active_goals'] ?? json['recentActiveGoals'];
    final goals = rawGoals is List
        ? rawGoals
              .whereType<Map<String, dynamic>>()
              .map(ActiveGoal.fromJson)
              .toList(growable: false)
        : <ActiveGoal>[];

    return GoalsSummary(
      activeGoalCount: intOr(json, 'active_goal_count', 'activeGoalCount'),
      totalCheckInDays: intOr(json, 'total_check_in_days', 'totalCheckInDays'),
      maxCurrentStreak: intOr(json, 'max_current_streak', 'maxCurrentStreak'),
      maxLongestStreak: intOr(json, 'max_longest_streak', 'maxLongestStreak'),
      thisMonthCheckIns: intOr(
        json,
        'this_month_check_ins',
        'thisMonthCheckIns',
      ),
      unlockedMilestoneCount: intOr(
        json,
        'unlocked_milestone_count',
        'unlockedMilestoneCount',
      ),
      totalMilestoneCount: intOr(
        json,
        'total_milestone_count',
        'totalMilestoneCount',
      ),
      recentActiveGoals: goals,
    );
  }
}

class ActiveGoal {
  const ActiveGoal({
    required this.id,
    required this.name,
    this.description,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalCheckIns = 0,
  });

  final String id;
  final String name;
  final String? description;
  final int currentStreak;
  final int longestStreak;
  final int totalCheckIns;

  factory ActiveGoal.fromJson(Map<String, dynamic> json) {
    return ActiveGoal(
      id: stringValue(json, 'id'),
      name: stringValue(json, 'name'),
      description: nullableString(json, 'description'),
      currentStreak:
          intValue(json, 'current_streak') | intValue(json, 'currentStreak'),
      longestStreak:
          intValue(json, 'longest_streak') | intValue(json, 'longestStreak'),
      totalCheckIns:
          intValue(json, 'total_check_ins') | intValue(json, 'totalCheckIns'),
    );
  }
}
