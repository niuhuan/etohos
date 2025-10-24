
class EtConfig {
  final String instanceId;
  final String instanceName;
  final String hostname;
  final String networkName;
  final String networkSecret;
  final List<String> peers;
  final String ipv4;
  final bool dhcp;
  final bool enableKcpProxy;
  final bool disableKcpInput;
  final bool enableQuicProxy;
  final bool disableQuicInput;
  final bool privateMode;
  final bool latencyFirst;
  final bool useSmoltcp;
  final bool noTun;

  const EtConfig({
    required this.instanceId,
    required this.instanceName,
    required this.hostname,
    required this.networkName,
    required this.networkSecret,
    required this.peers,
    required this.ipv4,
    this.dhcp = true,
    this.enableKcpProxy = false,
    this.disableKcpInput = false,
    this.enableQuicProxy = false,
    this.disableQuicInput = false,
    this.privateMode = false,
    this.latencyFirst = false,
    this.useSmoltcp = false,
    this.noTun = false,
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
      ipv4: (json['ipv4'] ?? '') as String,
      dhcp: (json['dhcp'] ?? true) as bool,
      enableKcpProxy: (json['enableKcpProxy'] ?? false) as bool,
      disableKcpInput: (json['disableKcpInput'] ?? false) as bool,
      enableQuicProxy: (json['enableQuicProxy'] ?? false) as bool,
      disableQuicInput: (json['disableQuicInput'] ?? false) as bool,
      privateMode: (json['privateMode'] ?? false) as bool,
      latencyFirst: (json['latencyFirst'] ?? false) as bool,
      useSmoltcp: (json['useSmoltcp'] ?? false) as bool,
      noTun: (json['noTun'] ?? false) as bool,
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
      'dhcp': dhcp,
      'enableKcpProxy': enableKcpProxy,
      'disableKcpInput': disableKcpInput,
      'enableQuicProxy': enableQuicProxy,
      'disableQuicInput': disableQuicInput,
      'privateMode': privateMode,
      'latencyFirst': latencyFirst,
      'useSmoltcp': useSmoltcp,
      'noTun': noTun,
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
    bool? dhcp,
    bool? enableKcpProxy,
    bool? disableKcpInput,
    bool? enableQuicProxy,
    bool? disableQuicInput,
    bool? privateMode,
    bool? latencyFirst,
    bool? useSmoltcp,
    bool? noTun,
  }) {
    return EtConfig(
      instanceId: instanceId ?? this.instanceId,
      instanceName: instanceName ?? this.instanceName,
      hostname: hostname ?? this.hostname,
      networkName: networkName ?? this.networkName,
      networkSecret: networkSecret ?? this.networkSecret,
      peers: peers ?? this.peers,
      ipv4: ipv4 ?? this.ipv4,
      dhcp: dhcp ?? this.dhcp,
      enableKcpProxy: enableKcpProxy ?? this.enableKcpProxy,
      disableKcpInput: disableKcpInput ?? this.disableKcpInput,
      enableQuicProxy: enableQuicProxy ?? this.enableQuicProxy,
      disableQuicInput: disableQuicInput ?? this.disableQuicInput,
      privateMode: privateMode ?? this.privateMode,
      latencyFirst: latencyFirst ?? this.latencyFirst,
      useSmoltcp: useSmoltcp ?? this.useSmoltcp,
      noTun: noTun ?? this.noTun,
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
        other.ipv4 == ipv4 &&
        other.dhcp == dhcp &&
        other.enableKcpProxy == enableKcpProxy &&
        other.disableKcpInput == disableKcpInput &&
        other.enableQuicProxy == enableQuicProxy &&
        other.disableQuicInput == disableQuicInput &&
        other.privateMode == privateMode &&
        other.latencyFirst == latencyFirst &&
        other.useSmoltcp == useSmoltcp &&
        other.noTun == noTun;
  }

  @override
  int get hashCode {
    return instanceId.hashCode ^
        instanceName.hashCode ^
        hostname.hashCode ^
        networkName.hashCode ^
        networkSecret.hashCode ^
        peers.hashCode ^
        ipv4.hashCode ^
        dhcp.hashCode ^
        enableKcpProxy.hashCode ^
        disableKcpInput.hashCode ^
        enableQuicProxy.hashCode ^
        disableQuicInput.hashCode ^
        privateMode.hashCode ^
        latencyFirst.hashCode ^
        useSmoltcp.hashCode ^
        noTun.hashCode;
  }

  @override
  String toString() {
    return 'EtConfig(instanceId: $instanceId, instanceName: $instanceName, hostname: $hostname, networkName: $networkName, networkSecret: $networkSecret, peers: $peers, ipv4: $ipv4, dhcp: $dhcp, enableKcpProxy: $enableKcpProxy, disableKcpInput: $disableKcpInput, enableQuicProxy: $enableQuicProxy, disableQuicInput: $disableQuicInput, privateMode: $privateMode, latencyFirst: $latencyFirst, useSmoltcp: $useSmoltcp, noTun: $noTun)';
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
