const defaultDnsList = ['223.5.5.5', '223.6.6.6', '8.8.8.8', '8.8.4.4'];

class Settings {
  final List<String> dnsList;
  final String themeMode; // 'system', 'light', 'dark'

  const Settings({
    required this.dnsList,
    this.themeMode = 'system',
  });

  // Create object from JSON
  factory Settings.fromJson(Map<String, dynamic> json) {
    final rawDnsList = json['dnsList'];
    final dnsList = rawDnsList is List
        ? rawDnsList.map((e) => e.toString()).toList()
        : defaultDnsList;

    return Settings(
      dnsList: dnsList,
      themeMode: (json['themeMode'] ?? 'system') as String,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'dnsList': dnsList,
      'themeMode': themeMode,
    };
  }

  // Copy object and modify some fields
  Settings copyWith({
    List<String>? dnsList,
    String? language,
    String? themeMode,
  }) {
    return Settings(
      dnsList: dnsList ?? this.dnsList,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Settings &&
        _listEquals(other.dnsList, dnsList) &&
        other.themeMode == themeMode;
  }

  @override
  int get hashCode {
    return Object.hash(dnsList.hashCode, themeMode.hashCode);
  }

  @override
  String toString() {
    return 'Settings(dnsList: $dnsList, themeMode: $themeMode)';
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
