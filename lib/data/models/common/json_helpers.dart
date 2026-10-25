String stringValue(
  Map<String, dynamic> json,
  String key, [
  String fallback = '',
]) {
  return json[key]?.toString() ?? fallback;
}

String? nullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

int intValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double doubleValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double? doubleOrNull(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool boolValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is bool) return value;
  return value?.toString().toLowerCase() == 'true';
}

List<String> stringList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is List) {
    return value.map((item) => item.toString()).toList(growable: false);
  }
  return const [];
}

List<String> tagList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is List) {
    return value
        .map((item) {
          if (item is Map) return item['name']?.toString() ?? '';
          return item.toString();
        })
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }
  return const [];
}

/// Reads int from [key1], falling back to [key2], then 0.
int intOr(Map<String, dynamic> json, String key1, String key2) {
  final v1 = json[key1];
  if (v1 != null) {
    if (v1 is int) return v1;
    if (v1 is num) return v1.toInt();
    final parsed = int.tryParse(v1.toString());
    if (parsed != null) return parsed;
  }
  final v2 = json[key2];
  if (v2 != null) {
    if (v2 is int) return v2;
    if (v2 is num) return v2.toInt();
    return int.tryParse(v2.toString()) ?? 0;
  }
  return 0;
}

String? categoryFromJson(Map<String, dynamic> json) {
  final cat = json['category'];
  if (cat is Map) return cat['name']?.toString();
  return nullableString(json, 'category_name') ??
      nullableString(json, 'categoryName');
}
