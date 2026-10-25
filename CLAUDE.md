# CLAUDE.md

本文件为 [CC] / 其他 AI 编码助手提供本仓库的协作指引。

完整内容与 `AGENTS.md` 保持一致。为避免两份文档长期分叉，请以 `AGENTS.md` 作为唯一权威来源，本文件只保留最关键的约束摘要与跳转说明。

> **请先阅读 [`AGENTS.md`](./AGENTS.md)。**

## 仓库定位

本仓库 `AnkiBlog-Mobile-OSS` 是 AnkiBlog 开源版本的 **Flutter 移动端客户端**（Dart SDK `^3.12.2`），后端为 [AnkiBlog-OSS](https://github.com/MoeShimaKaze/AnkiBlog-OSS)，Web 前端为 [AnkiBlog-Fronted-OSS](https://github.com/MoeShimaKaze/AnkiBlog-Fronted-OSS)。三端通过后端 HTTP API 协作。

## 必须遵守的硬性约束

1. **开发流程四步制**：需求评审 → PRD → 技术方案 → 用户确认 → 开发，不可跳过；未经确认不得开始编码。
2. **禁止硬编码后端地址**：统一通过 `--dart-define=ANKIBLOG_API_BASE_URL=...` 注入，默认值只保留 `http://localhost:8080/`。
3. **禁止提交真实凭据、个人域名、邮箱、内网地址、本机绝对路径**；示例值用 `example.com`、`localhost`。
4. **禁止提交构建产物与本地配置**：`.dart_tool/`、`build/`、`.idea/`、`*.iml`、`android/local.properties`、`android/.gradle/`、`ios/Pods/`。
5. **禁止提交第三方版权素材**。
6. **页面不直接使用 `dio`**，API 调用只放 `data/api/`，页面通过 Provider 获取仓储实例。
7. **权限控制不能只靠客户端**，必须有后端 `@PreAuthorize` 兜底。

## 关键事实（易踩坑）

- 后端响应是 **SNAKE_CASE**，但**请求体是 camelCase**（Web MVC 按 Java 字段名绑定），混用会导致 400。
- 分页页码从 **0** 开始。
- 后端 `context-path` 为 `/api`，`baseUrl` 只写到端口，路径在 API 层拼接。
- Android 应用 ID `com.example.ankiblog`，iOS Bundle ID `com.example.ankiblogMobile`，发布前需替换并配置签名。
- 敏感数据（token）必须用 `flutter_secure_storage`，不能用 `shared_preferences`。

## 常用命令

```bash
flutter pub get      # 安装依赖
flutter analyze      # 静态分析
flutter test         # 运行测试
flutter run          # 运行
flutter build apk --release   # 构建发布 APK
```

## 延伸阅读

- 功能范围与启动方式：[`README.md`](./README.md)
- 架构、目录、编码规范、路由与权限：[`AGENTS.md`](./AGENTS.md)
