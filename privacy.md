# 隐私政策 / Privacy Policy
版本：v1.1 | 生效日期：2025-11-10  
Version: v1.1 | Effective Date: 2025-11-10

1. 数据控制者与联系方式 / 1. Data Controller and Contact
- 当前技术支持邮箱：fandyoffice@163.com  
  Current technical support email: fandyoffice@163.com
- 若需行使隐私相关请求（访问、更正、删除、可携带性等），请联系上方隐私邮箱。  
  To exercise privacy-related requests (access, correction, deletion, portability, etc.), please contact the privacy email above.

2. 摘要（通俗说明） / 2. Summary (Plain Language)
- 本应用不会将您的个人数据发送到我们的服务器。  
  This App does not send your personal data to our servers.

3. 数据收集声明 / 3. Data Collection Statement
- 本应用不会在任何中央服务器上收集、传输或存储以下数据：  
  This App does not collect, transmit, or store the following on any central server:
    - 用户身份信息（姓名、电子邮件地址、上传到我们服务器的设备标识符等）  
      User identity information (name, email addresses, device identifiers uploaded to our servers, etc.)
    - 应用使用遥测或分析数据（除非您明确启用并另行告知）  
      Application usage telemetry or analytics (unless you explicitly enable and are separately notified)
    - 对等方之间的通信内容（我们不将其持久化到我们的服务器）  
      Communication content between peers (we do not persist it to our servers)
- 在正常运行中可能会暴露（应当披露，因为这些可能构成个人数据）的信息：  
  Information that may be exposed during normal operation (disclosed because it may constitute personal data):
    - 点对点连接期间可见的网络端点信息（IP 地址和端口）  
      Network endpoint information visible during P2P connections (IP address and port)
    - 您主动发送给其他对等方的任何数据（消息、文件等）— 我们无法控制接收方的行为  
      Any data you actively send to other peers (messages, files, etc.) — we cannot control recipient behavior
- 配置文件：  
  Configuration files:
    - 默认以数据库形式保存在您设备上，设备会对其进行权限控制，保证数据安全。  
      By default stored on your device in a database format; the device enforces permissions to help protect the data.

4. 技术实现 / 4. Technical Implementation
- 可选加密：  
  Optional encryption:
    - 算法：AES-GCM-256（符合 RFC 5116），每次加密操作使用 12 字节随机 nonce（随机数/初始化向量）。  
      Algorithm: AES-GCM-256 (RFC 5116 compatible), using a 12-byte random nonce for each encryption operation.
    - 密钥：用户在本地生成并保存密钥。本应用不会将用户密钥上传至任何服务器。  
      Keys: Users generate and store keys locally. The App does not upload user keys to any server.
    - 推荐的密钥管理：将密钥存储在操作系统的安全密钥库（例如 macOS 的 Keychain、Windows Credential Manager、Android Keystore）或硬件支持的存储中。本应用提供安全密钥存储的指引，但不强制使用特定存储方式。  
      Recommended key management: Store keys in the OS secure keystore (e.g., macOS Keychain, Windows Credential Manager, Android Keystore) or hardware-backed storage. The App provides guidance for secure key storage but does not enforce a specific method.
- 网络架构：  
  Network architecture:
    - 默认：完全点对点（P2P）直接连接。  
      Default: Fully peer-to-peer (P2P) direct connections.
    - NAT 穿透：使用 ICE 协议（基于 SDP）。根据网络状况，可能会使用 STUN 或 TURN 服务器来建立连接。若使用 TURN/中继，我们将在应用设置或文档中披露其作用与运营方。  
      NAT traversal: Uses the ICE protocol (SDP-based). Depending on network conditions, STUN or TURN servers may be used to establish connections. If TURN/relays are used, we will disclose their role and operators in the app settings or documentation.
    - 传输安全：默认情况下连接未加密，除非您启用 TLS 或端到端加密。我们强烈建议启用 TLS 或应用的端到端加密选项。  
      Transport security: Connections are unencrypted by default unless you enable TLS or end-to-end encryption. We strongly recommend enabling TLS or the App's end-to-end encryption option.
- 日志：  
  Logging:
    - 默认情况下本应用不会将日志传输到我们的服务器。本地日志可能包含网络地址和调试数据；请参阅设置中的本地日志控制选项。  
      By default the App does not transmit logs to our servers. Local logs may contain network addresses and debug data; refer to local log controls in settings.

5. 用户控制与数据生命周期 / 5. User Control and Data Lifecycle
- 加密控制：  
  Encryption control:
    - 您可以通过设置或编辑配置文件来启用或禁用配置文件加密。启用后将使用 AES-GCM-256。  
      You can enable or disable configuration file encryption via settings or by editing the configuration file. When enabled, AES-GCM-256 is used.
- 删除：  
  Deletion:
    - 您可随时在设备上删除配置文件。  
      You can delete configuration files on your device at any time.
- 保留：  
  Retention:
    - 我们不会在服务器上保留用户数据，从未上传配置文件。本地保留由用户设备上的文件决定。  
      We do not retain user data on servers and have never uploaded configuration files. Local retention is determined by the files on the user's device.
- 导出与访问：  
  Export & access:
    - 应用提供导出配置文件的选项；导出文件将遵循当前的加密设置。  
      The App provides an option to export configuration files; exported files follow the current encryption setting.

