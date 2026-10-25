import 'package:ankiblog_mobile/data/sources/local/draft_local_source.dart';
import 'package:ankiblog_mobile/data/sources/local/image_cache_local_source.dart';
import 'package:ankiblog_mobile/data/sources/local/json_cache_local_source.dart';
import 'package:ankiblog_mobile/data/sources/local/search_history_local_source.dart';
import 'package:ankiblog_mobile/presentation/common/widgets/glass_container.dart';
import 'package:ankiblog_mobile/presentation/providers/auth_provider.dart';
import 'package:ankiblog_mobile/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const _themeColors = [
    Color(0xFF8EA7FF),
    Color(0xFF5EC4A7),
    Color(0xFFFFB86B),
    Color(0xFFE983A8),
    Color(0xFF8BCA6B),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = ref.watch(appThemeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (authState.isAuthenticated) ...[
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: authState.user?.avatarUrl != null
                        ? NetworkImage(authState.user!.avatarUrl!)
                        : null,
                    child: authState.user?.avatarUrl == null
                        ? Text(
                            authState.user?.displayName.isNotEmpty == true
                                ? authState.user!.displayName[0].toUpperCase()
                                : '?',
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.user?.displayName ?? '',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          authState.user?.email ?? '',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          GlassContainer(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('个人资料'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/user/info'),
                ),
                const Divider(height: 1),
                _ThemeModeTile(mode: theme.mode),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      const Icon(Icons.palette_outlined),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _themeColors.map((color) {
                            final selected =
                                color.toARGB32() == theme.seedColor.toARGB32();
                            return InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                ref
                                    .read(appThemeProvider.notifier)
                                    .setSeedColor(color);
                              },
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: color,
                                    child: selected
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cleaning_services_outlined),
                  title: const Text('清除离线内容缓存'),
                  subtitle: const Text('文章、产品、页面等公开内容会在下次访问时重新获取'),
                  onTap: () => _runAction(
                    context,
                    () => ref.read(jsonCacheLocalSourceProvider).clear(),
                    '离线内容缓存已清除',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.image_not_supported_outlined),
                  title: const Text('清除图片缓存'),
                  subtitle: const Text('已缓存图片会在下次显示时重新下载'),
                  onTap: () => _runAction(
                    context,
                    () => ref.read(imageCacheLocalSourceProvider).clear(),
                    '图片缓存已清除',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.history_outlined),
                  title: const Text('清除搜索历史'),
                  onTap: () => _runAction(
                    context,
                    () => ref.read(searchHistoryLocalSourceProvider).clear(),
                    '搜索历史已清除',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.note_alt_outlined),
                  title: const Text('清理过期草稿'),
                  subtitle: const Text('超过 7 天的本地草稿会被移除'),
                  onTap: () => _runAction(
                    context,
                    () => ref.read(draftLocalSourceProvider).clearExpired(),
                    '过期草稿已清理',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            padding: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('关于'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'AnkiBlog',
                  applicationVersion: '1.0.0',
                  children: const [Text('AnkiBlog Flutter 移动端客户端')],
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          if (authState.isAuthenticated)
            FilledButton.tonalIcon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('退出登录'),
                    content: const Text('确定要退出登录吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('退出登录'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _runAction(
    BuildContext context,
    Future<void> Function() action,
    String message,
  ) async {
    try {
      await action();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
      }
    }
  }
}

class _ThemeModeTile extends ConsumerWidget {
  const _ThemeModeTile({required this.mode});

  final ThemeMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.contrast_outlined),
      title: const Text('外观模式'),
      subtitle: Text(_modeLabel(mode)),
      trailing: DropdownButton<ThemeMode>(
        value: mode,
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(value: ThemeMode.dark, child: Text('深色')),
          DropdownMenuItem(value: ThemeMode.light, child: Text('浅色')),
          DropdownMenuItem(value: ThemeMode.system, child: Text('跟随系统')),
        ],
        onChanged: (value) {
          if (value == null) return;
          ref.read(appThemeProvider.notifier).setMode(value);
        },
      ),
    );
  }

  String _modeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.dark => '深色',
      ThemeMode.light => '浅色',
      ThemeMode.system => '跟随系统',
    };
  }
}
