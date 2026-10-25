import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final jsonCacheLocalSourceProvider = Provider<JsonCacheLocalSource>((ref) {
  return const JsonCacheLocalSource();
});

class JsonCacheLocalSource {
  const JsonCacheLocalSource();

  static const _prefix = 'json_cache:';

  Future<Object?> getFresh(String key, {required Duration maxAge}) async {
    final entry = await _readEntry(key);
    if (entry == null) return null;
    final savedAt = DateTime.fromMillisecondsSinceEpoch(entry.savedAt);
    if (DateTime.now().difference(savedAt) > maxAge) return null;
    return entry.payload;
  }

  Future<Object?> getAny(String key) async {
    return (await _readEntry(key))?.payload;
  }

  Future<void> put(String key, Object? payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey(key),
      jsonEncode({
        'savedAt': DateTime.now().millisecondsSinceEpoch,
        'payload': payload,
      }),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  Future<_JsonCacheEntry?> _readEntry(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey(key));
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map<String, dynamic>) return null;
      final savedAt = map['savedAt'];
      return _JsonCacheEntry(
        savedAt: savedAt is int ? savedAt : 0,
        payload: map['payload'],
      );
    } catch (_) {
      await prefs.remove(_storageKey(key));
      return null;
    }
  }

  String _storageKey(String key) => '$_prefix${_fnv1a(key)}';
}

class _JsonCacheEntry {
  const _JsonCacheEntry({required this.savedAt, required this.payload});

  final int savedAt;
  final Object? payload;
}

String _fnv1a(String input) {
  var hash = 0x811c9dc5;
  for (final codeUnit in input.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}
