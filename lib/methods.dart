import 'dart:convert';
import 'dart:io';
import 'package:etohos/app_data.dart';
import 'package:etohos/et_config.dart';
import 'package:etohos/settings.dart';
import 'package:etohos/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        final settings = const Settings(dnsList: defaultDnsList);
        AppData.settings = settings;
        return settings;
      }
      
      final jsonString = await file.readAsString();
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      
      final settings = Settings.fromJson(json);
      AppData.settings = settings;
      return settings;
    } catch (e) {
      AppLogger.error('Error loading settings', error: e);
      // Return default settings on error
      final settings = const Settings(dnsList: defaultDnsList);
      AppData.settings = settings;
      return settings;
    }
  }

  Future<void> saveSettings(Settings settings) async {
    try {
      final filePath = await _getSettingsFilePath();
      final file = File(filePath);
      
      final jsonString = jsonEncode(settings.toJson());
      await file.writeAsString(jsonString);
      AppData.settings = settings;
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

  /// Launch URL in external browser
  Future<bool> launchUrl(String url) async {
    try {
      final result = await _channel.invokeMethod("launch_url", url);
      return result == true;
    } catch (e) {
      AppLogger.error('Error launching URL', error: e);
      return false;
    }
  }

  /// Get device type ("phone" or "tablet")
  Future<String> getDeviceType() async {
    try {
      final result = await _channel.invokeMethod("get_device_type");
      return result as String? ?? "phone";
    } catch (e) {
      AppLogger.error('Error getting device type', error: e);
      return "phone"; // Default to phone
    }
  }

  /// Get device name
  Future<String> getDeviceName() async {
    try {
      final result = await _channel.invokeMethod("get_device_name");
      return result as String? ?? "HarmonyOS Device";
    } catch (e) {
      AppLogger.error('Error getting device name', error: e);
      return "HarmonyOS Device";
    }
  }

  /// Exit the application
  Future<void> exitApp() async {
    try {
      await _channel.invokeMethod("exit_app");
    } catch (e) {
      AppLogger.error('Error exiting app', error: e);
    }
  }

  /// HTTP 请求方法
  Future<HttpResponse> httpRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    String? body,
  }) async {
    try {
      final result = await _channel.invokeMethod('http_request', {
        'method': method,
        'url': url,
        'headers': headers ?? {},
        'body': body ?? '',
      });
      
      final Map<String, dynamic> response = Map<String, dynamic>.from(result);
      return HttpResponse(
        statusCode: response['statusCode'] as int,
        headers: Map<String, String>.from(response['headers'] ?? {}),
        body: response['body'] as String,
      );
    } catch (e) {
      AppLogger.error('HTTP request failed', error: e);
      rethrow;
    }
  }

  /// HTTP 204 连通性检测（替代 Ping）
  Future<Http204CheckResult> http204Check() async {
    try {
      final result = await _channel.invokeMethod('http204_check', {});
      
      final Map<String, dynamic> response = Map<String, dynamic>.from(result);
      final List<dynamic> resultsJson = response['results'] ?? [];
      
      final routes = resultsJson.map((r) {
        final routeMap = Map<String, dynamic>.from(r);
        return Http204RouteResult(
          name: routeMap['name'] as String,
          url: routeMap['url'] as String,
          success: routeMap['success'] as bool,
          statusCode: routeMap['statusCode'] as int? ?? 0,
          latency: routeMap['latency'] as int? ?? 0,
          message: routeMap['message'] as String? ?? '',
        );
      }).toList();
      
      return Http204CheckResult(
        success: response['success'] as bool,
        successCount: response['successCount'] as int? ?? 0,
        totalCount: response['totalCount'] as int? ?? 0,
        results: routes,
        message: response['message'] as String? ?? '',
      );
    } catch (e) {
      AppLogger.error('HTTP 204 check failed', error: e);
      return Http204CheckResult(
        success: false,
        successCount: 0,
        totalCount: 0,
        results: [],
        message: 'Error: $e',
      );
    }
  }

  /// DNS 查询（多 DoH 提供商）
  Future<DnsResult> dnsLookup(String host, {String type = 'A'}) async {
    try {
      final result = await _channel.invokeMethod('dns_lookup', {
        'host': host,
        'type': type,
      });
      
      final Map<String, dynamic> response = Map<String, dynamic>.from(result);
      final List<dynamic> resultsJson = response['results'] ?? [];
      
      final providerResults = resultsJson.map((r) {
        final providerMap = Map<String, dynamic>.from(r);
        return DnsProviderResult(
          provider: providerMap['provider'] as String,
          success: providerMap['success'] as bool,
          addresses: List<String>.from(providerMap['addresses'] ?? []),
          latency: providerMap['latency'] as int? ?? 0,
          message: providerMap['message'] as String? ?? '',
        );
      }).toList();
      
      return DnsResult(
        host: response['host'] as String,
        type: response['type'] as String? ?? type,
        success: response['success'] as bool,
        addresses: List<String>.from(response['addresses'] ?? []),
        results: providerResults,
        message: response['message'] as String? ?? '',
      );
    } catch (e) {
      AppLogger.error('DNS lookup failed', error: e);
      return DnsResult(
        host: host,
        type: type,
        success: false,
        addresses: [],
        results: [],
        message: 'Error: $e',
      );
    }
  }

  /// 查询本机公网 IP 信息
  Future<IpInfoResult> getMyIpInfo() async {
    try {
      final result = await _channel.invokeMethod('get_my_ip_info', {});
      
      final Map<String, dynamic> response = Map<String, dynamic>.from(result);
      final List<dynamic> resultsJson = response['results'] ?? [];
      
      final providerResults = resultsJson.map((r) {
        final providerMap = Map<String, dynamic>.from(r);
        return IpProviderResult(
          provider: providerMap['provider'] as String,
          success: providerMap['success'] as bool,
          ip: providerMap['ip'] as String? ?? '',
          country: providerMap['country'] as String? ?? '',
          region: providerMap['region'] as String? ?? '',
          city: providerMap['city'] as String? ?? '',
          isp: providerMap['isp'] as String? ?? '',
          org: providerMap['org'] as String? ?? '',
          latency: providerMap['latency'] as int? ?? 0,
          message: providerMap['message'] as String? ?? '',
        );
      }).toList();
      
      return IpInfoResult(
        success: response['success'] as bool,
        results: providerResults,
        message: response['message'] as String? ?? '',
      );
    } catch (e) {
      AppLogger.error('Get IP info failed', error: e);
      return IpInfoResult(
        success: false,
        results: [],
        message: 'Error: $e',
      );
    }
  }
}

