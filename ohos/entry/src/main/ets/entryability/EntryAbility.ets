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
import { statusBarManager } from '@kit.StatusBarExtensionKit';
import { image } from '@kit.ImageKit';
import { display, window } from '@kit.ArkUI'
import { scanBarcode, scanCore, generateBarcode } from '@kit.ScanKit';
import { buffer } from '@kit.ArkTS';
import distributedDeviceManager from '@ohos.distributedDeviceManager';
import distributedKVStore from '@ohos.data.distributedKVStore';

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
  private dmClass: distributedDeviceManager.DeviceManager | null = null;
  private kvStoreManager: distributedKVStore.KVManager | null = null;
  private kvStore: distributedKVStore.DeviceKVStore | null = null;

  initDmClass(): void {
    try {
      this.dmClass = distributedDeviceManager.createDeviceManager("dev.niuhuan.etohos");
    } catch (err) {
      hilog.error(0x0000, 'testTag', 'createDeviceManager err: ' + JSON.stringify(err));
    }
  }

  async initKVStore(): Promise<void> {
    try {
      const kvManagerConfig: distributedKVStore.KVManagerConfig = {
        bundleName: 'dev.niuhuan.etohos',
        context: this.context
      };

      this.kvStoreManager = distributedKVStore.createKVManager(kvManagerConfig);
      hilog.info(0x0000, 'kvStore', 'KVManager created successfully');

      const options: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: false,
        backup: false,
        autoSync: true,
        kvStoreType: distributedKVStore.KVStoreType.DEVICE_COLLABORATION,
        securityLevel: distributedKVStore.SecurityLevel.S2
      };

      this.kvStore = await this.kvStoreManager.getKVStore<distributedKVStore.DeviceKVStore>(
        'etohos_config_store',
        options
      );

      // Add sync complete listener
      this.kvStore.on('dataChange', distributedKVStore.SubscribeType.SUBSCRIBE_TYPE_REMOTE, this.syncCallback)

      hilog.info(0x0000, 'kvStore', 'KVStore created successfully');
    } catch (err) {
      hilog.error(0x0000, 'kvStore', 'Failed to init KVStore: ' + JSON.stringify(err));
      if (err.code == 15100002) {
        await this.kvStoreManager!.deleteKVStore('dev.niuhuan.etohos', 'etohos_config_store');
      }

      const options: distributedKVStore.Options = {
        createIfMissing: true,
        encrypt: false,
        backup: false,
        autoSync: true,
        kvStoreType: distributedKVStore.KVStoreType.DEVICE_COLLABORATION,
        securityLevel: distributedKVStore.SecurityLevel.S2
      };
      this.kvStore = await this.kvStoreManager!.getKVStore<distributedKVStore.DeviceKVStore>(
        'etohos_config_store',
        options
      );
      this.kvStore.on('dataChange', distributedKVStore.SubscribeType.SUBSCRIBE_TYPE_REMOTE, this.syncCallback)
      hilog.info(0x0000, 'kvStore', 'KVStore created successfully');
    }
  }

  syncCallback(data: distributedKVStore.ChangeNotification){
    hilog.info(0x0000, 'kvStore', '收到数据同步:', data)
    data.insertEntries.forEach((e) => {
      hilog.info(0x0000, 'kvStore', `同步数据: ${data.deviceId} insertEntries => ${e.key} = ${e.value}`)
    })
    data.updateEntries.forEach((e) => {
      hilog.info(0x0000, 'kvStore', `同步数据: ${data.deviceId} updateEntries => ${e.key} = ${e.value}`)
    })
    data.deleteEntries.forEach((e) => {
      hilog.info(0x0000, 'kvStore', `同步数据: ${data.deviceId} deleteEntries => ${e.key} = ${e.value}`)
    })
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    super.onCreate(want, launchParam);
    // 初始化资源管理器
    this.resourceMgr = this.context.resourceManager;
    //
    this.initDmClass();
    this.initKVStore();
    // 如果是手机则需要开启地理位置
    let value = this.context.resourceManager.getDeviceCapabilitySync();
    let deviceType = value.deviceType;

    if (resourceManager.DeviceType.DEVICE_TYPE_PC == deviceType ||
      resourceManager.DeviceType.DEVICE_TYPE_2IN1 == deviceType) {
      this.addToStatusBar(
        this.context,
      );
    } else {
    }
    let atManager = abilityAccessCtrl.createAtManager();
    try {
      let p = atManager.requestPermissionsFromUser(
        this.context,
        ['ohos.permission.LOCATION', 'ohos.permission.APPROXIMATELY_LOCATION',
          'ohos.permission.LOCATION_IN_BACKGROUND', 'ohos.permission.DISTRIBUTED_DATASYNC'])
        .then((data) => {
          hilog.info(0x0000, 'testTag', `data: ${JSON.stringify(data)}`);
        })
        .catch((err: BusinessError) => {
          hilog.error(0x0000, 'testTag', `err: ${JSON.stringify(err)}`);
        });
    } catch (err) {
      hilog.error(0x0000, 'testTag', `catch err->${JSON.stringify(err)}`);
    }
  }

  /**
   * 可以通过自定义组件的内置方法获取Context信息
   * 具体方法：this.getUIContext().getHostContext();
   */
  async addToStatusBar(context: Context) {
    if (!context) {
      console.error('getHostContext failed');
      return;
    }

    // 获取resourceManager资源管理器
    const resourceMgr: resourceManager.ResourceManager = context.resourceManager;

    // 创建white pixelMap，需在资源rawfile文件夹中预置testWhite.png图片，图片大小为24vp * 24vp
    const whiteFileData = resourceMgr.getRawFileContentSync('white.png');
    const whiteBuffer = whiteFileData.buffer;
    const whiteImageSource = image.createImageSource(whiteBuffer);
    let whitePixelMap = await whiteImageSource.createPixelMap();

    // 创建black pixelMap，需在资源rawfile文件夹中预置testBlack.png图片，图片大小为24vp * 24vp
    const blackFileData = resourceMgr.getRawFileContentSync('black.png');
    const blackBuffer = blackFileData.buffer;
    const blackImageSource = image.createImageSource(blackBuffer);
    let blackPixelMap = await blackImageSource.createPixelMap();

    // 构建图标信息
    let icon: statusBarManager.StatusBarIcon = {
      white: whitePixelMap,
      black: blackPixelMap
    }
    // 构建左键业务弹窗信息
    let operation: statusBarManager.QuickOperation = {
      abilityName: "",
      title: "测试Demo",
      height: 300,
      // 可缺省
      moduleName: 'entry'
    };

    // 构建添加到状态栏的图标详细信息
    let item: statusBarManager.StatusBarItem = {
      icons: icon,
      quickOperation: operation,
      statusBarGroupMenu: []
    };

    try {
      statusBarManager.addToStatusBar(context, item);
    } catch (error) {
      console.error(`addToStatusBar failed. error code: ${error.code}, error message: ${error.message}`);
    }

    statusBarManager.on(
      "statusBarIconClick",
      () => {
        this.context.showAbility();
      },
    )
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    super.onWindowStageCreate(windowStage);
    console.info('onWindowStageCreate');
    let value = this.context.resourceManager.getDeviceCapabilitySync();
    let deviceType = value.deviceType;

    if (resourceManager.DeviceType.DEVICE_TYPE_PC == deviceType ||
      resourceManager.DeviceType.DEVICE_TYPE_2IN1 == deviceType) {
      const callback = () => {
        // ...
        return new Promise<boolean>((resolve, reject) => {
          // 是否关闭该窗口
          this.context.hideAbility();
          let result: boolean = true;
          resolve(result);
        });
      }
      try {
        let windowClass = windowStage.getMainWindowSync();
        windowClass.on('windowWillClose', callback);
      } catch (exception) {
        console.error(`Failed to register callback. Cause code: ${exception.code}, message: ${exception.message}`);
      }
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
        case 'scan_code':
          result.success(await this.scanCode());
          break;
        case 'gen_code':
          result.success(await this.genCode(call.args));
          break;
        case 'device_list':
          result.success(await this.deviceList());
          break;
        case 'share_config_to_kvstore':
          result.success(await this.shareConfigToKVStore(call.args));
          break;
        case 'stop_sharing_config':
          result.success(await this.stopSharingConfig());
          break;
        case 'request_config_from_device':
          result.success(await this.requestConfigFromDevice(call.args));
          break;
        case 'launch_url':
          result.success(await this.launchUrl(call.args));
          break;
        case 'get_device_type':
          result.success(this.getDeviceType());
          break;
        case 'exit_app':
          this.exitApp();
          result.success("");
          break;
        default:
          result.error("-1", `no call`, null);
          break;
      }
    } catch (e) {
      hilog.error(0x0001, 'testTag', `错误码: ${e.code}, 错误信息: ${e.message}`);
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
    if (resourceManager.DeviceType.DEVICE_TYPE_PC == deviceType ||
      resourceManager.DeviceType.DEVICE_TYPE_2IN1 == deviceType) {
      bgMod = [
        "dataTransfer",
        "taskKeeping"
      ];
    } else {
      bgMod = [
        "dataTransfer"
      ];
    }

    bgMod.push("location");
    try {
      let request: geoLocationManager.ContinuousLocationRequest =
        { 'interval': 5, 'locationScenario': geoLocationManager.UserActivityScenario.NAVIGATION };
      geoLocationManager.on('locationChange', request, this.mock_loc);
    } catch (e) {
      hilog.error(0x0000, 'testTag', `catch err->${e}`);
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
    if (resourceManager.DeviceType.DEVICE_TYPE_PC == deviceType ||
      resourceManager.DeviceType.DEVICE_TYPE_2IN1 == deviceType) {
      //
    } else {
    }
    try {
      geoLocationManager.off('locationChange', this.mock_loc);
    } catch (e) {
      hilog.error(0x0000, 'testTag', `catch err->${e}`);
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

  async scanCode() {
    let options: scanBarcode.ScanOptions =
      { scanTypes: [scanCore.ScanType.ALL], enableMultiMode: true, enableAlbum: true };
    let result: scanBarcode.ScanResult = await scanBarcode.startScanForResult(this.context, options);
    return result.originalValue;
  }

  async genCode(data: string): Promise<string> {
    let hexString = this.stringToHex(data);
    let contentBuffer: ArrayBuffer = buffer.from(hexString, 'hex').buffer; // 通过包含十六进制字符的字符串创建Buffer
    let options: generateBarcode.CreateOptions = {
      scanType: scanCore.ScanType.QR_CODE,
      height: 800,
      width: 800
    }
    let pm = await generateBarcode.createBarcode(contentBuffer, options);
    const imagePacker: image.ImagePacker = image.createImagePacker();
    let packOpts: image.PackingOption = { format: 'image/png', quality: 100 };
    let imgData = await imagePacker.packToData(pm, packOpts);
    return buffer.from(imgData).toString('base64');
  }

  stringToHex(input: string) {
    return Array.from(input).map(char =>
    char.charCodeAt(0).toString(16).padStart(2, '0')
    ).join('');
  }

  async deviceList() {
    if (this.dmClass == null) {
      return [];
    }
    return this.dmClass!.getAvailableDeviceListSync();
  }

  async shareConfigToKVStore(configJson: string): Promise<boolean> {
    try {
      if (this.kvStore == null) {
        hilog.error(0x0000, 'kvStore', 'KVStore not initialized');
        return false;
      }

      // Use fixed key "shared_config"
      await this.kvStore.put('shared_config', configJson);
      hilog.info(0x0000, 'kvStore', 'Config shared with fixed key: shared_config');

      if (this.dmClass != null) {
        try {
          let list = this.dmClass!.getAvailableDeviceListSync();
          this.kvStore.sync(
            list.map(e => e.deviceId),
            distributedKVStore.SyncMode.PUSH_PULL,
            1000,
          );
          hilog.info(0x0000, 'kvStore', 'Sync config: ' + list.map(e => `[${e.deviceName}(${e.deviceId})]`));
        } catch (error) {
          hilog.error(0x0000, 'kvStore', 'Failed to sync config: ' + JSON.stringify(error));
        }
      }

      return true;
    } catch (error) {
      hilog.error(0x0000, 'kvStore', 'Failed to share config: ' + JSON.stringify(error));
      return false;
    }
  }

  async stopSharingConfig(): Promise<boolean> {
    try {
      if (this.kvStore == null) {
        hilog.error(0x0000, 'kvStore', 'KVStore not initialized');
        return false;
      }

      // Delete the shared config with fixed key
      await this.kvStore.delete('shared_config');
      hilog.info(0x0000, 'kvStore', 'Stopped sharing config');

      return true;
    } catch (error) {
      hilog.error(0x0000, 'kvStore', 'Failed to stop sharing: ' + JSON.stringify(error));
      return false;
    }
  }

  async requestConfigFromDevice(deviceId: string): Promise<string | null> {
    if (this.kvStore == null) {
      hilog.error(0x0000, 'kvStore', 'KVStore not initialized');
      return null;
    }

    hilog.info(0x0000, 'kvStore', 'Syncing from device: %{public}s', deviceId);

    // Sync only from the specific device
    await this.kvStore.sync([deviceId], distributedKVStore.SyncMode.PULL_ONLY, 1000);

    let es = await this.kvStore.getEntries("shared");
    es.forEach((e)=> {
      hilog.info(0x0000, 'kvStore', `${e.key} ====> ${e.value}`);
    });

    // Get config from kvStore using fixed key
    // let configValue = await this.kvStore.get(deviceId, 'shared_config');
    let configValue = "";

    if (configValue) {
      let configJson = configValue as string;
      hilog.info(0x0000, 'kvStore', 'Config retrieved successfully from device %{public}s', deviceId);
      return configJson;
    } else {
      hilog.warn(0x0000, 'kvStore', 'No shared config found on device %{public}s', deviceId);
      return null;
    }

  }

  async launchUrl(url: string): Promise<boolean> {
    try {
      await this.context.startAbility({
        action: 'ohos.want.action.viewData',
        entities: ['entity.system.browsable'],
        uri: url,
      });
      hilog.info(0x0000, 'launchUrl', 'Launched URL: %{public}s', url);
      return true;
    } catch (error) {
      hilog.error(0x0000, 'launchUrl', 'Failed to launch URL: ' + JSON.stringify(error));
      return false;
    }
  }

  getDeviceType(): string {
    try {
      let value = this.context.resourceManager.getDeviceCapabilitySync();
      let deviceType = value.deviceType;
      
      // DEVICE_TYPE_PHONE = 0x00
      // DEVICE_TYPE_TABLET = 0x11
      if (resourceManager.DeviceType.DEVICE_TYPE_TABLET == deviceType) {
        return 'tablet';
      }
      if (resourceManager.DeviceType.DEVICE_TYPE_PHONE == deviceType) {
        return 'phone';
      }
      return 'other';
    } catch (error) {
      hilog.error(0x0000, 'getDeviceType', 'Failed to get device type: ' + JSON.stringify(error));
      return 'phone'; // Default to phone
    }
  }

  exitApp(): void {
    try {
      this.context.terminateSelf();
      hilog.info(0x0000, 'exitApp', 'Application terminated');
    } catch (error) {
      hilog.error(0x0000, 'exitApp', 'Failed to exit app: ' + JSON.stringify(error));
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
