
import 'dart:convert';

import 'package:etohos/et_config.dart';
import 'package:etohos/edit_screen.dart';
import 'package:etohos/settings.dart';
import 'package:etohos/settings_screen.dart';
import 'package:etohos/app_data.dart';
import 'package:flutter/material.dart';

import 'methods.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  bool _isConnecting = false; // Loading state for connection operations

  @override
  void initState() {
    super.initState();
    // Initialize selected configuration
    if (AppData.configs.isNotEmpty && AppData.selectedConfig == null) {
      AppData.selectedConfig = AppData.configs.first;
    }
  }

  void _refreshData() {
    setState(() {
      // Trigger UI update
    });
  }

  void _toggleConnection() async {
    if (AppData.selectedConfig == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a configuration first')),
      );
      return;
    }

    // Set loading state
    setState(() {
      _isConnecting = true;
    });
    
    try {
      if (!AppData.connected) {
        // Connecting
        await methods.connectVpn({
          "args": jsonDecode(jsonEncode(AppData.selectedConfig)),
          "settings": jsonDecode(jsonEncode(AppData.settings)),
        });
        setState(() {
          AppData.connected = true;
        });
      } else {
        // Disconnecting
        await methods.disconnectVpn();
        setState(() {
          AppData.connected = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppData.connected ? 'Failed to disconnect: $e' : 'Failed to connect: $e')),
      );
    } finally {
      // Clear loading state
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _switchToConfig(EtConfig newConfig) async {
    if (AppData.selectedConfig == null || AppData.selectedConfig!.instanceId == newConfig.instanceId) {
      return; // No need to switch
    }

    // Set loading state
    setState(() {
      _isConnecting = true;
    });

    try {
      // First disconnect current connection if connected
      if (AppData.connected) {
        await methods.disconnectVpn();
        setState(() {
          AppData.connected = false;
        });
        
        // Wait 1 second before connecting to new config
        await Future.delayed(const Duration(seconds: 1));
      }

      // Switch to new config
      AppData.selectedConfig = newConfig;
      
      // Connect to new config
      await methods.connectVpn({
        "args": jsonDecode(jsonEncode(AppData.selectedConfig)),
        "settings": jsonDecode(jsonEncode(AppData.settings)),
      });
      
      setState(() {
        AppData.connected = true;
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to switch configuration: $e')),
      );
    } finally {
      // Clear loading state
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _addConfig() async {
    final result = await Navigator.of(context).push<EtConfig>(
      MaterialPageRoute(
        builder: (context) => const EditScreen(),
      ),
    );

    if (result != null) {
      try {
        await methods.saveConfig(result);
        AppData.configs = await methods.loadConfigs();
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration saved successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save configuration: $e')),
        );
      }
    }
  }

  void _editConfig(EtConfig config) async {
    final result = await Navigator.of(context).push<EtConfig>(
      MaterialPageRoute(
        builder: (context) => EditScreen(source: config),
      ),
    );

    if (result != null) {
      try {
        await methods.saveConfig(result);
        AppData.configs = await methods.loadConfigs();
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update configuration: $e')),
        );
      }
    }
  }

  void _deleteConfig(EtConfig config) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Configuration'),
        content: Text('Are you sure you want to delete "${config.instanceName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await methods.deleteConfig(config.instanceId);
        AppData.configs = await methods.loadConfigs();
        if (AppData.selectedConfig?.instanceId == config.instanceId) {
          AppData.selectedConfig = AppData.configs.isNotEmpty ? AppData.configs.first : null;
        }
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuration deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete configuration: $e')),
        );
      }
    }
  }

  void _openSettings() async {
    final result = await Navigator.of(context).push<Settings>(
      MaterialPageRoute(
        builder: (context) => SettingsScreen(source: AppData.settings),
      ),
    );

    if (result != null) {
      try {
        await methods.saveSettings(result);
        AppData.settings = result;
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save settings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Easytier App"),
        actions: [
          // 设置按钮
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
          // 右上角加号按钮
          IconButton(
            onPressed: _addConfig,
            icon: const Icon(Icons.add),
            tooltip: 'Add Configuration',
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (AppData.selectedConfig != null) ...[
                  Text(
                    'Selected: ${AppData.selectedConfig!.instanceName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppData.connected ? "Connected" : "Disconnected",
                    style: TextStyle(
                      color: AppData.connected ? Colors.green : Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Configurations list
          Expanded(
            child: AppData.configs.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.settings, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No configurations found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the + button to add a new configuration',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: AppData.configs.length,
                    itemBuilder: (context, index) {
                      final config = AppData.configs[index];
                      final isSelected = AppData.selectedConfig?.instanceId == config.instanceId;
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        elevation: isSelected ? 8 : 2,
                        color: isSelected ? Colors.blue.shade100 : Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected 
                                ? Border.all(color: Colors.blue, width: 2)
                                : null,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
                              child: Icon(
                                isSelected ? Icons.check : Icons.router,
                                color: isSelected ? Colors.white : Colors.grey.shade600,
                              ),
                            ),
                            title: Text(
                              config.instanceName,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.blue.shade800 : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              '${config.hostname} • ${config.peers.length} peers',
                              style: TextStyle(
                                color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: (AppData.connected && isSelected) ? null : () => _editConfig(config),
                                  icon: Icon(
                                    Icons.edit,
                                    color: (AppData.connected && isSelected) 
                                        ? Colors.grey.shade400 
                                        : (isSelected ? Colors.blue.shade700 : Colors.grey.shade600),
                                  ),
                                  tooltip: (AppData.connected && isSelected) ? 'Cannot edit active configuration' : 'Edit',
                                ),
                                IconButton(
                                  onPressed: (AppData.connected && isSelected) ? null : () => _deleteConfig(config),
                                  icon: Icon(
                                    Icons.delete,
                                    color: (AppData.connected && isSelected) 
                                        ? Colors.grey.shade400 
                                        : (isSelected ? Colors.red.shade600 : Colors.grey.shade600),
                                  ),
                                  tooltip: (AppData.connected && isSelected) ? 'Cannot delete active configuration' : 'Delete',
                                ),
                              ],
                            ),
                            onTap: () {
                              if (AppData.connected && isSelected) {
                                // Already using this config, do nothing
                                return;
                              }
                              
                              if (AppData.connected && !isSelected) {
                                // Switch to new config
                                _switchToConfig(config);
                              } else {
                                // Just select the config
                                setState(() {
                                  AppData.selectedConfig = config;
                                });
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (AppData.configs.isEmpty || _isConnecting) ? null : _toggleConnection,
        tooltip: _isConnecting 
            ? 'Switching configuration...'
            : (AppData.connected ? 'Disconnect VPN' : 'Connect VPN'),
        backgroundColor: _isConnecting 
            ? Colors.grey 
            : (AppData.connected ? Colors.red : Colors.green),
        foregroundColor: Colors.white,
        child: _isConnecting 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(AppData.connected ? Icons.stop : Icons.play_arrow),
      ),
    );
  }
}
