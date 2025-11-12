import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:etohos/l10n/l10n_extensions.dart';
import 'package:etohos/methods.dart';
import 'package:etohos/privacy_config.dart';

class ManualScreen extends StatelessWidget {
  const ManualScreen({super.key});

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
              child: const Icon(Icons.info, size: 20),
            ),
            const SizedBox(width: 12),
            Text(t('about')),
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
                      Icons.vpn_key,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'EasyTier OHOS',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t('manual_subtitle'),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 核心特性
            _buildFeatureCard(
              context,
              icon: Icons.account_tree,
              title: t('decentralization'),
              description: t('decentralization_desc'),
              color: Colors.blue,
            ),
            
            _buildFeatureCard(
              context,
              icon: Icons.lock,
              title: t('security'),
              description: t('security_desc'),
              color: Colors.green,
            ),
            
            _buildFeatureCard(
              context,
              icon: Icons.speed,
              title: t('high_performance'),
              description: t('high_performance_desc'),
              color: Colors.orange,
            ),
            
            _buildFeatureCard(
              context,
              icon: Icons.cloud_off,
              title: t('no_public_ip'),
              description: t('no_public_ip_desc'),
              color: Colors.purple,
            ),
            
            _buildFeatureCard(
              context,
              icon: Icons.router,
              title: t('nat_traversal'),
              description: t('nat_traversal_desc'),
              color: Colors.teal,
            ),
            
            _buildFeatureCard(
              context,
              icon: Icons.network_check,
              title: t('subnet'),
              description: t('subnet_desc'),
              color: Colors.indigo,
            ),
            
            _buildFeatureCard(
              context,
              icon: Icons.route,
              title: t('intelligent_routing'),
              description: t('intelligent_routing_desc'),
              color: Colors.red,
            ),
            
            _buildFeatureCard(
              context,
              icon: Icons.network_wifi,
              title: t('tcp_support'),
              description: t('tcp_support_desc'),
              color: Colors.cyan,
            ),
            
            _buildFeatureCard(
              context,
              icon: Icons.swap_horiz,
              title: t('high_availability'),
              description: t('high_availability_desc'),
              color: Colors.amber,
            ),
            
            _buildFeatureCard(
              context,
              icon: Icons.dns,
              title: t('ipv6_support'),
              description: t('ipv6_support_desc'),
              color: Colors.deepPurple,
            ),

            const SizedBox(height: 24),

            // 网络日志说明
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.list_alt,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t('network_logs'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t('network_logs_desc'),
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                      label: t('website'),
                      url: t('website_url'),
                    ),
                    const SizedBox(height: 8),
                    _buildLinkButton(
                      context,
                      icon: Icons.help_outline,
                      label: t('config_guide'),
                      url: t('config_guide_url'),
                    ),
                    // 隐私政策链接（仅在 flag 为 true 时显示）
                    if (enablePrivacyPolicy) ...[
                      const SizedBox(height: 8),
                      _buildLinkButton(
                        context,
                        icon: Icons.privacy_tip,
                        label: t('privacy_policy'),
                        url: privacyPolicyUrl,
                      ),
                    ],
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

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
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
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
              ),
            ),
            const Spacer(),
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

