/// API 请求模型
class ApiRequest {
  final String id;
  final String name;
  final String method;
  final String url;
  final Map<String, String> headers;
  final String body;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final String? collectionId; // 所属集合ID

  const ApiRequest({
    required this.id,
    required this.name,
    required this.method,
    required this.url,
    required this.headers,
    required this.body,
    required this.createdAt,
    this.lastUsedAt,
    this.collectionId,
  });

  ApiRequest copyWith({
    String? id,
    String? name,
    String? method,
    String? url,
    Map<String, String>? headers,
    String? body,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    String? collectionId,
  }) {
    return ApiRequest(
      id: id ?? this.id,
      name: name ?? this.name,
      method: method ?? this.method,
      url: url ?? this.url,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      collectionId: collectionId ?? this.collectionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'method': method,
      'url': url,
      'headers': headers,
      'body': body,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'collectionId': collectionId,
    };
  }

  factory ApiRequest.fromJson(Map<String, dynamic> json) {
    return ApiRequest(
      id: json['id'] as String,
      name: json['name'] as String,
      method: json['method'] as String,
      url: json['url'] as String,
      headers: Map<String, String>.from(json['headers'] as Map),
      body: json['body'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUsedAt: json['lastUsedAt'] != null 
          ? DateTime.parse(json['lastUsedAt'] as String) 
          : null,
      collectionId: json['collectionId'] as String?,
    );
  }
}

/// API 测试历史记录
class ApiTestHistory {
  final String id;
  final ApiRequest request;
  final int statusCode;
  final Map<String, String> responseHeaders;
  final String responseBody;
  final DateTime timestamp;
  final int duration; // 毫秒

  const ApiTestHistory({
    required this.id,
    required this.request,
    required this.statusCode,
    required this.responseHeaders,
    required this.responseBody,
    required this.timestamp,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request': request.toJson(),
      'statusCode': statusCode,
      'responseHeaders': responseHeaders,
      'responseBody': responseBody,
      'timestamp': timestamp.toIso8601String(),
      'duration': duration,
    };
  }

  factory ApiTestHistory.fromJson(Map<String, dynamic> json) {
    return ApiTestHistory(
      id: json['id'] as String,
      request: ApiRequest.fromJson(json['request'] as Map<String, dynamic>),
      statusCode: json['statusCode'] as int,
      responseHeaders: Map<String, String>.from(json['responseHeaders'] as Map),
      responseBody: json['responseBody'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      duration: json['duration'] as int,
    );
  }
}