/// HTTP 204 单个路由结果
class Http204RouteResult {
  final String name;
  final String url;
  final bool success;
  final int statusCode;
  final int latency; // 毫秒
  final String message;

  const Http204RouteResult({
    required this.name,
    required this.url,
    required this.success,
    required this.statusCode,
    required this.latency,
    required this.message,
  });
}

/// HTTP 204 连通性检测结果
class Http204CheckResult {
  final bool success;
  final int successCount;
  final int totalCount;
  final List<Http204RouteResult> results;
  final String message;

  const Http204CheckResult({
    required this.success,
    required this.successCount,
    required this.totalCount,
    required this.results,
    required this.message,
  });
}

/// DNS 单个提供商结果
class DnsProviderResult {
  final String provider;
  final bool success;
  final List<String> addresses;
  final int latency; // 毫秒
  final String message;

  const DnsProviderResult({
    required this.provider,
    required this.success,
    required this.addresses,
    required this.latency,
    required this.message,
  });
}

/// DNS 查询结果
class DnsResult {
  final String host;
  final String type;
  final bool success;
  final List<String> addresses;
  final List<DnsProviderResult> results;
  final String message;

  const DnsResult({
    required this.host,
    required this.type,
    required this.success,
    required this.addresses,
    required this.results,
    required this.message,
  });
}

/// IP 信息提供商结果
class IpProviderResult {
  final String provider;
  final bool success;
  final String ip;
  final String country;
  final String region;
  final String city;
  final String isp;
  final String org;
  final int latency;
  final String message;

  const IpProviderResult({
    required this.provider,
    required this.success,
    required this.ip,
    required this.country,
    required this.region,
    required this.city,
    required this.isp,
    required this.org,
    required this.latency,
    required this.message,
  });
}

/// IP 信息查询结果
class IpInfoResult {
  final bool success;
  final List<IpProviderResult> results;
  final String message;

  const IpInfoResult({
    required this.success,
    required this.results,
    required this.message,
  });
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

/// HTTP 响应类
class HttpResponse {
  final int statusCode;
  final Map<String, String> headers;
  final String body;

  const HttpResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
  });
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
