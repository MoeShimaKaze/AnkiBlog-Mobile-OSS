class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final T data;

  static T unwrap<T>(Object? json, T Function(Object? data) parser) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid API response');
    }
    final success = json['success'] == true;
    final message = json['message']?.toString() ?? 'Request failed';
    if (!success) {
      throw FormatException(message);
    }
    return parser(json['data']);
  }
}
