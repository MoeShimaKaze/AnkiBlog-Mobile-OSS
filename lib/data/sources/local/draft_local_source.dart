import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final draftLocalSourceProvider = Provider<DraftLocalSource>((ref) {
  return const DraftLocalSource();
});

class DraftLocalSource {
  const DraftLocalSource();

  static const _prefix = 'draft:v1:';
  static const maxAge = Duration(days: 7);

  Future<DraftEntry?> getDraft(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final storageKey = _storageKey(key);
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final savedAt = _asInt(decoded['savedAt']);
      if (savedAt == 0) return null;
      final savedDate = DateTime.fromMillisecondsSinceEpoch(savedAt);
      if (DateTime.now().difference(savedDate) > maxAge) {
        await prefs.remove(storageKey);
        return null;
      }
      final payload = decoded['payload'];
      if (payload is! Map<String, dynamic>) return null;
      return DraftEntry(savedAt: savedDate, payload: payload);
    } catch (_) {
      await prefs.remove(storageKey);
      return null;
    }
  }

  Future<void> saveDraft(String key, Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey(key),
      jsonEncode({
        'savedAt': DateTime.now().millisecondsSinceEpoch,
        'payload': payload,
      }),
    );
  }

  Future<void> clearDraft(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey(key));
  }

  Future<void> clearExpired() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys().where((key) => key.startsWith(_prefix))) {
      final raw = prefs.getString(key);
      if (raw == null) continue;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic>) {
          await prefs.remove(key);
          continue;
        }
        final savedAt = _asInt(decoded['savedAt']);
        final savedDate = DateTime.fromMillisecondsSinceEpoch(savedAt);
        if (DateTime.now().difference(savedDate) > maxAge) {
          await prefs.remove(key);
        }
      } catch (_) {
        await prefs.remove(key);
      }
    }
  }

  String _storageKey(String key) => '$_prefix$key';

  int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class DraftEntry {
  const DraftEntry({required this.savedAt, required this.payload});

  final DateTime savedAt;
  final Map<String, dynamic> payload;
}
