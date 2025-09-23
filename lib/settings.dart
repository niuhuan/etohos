class Settings {
  final List<String> dnsList;

  const Settings({
    required this.dnsList,
  });

  // 从 JSON 创建对象
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      dnsList: List<String>.from(json['dnsList'] as List),
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'dnsList': dnsList,
    };
  }

  // 复制对象并修改部分字段
  Settings copyWith({
    List<String>? dnsList,
  }) {
    return Settings(
      dnsList: dnsList ?? this.dnsList,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Settings &&
        _listEquals(other.dnsList, dnsList);
  }

  @override
  int get hashCode {
    return dnsList.hashCode;
  }

  @override
  String toString() {
    return 'Settings(dnsList: $dnsList)';
  }

  // 辅助方法：比较两个列表是否相等
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
