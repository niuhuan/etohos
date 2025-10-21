import 'package:etohos/methods.dart';
import 'package:etohos/app_data.dart';
import 'package:etohos/themes.dart';
import 'package:flutter/material.dart';

import 'app_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      darkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
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
      // Initialize VPN
      await methods.prepareVpn();
      
      // Load configs and settings
      AppData.configs = await methods.loadConfigs();
      AppData.settings = await methods.loadSettings();

      final state = await methods.connectState();
      if (state.isConnected) {
        AppData.connected = true;
        for (var cfg in AppData.configs) {
          if (cfg.instanceName == state.runningInst) {
            AppData.selectedConfig = cfg;
            break;
          }
        }
      }
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AppScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        state = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: state == 0
            ? const CircularProgressIndicator()
            : const Text("Error preparing VPN"),
      ),
    );
  }
}
