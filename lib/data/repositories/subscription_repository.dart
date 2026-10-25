import 'package:ankiblog_mobile/data/api/api_client.dart';
import 'package:ankiblog_mobile/data/models/common/api_response.dart';
import 'package:ankiblog_mobile/data/models/subscription.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(ref.watch(dioProvider));
});

class SubscriptionRepository {
  const SubscriptionRepository(this._dio);

  final Dio _dio;

  Future<List<Subscription>> getMySubscriptions() async {
    final response = await _dio.get<Object?>('/user/subscriptions/my');
    return ApiResponse.unwrap(response.data, (data) {
      final items = data as List? ?? const [];
      return items
          .whereType<Map<String, dynamic>>()
          .map(Subscription.fromJson)
          .toList(growable: false);
    });
  }

  Future<List<String>> getSubscriptionTypes() async {
    final response = await _dio.get<Object?>('/user/subscriptions/types');
    return ApiResponse.unwrap(response.data, (data) {
      final items = data as List? ?? const [];
      return items.map((e) => e.toString()).toList(growable: false);
    });
  }

  Future<Subscription> subscribe({
    required String email,
    required String subscriptionType,
  }) async {
    final response = await _dio.post<Object?>(
      '/user/subscriptions/subscribe',
      data: {'email': email, 'subscriptionType': subscriptionType},
    );
    return ApiResponse.unwrap(
      response.data,
      (data) =>
          Subscription.fromJson(data as Map<String, dynamic>? ?? const {}),
    );
  }

  Future<void> unsubscribe({
    required String email,
    required String subscriptionType,
  }) async {
    await _dio.post<Object?>(
      '/user/subscriptions/send-unsubscribe-code',
      queryParameters: {'email': email, 'subscriptionType': subscriptionType},
    );
  }
}
