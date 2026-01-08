import 'dart:io';
import 'package:etohos/methods.dart';
import 'package:etohos/app_data.dart';
import 'package:etohos/themes.dart';
import 'package:etohos/l10n/app_localizations.dart';
import 'package:etohos/l10n/locale_provider.dart';
import 'package:etohos/l10n/theme_provider.dart';
import 'package:etohos/privacy_config.dart';
import 'package:etohos/privacy_dialog.dart';
import 'package:etohos/main_screen.dart';
import 'package:etohos/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:signals/signals_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 允许所有方向的旋转
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the locale and theme signals
    final locale = localeSignal.watch(context);
    final themeMode = themeModeSignal.watch(context);

    return MaterialApp(
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const InitScreen(),
    );
  }
}

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  var state = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    try {
      
      // Get app language and initialize locale
      final appLanguage = await methods.getAppLanguage();
      await initializeLocale(appLanguage);

      // Initialize theme
      await initializeTheme();

      // Get device type
      AppData.deviceType = await methods.getDeviceType();

      AppLogger.debug('enablePrivacyPolicy: ${AppData.deviceType}');
      
      // 检查隐私政策同意状态（仅在 flag 为 true 时）
      if (enablePrivacyPolicy) {
        final dataDir = await methods.dataDir();
        final acceptedFile = File('$dataDir/$privacyPolicyAcceptedFileName');
        final hasAccepted = await acceptedFile.exists();
        
        if (!hasAccepted) {
          
          // 显示隐私政策对话框
          final accepted = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => const PrivacyPolicyDialog(),
          );
          
          if (accepted != true) {
            // 用户不同意，退出应用
            await methods.exitApp();
            return;
          }
          
          // 保存同意状态（创建空文件）
          await acceptedFile.create(recursive: true);
        }
      }

      // Initialize VPN
      await methods.prepareVpn();

      // Load configs and settings
      AppData.configs = await methods.loadConfigs();
      AppData.settings = await methods.loadSettings();

      // final state = await methods.connectState();
      // if (state.isConnected) {
      //   AppData.connected = true;
      //   for (var cfg in AppData.configs) {
      //     if (cfg.instanceName == state.runningInst) {
      //       AppData.selectedConfig = cfg;
      //       break;
      //     }
      //   }
      // }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          state = 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      var _ = localeSignal.value;
      return Scaffold(
        body: Center(
          child: state == 0
              ? const CircularProgressIndicator()
              : const Text("Error preparing VPN"),
        ),
      );
    });
  }
}
