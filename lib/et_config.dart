
class EtConfig {
  final String instanceId;
  final String instanceName;
  final String hostname;
  final String networkName;
  final String networkSecret;
  final List<String> peers;

  const EtConfig({
    required this.instanceId,
    required this.instanceName,
    required this.hostname,
    required this.networkName,
    required this.networkSecret,
    required this.peers,
  });

  // 从 JSON 创建对象
  factory EtConfig.fromJson(Map<String, dynamic> json) {
    return EtConfig(
      instanceId: json['instanceId'] as String,
      instanceName: json['instanceName'] as String,
      hostname: json['hostname'] as String,
      networkName: json['networkName'] as String,
      networkSecret: json['networkSecret'] as String,
      peers: List<String>.from(json['peers'] as List),
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'instanceId': instanceId,
      'instanceName': instanceName,
      'hostname': hostname,
      'networkName': networkName,
      'networkSecret': networkSecret,
      'peers': peers,
    };
  }

  // 复制对象并修改部分字段
  EtConfig copyWith({
    String? instanceId,
    String? instanceName,
    String? hostname,
    String? networkName,
    String? networkSecret,
    List<String>? peers,
  }) {
    return EtConfig(
      instanceId: instanceId ?? this.instanceId,
      instanceName: instanceName ?? this.instanceName,
      hostname: hostname ?? this.hostname,
      networkName: networkName ?? this.networkName,
      networkSecret: networkSecret ?? this.networkSecret,
      peers: peers ?? this.peers,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EtConfig &&
        other.instanceId == instanceId &&
        other.instanceName == instanceName &&
        other.hostname == hostname &&
        other.networkName == networkName &&
        other.networkSecret == networkSecret &&
        _listEquals(other.peers, peers);
  }

  @override
  int get hashCode {
    return instanceId.hashCode ^
        instanceName.hashCode ^
        hostname.hashCode ^
        networkName.hashCode ^
        networkSecret.hashCode ^
        peers.hashCode;
  }

  @override
  String toString() {
    return 'EtConfig(instanceId: $instanceId, instanceName: $instanceName, hostname: $hostname, networkName: $networkName, networkSecret: $networkSecret, peers: $peers)';
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
