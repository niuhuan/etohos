import 'dart:io';
import 'package:etohos/settings.dart';
import 'package:etohos/l10n/l10n_extensions.dart';
import 'package:etohos/l10n/locale_provider.dart';
import 'package:etohos/l10n/theme_provider.dart';
import 'package:etohos/methods.dart';
import 'package:etohos/utils/text_field_utils.dart';
import 'package:etohos/privacy_config.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class SettingsScreen extends StatefulWidget {
  final Settings? source;

  const SettingsScreen({super.key, this.source});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<String> _dnsList = [];
  String _selectedLanguage = 'auto';
  String _selectedTheme = 'system';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _refreshSettingsFromDisk();
  }

  void _initializeControllers() {
    final settings = widget.source;
    
    // Initialize DNS list
    _dnsList = settings?.dnsList ?? [];
    
    // Initialize language and theme
    _selectedLanguage = localeSignal.value?.languageCode ?? 'zh';
    // 不在这里初始化主题，等待从磁盘加载
    _selectedTheme = 'system';
  }

  Future<void> _refreshSettingsFromDisk() async {
    final settings = await methods.loadSettings();
    if (!mounted) return;
    setState(() {
      _dnsList = settings.dnsList;
      _selectedTheme = settings.themeMode;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveDnsSettings() async {
    final settings = Settings(
      dnsList: _dnsList,
      themeMode: _selectedTheme,
    );
    await methods.saveSettings(settings);
  }

  void _addDns() async {
    final result = await _showEditDnsDialog(null, -1);
    if (result != null && result.isNotEmpty) {
      setState(() {
        _dnsList.add(result);
      });
      await _saveDnsSettings();
    }
  }

  void _editDns(int index) async {
    final result = await _showEditDnsDialog(_dnsList[index], index);
    if (result != null) {
      if (result.isEmpty) {
        // 删除
        setState(() {
          _dnsList.removeAt(index);
        });
      } else {
        // 更新
        setState(() {
          _dnsList[index] = result;
        });
      }
      await _saveDnsSettings();
    }
  }

  Future<String?> _showEditDnsDialog(String? initialValue, int index) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(index == -1 ? t('add_dns') : t('dns_servers')),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: t('dns_servers'),
              hintText: t('dns_hint'),
              border: const OutlineInputBorder(),
            ),
            enableInteractiveSelection: TextFieldConfig.enableInteractiveSelection,
            textCapitalization: TextFieldConfig.textCapitalization,
            contextMenuBuilder: TextFieldConfig.contextMenuBuilder,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return t('dns_server_required');
              }
              if (!_isValidIpAddress(value.trim())) {
                return t('valid_ip_required');
              }
              return null;
            },
          ),
        ),
        actions: [
          if (index != -1)
            TextButton(
              onPressed: () => Navigator.of(context).pop(''),
              child: Text(
                t('delete'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(t('cancel')),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            child: Text(t('save')),
          ),
        ],
      ),
    );
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

  String _getLanguageName(String lang) {
    switch (lang) {
      case 'zh':
        return t('language_zh');
      case 'en':
      default:
        return t('language_en');
    }
  }

  String _getThemeName(String theme) {
    if (theme == 'system') {
      // 如果是跟随系统，显示当前实际使用的主题
      final brightness = Theme.of(context).brightness;
      return '${t('theme_system')} (${brightness == Brightness.dark ? t('theme_dark') : t('theme_light')})';
    }
    
    switch (theme) {
      case 'light':
        return t('theme_light');
      case 'dark':
        return t('theme_dark');
      default:
        return t('theme_system');
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('language_settings')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('zh', t('language_zh')),
            _buildLanguageOption('en', t('language_en')),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('theme_settings')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('system', t('theme_system'), Icons.brightness_auto),
            _buildThemeOption('light', t('theme_light'), Icons.light_mode),
            _buildThemeOption('dark', t('theme_dark'), Icons.dark_mode),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String value, String label) {
    final isSelected = _selectedLanguage == value;
    return ListTile(
      leading: Radio<String>(
        value: value,
        groupValue: _selectedLanguage,
        onChanged: (val) async {
          setState(() {
            _selectedLanguage = val!;
          });
          Navigator.of(context).pop();
          await methods.setAppLanguage(_selectedLanguage);
          await initializeLocale(_selectedLanguage);
        },
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () async {
        setState(() {
          _selectedLanguage = value;
        });
        Navigator.of(context).pop();
        // 自动保存
        await methods.setAppLanguage(_selectedLanguage);
        await initializeLocale(_selectedLanguage);
      },
    );
  }

  Widget _buildThemeOption(String value, String label, IconData icon) {
    final isSelected = _selectedTheme == value;
    return ListTile(
      leading: Radio<String>(
        value: value,
        groupValue: _selectedTheme,
        onChanged: (val) async {
          setState(() {
            _selectedTheme = val!;
          });
          Navigator.of(context).pop();
          
          // 自动保存
          await setThemeMode(_selectedTheme);
        },
      ),
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      onTap: () async {
        setState(() {
          _selectedTheme = value;
        });
        Navigator.of(context).pop();
        
        // 自动保存
        await setThemeMode(_selectedTheme);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) => _build(context));
  }

  Widget _build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
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
              child: const Icon(Icons.settings, size: 20),
            ),
            const SizedBox(width: 12),
            Text(t('settings_title')),
          ],
        ),
        // 移除渐变色，使用主题定义的backgroundColor
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance Section
              Text(
                t('appearance'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Language Settings
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.language,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        t('language'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(_getLanguageName(_selectedLanguage)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showLanguageDialog(),
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.palette,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        t('theme'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(_getThemeName(_selectedTheme)),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showThemeDialog(),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // DNS List section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t('dns_servers'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _addDns,
                    icon: const Icon(Icons.add),
                    tooltip: t('add_dns_server'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t('configure_dns'),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              
              // DNS list
              if (_dnsList.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      t('no_dns'),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                )
              else
                ...List.generate(_dnsList.length, (index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: Icon(Icons.dns, color: colorScheme.primary),
                      title: Text(_dnsList[index]),
                      subtitle: Text(t('dns_server_number').replaceAll('{number}', '${index + 1}')),
                      trailing: Icon(Icons.edit, color: colorScheme.primary),
                      onTap: () => _editDns(index),
                    ),
                  );
                }),
              
              const SizedBox(height: 24),
              
              // Info card
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50.withAlpha(0x30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade200.withOpacity(0.5),
                    width: 1,
                  ),
                ),
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
                            t('dns_info_title'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t('dns_info_desc'),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 隐私政策撤销同意（仅在 flag 为 true 时显示）
              if (enablePrivacyPolicy) ...[
                const SizedBox(height: 32),
                Text(
                  t('privacy_policy'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.privacy_tip,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    title: Text(
                      t('revoke_privacy_consent'),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(t('revoke_privacy_consent_desc')),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showRevokeConsentDialog(),
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
  }
  
  void _showRevokeConsentDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.privacy_tip, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                t('revoke_privacy_consent'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('revoke_consent_confirm'),
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  try {
                    await methods.launchUrl(privacyPolicyUrl);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${t('failed_to_open_url')}: $e')),
                      );
                    }
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.link, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      t('privacy_policy'),
                      style: TextStyle(
                        color: colorScheme.primary,
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.open_in_new, size: 14, color: colorScheme.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // 清除同意状态（删除文件）
              final dataDir = await methods.dataDir();
              final acceptedFile = File('$dataDir/$privacyPolicyAcceptedFileName');
              if (await acceptedFile.exists()) {
                await acceptedFile.delete();
              }
              // 退出应用
              await methods.exitApp();
            },
            child: Text(
              t('revoke_and_exit'),
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
