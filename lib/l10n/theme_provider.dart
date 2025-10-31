import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:etohos/methods.dart';

/// 主题模式 Signal
final themeModeSignal = signal<ThemeMode>(ThemeMode.system);

/// 设置主题模式（'system', 'light', 'dark'）
Future<void> setThemeMode(String mode) async {
  // 保存到Settings
  final settings = await methods.loadSettings();
  final updatedSettings = settings.copyWith(themeMode: mode);
  await methods.saveSettings(updatedSettings);
  
  // 更新主题模式
  _updateThemeMode(mode);
}

/// 初始化主题设置
Future<void> initializeTheme() async {
  final settings = await methods.loadSettings();
  _updateThemeMode(settings.themeMode);
}

/// 更新ThemeMode
void _updateThemeMode(String mode) {
  switch (mode) {
    case 'light':
      themeModeSignal.value = ThemeMode.light;
      break;
    case 'dark':
      themeModeSignal.value = ThemeMode.dark;
      break;
    case 'system':
    default:
      themeModeSignal.value = ThemeMode.system;
      break;
  }
}

/// 获取当前主题模式显示名称
String getCurrentThemeName(String mode) {
  switch (mode) {
    case 'light':
      return 'Light';
    case 'dark':
      return 'Dark';
    case 'system':
    default:
      return 'Follow System';
  }
}

