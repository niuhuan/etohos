import 'package:etohos/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

/// 当前语言 Signal
final localeSignal = signal<Locale?>(null);

/// 初始化语言设置
Future<void> initializeLocale(String appLanguage) async {
  localeSignal.value = appLanguage == 'zh' ? const Locale('zh') : const Locale('en');
  AppLogger.debug("initializeLocale : $appLanguage");
}

/// 获取当前语言显示名称
String getCurrentLanguageName() {
  if (localeSignal.value?.languageCode == 'zh') {
    return '中文';
  } else {
    return 'English';
  }
}

