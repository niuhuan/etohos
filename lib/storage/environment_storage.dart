import 'dart:convert';
import 'dart:io';
import 'package:etohos/models/environment.dart';
import 'package:etohos/methods.dart';
import 'package:etohos/utils/logger.dart';

/// 环境变量存储管理
class EnvironmentStorage {
  static const String _fileName = 'api_environments.json';

  static Future<String> _getFilePath() async {
    final directory = await methods.dataDir();
    return '$directory/$_fileName';
  }

  /// 加载所有环境
  static Future<List<Environment>> loadEnvironments() async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);

      if (!await file.exists()) {
        // 创建默认环境
        final defaultEnv = Environment(
          id: 'default',
          name: 'Default',
          variables: {
            'baseUrl': 'https://api.example.com',
            'apiKey': '',
          },
          isDefault: true,
        );
        await saveEnvironments([defaultEnv]);
        return [defaultEnv];
      }

      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);

      return jsonList.map((json) => Environment.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error loading environments', error: e);
      return [];
    }
  }

  /// 保存环境列表
  static Future<void> saveEnvironments(List<Environment> environments) async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);
      final jsonString = jsonEncode(environments.map((e) => e.toJson()).toList());

      await file.writeAsString(jsonString);
    } catch (e) {
      AppLogger.error('Error saving environments', error: e);
      throw Exception('Failed to save environments: $e');
    }
  }

  /// 保存单个环境
  static Future<void> saveEnvironment(Environment environment) async {
    final environments = await loadEnvironments();
    
    final existingIndex = environments.indexWhere((e) => e.id == environment.id);
    
    if (existingIndex >= 0) {
      environments[existingIndex] = environment;
    } else {
      environments.add(environment);
    }

    await saveEnvironments(environments);
  }

  /// 删除环境
  static Future<void> deleteEnvironment(String id) async {
    final environments = await loadEnvironments();
    environments.removeWhere((e) => e.id == id);
    await saveEnvironments(environments);
  }

  /// 获取默认环境
  static Future<Environment?> getDefaultEnvironment() async {
    final environments = await loadEnvironments();
    return environments.firstWhere(
      (e) => e.isDefault,
      orElse: () => environments.isNotEmpty ? environments.first : throw StateError('No environments'),
    );
  }
}

