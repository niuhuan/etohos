import { Any, FlutterAbility, FlutterEngine, MethodCall, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { vpnExtension } from '@kit.NetworkKit';
import { Want, WantAgent, wantAgent } from '@kit.AbilityKit';
import { collectNetworkInfos, runNetworkInstance, setTunFd, stopNetworkInstance } from 'easyiter-ohrs';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { BusinessError, deviceInfo } from "@kit.BasicServicesKit";
import { promptAction } from '@kit.ArkUI';
import { JSON, util } from '@kit.ArkTS';
import { NetworkInstanceRunningInfo } from './PeerInfo';

let vpnWant: Want = {
  deviceId: "",
  bundleName: "dev.niuhuan.etohos",
  abilityName: "VpnExtAbility",
};

let entryWant: Want = {
  bundleName: "dev.niuhuan.etohos",
  abilityName: "EntryAbility"
};

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    new MethodChannel(flutterEngine.dartExecutor.getBinaryMessenger(), "methods")
      .setMethodCallHandler(this)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
  }

  isConnected = false;
  vpnConnection: vpnExtension.VpnConnection | undefined
  tun_fd: number = -1
  time_id: number = -1
  running_inst = ""

  async onMethodCall(call: MethodCall, result: MethodResult) {
    hilog.warn(0, 'onMethodCall', '%{public}s', call.method);
    hilog.warn(0, 'onMethodCall', '%{public}s', call.args);
    try {
      switch (call.method) {
        case 'data_dir':
          result.success(this.context.filesDir);
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
        message: `emulator`
      });
      return;
    }
    if (this.vpnConnection === undefined) {
      try {
        await vpnExtension.startVpnExtensionAbility(vpnWant);
        promptAction.showToast({
          message: `VPN已授权`
        });
      } catch (e) {
        // promptAction.showToast({
        //  message: `VPN权限未授权，将无法启动实例`
        // });
        // return;
      }
    }
    vpnExtension.stopVpnExtensionAbility(vpnWant);
  }

  async connect_vpn(argsAll: Map<string, Any>) {
    if (this.isConnected) {
      throw Error("connected");
    }
    this.isConnected = true;
    let settings: Map<string, Any> = argsAll.get("settings");
    let dnsList: Array<string> = settings.get("dnsList");
    let args: Map<string, Any> = argsAll.get("args");
    let peers = "";
    args.get("peers").forEach((element: string) => {
      peers += `
[[peer]]
uri = "${element}"
      `
    });
    const etConfigString = `
instance_id = "${args.get("instanceId")}"
instance_name = "${args.get("instanceName")}"
hostname = "${args.get("hostname")}"
dhcp = true
listeners = []
rpc_portal = "0.0.0.0:0"
routes = []
[network_identity]
network_name = "${args.get("networkName")}"
network_secret = "${args.get("networkSecret")}"
${peers}
[flags]
accept_dns = true
dev_name = "vpn-tun"
mtu = 1500
    `;
    this.running_inst = args.get("instanceId");
    if (runNetworkInstance(etConfigString)) {
      hilog.warn(0, 'onMethodCall', '%{public}s', "[EntryAbi] 成功启动")
    } else {
      hilog.warn(0, 'onMethodCall', '%{public}s', "[EntryAbi] 失败启动")
      this.isConnected = false;
      throw Error("config error");
    }

    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [entryWant],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    let agent = await wantAgent.getWantAgent(wantAgentInfo);
    backgroundTaskManager.startBackgroundRunning(this.context, ["taskKeeping"], agent).then(() => {
      let needSetTun = true;
      this.time_id = setInterval(() => {
        hilog.warn(0, 'loop', '%{public}s', "setInterval");
        let infos = collectNetworkInfos();
        hilog.warn(0, 'loop', '%{public}s', "infos : " + JSON.stringify(infos));
        for (let element of infos) {
          hilog.warn(0, 'loop', '%{public}s', "element : " + JSON.stringify(element));
          let json: Any = JSON.parse(element.value);
          hilog.warn(0, 'loop', '%{public}s', "json : " + JSON.stringify(json));
          if (json) {
            let infos = json as NetworkInstanceRunningInfo;
            hilog.warn(0, 'loop', '%{public}s', "infos2 : " + JSON.stringify(infos));
            if (needSetTun && infos.my_node_info.virtual_ipv4 != null && infos.peers.length > 0) {
              needSetTun = false;
              let vpnConfig: vpnExtension.VpnConfig = {
                // 配置VPN虚拟网卡的IP地址。
                addresses: [{
                  address: {
                    address: convertAddrToIp(infos.my_node_info.virtual_ipv4.address.addr),
                    family: 1
                  },
                  prefixLength: 24
                }],
                mtu: 1500,
                blockedApplications: [
                  "dev.niuhuan.etohos"
                ],
                dnsAddresses: dnsList,
              };
              let setUpTun = async () => {
                this.vpnConnection =
                  vpnExtension.createVpnConnection(getContext(this) as vpnExtension.VpnExtensionContext)
                let fd = await this.vpnConnection.create(vpnConfig);
                setTunFd(this.running_inst, fd);
              };
              setUpTun();
            }
          }
        }
      }, 3000);
    }).catch((e: Any) => {
      this.isConnected = false;
      stopNetworkInstance([this.running_inst]);
      promptAction.showToast({
        message: `${JSON.stringify(e)}`,
        duration: 2000
      })
    });
  }

  async disconnect_vpn() {
    backgroundTaskManager.stopBackgroundRunning(this.context);
    this.vpnConnection?.destroy();
    clearInterval(this.time_id);
    stopNetworkInstance([this.running_inst]);
    this.isConnected = false;
  }
}

export function convertAddrToIp(addr: number): string {
  const byte1 = (addr >> 24) & 0xFF;
  const byte2 = (addr >> 16) & 0xFF;
  const byte3 = (addr >> 8) & 0xFF;
  const byte4 = addr & 0xFF;

  return `${byte1}.${byte2}.${byte3}.${byte4}`;
}
