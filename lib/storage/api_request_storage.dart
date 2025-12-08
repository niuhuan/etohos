import 'dart:convert';
import 'dart:io';
import 'package:etohos/models/api_request.dart';
import 'package:etohos/methods.dart';
import 'package:etohos/utils/logger.dart';

/// API 请求存储管理
class ApiRequestStorage {
  static const String _requestsFileName = 'api_requests.json';
  static const String _historyFileName = 'api_test_history.json';

  /// 获取请求文件路径
  static Future<String> _getRequestsFilePath() async {
    final directory = await methods.dataDir();
    return '$directory/$_requestsFileName';
  }

  /// 获取历史文件路径
  static Future<String> _getHistoryFilePath() async {
    final directory = await methods.dataDir();
    return '$directory/$_historyFileName';
  }

  /// 加载所有保存的请求
  static Future<List<ApiRequest>> loadRequests() async {
    try {
      final filePath = await _getRequestsFilePath();
      final file = File(filePath);

      if (!await file.exists()) {
        return [];
      }

      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);

      return jsonList.map((json) => ApiRequest.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error loading API requests', error: e);
      return [];
    }
  }

  /// 保存请求列表
  static Future<void> saveRequests(List<ApiRequest> requests) async {
    try {
      final filePath = await _getRequestsFilePath();
      final file = File(filePath);
      final jsonString = jsonEncode(requests.map((r) => r.toJson()).toList());

      await file.writeAsString(jsonString);
    } catch (e) {
      AppLogger.error('Error saving API requests', error: e);
      throw Exception('Failed to save API requests: $e');
    }
  }

  /// 保存单个请求
  static Future<void> saveRequest(ApiRequest request) async {
    final requests = await loadRequests();
    
    // 检查是否已存在
    final existingIndex = requests.indexWhere((r) => r.id == request.id);
    
    if (existingIndex >= 0) {
      requests[existingIndex] = request;
    } else {
      requests.add(request);
    }

    await saveRequests(requests);
  }

  /// 删除请求
  static Future<void> deleteRequest(String id) async {
    final requests = await loadRequests();
    requests.removeWhere((r) => r.id == id);
    await saveRequests(requests);
  }

  /// 加载测试历史
  static Future<List<ApiTestHistory>> loadHistory() async {
    try {
      final filePath = await _getHistoryFilePath();
      final file = File(filePath);

      if (!await file.exists()) {
        return [];
      }

      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);

      return jsonList.map((json) => ApiTestHistory.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error loading API test history', error: e);
      return [];
    }
  }

  /// 保存测试历史
  static Future<void> saveHistory(List<ApiTestHistory> history) async {
    try {
      final filePath = await _getHistoryFilePath();
      final file = File(filePath);
      
      // 只保留最近100条历史记录
      final limitedHistory = history.length > 100 
          ? history.sublist(history.length - 100) 
          : history;
      
      final jsonString = jsonEncode(limitedHistory.map((h) => h.toJson()).toList());

      await file.writeAsString(jsonString);
    } catch (e) {
      AppLogger.error('Error saving API test history', error: e);
      throw Exception('Failed to save API test history: $e');
    }
  }

  /// 添加历史记录
  static Future<void> addHistory(ApiTestHistory history) async {
    final historyList = await loadHistory();
    historyList.add(history);
    await saveHistory(historyList);
  }

  /// 清除历史记录
  static Future<void> clearHistory() async {
    await saveHistory([]);
  }
}
