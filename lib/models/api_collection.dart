/// API 请求集合/文件夹
class ApiCollection {
  final String id;
  final String name;
  final String? parentId; // 父集合ID，用于嵌套
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ApiCollection({
    required this.id,
    required this.name,
    this.parentId,
    required this.createdAt,
    this.updatedAt,
  });

  ApiCollection copyWith({
    String? id,
    String? name,
    String? parentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ApiCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentId': parentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ApiCollection.fromJson(Map<String, dynamic> json) {
    return ApiCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      parentId: json['parentId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}

