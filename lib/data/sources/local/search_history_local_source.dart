import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final searchHistoryLocalSourceProvider = Provider<SearchHistoryLocalSource>((
  ref,
) {
  return const SearchHistoryLocalSource();
});

class SearchHistoryLocalSource {
  const SearchHistoryLocalSource();

  static const _key = 'search_history:v1';
  static const _limit = 20;

  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .take(_limit)
          .toList(growable: false);
    } catch (_) {
      await prefs.remove(_key);
      return const [];
    }
  }

  Future<List<String>> add(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return getHistory();
    final next = <String>[
      normalized,
      ...(await getHistory()).where(
        (item) => item.toLowerCase() != normalized.toLowerCase(),
      ),
    ].take(_limit).toList(growable: false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(next));
    return next;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
