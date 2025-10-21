import 'package:etohos/et_config.dart';
import 'package:etohos/settings.dart';

import 'methods.dart';

// Static data cache class
class AppData {
  static List<EtConfig> configs = [];
  static Settings settings =
      const Settings(dnsList: defaultDnsList);
  static EtConfig? selectedConfig;
  static bool connected = false;
}
