# AGENTS.md

This file provides guidance to AI coding agents (Codex / [CC] / Cursor 等) when working with code in this repository.

## 开源仓库说明（重要）

本仓库是 **AnkiBlog 的开源（脱敏）版本**，对应私有开发仓库的移动端部分。

### 仓库拆分

AnkiBlog 由三个独立仓库组成，本仓库只包含移动端：

| 仓库 | 内容 | 技术栈 |
| --- | --- | --- |
| [AnkiBlog-OSS](https://github.com/MoeShimaKaze/AnkiBlog-OSS) | 后端服务 | Spring Boot 3.3 + Java 17 + Maven |
| [AnkiBlog-Fronted-OSS](https://github.com/MoeShimaKaze/AnkiBlog-Fronted-OSS) | Web 前端 | React 18 + TypeScript 5 + Vite 4 + Ant Design 5 |
| `AnkiBlog-Mobile-OSS`（本仓库） | 移动端客户端 | Flutter / Dart |

三端通过后端 HTTP API 协作。本仓库不包含后端与 Web 前端代码，需要时请单独 clone 对应仓库。

### 脱敏约定

本仓库在发布前已做以下处理，**修改代码时必须保持这些约定**：

1. **禁止硬编码后端地址**。API 根地址统一通过 `--dart-define=ANKIBLOG_API_BASE_URL=...` 注入，`lib/core/constants/api_constants.dart` 中的 `defaultValue` 只保留 `http://localhost:8080/` 作为本地开发默认值。
2. **禁止提交真实凭据**。任何 token、密钥、第三方服务凭据都不得写入仓库，也不得写入 `android/local.properties`。
3. **禁止提交个人域名、邮箱、手机号、内网地址、本机绝对路径**。示例值统一使用 `example.com`、`localhost`。Android 应用 ID 为 `com.example.ankiblog`，iOS Bundle ID 为 `com.example.ankiblogMobile`，发布前自行替换。
4. **禁止提交构建产物与本地配置**：`.dart_tool/`、`build/`、`.idea/`、`*.iml`、`android/local.properties`、`android/.gradle/`、`ios/Pods/`。
5. **禁止提交第三方版权素材**。仓库内不含任何第三方画师作品或未授权图片。

如发现遗留敏感信息，请立刻停止改动并提交 Issue，不要直接在公开 PR 中附上原文。

## 工作流规范

### 会话启动前置步骤

每次开始工作前，依次读取：

1. `AGENTS.md`（本文档）—— 项目架构与编码规范
2. `README.md` —— 功能范围、目录结构与启动方式

### 开发流程（四步制）

任何非 trivial 的功能开发或修改必须遵循以下流程，**不可跳过**：

1. **需求评审**：与用户沟通明确需求范围、优先级、边界条件
2. **输出 PRD**：编写产品需求文档，包含功能描述、用户交互流程、验收标准
3. **输出技术方案**：基于 PRD 输出技术实现方案，包含涉及文件、API 映射、状态设计、关键算法
4. **用户确认 → 开发**：针对技术方案中不明确或存在模糊的内容，**必须向用户提问并确认**，明确后方可进入代码实现

> 规则：未经用户确认技术方案，不得直接开始编码。

## 项目概览

AnkiBlog 是一个个人博客 + 生活记录 + 商品收藏的全栈系统。本仓库是其 Flutter 移动端客户端，**不复用 React 代码**，但复用后端的 API、认证体系、业务模型与 Web 端的视觉风格。

功能域包括：

- **公开内容**：文章、商品、妆容、穿搭、自定义页面、待办、搜索
- **用户中心**：登录注册、个人资料、我的评论/点赞/收藏、主题切换
- **管理后台**：文章、商品、自定义页面、评论、用户、订阅、站点配置、生活记录、缓存与文件管理

## 常用命令

| 任务 | 命令 |
| --- | --- |
| 安装依赖 | `flutter pub get` |
| 静态分析 | `flutter analyze` |
| 运行测试 | `flutter test` |
| 运行（默认 localhost） | `flutter run` |
| 运行（指定后端） | `flutter run --dart-define=ANKIBLOG_API_BASE_URL=http://10.0.2.2:8080/` |
| 构建调试 APK | `flutter build apk --debug` |
| 构建发布 APK | `flutter build apk --release` |

## 移动端架构

### 技术栈

- **框架**：Flutter，Dart SDK `^3.12.2`
- **状态管理**：`flutter_riverpod`
- **路由**：`go_router`，路由表在 `lib/router/app_router.dart`
- **网络**：`dio`，拦截器在 `lib/data/api/api_interceptors.dart`
- **序列化**：`json_serializable` + `build_runner`
- **本地存储**：`shared_preferences`、`flutter_secure_storage`、`path_provider`
- **UI**：Material 3、`fl_chart`、`flutter_markdown`
- **媒体**：`image_picker`、`image_cropper`、`webview_flutter`

### 目录结构

```text
lib/
├── core/
│   ├── constants/      # API 地址、本地存储键
│   └── theme/          # 主题与配色
├── data/
│   ├── api/            # ApiClient、拦截器、各领域 API
│   ├── models/         # 数据模型（含 admin 子集）
│   ├── repositories/   # 仓储层，聚合 API 与本地缓存
│   └── sources/local/  # 本地缓存、草稿、搜索历史、图片缓存
├── presentation/
│   ├── pages/          # 页面，按 public / admin / profile 分区
│   ├── providers/      # Riverpod Provider
│   └── common/         # 通用组件与工具
├── router/             # go_router 路由表
├── app.dart
└── main.dart
```

### 数据流

```text
Page (presentation/pages)
  → Provider (presentation/providers)
    → Repository (data/repositories)
      → ApiClient (data/api) → 后端 REST API
      → LocalSource (data/sources/local) → 本地缓存
    → Model (data/models)
```

### API 约定

- `ApiConstants.baseUrl` 通过 `--dart-define=ANKIBLOG_API_BASE_URL` 注入，默认 `http://localhost:8080/`。
- 后端 `server.servlet.context-path` 为 `/api`，因此 `baseUrl` 只写到端口，路径由各 API 拼接时补齐。
- 统一响应结构：`{ success, message, data, timestamp }`，见 `data/models/common/api_response.dart`。
- 分页结构见 `data/models/common/page_response.dart`，**页码从 0 开始**。
- **后端响应字段为 `SNAKE_CASE`，但请求体字段为 camelCase**（Web MVC 按 Java 字段名绑定）。发送请求时混用 snake_case 会导致 400。

## 编码规范

### 分层与职责

- `presentation/pages/` 只负责页面装配与交互，不直接调用 `dio`。
- `presentation/providers/` 承载页面状态与异步加载逻辑。
- `data/repositories/` 聚合多个 API 与本地缓存，向上暴露领域方法。
- `data/api/` 只做 HTTP 请求与响应解析，不写业务规则。
- `data/models/` 只做数据载体，不塞入 UI 逻辑。

### 命名与风格

- 文件与目录使用 `snake_case.dart`。
- 类名使用 `UpperCamelCase`，变量与方法使用 `lowerCamelCase`。
- 页面类统一以 `Page` 结尾，Widget 组件以描述性名称结尾。
- 私有成员使用 `_` 前缀。
- 遵循 `analysis_options.yaml` 中的 `flutter_lints` 规则，不通过 `// ignore` 掩盖真实问题。

### UI 与主题

- 主题色统一从 `core/theme/app_theme.dart` 取，不在页面中硬编码颜色。
- 新增页面必须在 `router/app_router.dart` 注册，并按 `public` / `admin` / `profile` 分区放置。
- 列表页需要处理加载中、空态、错误重试三种状态。

### 本地存储

- 缓存键集中定义在 `core/constants/storage_keys.dart`，不要在业务代码中散落字符串。
- 敏感数据（token）必须使用 `flutter_secure_storage`，不要用 `shared_preferences`。

## 参考规范

- 主参考：Flutter 官方风格指南与 `flutter_lints` 推荐规则。
- 补充参考：Riverpod 官方文档、go_router 官方文档、Material 3 设计规范。