6. 安全措施与责任 / 6. Security Measures and Responsibilities
- 我们在应用中实施了安全最佳实践；但由于加密与本地存储由用户控制，最终的数据安全取决于用户的选择与设备安全（例如全盘加密、操作系统账户保护）。  
  We implement security best practices in the App; however, because encryption and local storage are controlled by users, final data security depends on user choices and device security (e.g., full-disk encryption, OS account protection).
- 用户需负责以下事项：  
  Users are responsible for:
    - 在传输或存储敏感数据时启用加密。  
      Enabling encryption when transmitting or storing sensitive data.
    - 保护加密密钥与设备存储（建议使用操作系统密钥库、全盘加密）。  
      Protecting encryption keys and device storage (recommended: use OS keystore, full-disk encryption).
    - 管理与之建立点对点会话的对等方身份。  
      Managing the identities of peers they connect with in P2P sessions.
- 我们建议在首次运行时默认启用 TLS 与应用的加密；或者在未启用时显示明确警告。  
  We recommend enabling TLS and the App's encryption by default on first run, or displaying a clear warning if not enabled.

7. 违规通报 / 7. Breach Notification
- 若我们发现影响任一我们运营的集中式服务的安全漏洞，我们将：  
  If we discover a security breach affecting any centralized service we operate, we will:
    - 在法律要求的范围内，及时通过注册联系方式或应用/网站在必要时于 72 小时内通知受影响用户。  
      Notify affected users promptly via the registered contact method or via the app/website within 72 hours when legally required.
    - 提供漏洞详情、受影响数据和应对措施。  
      Provide details of the breach, the data affected, and mitigations.

8. 第三方服务与库 / 8. Third-Party Services and Libraries
- 应用可能包含第三方开源库。默认不使用分析或遥测库。任何可能处理数据的第三方服务（例如可选的更新或崩溃报告服务）将在设置与文档中披露，并要求用户选择性同意（opt-in）。  
  The App may include third-party open-source libraries. Analytics or telemetry libraries are not used by default. Any third-party services that may process data (e.g., optional update or crash-reporting services) will be disclosed in settings and documentation and will require user opt-in.

9. 国际数据传输 / 9. International Data Transfers
- 由于应用为点对点并且我们不收集中央数据，个人数据的跨境传输主要发生在对等方之间。用户在与其他司法辖区内的对等方连接时，应自行遵守当地法律。  
  Because the App is peer-to-peer and we do not collect central data, cross-border transfers of personal data primarily occur between peers. Users should comply with local laws when connecting to peers in other jurisdictions.

10. 儿童 / 10. Children
- 本应用并非专门面向 16 岁以下儿童（或本地法律规定的其他最低年龄），但允许被使用。  
  This App is not specifically intended for children under 16 (or the minimum age required by local law), but it may be used by them.

11. 本政策的变更 / 11. Changes to This Policy
- 我们会根据需要更新本政策。政策顶部将显示生效日期，并在安装包中提供变更日志详情。  
  We will update this policy as necessary. The effective date will be shown at the top of the policy and changelog details will be provided in installation packages.
- 若发生重大变更，我们也会尝试通过应用内通知或网站向用户发出通知。  
  For material changes, we will also attempt to notify users via in-app notification or the website.

12. 联系方式 / 12. Contact
- 当前技术支持（非隐私事务）：fandyoffice@163.com  
  Current technical support (non-privacy matters): fandyoffice@163.com

13. 免责声明 / 13. Disclaimer
- 我们提供指导与可选的加密功能，但最终安全取决于设备配置和用户选择。本政策并不能免除适用法律所施加的义务。  
  We provide guidance and optional encryption features, but final security depends on device configuration and user choices. This policy does not exempt any obligations imposed by applicable law.

14. 当前APP在华为设备中获取权限的用途说明 / 14. Purpose of Permissions Requested by the App on Huawei Devices
- ohos.permission.CAMERA: 用于扫描二维码  
  ohos.permission.CAMERA: Used for scanning QR codes
- ohos.permission.INTERNET: 用于介入网络  
  ohos.permission.INTERNET: Used for network access
- ohos.permission.GET_NETWORK_INFO: 获取当前网络状态  
  ohos.permission.GET_NETWORK_INFO: To obtain the current network status
- ohos.permission.SET_NETWORK_INFO: 设置当前网络状态  
  ohos.permission.SET_NETWORK_INFO: To set the current network status
- ohos.permission.ACCESS_EXTENSIONAL_DEVICE_DRIVER | ohos.permission.DISTRIBUTED_DATASYNC: 设备发现和数据传输  
  ohos.permission.ACCESS_EXTENSIONAL_DEVICE_DRIVER | ohos.permission.DISTRIBUTED_DATASYNC: Device discovery and data transfer
- ohos.permission.KEEP_BACKGROUND_RUNNING: 后台运行  
  ohos.permission.KEEP_BACKGROUND_RUNNING: Background running
- ohos.permission.LOCATION ｜ ohos.permission.APPROXIMATELY_LOCATION ｜ ohos.permission.LOCATION_IN_BACKGROUND : 后台运行（模拟在使用定位，防止被杀掉）  
  ohos.permission.LOCATION | ohos.permission.APPROXIMATELY_LOCATION | ohos.permission.LOCATION_IN_BACKGROUND: Background running (simulates location usage to prevent the process from being killed)

变更日志 / Changelog
