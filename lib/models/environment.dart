/// 环境变量模型
class Environment {
  final String id;
  final String name;
  final Map<String, String> variables;
  final bool isDefault;

  const Environment({
    required this.id,
    required this.name,
    required this.variables,
    this.isDefault = false,
  });

  Environment copyWith({
    String? id,
    String? name,
    Map<String, String>? variables,
    bool? isDefault,
  }) {
    return Environment(
      id: id ?? this.id,
      name: name ?? this.name,
      variables: variables ?? this.variables,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'variables': variables,
      'isDefault': isDefault,
    };
  }

  factory Environment.fromJson(Map<String, dynamic> json) {
    return Environment(
      id: json['id'] as String,
      name: json['name'] as String,
      variables: Map<String, String>.from(json['variables'] as Map),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  /// 替换字符串中的变量 {{variable}}
  String replaceVariables(String text) {
    String result = text;
    variables.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value);
      result = result.replaceAll('{{{$key}}}', value); // 支持 {{{variable}}}
    });
    return result;
  }
}

