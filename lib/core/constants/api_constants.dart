class ApiConstants {
  const ApiConstants._();

  /// 后端 API 根地址。
  ///
  /// 构建或运行时可通过 `--dart-define` 覆盖，例如：
  /// `flutter run --dart-define=ANKIBLOG_API_BASE_URL=http://10.0.2.2:8080/`
  static const baseUrl = String.fromEnvironment(
    'ANKIBLOG_API_BASE_URL',
    defaultValue: 'http://localhost:8080/',
  );

  static const pageSize = 10;
}
