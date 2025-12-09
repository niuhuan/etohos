import 'package:flutter/material.dart';
import 'package:etohos/l10n/l10n_extensions.dart';
import 'package:etohos/tools/connectivity_test_screen.dart';
import 'package:etohos/tools/dns_lookup_screen.dart';
import 'package:etohos/tools/my_ip_screen.dart';

/// 网络工具列表页面
class NetworkToolsScreen extends StatelessWidget {
  const NetworkToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('network_tools')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildToolCard(
            context,
            icon: Icons.public,
            title: t('my_ip'),
            subtitle: t('my_ip_desc'),
            color: Colors.purple,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyIpScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildToolCard(
            context,
            icon: Icons.network_check,
            title: t('connectivity_test'),
            subtitle: t('connectivity_test_desc'),
            color: Colors.orange,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ConnectivityTestScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildToolCard(
            context,
            icon: Icons.dns,
            title: t('dns_lookup'),
            subtitle: t('dns_lookup_desc'),
            color: Colors.blue,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DnsLookupScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
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
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
