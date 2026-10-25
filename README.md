# AnkiBlog Mobile

AnkiBlog 的 Flutter 移动端客户端，与 [AnkiBlog-OSS](https://github.com/MoeShimaKaze/AnkiBlog-OSS)（Spring Boot 后端）和 [AnkiBlog-Fronted-OSS](https://github.com/MoeShimaKaze/AnkiBlog-Fronted-OSS)（React 前端）共用同一套 HTTP API 与数据模型。

## 功能概览

**公开内容**

- 文章列表与详情，Markdown 渲染，代码块高亮
- 商品列表与详情、商品分类浏览
- 生活记录：妆容、每日穿搭、穿搭详情
- 自定义页面（HTML 直出，支持自定义 CSS/JS）
- 待办清单公开展示
- 全站搜索与搜索历史

**用户中心**

- 注册、登录、Token 自动刷新（access + refresh 双 Token）
- 我的评论、我的点赞、我的收藏
- 个人资料编辑、头像上传
- 主题切换（亮色 / 暗色 / 跟随系统）

**管理后台**

- 仪表盘统计
- 文章 / 商品 / 自定义页面的增删改查与快照
- 评论审核、用户管理、订阅管理
- 妆容、穿搭、衣橱、购买记录、待办清单管理
- 站点配置、背景图、友情链接、社交链接、页面类型
- 缓存管理与文件管理

## 技术栈

| 层次 | 选型 |
| --- | --- |
| 框架 | Flutter（Dart SDK `^3.12.2`） |
| 状态管理 | `flutter_riverpod` |
| 路由 | `go_router` |
| 网络 | `dio`，自定义拦截器处理鉴权与刷新 |
| 序列化 | `json_serializable` + 手写 `fromJson` 兼容层 |
| 本地存储 | `shared_preferences`、`flutter_secure_storage`、`path_provider` |
| UI | Material 3、`fl_chart`（统计图表）、`flutter_markdown` |
| 媒体 | `image_picker`、`image_cropper`、`webview_flutter` |

## 目录结构

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

## 快速开始

### 1. 准备后端

先按 [AnkiBlog-OSS](https://github.com/MoeShimaKaze/AnkiBlog-OSS) 的说明启动后端，确保 `http://localhost:8080/api` 可访问。

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 配置 API 地址

API 根地址通过编译期变量注入，默认值为 `http://localhost:8080/`：

```bash
# Android 模拟器访问宿主机
flutter run --dart-define=ANKIBLOG_API_BASE_URL=http://10.0.2.2:8080/

# 真机访问局域网内的后端
flutter run --dart-define=ANKIBLOG_API_BASE_URL=http://192.168.1.10:8080/
```

也可以在 `lib/core/constants/api_constants.dart` 中修改 `defaultValue`。

> 注意：后端 `server.servlet.context-path` 为 `/api`，因此 `baseUrl` 只写到端口，路径由各 API 拼接时补齐。

### 4. 运行

```bash
flutter run
```

### 5. 构建

```bash
flutter build apk --debug
flutter build apk --release --dart-define=ANKIBLOG_API_BASE_URL=https://your-domain.example.com/
```

Android 应用 ID 为 `com.example.ankiblog`，iOS Bundle ID 为 `com.example.ankiblogMobile`。发布前请替换为自己的标识，并配置 release 签名。

## 开发约定

- **请求体字段使用 camelCase，响应字段使用 SNAKE_CASE。** 后端 Jackson 对响应开启 `SNAKE_CASE`，但 Web MVC 请求体按 Java 字段名绑定，混用会导致 400。
- API 调用只放在 `data/api/`，**页面不直接使用 `dio`**。
- 页面通过 `providers/` 获取仓储实例，不自行实例化。
- 新增页面须在 `router/app_router.dart` 注册，并按 `public` / `admin` / `profile` 分区放置。
- 主题色统一从 `core/theme/app_theme.dart` 取，不在页面中硬编码颜色。
- 本地缓存键集中定义在 `core/constants/storage_keys.dart`。

## 已知限制

- 自定义主题色与基于图片取色的动态主题尚未实现，当前提供预设配色。
- `test/` 仅包含 Flutter 默认的 widget 测试模板，业务逻辑缺少单元测试。
- iOS 端未做专门适配验证，构建配置为 Flutter 默认模板。

## 相关仓库

| 仓库 | 说明 |
| --- | --- |
| [AnkiBlog-OSS](https://github.com/MoeShimaKaze/AnkiBlog-OSS) | Spring Boot 后端 |
| [AnkiBlog-Fronted-OSS](https://github.com/MoeShimaKaze/AnkiBlog-Fronted-OSS) | React + TypeScript 前端 |
| [AnkiBlog-Mobile-OSS](https://github.com/MoeShimaKaze/AnkiBlog-Mobile-OSS) | Flutter 移动端（本仓库） |

## 许可证

[MIT](LICENSE)
