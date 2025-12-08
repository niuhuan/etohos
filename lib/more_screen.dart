import 'package:flutter/material.dart';
import 'package:etohos/l10n/l10n_extensions.dart';
import 'package:etohos/manual_screen.dart';
import 'package:etohos/guide_screen.dart';
import 'package:etohos/log_viewer.dart';
import 'package:etohos/settings_screen.dart';
import 'package:etohos/app_data.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('tab_more')),
      ),
      body: ListView(
        children: [
          // 事件
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(t('events')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LogViewer(),
                ),
              );
            },
          ),
          const Divider(),
          // 指南
          ListTile(
            leading: const Icon(Icons.school),
            title: Text(t('guide')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GuideScreen(),
                ),
              );
            },
          ),
          const Divider(),
          // 关于
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(t('about')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ManualScreen(),
                ),
              );
            },
          ),
          const Divider(),
          // 设置
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(t('settings')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(source: AppData.settings),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
