import 'package:flutter/material.dart';
import 'package:etohos/privacy_config.dart';
import 'package:etohos/l10n/l10n_extensions.dart';
import 'package:etohos/app_screen.dart';
import 'package:etohos/api_test_screen.dart';
import 'package:etohos/more_screen.dart';

/// 主页面容器
/// 当 enablePrivacyPolicy 为 true 时显示底部导航栏
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AppScreen(),
    ApiTestScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // 如果不启用隐私政策，直接显示原来的 AppScreen
    if (!enablePrivacyPolicy) {
      return const AppScreen();
    }

    // 启用隐私政策时，显示底部导航栏
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.link),
            label: t('tab_connection'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.api),
            label: t('tab_api'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz),
            label: t('tab_more'),
          ),
        ],
      ),
    );
  }
}
