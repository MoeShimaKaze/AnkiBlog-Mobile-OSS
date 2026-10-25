import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const _destinations = [
    _ShellDestination('/', Icons.home_outlined, Icons.home, '首页'),
    _ShellDestination('/discover', Icons.explore_outlined, Icons.explore, '发现'),
    _ShellDestination(
      '/create',
      Icons.add_circle_outline,
      Icons.add_circle,
      '创作',
    ),
    _ShellDestination(
      '/messages',
      Icons.notifications_outlined,
      Icons.notifications,
      '消息',
    ),
    _ShellDestination('/profile', Icons.person_outline, Icons.person, '我的'),
  ];

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final index = _destinations.indexWhere((item) {
      if (item.path == '/') return path == '/';
      return path.startsWith(item.path);
    });

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index < 0 ? 0 : index,
        onDestinationSelected: (selected) {
          context.go(_destinations[selected].path);
        },
        destinations: [
          for (final item in _destinations)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.label,
            ),
        ],
      ),
    );
  }
}

class _ShellDestination {
  const _ShellDestination(this.path, this.icon, this.selectedIcon, this.label);

  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
