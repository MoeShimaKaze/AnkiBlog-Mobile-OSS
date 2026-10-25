import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appThemeProvider =
    StateNotifierProvider<AppThemeNotifier, AppThemeSettings>((ref) {
      return AppThemeNotifier();
    });

class AppThemeNotifier extends StateNotifier<AppThemeSettings> {
  AppThemeNotifier() : super(AppThemeSettings.defaults()) {
    _load();
  }

  static const _modeKey = 'theme:mode';
  static const _seedKey = 'theme:seed';

  Future<void> setMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode.name);
  }

  Future<void> setSeedColor(Color color) async {
    state = state.copyWith(seedColor: color);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seedKey, color.toARGB32());
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString(_modeKey);
    final seedValue = prefs.getInt(_seedKey);
    state = AppThemeSettings(
      mode: ThemeMode.values.firstWhere(
        (mode) => mode.name == modeName,
        orElse: () => ThemeMode.dark,
      ),
      seedColor: seedValue == null
          ? AppThemeSettings.defaultSeed
          : Color(seedValue),
    );
  }
}

class AppThemeSettings {
  const AppThemeSettings({required this.mode, required this.seedColor});

  static const defaultSeed = Color(0xFF8EA7FF);

  final ThemeMode mode;
  final Color seedColor;

  factory AppThemeSettings.defaults() {
    return const AppThemeSettings(mode: ThemeMode.dark, seedColor: defaultSeed);
  }

  AppThemeSettings copyWith({ThemeMode? mode, Color? seedColor}) {
    return AppThemeSettings(
      mode: mode ?? this.mode,
      seedColor: seedColor ?? this.seedColor,
    );
  }
}
