class Settings {
  final List<String> dnsList;

  const Settings({
    required this.dnsList,
  });

  // Create object from JSON
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      dnsList: List<String>.from(json['dnsList'] as List),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'dnsList': dnsList,
    };
  }

  // Copy object and modify some fields
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

  // Helper method: compare if two lists are equal
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
