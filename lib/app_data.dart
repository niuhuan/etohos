import 'package:etohos/et_config.dart';
import 'package:etohos/settings.dart';
import 'package:signals/signals.dart';

// Static data cache class
class AppData {
  // 使用 Signal 使配置列表响应式
  static final configsSignal = signal<List<EtConfig>>([]);
  
  // 兼容旧代码的getter/setter
  static List<EtConfig> get configs => configsSignal.value;
  static set configs(List<EtConfig> value) => configsSignal.value = value;
  
  static Settings settings =
      const Settings(dnsList: defaultDnsList);
  static EtConfig? selectedConfig;
  static bool connected = false;
  static String deviceType = "other"; // Default to phone, initialized in InitScreen
}
