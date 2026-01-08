import 'dart:convert';
import 'package:etohos/et_config.dart';
import 'package:etohos/l10n/l10n_extensions.dart';
import 'package:etohos/methods.dart';
import 'package:etohos/utils/text_field_utils.dart';
import 'package:etohos/widgets/section_header.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
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
    // 如果是新建配置，自动获取设备名称作为主机名
    if (config == null) {
      _hostnameController = TextEditingController();
      _loadDeviceName();
    } else {
      _hostnameController = TextEditingController(text: config.hostname ?? '');
    }
    _networkNameController = TextEditingController(text: config?.networkName ?? '');
    _networkSecretController = TextEditingController(text: config?.networkSecret ?? '');
    
    // Initialize peer controllers
    if (config?.peers != null && config!.peers.isNotEmpty) {
      _peerControllers = config.peers.map((peer) => TextEditingController(text: peer)).toList();
    } else if (config == null) {
      // When creating new config, start with one empty peer input
      _peerControllers = [TextEditingController()];
    } else {
      _peerControllers = []; // Editing existing config with no peers
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

  Future<void> _loadDeviceName() async {
    try {
      final deviceName = await methods.getDeviceName();
      if (mounted && _hostnameController.text.isEmpty) {
        _hostnameController.text = deviceName;
      }
    } catch (e) {
      // 如果获取失败，保持为空，让用户手动输入
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

  void _scanQRCode() async {
    try {
      final result = await methods.scanCode();
      if (result.isEmpty) {
        return;
      }

      // Parse JSON from scanned code
      try {
        final jsonData = jsonDecode(result) as Map<String, dynamic>;
        final config = EtConfig.fromJson(jsonData);

        // Fill in the form with scanned data
        // Note: hostname, ipv4, and dhcp are device-specific and should not be imported
        setState(() {
          _instanceIdController.text = config.instanceId;
          _instanceNameController.text = config.instanceName;
          // _hostnameController.text = config.hostname; // 不导入主机名，保持设备特定值
          _networkNameController.text = config.networkName;
          _networkSecretController.text = config.networkSecret;
          
          // Update peer controllers
          for (var controller in _peerControllers) {
            controller.dispose();
          }
          _peerControllers = config.peers.map((peer) => TextEditingController(text: peer)).toList();
          if (_peerControllers.isEmpty) {
            _peerControllers = [TextEditingController()];
          }
          
          // _ipv4Controller.text = config.ipv4; // 不导入IPv4地址，保持设备特定值
          // _dhcp = config.dhcp; // 不导入DHCP设置，保持设备特定值
          _enableKcpProxy = config.enableKcpProxy;
          _disableKcpInput = config.disableKcpInput;
          _enableQuicProxy = config.enableQuicProxy;
          _disableQuicInput = config.disableQuicInput;
          _privateMode = config.privateMode;
          _latencyFirst = config.latencyFirst;
          _useSmoltcp = config.useSmoltcp;
          _noTun = config.noTun;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('scan_success'))),
        );
      } catch (e) {
        // JSON parsing or config creation failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('invalid_qr_data'))),
        );
      }
    } catch (e) {
      // Scan operation failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('scan_failed'))),
      );
    }
  }

  void _importFromNearby() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(t('searching_devices')),
              ],
            ),
          ),
        ),
      );

      // Get available devices
      final devices = await methods.getDeviceList();
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (devices.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t('no_devices_found'))),
          );
        }
        return;
      }

      // Show device selection dialog
      if (mounted) {
        _showDeviceSelectionDialog(devices);
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('failed_to_get_devices'))),
        );
      }
    }
  }

  void _showDeviceSelectionDialog(List<DeviceBasicInfo> devices) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.devices),
            const SizedBox(width: 8),
            Text(t('select_device')),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return _buildDeviceListItem(device);
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t('cancel')),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceListItem(DeviceBasicInfo device) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            device.getDeviceIcon(),
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          device.deviceName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          device.getDeviceTypeName(),
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: colorScheme.primary,
        ),
        onTap: () {
          Navigator.of(context).pop();
          _requestConfigFromDevice(device);
        },
      ),
    );
  }

  void _requestConfigFromDevice(DeviceBasicInfo device) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(t('importing_config')),
              ],
            ),
          ),
        ),
      );

      // Request configuration from the selected device
      final configJson = await methods.requestConfigFromDevice(device.deviceId);
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (configJson == null || configJson.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t('config_not_available'))),
          );
        }
        return;
      }

      // Parse and fill the form with received configuration
      try {
        final jsonData = jsonDecode(configJson) as Map<String, dynamic>;
        final config = EtConfig.fromJson(jsonData);

        // Note: hostname, ipv4, and dhcp are device-specific and should not be imported
        setState(() {
          _instanceIdController.text = config.instanceId;
          _instanceNameController.text = config.instanceName;
          // _hostnameController.text = config.hostname; // 不导入主机名，保持设备特定值
          _networkNameController.text = config.networkName;
          _networkSecretController.text = config.networkSecret;
          
          // Update peer controllers
          for (var controller in _peerControllers) {
            controller.dispose();
          }
          _peerControllers = config.peers.map((peer) => TextEditingController(text: peer)).toList();
          if (_peerControllers.isEmpty) {
            _peerControllers = [TextEditingController()];
          }
          
          // _ipv4Controller.text = config.ipv4; // 不导入IPv4地址，保持设备特定值
          // _dhcp = config.dhcp; // 不导入DHCP设置，保持设备特定值
          _enableKcpProxy = config.enableKcpProxy;
          _disableKcpInput = config.disableKcpInput;
          _enableQuicProxy = config.enableQuicProxy;
          _disableQuicInput = config.disableQuicInput;
          _privateMode = config.privateMode;
          _latencyFirst = config.latencyFirst;
          _useSmoltcp = config.useSmoltcp;
          _noTun = config.noTun;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                t('config_imported_from')
                    .replaceAll('{name}', device.deviceName),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t('invalid_config_data'))),
          );
        }
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('failed_to_import_config'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) => _build(context));
  }

  Widget _build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.source == null ? t('add_configuration') : t('edit_configuration')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _saveConfig,
              icon: const Icon(Icons.check, size: 18),
              label: Text(t('save')),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.primaryContainer.withOpacity(0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Import buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // _buildModernButton(
                  //   context,
                  //   icon: Icons.devices,
                  //   label: t('import_nearby'),
                  //   onPressed: _importFromNearby,
                  //   isPrimary: false,
                  // ),
                  const SizedBox(width: 12),
                  _buildModernButton(
                    context,
                    icon: Icons.qr_code_scanner,
                    label: t('scan_qr'),
                    onPressed: _scanQRCode,
                    isPrimary: false,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 基本信息分组
              SectionHeader(title: t('basic_info'), icon: Icons.info_outline),
              const SizedBox(height: 12),
              
              // Instance ID (read-only)
              TextFormField(
                controller: _instanceIdController,
                decoration: InputDecoration(
                  labelText: t('instance_id'),
                  hintText: t('auto_generated_uuid'),
                  border: const OutlineInputBorder(),
                ),
                readOnly: true,
                enableInteractiveSelection: TextFieldConfig.enableInteractiveSelection,
                textCapitalization: TextFieldConfig.textCapitalization,
                contextMenuBuilder: TextFieldConfig.contextMenuBuilder,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              
              // Instance Name
              TextFormField(
                controller: _instanceNameController,
                decoration: InputDecoration(
                  labelText: t('instance_name'),
                  hintText: t('enter_instance_name'),
                  border: const OutlineInputBorder(),
                ),
                enableInteractiveSelection: TextFieldConfig.enableInteractiveSelection,
                textCapitalization: TextFieldConfig.textCapitalization,
                contextMenuBuilder: TextFieldConfig.contextMenuBuilder,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return t('instance_name_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Hostname
              TextFormField(
                controller: _hostnameController,
                decoration: InputDecoration(
                  labelText: t('hostname'),
                  hintText: t('enter_hostname'),
                  border: const OutlineInputBorder(),
                ),
                enableInteractiveSelection: TextFieldConfig.enableInteractiveSelection,
                textCapitalization: TextFieldConfig.textCapitalization,
                contextMenuBuilder: TextFieldConfig.contextMenuBuilder,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return t('hostname_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Network Name
              TextFormField(
                controller: _networkNameController,
                decoration: InputDecoration(
                  labelText: t('network_name'),
                  hintText: t('enter_network_name'),
                  border: const OutlineInputBorder(),
                ),
                enableInteractiveSelection: TextFieldConfig.enableInteractiveSelection,
                textCapitalization: TextFieldConfig.textCapitalization,
                contextMenuBuilder: TextFieldConfig.contextMenuBuilder,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return t('network_name_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Network Secret
              TextFormField(
                controller: _networkSecretController,
                decoration: InputDecoration(
                  labelText: t('network_secret'),
                  hintText: t('enter_network_secret'),
                  border: const OutlineInputBorder(),
                ),
                obscureText: true,
                enableInteractiveSelection: TextFieldConfig.enableInteractiveSelection,
                textCapitalization: TextFieldConfig.textCapitalization,
                contextMenuBuilder: TextFieldConfig.contextMenuBuilder,
                // Network secret is optional, no validation needed
              ),
              const SizedBox(height: 24),
              
              // Peers section
              SectionHeader(
                title: t('peers'),
                icon: Icons.group,
                action: IconButton(
                  onPressed: _addPeer,
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: t('add_peer'),
                  color: Theme.of(context).colorScheme.primary,
                ),
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
                            labelText: t('peer_number').replaceAll('{number}', '${index + 1}'),
                            hintText: t('peer_url_hint'),
                            border: const OutlineInputBorder(),
                          ),
                          enableInteractiveSelection: TextFieldConfig.enableInteractiveSelection,
                          textCapitalization: TextFieldConfig.textCapitalization,
                          contextMenuBuilder: TextFieldConfig.contextMenuBuilder,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null; // Empty is allowed
                            }
                            if (!_isValidPeerUrl(value)) {
                              return t('invalid_peer_url');
                            }
                            return null;
                          },
                        ),
                      ),
                      // Always show remove button, peers can be empty
                        IconButton(
                          onPressed: () => _removePeer(index),
                          icon: const Icon(Icons.remove_circle_outline),
                          tooltip: t('delete'),
                        ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 24),
              // IPv4 Address
              TextFormField(
                controller: _ipv4Controller,
                decoration: InputDecoration(
                  labelText: t('ipv4_address'),
                  hintText: t('enter_ipv4_optional'),
                  border: const OutlineInputBorder(),
                ),
                enableInteractiveSelection: TextFieldConfig.enableInteractiveSelection,
                textCapitalization: TextFieldConfig.textCapitalization,
                contextMenuBuilder: TextFieldConfig.contextMenuBuilder,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null; // Empty is allowed
                  }
                  if (!_isValidIPv4(value)) {
                    return t('invalid_ipv4');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Advanced Settings section
              SectionHeader(title: t('advanced_settings'), icon: Icons.tune),
              const SizedBox(height: 8),

              // DHCP
              _buildModernSwitch(
                context,
                title: t('dhcp'),
                subtitle: t('dhcp_desc'),
                value: _dhcp,
                icon: Icons.router,
                onChanged: (value) => setState(() => _dhcp = value),
              ),
              
              // Enable KCP Proxy
              _buildModernSwitch(
                context,
                title: t('enable_kcp_proxy'),
                subtitle: t('enable_kcp_proxy_desc'),
                value: _enableKcpProxy,
                icon: Icons.speed,
                onChanged: (value) => setState(() => _enableKcpProxy = value),
              ),
              
              // Disable KCP Input
              _buildModernSwitch(
                context,
                title: t('disable_kcp_input'),
                subtitle: t('disable_kcp_input_desc'),
                value: _disableKcpInput,
                icon: Icons.block,
                onChanged: (value) => setState(() => _disableKcpInput = value),
              ),
              
              // Enable QUIC Proxy
              _buildModernSwitch(
                context,
                title: t('enable_quic_proxy'),
                subtitle: t('enable_quic_proxy_desc'),
                value: _enableQuicProxy,
                icon: Icons.flash_on,
                onChanged: (value) => setState(() => _enableQuicProxy = value),
              ),
              
              // Disable QUIC Input
              _buildModernSwitch(
                context,
                title: t('disable_quic_input'),
                subtitle: t('disable_quic_input_desc'),
                value: _disableQuicInput,
                icon: Icons.flash_off,
                onChanged: (value) => setState(() => _disableQuicInput = value),
              ),
              
              // Private Mode
              _buildModernSwitch(
                context,
                title: t('private_mode'),
                subtitle: t('private_mode_desc'),
                value: _privateMode,
                icon: Icons.lock,
                onChanged: (value) => setState(() => _privateMode = value),
              ),
              
              // Latency First
              _buildModernSwitch(
                context,
                title: t('latency_first'),
                subtitle: t('latency_first_desc'),
                value: _latencyFirst,
                icon: Icons.timer,
                onChanged: (value) => setState(() => _latencyFirst = value),
              ),
              
              // Use Smoltcp
              _buildModernSwitch(
                context,
                title: t('use_smoltcp'),
                subtitle: t('use_smoltcp_desc'),
                value: _useSmoltcp,
                icon: Icons.memory,
                onChanged: (value) => setState(() => _useSmoltcp = value),
              ),
              
              // No TUN
              _buildModernSwitch(
                context,
                title: t('no_tun'),
                subtitle: t('no_tun_desc'),
                value: _noTun,
                icon: Icons.network_check,
                onChanged: (value) => setState(() => _noTun = value),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildModernButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isPrimary ? null : (isDark ? colorScheme.surfaceVariant : colorScheme.surface),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPrimary 
                  ? colorScheme.primary 
                  : colorScheme.outline.withOpacity(0.3),
              width: isPrimary ? 0 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isPrimary
                    ? colorScheme.primary.withOpacity(0.3)
                    : Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: isPrimary ? 8 : 4,
                offset: Offset(0, isPrimary ? 3 : 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isPrimary 
                    ? Colors.white 
                    : colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPrimary 
                      ? Colors.white 
                      : colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernSwitch(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value 
            ? colorScheme.primary.withOpacity(0.5)
            : colorScheme.outline.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          if (value)
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value 
              ? colorScheme.primary.withOpacity(0.15)
              : colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: value ? colorScheme.primary : colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
