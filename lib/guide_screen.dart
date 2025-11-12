import 'package:flutter/material.dart';
import 'package:etohos/l10n/l10n_extensions.dart';
import 'package:etohos/methods.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(Icons.school, size: 20),
            ),
            const SizedBox(width: 12),
            Text(t('guide')),
          ],
        ),
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 标题卡片
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.settings,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t('configuration_guide'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t('configuration_guide_subtitle'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

             // VPN 和组网知识
            _buildSectionHeader(context, t('vpn_and_networking_knowledge'), Icons.lightbulb_outline),
            const SizedBox(height: 12),
            
            _buildConfigItem(
              context,
              title: t('what_is_vpn'),
              description: t('what_is_vpn_desc'),
              icon: Icons.vpn_key,
              color: Colors.blue,
            ),
            
            _buildConfigItem(
              context,
              title: t('what_is_networking'),
              description: t('what_is_networking_desc'),
              icon: Icons.devices,
              color: Colors.green,
            ),
            
            _buildConfigItem(
              context,
              title: t('how_vpn_works'),
              description: t('how_vpn_works_desc'),
              icon: Icons.settings_ethernet,
              color: Colors.orange,
            ),
            
            _buildConfigItem(
              context,
              title: t('networking_benefits'),
              description: t('networking_benefits_desc'),
              icon: Icons.star,
              color: Colors.purple,
            ),
            
            _buildConfigItem(
              context,
              title: t('vpn_security'),
              description: t('vpn_security_desc'),
              icon: Icons.lock,
              color: Colors.red,
            ),
            
            _buildConfigItem(
              context,
              title: t('decentralized_networking'),
              description: t('decentralized_networking_desc'),
              icon: Icons.account_tree,
              color: Colors.teal,
            ),
            
            _buildConfigItem(
              context,
              title: t('what_is_ipv6'),
              description: t('what_is_ipv6_desc'),
              icon: Icons.dns,
              color: Colors.indigo,
            ),
            
            _buildConfigItem(
              context,
              title: t('ipv6_benefits'),
              description: t('ipv6_benefits_desc'),
              icon: Icons.trending_up,
              color: Colors.deepPurple,
            ),
            
            _buildConfigItem(
              context,
              title: t('what_is_dhcp'),
              description: t('what_is_dhcp_desc'),
              icon: Icons.router,
              color: Colors.cyan,
            ),
            
            _buildConfigItem(
              context,
              title: t('dhcp_benefits'),
              description: t('dhcp_benefits_desc'),
              icon: Icons.auto_awesome,
              color: Colors.lightGreen,
            ),

            const SizedBox(height: 24),

            // 基本设置
            _buildSectionHeader(context, t('basic_settings'), Icons.info_outline),
            const SizedBox(height: 12),
            
            _buildConfigItem(
              context,
              title: t('instance_name'),
              description: t('instance_name_guide_desc'),
              icon: Icons.label,
              color: Colors.blue,
            ),
            
            _buildConfigItem(
              context,
              title: t('hostname'),
              description: t('hostname_guide_desc'),
              icon: Icons.computer,
              color: Colors.green,
            ),
            
            _buildConfigItem(
              context,
              title: t('network_name'),
              description: t('network_name_guide_desc'),
              icon: Icons.network_check,
              color: Colors.orange,
            ),
            
            _buildConfigItem(
              context,
              title: t('network_secret'),
              description: t('network_secret_guide_desc'),
              icon: Icons.lock,
              color: Colors.red,
            ),
            
            _buildConfigItem(
              context,
              title: t('ipv4_address'),
              description: t('ipv4_guide_desc'),
              icon: Icons.dns,
              color: Colors.purple,
            ),
            
            _buildConfigItem(
              context,
              title: t('dhcp'),
              description: t('dhcp_guide_desc'),
              icon: Icons.router,
              color: Colors.teal,
            ),
            
            _buildConfigItem(
              context,
              title: t('peers'),
              description: t('peers_guide_desc'),
              icon: Icons.group,
              color: Colors.indigo,
            ),

            const SizedBox(height: 24),

            // 高级设置
            _buildSectionHeader(context, t('advanced_settings'), Icons.tune),
            const SizedBox(height: 12),
            
            _buildConfigItem(
              context,
              title: t('enable_kcp_proxy'),
              description: t('enable_kcp_proxy_guide_desc'),
              icon: Icons.speed,
              color: Colors.cyan,
            ),
            
            _buildConfigItem(
              context,
              title: t('disable_kcp_input'),
              description: t('disable_kcp_input_guide_desc'),
              icon: Icons.block,
              color: Colors.amber,
            ),
            
            _buildConfigItem(
              context,
              title: t('enable_quic_proxy'),
              description: t('enable_quic_proxy_guide_desc'),
              icon: Icons.flash_on,
              color: Colors.deepOrange,
            ),
            
            _buildConfigItem(
              context,
              title: t('disable_quic_input'),
              description: t('disable_quic_input_guide_desc'),
              icon: Icons.block,
              color: Colors.deepPurple,
            ),
            
            _buildConfigItem(
              context,
              title: t('private_mode'),
              description: t('private_mode_guide_desc'),
              icon: Icons.security,
              color: Colors.pink,
            ),
            
            _buildConfigItem(
              context,
              title: t('latency_first'),
              description: t('latency_first_guide_desc'),
              icon: Icons.speed,
              color: Colors.lightBlue,
            ),
            
            _buildConfigItem(
              context,
              title: t('use_smoltcp'),
              description: t('use_smoltcp_guide_desc'),
              icon: Icons.memory,
              color: Colors.brown,
            ),
            
            _buildConfigItem(
              context,
              title: t('no_tun'),
              description: t('no_tun_guide_desc'),
              icon: Icons.network_check,
              color: Colors.grey,
            ),

            const SizedBox(height: 24),

            // 相关链接
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.link,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t('related_links'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLinkButton(
                      context,
                      icon: Icons.language,
                      label: t('full_configuration_docs'),
                      url: t('config_guide_url'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.5),
            colorScheme.secondaryContainer.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigItem(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String url,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: () async {
        try {
          final success = await methods.launchUrl(url);
          if (!success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t('failed_to_open_url'))),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${t('failed_to_open_url')}: $e')),
            );
          }
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.open_in_new,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

