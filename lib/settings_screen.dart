import 'package:etohos/settings.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final Settings? source;

  const SettingsScreen({super.key, this.source});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> _dnsControllers = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final settings = widget.source;
    
    // Initialize DNS controllers based on current settings
    if (settings?.dnsList != null && settings!.dnsList.isNotEmpty) {
      _dnsControllers = settings.dnsList.map((dns) => TextEditingController(text: dns)).toList();
    } else {
      // If no settings provided, start with empty list
      _dnsControllers = [TextEditingController()];
    }
  }

  @override
  void dispose() {
    for (var controller in _dnsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addDns() {
    setState(() {
      _dnsControllers.add(TextEditingController());
    });
  }

  void _removeDns(int index) {
    if (_dnsControllers.length > 1) {
      setState(() {
        _dnsControllers[index].dispose();
        _dnsControllers.removeAt(index);
      });
    }
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      final dnsList = _dnsControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();
      
      final settings = Settings(
        dnsList: dnsList,
      );
      
      Navigator.of(context).pop(settings);
    }
  }

  bool _isValidIpAddress(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return false;
    
    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [
          TextButton(
            onPressed: _saveSettings,
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
              // DNS List section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "DNS Servers",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _addDns,
                    icon: const Icon(Icons.add),
                    tooltip: "Add DNS Server",
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Configure DNS servers for network resolution",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              
              // DNS list
              ...List.generate(_dnsControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _dnsControllers[index],
                          decoration: InputDecoration(
                            labelText: "DNS Server ${index + 1}",
                            hintText: "e.g., 8.8.8.8",
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.dns),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "DNS server address is required";
                            }
                            if (!_isValidIpAddress(value.trim())) {
                              return "Please enter a valid IP address";
                            }
                            return null;
                          },
                        ),
                      ),
                      if (_dnsControllers.length > 1)
                        IconButton(
                          onPressed: () => _removeDns(index),
                          icon: const Icon(Icons.remove_circle_outline),
                          tooltip: "Remove DNS Server",
                        ),
                    ],
                  ),
                );
              }),
              
              const SizedBox(height: 24),
              
              // Info card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            "DNS Information",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "• DNS servers are used to resolve domain names to IP addresses\n"
                        "• Common public DNS servers include Google (8.8.8.8) and Cloudflare (1.1.1.1)\n"
                        "• You can add multiple DNS servers for redundancy",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Save Settings",
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
