import 'package:etohos/et_config.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class EditScreen extends StatefulWidget {
  final EtConfig? source;

  const EditScreen({super.key, this.source});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _instanceIdController;
  late TextEditingController _instanceNameController;
  late TextEditingController _hostnameController;
  late TextEditingController _networkNameController;
  late TextEditingController _networkSecretController;
  List<TextEditingController> _peerControllers = [];
  late TextEditingController _ipv4Controller;
  bool _dhcp = false;
  bool _enableKcpProxy = false;
  bool _disableKcpInput = false;
  bool _enableQuicProxy = false;
  bool _disableQuicInput = false;
  bool _privateMode = false;
  bool _latencyFirst = false;
  bool _useSmoltcp = false;
  bool _noTun = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final config = widget.source;
    final uuid = const Uuid();
    
    // Generate random UUID if no config provided
    final instanceId = config?.instanceId ?? uuid.v4();
    
    _instanceIdController = TextEditingController(text: instanceId);
    _instanceNameController = TextEditingController(text: config?.instanceName ?? '');
    _hostnameController = TextEditingController(text: config?.hostname ?? '');
    _networkNameController = TextEditingController(text: config?.networkName ?? '');
    _networkSecretController = TextEditingController(text: config?.networkSecret ?? '');
    
    // Initialize peer controllers
    if (config?.peers != null && config!.peers.isNotEmpty) {
      _peerControllers = config.peers.map((peer) => TextEditingController(text: peer)).toList();
    } else {
      _peerControllers = []; // Start with empty list, peers can be empty
    }
    _ipv4Controller = TextEditingController(text: config?.ipv4 ?? '');
    _dhcp = config?.dhcp ?? true;
    _enableKcpProxy = config?.enableKcpProxy ?? false;
    _disableKcpInput = config?.disableKcpInput ?? false;
    _enableQuicProxy = config?.enableQuicProxy ?? false;
    _disableQuicInput = config?.disableQuicInput ?? false;
    _privateMode = config?.privateMode ?? false;
    _latencyFirst = config?.latencyFirst ?? false;
    _useSmoltcp = config?.useSmoltcp ?? false;
    _noTun = config?.noTun ?? false;
  }

  @override
  void dispose() {
    _instanceIdController.dispose();
    _instanceNameController.dispose();
    _hostnameController.dispose();
    _networkNameController.dispose();
    _networkSecretController.dispose();
    for (var controller in _peerControllers) {
      controller.dispose();
    }
    _ipv4Controller.dispose();
    super.dispose();
  }

  void _addPeer() {
    setState(() {
      _peerControllers.add(TextEditingController());
    });
  }

  void _removePeer(int index) {
    setState(() {
      _peerControllers[index].dispose();
      _peerControllers.removeAt(index);
    });
  }

  bool _isValidPeerUrl(String url) {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) return true; // Empty is allowed
    return trimmedUrl.startsWith('tcp://') ||
           trimmedUrl.startsWith('udp://') ||
           trimmedUrl.startsWith('wg://') ||
           trimmedUrl.startsWith('ws://') ||
           trimmedUrl.startsWith('wss://');
  }

  bool _isValidIPv4(String ip) {
    final trimmedIp = ip.trim();
    if (trimmedIp.isEmpty) return true; // Empty is allowed
    
    // IPv4 regex pattern
    final ipv4Pattern = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    );
    
    return ipv4Pattern.hasMatch(trimmedIp);
  }

  void _saveConfig() {
    if (_formKey.currentState!.validate()) {
      final peers = _peerControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      
      final config = EtConfig(
        instanceId: _instanceIdController.text.trim(),
        instanceName: _instanceNameController.text.trim(),
        hostname: _hostnameController.text.trim(),
        networkName: _networkNameController.text.trim(),
        networkSecret: _networkSecretController.text.trim(),
        peers: peers,
        ipv4: _ipv4Controller.text.trim(),
        dhcp: _dhcp,
        enableKcpProxy: _enableKcpProxy,
        disableKcpInput: _disableKcpInput,
        enableQuicProxy: _enableQuicProxy,
        disableQuicInput: _disableQuicInput,
        privateMode: _privateMode,
        latencyFirst: _latencyFirst,
        useSmoltcp: _useSmoltcp,
        noTun: _noTun,
      );
      
      Navigator.of(context).pop(config);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.source == null ? "Add Configuration" : "Edit Configuration"),
        actions: [
          TextButton(
            onPressed: _saveConfig,
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instance ID (read-only)
              TextFormField(
                controller: _instanceIdController,
                decoration: const InputDecoration(
                  labelText: "Instance ID (UUID)",
                  hintText: "Auto-generated UUID",
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              
              // Instance Name
              TextFormField(
                controller: _instanceNameController,
                decoration: const InputDecoration(
                  labelText: "Instance Name",
                  hintText: "Enter instance name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Instance name is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Hostname
              TextFormField(
                controller: _hostnameController,
                decoration: const InputDecoration(
                  labelText: "Hostname",
                  hintText: "Enter hostname",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Hostname is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Network Name
              TextFormField(
                controller: _networkNameController,
                decoration: const InputDecoration(
                  labelText: "Network Name",
                  hintText: "Enter network name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Network name is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Network Secret
              TextFormField(
                controller: _networkSecretController,
                decoration: const InputDecoration(
                  labelText: "Network Secret",
                  hintText: "Enter network secret",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                // Network secret is optional, no validation needed
              ),
              const SizedBox(height: 24),
              
              // Peers section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Peers",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _addPeer,
                    icon: const Icon(Icons.add),
                    tooltip: "Add Peer",
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Peer list
              ...List.generate(_peerControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _peerControllers[index],
                          decoration: InputDecoration(
                            labelText: "Peer ${index + 1}",
                            hintText: "Enter peer address",
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null; // Empty is allowed
                            }
                            if (!_isValidPeerUrl(value)) {
                              return "Must start with tcp://, udp://, wg://, ws://, or wss://";
                            }
                            return null;
                          },
                        ),
                      ),
                      // Always show remove button, peers can be empty
                        IconButton(
                          onPressed: () => _removePeer(index),
                          icon: const Icon(Icons.remove_circle_outline),
                          tooltip: "Remove Peer",
                        ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),
              // IPv4 Address
              TextFormField(
                controller: _ipv4Controller,
                decoration: const InputDecoration(
                  labelText: "IPv4 Address",
                  hintText: "Enter IPv4 address (optional)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null; // Empty is allowed
                  }
                  if (!_isValidIPv4(value)) {
                    return "Please enter a valid IPv4 address (e.g., 192.168.1.1)";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Advanced Settings section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Advanced Settings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // DHCP
              SwitchListTile(
                title: const Text("DHCP"),
                subtitle: const Text("Enable DHCP for automatic IP assignment"),
                value: _dhcp,
                onChanged: (value) {
                  setState(() {
                    _dhcp = value;
                  });
                },
              ),
              
              // Enable KCP Proxy
              SwitchListTile(
                title: const Text("Enable KCP Proxy"),
                subtitle: const Text("Use KCP protocol for better performance"),
                value: _enableKcpProxy,
                onChanged: (value) {
                  setState(() {
                    _enableKcpProxy = value;
                  });
                },
              ),
              
              // Disable KCP Input
              SwitchListTile(
                title: const Text("Disable KCP Input"),
                subtitle: const Text("Disable KCP input processing"),
                value: _disableKcpInput,
                onChanged: (value) {
                  setState(() {
                    _disableKcpInput = value;
                  });
                },
              ),
              
              // Enable QUIC Proxy
              SwitchListTile(
                title: const Text("Enable QUIC Proxy"),
                subtitle: const Text("Use QUIC protocol for better performance"),
                value: _enableQuicProxy,
                onChanged: (value) {
                  setState(() {
                    _enableQuicProxy = value;
                  });
                },
              ),
              
              // Disable QUIC Input
              SwitchListTile(
                title: const Text("Disable QUIC Input"),
                subtitle: const Text("Disable QUIC input processing"),
                value: _disableQuicInput,
                onChanged: (value) {
                  setState(() {
                    _disableQuicInput = value;
                  });
                },
              ),
              
              // Private Mode
              SwitchListTile(
                title: const Text("Private Mode"),
                subtitle: const Text("Enable private mode for enhanced security"),
                value: _privateMode,
                onChanged: (value) {
                  setState(() {
                    _privateMode = value;
                  });
                },
              ),
              
              // Latency First
              SwitchListTile(
                title: const Text("Latency First"),
                subtitle: const Text("Prioritize low latency over throughput"),
                value: _latencyFirst,
                onChanged: (value) {
                  setState(() {
                    _latencyFirst = value;
                  });
                },
              ),
              
              // Use Smoltcp
              SwitchListTile(
                title: const Text("Use Smoltcp"),
                subtitle: const Text("Use smoltcp user-space stack"),
                value: _useSmoltcp,
                onChanged: (value) {
                  setState(() {
                    _useSmoltcp = value;
                  });
                },
              ),
              
              // No TUN
              SwitchListTile(
                title: const Text("No TUN"),
                subtitle: const Text("Disable TUN interface mode"),
                value: _noTun,
                onChanged: (value) {
                  setState(() {
                    _noTun = value;
                  });
                },
              ),
              
              const SizedBox(height: 32),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveConfig,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Save Configuration",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
