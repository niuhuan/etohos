import 'dart:convert';
import 'dart:io';
import 'package:etohos/models/api_collection.dart';
import 'package:etohos/methods.dart';
import 'package:etohos/utils/logger.dart';

/// API 集合存储管理
class CollectionStorage {
  static const String _fileName = 'api_collections.json';

  static Future<String> _getFilePath() async {
    final directory = await methods.dataDir();
    return '$directory/$_fileName';
  }

  /// 加载所有集合
  static Future<List<ApiCollection>> loadCollections() async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);

      if (!await file.exists()) {
        return [];
      }

      final jsonString = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(jsonString);

      return jsonList.map((json) => ApiCollection.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error loading collections', error: e);
      return [];
    }
  }

  /// 保存集合列表
  static Future<void> saveCollections(List<ApiCollection> collections) async {
    try {
      final filePath = await _getFilePath();
      final file = File(filePath);
      final jsonString = jsonEncode(collections.map((c) => c.toJson()).toList());

      await file.writeAsString(jsonString);
    } catch (e) {
      AppLogger.error('Error saving collections', error: e);
      throw Exception('Failed to save collections: $e');
    }
  }

  /// 保存单个集合
  static Future<void> saveCollection(ApiCollection collection) async {
    final collections = await loadCollections();
    
    final existingIndex = collections.indexWhere((c) => c.id == collection.id);
    
    if (existingIndex >= 0) {
      collections[existingIndex] = collection.copyWith(updatedAt: DateTime.now());
    } else {
      collections.add(collection);
    }

    await saveCollections(collections);
  }

  /// 删除集合
  static Future<void> deleteCollection(String id) async {
    final collections = await loadCollections();
    collections.removeWhere((c) => c.id == id);
    await saveCollections(collections);
  }

  /// 获取根集合（没有父集合的集合）
  static Future<List<ApiCollection>> getRootCollections() async {
    final collections = await loadCollections();
    return collections.where((c) => c.parentId == null).toList();
  }

  /// 获取子集合
  static Future<List<ApiCollection>> getChildCollections(String parentId) async {
    final collections = await loadCollections();
    return collections.where((c) => c.parentId == parentId).toList();
  }
}

