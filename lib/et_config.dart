
class EtConfig {
  final String instanceId;
  final String instanceName;
  final String hostname;
  final String networkName;
  final String networkSecret;
  final List<String> peers;
  final String ipv4;

  const EtConfig({
    required this.instanceId,
    required this.instanceName,
    required this.hostname,
    required this.networkName,
    required this.networkSecret,
    required this.peers,
    required this.ipv4,
  });

  // Create object from JSON
  factory EtConfig.fromJson(Map<String, dynamic> json) {
    return EtConfig(
      instanceId: json['instanceId'] as String,
      instanceName: json['instanceName'] as String,
      hostname: json['hostname'] as String,
      networkName: json['networkName'] as String,
      networkSecret: json['networkSecret'] as String,
      peers: List<String>.from(json['peers'] as List),
      ipv4: (json['ipv4'] ?? '') as String
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'instanceId': instanceId,
      'instanceName': instanceName,
      'hostname': hostname,
      'networkName': networkName,
      'networkSecret': networkSecret,
      'peers': peers,
      'ipv4': ipv4,
    };
  }

  // Copy object and modify some fields
  EtConfig copyWith({
    String? instanceId,
    String? instanceName,
    String? hostname,
    String? networkName,
    String? networkSecret,
    List<String>? peers,
    String? ipv4,
  }) {
    return EtConfig(
      instanceId: instanceId ?? this.instanceId,
      instanceName: instanceName ?? this.instanceName,
      hostname: hostname ?? this.hostname,
      networkName: networkName ?? this.networkName,
      networkSecret: networkSecret ?? this.networkSecret,
      peers: peers ?? this.peers,
      ipv4: ipv4 ?? this.ipv4,
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
        _listEquals(other.peers, peers) &&
        other.ipv4 == ipv4
    ;
  }

  @override
  int get hashCode {
    return instanceId.hashCode ^
        instanceName.hashCode ^
        hostname.hashCode ^
        networkName.hashCode ^
        networkSecret.hashCode ^
        peers.hashCode ^
        ipv4.hashCode;
  }

  @override
  String toString() {
    return 'EtConfig(instanceId: $instanceId, instanceName: $instanceName, hostname: $hostname, networkName: $networkName, networkSecret: $networkSecret, peers: $peers, ipv4: $ipv4)';
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
