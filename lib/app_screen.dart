import 'dart:convert';

import 'package:etohos/et_config.dart';
import 'package:etohos/edit_screen.dart';
import 'package:etohos/settings.dart';
import 'package:etohos/settings_screen.dart';
import 'package:etohos/app_data.dart';
import 'package:etohos/network_status.dart';
import 'package:etohos/log_viewer.dart';
import 'package:etohos/l10n/l10n_extensions.dart';
import 'package:etohos/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'l10n/locale_provider.dart';
import 'l10n/theme_provider.dart';
import 'methods.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  bool _isConnecting =
      AppData.connected; // Loading state for connection operations

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
        SnackBar(content: Text(t('select_config_first'))),
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
      final errorKey =
          AppData.connected ? 'failed_to_disconnect' : 'failed_to_connect';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t(errorKey)}: $e')),
      );
    } finally {
      // Clear loading state
      setState(() {
        _isConnecting = false;
      });
    }
  }

  void _switchToConfig(EtConfig newConfig) async {
    if (AppData.selectedConfig == null ||
        AppData.selectedConfig!.instanceId == newConfig.instanceId) {
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
        SnackBar(content: Text('${t('failed_to_switch_config')}: $e')),
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
        // Check if this is the first configuration being created
        final wasEmpty = AppData.configs.isEmpty;

        await methods.saveConfig(result);
        AppData.configs = await methods.loadConfigs();

        // Auto-select the first configuration
        if (wasEmpty && AppData.configs.isNotEmpty) {
          AppData.selectedConfig = AppData.configs.first;
        }

        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('config_saved_success'))),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t('failed_to_save_config')}: $e')),
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
        // Check if we're editing the currently selected config
        final wasSelectedConfig =
            AppData.selectedConfig?.instanceId == config.instanceId;

        await methods.saveConfig(result);
        AppData.configs = await methods.loadConfigs();

        // If we edited the selected config, update the selected config reference
        if (wasSelectedConfig) {
          AppData.selectedConfig = result;
        }

        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('config_updated_success'))),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t('failed_to_update_config')}: $e')),
        );
      }
    }
  }

  void _deleteConfig(EtConfig config) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('delete_configuration')),
        content: Text(t('delete_config_confirm')
            .replaceAll('{name}', config.instanceName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await methods.deleteConfig(config.instanceId);
        AppData.configs = await methods.loadConfigs();
        if (AppData.selectedConfig?.instanceId == config.instanceId) {
          AppData.selectedConfig =
              AppData.configs.isNotEmpty ? AppData.configs.first : null;
        }
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t('config_deleted_success'))),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t('failed_to_delete_config')}: $e')),
        );
      }
    }
  }

  void _shareConfig(EtConfig config) async {
    bool isSharing = false;
    
    try {
      // Convert config to JSON string
      final jsonString = jsonEncode(config.toJson());
      
      // Share to kvStore for nearby device import
      try {
        isSharing = await methods.shareConfigToKVStore(jsonString);
        if (isSharing) {
          AppLogger.info('Config shared to kvStore');
        }
      } catch (e) {
        AppLogger.error('Failed to share to kvStore', error: e);
      }
      
      // Generate QR code (returns base64)
      final qrCodeBase64 = await methods.genCode(jsonString);
      
      if (qrCodeBase64.isEmpty) {
        throw Exception('Failed to generate QR code');
      }

      // Show QR code in dialog
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.qr_code_2),
              const SizedBox(width: 8),
              Text(t('share_config')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display QR code image
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.memory(
                  base64Decode(qrCodeBase64),
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                config.instanceName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t('share_hint'),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t('close')),
            ),
          ],
        ),
      );
      
      // After dialog closes, stop sharing
      if (isSharing) {
        try {
          await methods.stopSharingConfig();
          AppLogger.info('Stopped sharing config');
        } catch (e) {
          AppLogger.error('Failed to stop sharing', error: e);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t('failed_to_generate_qr')}: $e')),
      );
      
      // Cleanup on error
      if (isSharing) {
        try {
          await methods.stopSharingConfig();
        } catch (e) {
          AppLogger.error('Failed to cleanup share', error: e);
        }
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
          SnackBar(content: Text(t('settings_saved_success'))),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t('failed_to_save_settings')}: $e')),
        );
      }
    }
  }

  Widget _buildModernConfigCard(
      BuildContext context, EtConfig config, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 配色方案
    final cardColor = isDark
        ? (isSelected
            ? colorScheme.primaryContainer
            : colorScheme.surfaceVariant)
        : (isSelected ? colorScheme.primaryContainer : colorScheme.surface);

    final borderColor = isSelected ? colorScheme.primary : Colors.transparent;
    final textColor =
        isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface;
    final subtitleColor = isSelected
        ? colorScheme.onPrimaryContainer.withOpacity(0.7)
        : colorScheme.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? colorScheme.primary.withOpacity(0.3)
                : Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: isSelected ? 12 : 8,
            offset: Offset(0, isSelected ? 4 : 2),
          ),
        ],
      ),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (AppData.connected && isSelected) {
              return;
            }

            if (AppData.connected && !isSelected) {
              _switchToConfig(config);
            } else {
              setState(() {
                AppData.selectedConfig = config;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
// 图标
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? const Color(0xFF334155)
                            : colorScheme.primary) // 暗色主题用深灰蓝
                        : (isDark
                            ? colorScheme.surface
                            : colorScheme.surfaceVariant),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (isDark
                                  ? const Color(0xFF334155).withOpacity(0.3)
                                  : colorScheme.primary.withOpacity(0.3)),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.router_outlined,
                    color: isSelected
                        ? (isDark
                            ? const Color(0xFF94A3B8)
                            : Colors.white) // 暗色主题用柔和的灰蓝
                        : colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

// 标题和hostname
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.instanceName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        config.hostname,
                        style: TextStyle(
                          fontSize: 13,
                          color: subtitleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
// 右上角：节点数量或连接状态
                    if (AppData.connected && isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              t('connected'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
// 节点数量
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? colorScheme.surface
                                  : colorScheme.surfaceVariant)
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.group_outlined,
                              size: 14,
                              color: subtitleColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${config.peers.length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: subtitleColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

// 底部：操作按钮（右对齐）
                    Row(
                      children: [
// 分享二维码按钮
                        IconButton(
                          onPressed: () => _shareConfig(config),
                          icon: Icon(
                            Icons.qr_code_2,
                            size: 20,
                            color: colorScheme.primary,
                          ),
                          tooltip: t('share_qr'),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
// 删除按钮
                        IconButton(
                          onPressed: (AppData.connected && isSelected)
                              ? null
                              : () => _deleteConfig(config),
                          icon: Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: (AppData.connected && isSelected)
                                ? subtitleColor.withOpacity(0.3)
                                : Colors.red,
                          ),
                          tooltip: (AppData.connected && isSelected)
                              ? t('cannot_delete_active')
                              : t('delete'),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
// 编辑按钮
                        IconButton(
                          onPressed: (AppData.connected && isSelected)
                              ? null
                              : () => _editConfig(config),
                          icon: Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: (AppData.connected && isSelected)
                                ? subtitleColor.withOpacity(0.3)
                                : colorScheme.primary,
                          ),
                          tooltip: (AppData.connected && isSelected)
                              ? t('cannot_edit_active')
                              : t('edit'),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) {
        // Watch locale, configs, and theme changes
        localeSignal.value;
        AppData.configsSignal.value;
        themeModeSignal.value;
        return _build(context);
      },
    );
  }

  Widget _build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.vpn_key, size: 20),
            ),
            const SizedBox(width: 12),
            Text(t('app_name')),
          ],
        ),
        // 移除渐变色，使用主题定义的backgroundColor
        actions: [
          // 日志查看按钮
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LogViewer(),
                ),
              );
            },
            icon: const Icon(Icons.list_alt),
            tooltip: t('view_logs_tooltip'),
          ),
          // 设置按钮
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
            tooltip: t('settings_tooltip'),
          ),
          // 右上角加号按钮
          IconButton(
            onPressed: _addConfig,
            icon: const Icon(Icons.add),
            tooltip: t('add_config_tooltip'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Network Status (only show when connected)
          const NetworkStatus(),

          // Configurations list
          Expanded(
            child: AppData.configs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.settings,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          t('no_configs_title'),
                          style:
                              const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t('no_configs_desc'),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: AppData.configs.length + 1,
                    itemBuilder: (context, index) {
                      if (index == AppData.configs.length) {
                        return SafeArea(child: Container(height: 100));
                      }
                      final config = AppData.configs[index];
                      final isSelected = AppData.selectedConfig?.instanceId ==
                          config.instanceId;

                      return Watch((context) => _buildModernConfigCard(
                          context, config, isSelected));
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (AppData.configs.isEmpty || _isConnecting)
            ? null
            : _toggleConnection,
        tooltip: _isConnecting
            ? t('switching_config')
            : (AppData.connected ? t('disconnect_vpn') : t('connect_vpn')),
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
