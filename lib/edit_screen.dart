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
           trimmedUrl.startsWith('ws://') ||
           trimmedUrl.startsWith('wss://');
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
                              return "Must start with tcp://, udp://, ws://, or wss://";
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
