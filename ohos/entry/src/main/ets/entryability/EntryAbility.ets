import { Any, FlutterAbility, FlutterEngine, MethodCall, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { vpnExtension } from '@kit.NetworkKit';
import { Want, WantAgent, wantAgent, AbilityConstant } from '@kit.AbilityKit';
import { collectNetworkInfos, runNetworkInstance, setTunFd, stopNetworkInstance } from 'easyiter-ohrs';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError, deviceInfo } from "@kit.BasicServicesKit";
import { promptAction } from '@kit.ArkUI';
import { JSON, util } from '@kit.ArkTS';
import { NetworkInstanceRunningInfo } from './PeerInfo';
import { resourceManager } from '@kit.LocalizationKit'
import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import { i18n } from '@kit.LocalizationKit';
import { geoLocationManager } from "@kit.LocationKit";

let vpnWant: Want = {
  deviceId: "",
  bundleName: "dev.niuhuan.etohos",
  abilityName: "VpnExtAbility",
};

let entryWant: Want = {
  bundleName: "dev.niuhuan.etohos",
  abilityName: "EntryAbility"
};

let isConnected = false;
let vpnConnection: vpnExtension.VpnConnection | undefined
let tun_fd: number = -1
let time_id: number = -1
let running_inst = ""

// Network status tracking
let networkHistory: Array<NetworkData> = []
let lastTotalRx: number = 0
let lastTotalTx: number = 0

interface NetworkData {
  timestamp: number;
  rxBytes: number;
  txBytes: number;
  ip: string;
  hostname: string;
}

