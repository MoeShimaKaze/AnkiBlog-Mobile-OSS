import 'package:ankiblog_mobile/data/models/common/json_helpers.dart';

class Subscription {
  const Subscription({
    required this.id,
    required this.email,
    this.userId,
    required this.subscriptionType,
    this.subscriptionTypeDescription,
    required this.status,
    this.statusDescription,
    this.subscriberName,
    this.verifiedAt,
    this.lastNotificationAt,
    this.notificationCount = 0,
    this.createdAt,
  });

  final String id;
  final String email;
  final String? userId;
  final String subscriptionType;
  final String? subscriptionTypeDescription;
  final String status;
  final String? statusDescription;
  final String? subscriberName;
  final String? verifiedAt;
  final String? lastNotificationAt;
  final int notificationCount;
  final String? createdAt;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: stringValue(json, 'id'),
      email: stringValue(json, 'email'),
      userId: nullableString(json, 'user_id') ?? nullableString(json, 'userId'),
      subscriptionType:
          nullableString(json, 'subscription_type') ??
          nullableString(json, 'subscriptionType') ??
          '',
      subscriptionTypeDescription:
          nullableString(json, 'subscription_type_description') ??
          nullableString(json, 'subscriptionTypeDescription'),
      status: stringValue(json, 'status'),
      statusDescription:
          nullableString(json, 'status_description') ??
          nullableString(json, 'statusDescription'),
      subscriberName:
          nullableString(json, 'subscriber_name') ??
          nullableString(json, 'subscriberName'),
      verifiedAt:
          nullableString(json, 'verified_at') ??
          nullableString(json, 'verifiedAt'),
      lastNotificationAt:
          nullableString(json, 'last_notification_at') ??
          nullableString(json, 'lastNotificationAt'),
      notificationCount:
          intValue(json, 'notification_count') |
          intValue(json, 'notificationCount'),
      createdAt:
          nullableString(json, 'created_at') ??
          nullableString(json, 'createdAt'),
    );
  }
}
