import 'dart:convert';
import 'dart:io';
import 'package:etohos/et_config.dart';
import 'package:etohos/settings.dart';
import 'package:flutter/services.dart';

const defaultDnsList = ['223.5.5.5', '223.6.6.6', '8.8.8.8', '8.8.4.4'];

const methods = Methods._();

class Methods {
  const Methods._();

  static const _channel = MethodChannel("methods");

  Future<void> prepareVpn() async {
    await _channel.invokeMethod("prepare_vpn");
  }

  Future<void> connectVpn(Map map) async {
    await _channel.invokeMethod("connect_vpn", map);
  }

  Future<void> disconnectVpn() async {
    await _channel.invokeMethod("disconnect_vpn");
  }

  Future<String> dataDir() async {
    return await _channel.invokeMethod("data_dir");
  }

  // File operations for configs
  Future<String> _getConfigFilePath() async {
    final directory = await dataDir();
    return '$directory/et_configs.json';
  }

  Future<List<EtConfig>> loadConfigs() async {
    try {
      final filePath = await _getConfigFilePath();
      final file = File(filePath);
      
      if (!await file.exists()) {
        return [];
      }
      
      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);
      
      return jsonList.map((json) => EtConfig.fromJson(json)).toList();
    } catch (e) {
      print('Error loading configs: $e');
      return [];
    }
  }

  Future<void> saveConfigs(List<EtConfig> configs) async {
    try {
      final filePath = await _getConfigFilePath();
      final file = File(filePath);
      final jsonString = jsonEncode(configs);
      
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving configs: $e');
      throw Exception('Failed to save configs: $e');
    }
  }

  Future<void> saveConfig(EtConfig config) async {
    final configs = await loadConfigs();
    
    // Check if config with same instanceId exists
    final existingIndex = configs.indexWhere((c) => c.instanceId == config.instanceId);
    
    if (existingIndex >= 0) {
      // Update existing config
      configs[existingIndex] = config;
    } else {
      // Add new config
      configs.add(config);
    }
    
    await saveConfigs(configs);
  }

  Future<void> deleteConfig(String instanceId) async {
    final configs = await loadConfigs();
    configs.removeWhere((config) => config.instanceId == instanceId);
    await saveConfigs(configs);
  }

  // Settings file operations
  Future<String> _getSettingsFilePath() async {
    final directory = await dataDir();
    return '$directory/settings.json';
  }

  Future<Settings> loadSettings() async {
    try {
      final filePath = await _getSettingsFilePath();
      final file = File(filePath);
      
      if (!await file.exists()) {
        // Return default settings
        return const Settings(dnsList: defaultDnsList);
      }
      
      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      
      return Settings.fromJson(json);
    } catch (e) {
      print('Error loading settings: $e');
      // Return default settings on error
      return const Settings(dnsList: defaultDnsList);
    }
  }

  Future<void> saveSettings(Settings settings) async {
    try {
      final filePath = await _getSettingsFilePath();
      final file = File(filePath);
      
      final jsonString = jsonEncode(settings.toJson());
      await file.writeAsString(jsonString);
    } catch (e) {
      print('Error saving settings: $e');
      throw Exception('Failed to save settings: $e');
    }
  }
}
