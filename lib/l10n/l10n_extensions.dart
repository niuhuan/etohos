import 'package:flutter/material.dart';
import 'package:etohos/l10n/app_localizations.dart';
import 'package:etohos/l10n/locale_provider.dart';

extension LocalizationExtension on BuildContext {
  /// 快捷方式获取本地化字符串
  /// 
  /// 推荐使用全局 t() 函数配合 Watch widget
  /// 使用方式：Watch((context) => Text(t('key')))
  String t(String key) {
    final locale = localeSignal.value;
    if (locale == null) return key;
    
    final language = locale.languageCode;
    final translations = AppLocalizations.localizedStrings[key];
    
    if (translations == null) return key;
    return translations[language] ?? translations['en'] ?? key;
  }
}

/// 全局获取国际化字符串（不依赖 BuildContext）
/// 使用方式：t('key')
String t(String key) {
  final locale = localeSignal.value;
  if (locale == null) return key;
  
  final language = locale.languageCode;
  final translations = AppLocalizations.localizedStrings[key];
  
  if (translations == null) return key;
  return translations[language] ?? translations['en'] ?? key;
}