export default class EntryAbility extends FlutterAbility {
  private resourceMgr: resourceManager.ResourceManager | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    super.onCreate(want, launchParam);
    // 初始化资源管理器
    this.resourceMgr = this.context.resourceManager;
    // 如果是手机则需要开启地理位置
    try {
      let value = this.context.resourceManager.getDeviceCapabilitySync();
      let deviceType = value.deviceType;
      if (resourceManager.DeviceType.DEVICE_TYPE_PC != deviceType) {
        let atManager = abilityAccessCtrl.createAtManager();
        atManager.requestPermissionsFromUser(
          this.context,
          ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION', 'ohos.permission.LOCATION_IN_BACKGROUND'])
          .then((data) => {
            hilog.info(0x0000, 'testTag', `data: ${JSON.stringify(data)}`);
          })
          .catch((err: BusinessError) => {
            hilog.error(0x0000, 'testTag', `err: ${JSON.stringify(err)}`);
          })
      }
    } catch (err) {
      hilog.error(0x0000, 'testTag', `catch err->${JSON.stringify(err)}`);
    }
  }

  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    new MethodChannel(flutterEngine.dartExecutor.getBinaryMessenger(), "methods")
      .setMethodCallHandler(this)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
  }

  async onMethodCall(call: MethodCall, result: MethodResult) {
    hilog.warn(0, 'onMethodCall', '%{public}s', call.method);
    hilog.warn(0, 'onMethodCall', '%{public}s', call.args);
    try {
      switch (call.method) {
        case 'data_dir':
          result.success(this.context.filesDir);
          break;
        case 'set_app_language':
          let language = call.args as string;
          if (language == 'zh') {
            language = "zh-Hans";
          } else if (language == 'en') {
            language = "en-US";
          }
          i18n.System.setAppPreferredLanguage(language);
          result.success("");
          break;
        case 'get_app_language':
          // 如果currentLanguage为空，返回默认中文
          let appPreferredLanguage: string = i18n.System.getAppPreferredLanguage(); // 获取应用偏好语言
          if (appPreferredLanguage.indexOf("-") > 0) {
            appPreferredLanguage = appPreferredLanguage.substring(0, appPreferredLanguage.indexOf("-"));
          }
          result.success(appPreferredLanguage || 'zh');
          break;
        case 'prepare_vpn':
          await this.prepare_vpn();
          result.success("");
          break;
        case 'connect_vpn':
          await this.connect_vpn(call.args);
          result.success("");
          break;
        case 'disconnect_vpn':
          await this.disconnect_vpn();
          result.success("");
          break;
        case 'connect_state':
          result.success({
            isConnected: isConnected,
            runningInst: running_inst,
          });
        case 'collect_network_infos':
          let json = collectNetworkInfos();
          result.success(json)
          break;
        case 'get_network_history':
          result.success(networkHistory);
          break;
        default:
          result.error("-1", `no call`, null);
          break;
      }
    } catch (e) {
      result.error("-1", `${JSON.stringify(e)}`, e);
    }
  }

  async prepare_vpn() {
    if (deviceInfo.productModel === "emulator") {
      promptAction.showToast({
        message: $r('app.string.emulator_detected'),
        duration: 2000
      });
      return;
    }
    if (vpnConnection === undefined) {
      try {
        await vpnExtension.startVpnExtensionAbility(vpnWant);
        promptAction.showToast({
          message: $r('app.string.vpn_authorized'),
          duration: 2000
        });
      } catch (e) {
        // this.showToast('vpn_not_authorized');
        // return;
      }
    }
    vpnExtension.stopVpnExtensionAbility(vpnWant);
  }

  async connect_vpn(argsAll: Map<string, Any>) {
    if (isConnected) {
      throw Error("connected");
    }
    isConnected = true;
    let settings: Map<string, Any> = argsAll.get("settings");
    let dnsList: Array<string> = settings.get("dnsList");
    let args: Map<string, Any> = argsAll.get("args");
    let optional = "";
    let ipv4: string = args.get("ipv4");
    if (ipv4) {
      optional += "\n";
      optional += `ipv4 = "${ipv4}"`
    }

    let dhcp: string = args.get("dhcp");
    if (dhcp) {
      optional += "\n";
      optional += `dhcp = true`
    }
    let enable_kcp_proxy: string = args.get("enable_kcp_proxy");
    if (enable_kcp_proxy) {
      optional += "\n";
      optional += `enable_kcp_proxy = true`
    }
    let disable_kcp_input: string = args.get("disable_kcp_input");
    if (disable_kcp_input) {
      optional += "\n";
      optional += `disable_kcp_input = true`
    }
    let enable_quic_proxy: string = args.get("enable_quic_proxy");
    if (enable_quic_proxy) {
      optional += "\n";
      optional += `enable_quic_proxy = true`
    }
    let disable_quic_input: string = args.get("disable_quic_input");
    if (disable_quic_input) {
      optional += "\n";
      optional += `disable_quic_input = true`
    }
    let private_mode: string = args.get("private_mode");
    if (private_mode) {
      optional += "\n";
      optional += `private_mode = true`
    }
    let latency_first: string = args.get("latency_first");
    if (latency_first) {
      optional += "\n";
      optional += `latency_first = true`
    }
    let use_smoltcp: string = args.get("use_smoltcp");
    if (use_smoltcp) {
      optional += "\n";
      optional += `use_smoltcp = true`
    }
    let no_tun: string = args.get("no_tun");
    if (no_tun) {
      optional += "\n";
      optional += `no_tun = true`
    }


    let peers = "";
    args.get("peers").forEach((element: string) => {
      peers += `
[[peer]]
uri = "${element}"
      `
    });
    let magic_dns = false;
    let flags = "";
    if (magic_dns) {
      flags +=
      "accept_dns = true\n";
    }
    const etConfigString = `
instance_id = "${args.get("instanceId")}"
instance_name = "${args.get("instanceName")}"
hostname = "${args.get("hostname")}"
listeners = []
rpc_portal = "0.0.0.0:0"
routes = []
${optional}
[network_identity]
network_name = "${args.get("networkName")}"
network_secret = "${args.get("networkSecret")}"
${peers}
[flags]
dev_name = "vpn-tun"
mtu = 1500
    `;
    running_inst = args.get("instanceId");
    if (runNetworkInstance(etConfigString)) {
      hilog.warn(0, 'onMethodCall', '%{public}s', "[EntryAbi] Successfully started")
    } else {
      hilog.warn(0, 'onMethodCall', '%{public}s', "[EntryAbi] Failed to start")
      isConnected = false;
      throw Error("config error");
    }

    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [entryWant],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    let agent = await wantAgent.getWantAgent(wantAgentInfo);

    let value = this.context.resourceManager.getDeviceCapabilitySync();
    let deviceType = value.deviceType;
    let bgMod: string[] = [];
    if (resourceManager.DeviceType.DEVICE_TYPE_PC == deviceType) {
      bgMod = [
        "dataTransfer",
        "taskKeeping"
      ];
    } else {
      bgMod = [
        "dataTransfer",
        "location"
      ];
    }

    if (resourceManager.DeviceType.DEVICE_TYPE_PC != deviceType) {
      try {
        let request: geoLocationManager.ContinuousLocationRequest =
          { 'interval': 5, 'locationScenario': geoLocationManager.UserActivityScenario.NAVIGATION };
        geoLocationManager.on('locationChange', request, this.mock_loc);
      } catch (e) {
        hilog.error(0x0000, 'testTag', `catch err->${e}`);
      }
    }
    backgroundTaskManager.startBackgroundRunning(this.context, bgMod, agent).then(() => {
      let needSetTun = true;
      time_id = setInterval(() => {
        hilog.warn(0, 'loop', '%{public}s', "setInterval");
        let infos = collectNetworkInfos();
        hilog.warn(0, 'loop', '%{public}s', "infos :" +
          " " + JSON.stringify(infos));
        for (let element of infos) {

          hilog.warn(0, 'loop', '%{public}s', "element : " + JSON.stringify(element));
          let json: Any = JSON.parse(element.value);
          hilog.warn(0, 'loop', '%{public}s', "json : " + JSON.stringify(json));
          if (json) {
            let infos = json as NetworkInstanceRunningInfo;
            hilog.warn(0, 'loop', '%{public}s', "infos2 : " + JSON.stringify(infos));
            // Record network status data
            this.recordNetworkStatus(infos);
            if (needSetTun && infos.my_node_info.virtual_ipv4 != null && infos.peers.length > 0) {
              needSetTun = false;
              let vpnConfig: vpnExtension.VpnConfig = {
                // Configure VPN virtual network card IP address.
                addresses: [{
                  address: {
                    address: convertAddrToIp(infos.my_node_info.virtual_ipv4.address.addr),
                    family: 1
                  },
                  prefixLength: infos.my_node_info.virtual_ipv4.network_length,
                }],
                mtu: 1500,
                blockedApplications: [
                  "dev.niuhuan.etohos"
                ],
                dnsAddresses: magic_dns ? ["100.100.100.101"] : dnsList,
              };
              let setUpTun = async () => {
                vpnConnection =
                  vpnExtension.createVpnConnection(getContext(this) as vpnExtension.VpnExtensionContext)
                let fd = await vpnConnection.create(vpnConfig);
                setTunFd(running_inst, fd);
              };
              setUpTun();
            }
          }
        }
      }, 3000);
    }).catch((e: Any) => {
      isConnected = false;
      stopNetworkInstance([running_inst]);
      hilog.error(0, 'connect_vpn', 'Connection error: %{public}s', JSON.stringify(e));
      promptAction.showToast({
        message: $r('app.string.connection_failed'),
        duration: 2000
      });
    });
  }

  async mock_loc() {
  }

  async disconnect_vpn() {
    backgroundTaskManager.stopBackgroundRunning(this.context);
    vpnConnection?.destroy();
    clearInterval(time_id);
    stopNetworkInstance([running_inst]);
    isConnected = false;
    let value = this.context.resourceManager.getDeviceCapabilitySync();
    let deviceType = value.deviceType;
    if (resourceManager.DeviceType.DEVICE_TYPE_PC != deviceType) {
      try {
         geoLocationManager.off('locationChange', this.mock_loc);
      } catch (e) {
        hilog.error(0x0000, 'testTag', `catch err->${e}`);
      }
    }
  }

  recordNetworkStatus(infos: NetworkInstanceRunningInfo) {
    try {
      // Calculate total traffic
      let totalRx = 0;
      let totalTx = 0;

      infos.peer_route_pairs.forEach((peerRoute) => {
        if (peerRoute.peer) {
          peerRoute.peer.conns.forEach((conn) => {
            totalRx += conn.stats?.rx_bytes ?? 0;
            totalTx += conn.stats?.tx_bytes ?? 0;
          });
        }
      });

      // Calculate delta (bytes per second)
      let rxDelta = totalRx - lastTotalRx;
      let txDelta = totalTx - lastTotalTx;

      // Get IP and hostname
      let ip = "";
      let hostname = infos.my_node_info.hostname ?? "";

      if (infos.my_node_info.virtual_ipv4) {
        ip = convertAddrToIp(infos.my_node_info.virtual_ipv4.address.addr);
      }

      // Only record if we have previous data (not the first record)
      if (lastTotalRx > 0 && lastTotalTx > 0) {
        let networkData: NetworkData = {
          timestamp: Date.now(),
          rxBytes: rxDelta,
          txBytes: txDelta,
          ip: ip,
          hostname: hostname
        };

        networkHistory.push(networkData);

        // Keep only last 20 records
        if (networkHistory.length > 20) {
          networkHistory.shift();
        }
      }

      // Update last totals
      lastTotalRx = totalRx;
      lastTotalTx = totalTx;

    } catch (e) {
      hilog.error(0, 'recordNetworkStatus', 'Error recording network status: %{public}s', JSON.stringify(e));
    }
  }
}

export function convertAddrToIp(addr: number): string {
  const byte1 = (addr >> 24) & 0xFF;
  const byte2 = (addr >> 16) & 0xFF;
  const byte3 = (addr >> 8) & 0xFF;
  const byte4 = addr & 0xFF;

  return `${byte1}.${byte2}.${byte3}.${byte4}`;
}
