import 'package:ankiblog_mobile/core/theme/app_theme.dart';
import 'package:ankiblog_mobile/data/api/auth_session_events.dart';
import 'package:ankiblog_mobile/presentation/providers/auth_provider.dart';
import 'package:ankiblog_mobile/presentation/providers/theme_provider.dart';
import 'package:ankiblog_mobile/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class AnkiBlogApp extends ConsumerWidget {
  const AnkiBlogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<int>(authSessionExpiredRevisionProvider, (previous, next) {
      if (next <= (previous ?? 0)) return;

      final shouldNotify = ref
          .read(authProvider.notifier)
          .handleSessionExpired();
      if (!shouldNotify) return;

      rootScaffoldMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text(AuthNotifier.sessionExpiredMessage)),
        );
    });

    final router = ref.watch(appRouterProvider);
    final theme = ref.watch(appThemeProvider);

    return MaterialApp.router(
      title: 'AnkiBlog',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: AppTheme.light(theme.seedColor),
      darkTheme: AppTheme.dark(theme.seedColor),
      themeMode: theme.mode,
      routerConfig: router,
    );
  }
}
