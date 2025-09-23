import 'package:etohos/et_config.dart';
import 'package:etohos/settings.dart';

import 'methods.dart';

// 静态数据缓存类
class AppData {
  static List<EtConfig> configs = [];
  static Settings settings =
      const Settings(dnsList: defaultDnsList);
  static EtConfig? selectedConfig;
  static bool connected = false;
}
