class PageResponse<T> {
  const PageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
  });

  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool hasNext;

  factory PageResponse.fromJson(
    Object? json,
    T Function(Map<String, dynamic> item) parser,
  ) {
    final map = json as Map<String, dynamic>? ?? const {};
    final rawContent = map['content'];
    return PageResponse<T>(
      content: rawContent is List
          ? rawContent
                .whereType<Map<String, dynamic>>()
                .map(parser)
                .toList(growable: false)
          : const [],
      page: _asInt(map['page']),
      size: _asInt(map['size']),
      totalElements: _asInt(map['total_elements'] ?? map['totalElements']),
      totalPages: _asInt(map['total_pages'] ?? map['totalPages']),
      hasNext: map['has_next'] == true || map['hasNext'] == true,
    );
  }

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
