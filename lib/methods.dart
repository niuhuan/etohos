import 'dart:convert';
import 'dart:io';
import 'package:etohos/et_config.dart';
import 'package:etohos/settings.dart';
import 'package:etohos/utils/logger.dart';
import 'package:flutter/material.dart';
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

  Future<String> setAppLanguage(String language) async {
    try {
      final result = await _channel.invokeMethod("set_app_language", language);
      return result ?? "";
    } catch (e) {
      AppLogger.error('Error setting app language', error: e);
      return "";
    }
  }

  Future<String> getAppLanguage() async {
    try {
      final result = await _channel.invokeMethod("get_app_language");
      return result ?? 'auto';
    } catch (e) {
      AppLogger.error('Error getting app language', error: e);
      return 'auto';
    }
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
      AppLogger.error('Error loading configs', error: e);
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
      AppLogger.error('Error saving configs', error: e);
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
      AppLogger.error('Error loading settings', error: e);
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
      AppLogger.error('Error saving settings', error: e);
      throw Exception('Failed to save settings: $e');
    }
  }

  Future<List<dynamic>> getNetworkHistory() async {
    try {
      final result = await _channel.invokeMethod("get_network_history");
      return result ?? [];
    } catch (e) {
      AppLogger.error('Error getting network history', error: e);
      return [];
    }
  }

  Future<String> scanCode() async {
    try {
      final result = await _channel.invokeMethod("scan_code");
      return result ?? "";
    } catch (e) {
      AppLogger.error('Error scanning code', error: e);
      rethrow;
    }
  }

  Future<String> genCode(String content) async {
    try {
      final result = await _channel.invokeMethod("gen_code", content);
      return result ?? "";
    } catch (e) {
      AppLogger.error('Error generating code', error: e);
      rethrow;
    }
  }

  Future<List<DeviceBasicInfo>> getDeviceList() async {
    try {
      final result = await _channel.invokeMethod("device_list");
      if (result == null) {
        return [];
      }
      
      final List<dynamic> deviceList = result as List<dynamic>;
      return deviceList
          .map((device) => DeviceBasicInfo.fromMap(device as Map<dynamic, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error('Error getting device list', error: e);
      rethrow;
    }
  }

  /// Share configuration to distributed kvStore (using fixed key "shared_config")
  Future<bool> shareConfigToKVStore(String configJson) async {
    try {
      final result = await _channel.invokeMethod("share_config_to_kvstore", configJson);
      return result == true;
    } catch (e) {
      AppLogger.error('Error sharing config to kvStore', error: e);
      rethrow;
    }
  }

  /// Stop sharing configuration (delete from kvStore)
  Future<bool> stopSharingConfig() async {
    try {
      final result = await _channel.invokeMethod("stop_sharing_config");
      return result == true;
    } catch (e) {
      AppLogger.error('Error stopping sharing', error: e);
      rethrow;
    }
  }

  /// Request configuration from another device via kvStore
  /// Syncs from the specific device and reads the "shared_config" key
  Future<String?> requestConfigFromDevice(String deviceId) async {
    try {
      final result = await _channel.invokeMethod("request_config_from_device", deviceId);
      return result as String?;
    } catch (e) {
      AppLogger.error('Error requesting config from device', error: e);
      rethrow;
    }
  }
}

/// Basic description information of a distributed device
class DeviceBasicInfo {
  /// Device identifier
  final String deviceId;
  
  /// Device name
  final String deviceName;
  
  /// Device type (phone, tablet, tv, smartVision, car)
  final String deviceType;
  
  /// Device network id (optional)
  final String? networkId;

  const DeviceBasicInfo({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    this.networkId,
  });

  factory DeviceBasicInfo.fromMap(Map<dynamic, dynamic> map) {
    return DeviceBasicInfo(
      deviceId: map['deviceId'] as String? ?? '',
      deviceName: map['deviceName'] as String? ?? '',
      deviceType: map['deviceType'] as String? ?? '',
      networkId: map['networkId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      if (networkId != null) 'networkId': networkId,
    };
  }

  @override
  String toString() {
    return 'DeviceBasicInfo(deviceId: $deviceId, deviceName: $deviceName, deviceType: $deviceType, networkId: $networkId)';
  }

  /// Get device type icon
  IconData getDeviceIcon() {
    switch (deviceType.toLowerCase()) {
      case 'phone':
        return Icons.phone_android;
      case 'tablet':
        return Icons.tablet;
      case 'tv':
        return Icons.tv;
      case 'smartvision':
        return Icons.visibility;
      case 'car':
        return Icons.directions_car;
      default:
        return Icons.devices;
    }
  }

  /// Get localized device type name
  String getDeviceTypeName() {
    switch (deviceType.toLowerCase()) {
      case 'phone':
        return 'Phone';
      case 'tablet':
        return 'Tablet';
      case 'tv':
        return 'TV';
      case 'smartvision':
        return 'Smart Vision';
      case 'car':
        return 'Car';
      default:
        return deviceType;
    }
  }
}

class ConnectState {
  final bool isConnected;
  final String runningInst;

  const ConnectState({
    required this.isConnected,
    required this.runningInst,
  });

  @override
  String toString() {
    return 'ConnectState(isConnected: $isConnected, runningInst: $runningInst)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConnectState &&
        other.isConnected == isConnected &&
        other.runningInst == runningInst;
  }

  @override
  int get hashCode {
    return isConnected.hashCode ^ runningInst.hashCode;
  }
}
