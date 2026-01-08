import 'package:flutter/material.dart';

/// 应用国际化类
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// 当前实例
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// 支持的语言
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // 英文
    Locale('zh', ''), // 中文
  ];

  /// 获取翻译文本
  String get(String key) {
    final isZh = locale.languageCode == 'zh';
    return _localizedValues[key]?[isZh ? 'zh' : 'en'] ?? key;
  }

  /// 所有文案的映射表（公开，供全局t()函数使用）
  static const Map<String, Map<String, String>> localizedStrings = _localizedValues;
  
  /// 所有文案的映射表
  static const Map<String, Map<String, String>> _localizedValues = {
    // 通用
    'app_name': {'en': 'ET', 'zh': 'ET'},
    'save': {'en': 'Save', 'zh': '保存'},
    'cancel': {'en': 'Cancel', 'zh': '取消'},
    'delete': {'en': 'Delete', 'zh': '删除'},
    'edit': {'en': 'Edit', 'zh': '编辑'},
    'add': {'en': 'Add', 'zh': '添加'},
    'settings': {'en': 'Settings', 'zh': '设置'},
    'confirm': {'en': 'Confirm', 'zh': '确认'},
    'back': {'en': 'Back', 'zh': '返回'},
    
    // 主界面
    'main_title': {'en': 'EasytierOHOS', 'zh': 'EasytierOHOS'},
    'view_logs': {'en': 'View Events', 'zh': '查看事件'},
    'add_config': {'en': 'Add Configuration', 'zh': '添加配置'},
    'connect': {'en': 'Connect', 'zh': '连接'},
    'disconnect': {'en': 'Disconnect', 'zh': '断开'},
    'connected': {'en': 'Connected', 'zh': '已连接'},
    'disconnected': {'en': 'Disconnected', 'zh': '未连接'},
    'no_configs': {'en': 'No configurations available', 'zh': '暂无配置'},
    'add_first_config': {'en': 'Tap + to add your first configuration', 'zh': '点击 + 添加第一个配置'},
    
    // 配置编辑
    'add_configuration': {'en': 'Add Configuration', 'zh': '添加配置'},
    'edit_configuration': {'en': 'Edit Configuration', 'zh': '编辑配置'},
    'basic_info': {'en': 'Basic Information', 'zh': '基本信息'},
    'instance_id': {'en': 'Instance ID (UUID)', 'zh': '实例ID (UUID)'},
    'instance_name': {'en': 'Instance Name', 'zh': '实例名称'},
    'hostname': {'en': 'Hostname', 'zh': '主机名'},
    'network_name': {'en': 'Network Name', 'zh': '网络名称'},
    'network_secret': {'en': 'Network Secret', 'zh': '网络密钥'},
    'ipv4_address': {'en': 'IPv4 Address', 'zh': 'IPv4地址'},
    'peers': {'en': 'Peer Configuration', 'zh': '节点配置'},
    'add_peer': {'en': 'Add Peer', 'zh': '添加节点'},
    'advanced_settings': {'en': 'Advanced Settings', 'zh': '高级设置'},
    
    // 高级设置项
    'dhcp': {'en': 'DHCP', 'zh': 'DHCP'},
    'dhcp_desc': {'en': 'Enable DHCP for automatic IP assignment', 'zh': '自动分配IP地址'},
    'enable_kcp_proxy': {'en': 'Enable KCP Proxy', 'zh': '启用 KCP 代理'},
    'enable_kcp_proxy_desc': {'en': 'Use KCP protocol for better performance', 'zh': '使用 KCP 协议提升性能'},
    'disable_kcp_input': {'en': 'Disable KCP Input', 'zh': '禁用 KCP 输入'},
    'disable_kcp_input_desc': {'en': 'Disable KCP input processing', 'zh': '关闭 KCP 输入处理'},
    'enable_quic_proxy': {'en': 'Enable QUIC Proxy', 'zh': '启用 QUIC 代理'},
    'enable_quic_proxy_desc': {'en': 'Use QUIC protocol', 'zh': '使用 QUIC 协议'},
    'disable_quic_input': {'en': 'Disable QUIC Input', 'zh': '禁用 QUIC 输入'},
    'disable_quic_input_desc': {'en': 'Disable QUIC input processing', 'zh': '关闭 QUIC 输入处理'},
    'private_mode': {'en': 'Private Mode', 'zh': '私密模式'},
    'private_mode_desc': {'en': 'Enable private connection mode', 'zh': '启用私密连接模式'},
    'latency_first': {'en': 'Latency First', 'zh': '延迟优先'},
    'latency_first_desc': {'en': 'Prioritize low latency paths', 'zh': '优先选择低延迟路径'},
    'use_smoltcp': {'en': 'Use Smoltcp', 'zh': '使用 Smoltcp'},
    'use_smoltcp_desc': {'en': 'Use lightweight TCP implementation', 'zh': '使用轻量级 TCP 实现'},
    'no_tun': {'en': 'No TUN', 'zh': '禁用 TUN'},
    'no_tun_desc': {'en': 'Do not create virtual network interface', 'zh': '不创建虚拟网卡'},
    
    // 验证消息
    'instance_name_required': {'en': 'Instance name is required', 'zh': '实例名称为必填项'},
    'hostname_required': {'en': 'Hostname is required', 'zh': '主机名为必填项'},
    'network_name_required': {'en': 'Network name is required', 'zh': '网络名称为必填项'},
    'invalid_ipv4': {'en': 'Please enter a valid IPv4 address', 'zh': '请输入有效的IPv4地址'},
    'invalid_peer_url': {'en': 'Invalid peer URL format', 'zh': '节点URL格式无效'},
    
    // 网络状态
    'network_status': {'en': 'Network Status', 'zh': '网络状态'},
    'ip_address': {'en': 'IP Address', 'zh': 'IP地址'},
    'rx_speed': {'en': 'RX', 'zh': 'RX'},
    'tx_speed': {'en': 'TX', 'zh': 'TX'},
    'no_network_data': {'en': 'No network data available', 'zh': '暂无网络数据'},
    'peer_info': {'en': 'Peer Information', 'zh': '节点信息'},
    'no_peers': {'en': 'No peers connected', 'zh': '暂无连接的节点'},
    'peer': {'en': 'Peer', 'zh': '节点'},
    'connections': {'en': 'Connections', 'zh': '连接'},
    'routes': {'en': 'Routes', 'zh': '路由'},
    'route_info': {'en': 'Route Information', 'zh': '路由信息'},
    'no_routes': {'en': 'No routes available', 'zh': '暂无路由'},
    'cost': {'en': 'Cost', 'zh': '成本'},
    
    // 事件查看器
    'log_viewer': {'en': 'Event Manager', 'zh': '事件管理器'},
    'clear_logs': {'en': 'Clear Events', 'zh': '清空事件'},
    'copy_logs': {'en': 'Copy Events', 'zh': '复制事件'},
    'search_logs': {'en': 'Search events...', 'zh': '搜索事件...'},
    'log_filter': {'en': 'Event Filter', 'zh': '事件过滤'},
    'statistics': {'en': 'Statistics', 'zh': '统计信息'},
    'total': {'en': 'Total', 'zh': '总计'},
    'filtered': {'en': 'Filtered', 'zh': '筛选'},
    'no_logs': {'en': 'No events available', 'zh': '暂无事件'},
    'logs_cleared': {'en': 'Events cleared successfully', 'zh': '事件已清空'},
    'logs_copied': {'en': 'Events copied to clipboard', 'zh': '事件已复制到剪贴板'},
    
    // 事件级别
    'log_level_all': {'en': 'All', 'zh': '全部'},
    'log_level_debug': {'en': 'Debug', 'zh': '调试'},
    'log_level_info': {'en': 'Info', 'zh': '信息'},
    'log_level_warning': {'en': 'Warning', 'zh': '警告'},
    'log_level_error': {'en': 'Error', 'zh': '错误'},
    'log_level_fatal': {'en': 'Fatal', 'zh': '严重'},
    
    // 设置
    'settings_title': {'en': 'Settings', 'zh': '设置'},
    'dns_settings': {'en': 'DNS Settings', 'zh': 'DNS设置'},
    'dns_servers': {'en': 'DNS Servers', 'zh': 'DNS服务器'},
    'add_dns': {'en': 'Add DNS', 'zh': '添加DNS'},
    'invalid_dns': {'en': 'Invalid DNS server address', 'zh': 'DNS服务器地址无效'},
    'language': {'en': 'Language', 'zh': '语言'},
    'language_auto': {'en': 'Auto (Follow System)', 'zh': '自动（跟随系统）'},
    'language_en': {'en': 'English', 'zh': 'English'},
    'language_zh': {'en': '中文', 'zh': '中文'},
    'theme': {'en': 'Theme', 'zh': '主题'},
    'theme_system': {'en': 'Follow System', 'zh': '跟随系统'},
    'theme_light': {'en': 'Light', 'zh': '浅色'},
    'theme_dark': {'en': 'Dark', 'zh': '深色'},
    'appearance': {'en': 'Appearance', 'zh': '外观'},
    'language_settings': {'en': 'Language Settings', 'zh': '语言设置'},
    'theme_settings': {'en': 'Theme Settings', 'zh': '主题设置'},
    
    // 提示消息
    'connecting': {'en': 'Connecting...', 'zh': '连接中...'},
    'connection_success': {'en': 'Connected successfully', 'zh': '连接成功'},
    'connection_failed': {'en': 'Connection failed', 'zh': '连接失败'},
    'disconnecting': {'en': 'Disconnecting...', 'zh': '断开中...'},
    'disconnect_success': {'en': 'Disconnected successfully', 'zh': '断开成功'},
    'config_saved': {'en': 'Configuration saved', 'zh': '配置已保存'},
    'config_deleted': {'en': 'Configuration deleted', 'zh': '配置已删除'},
    'confirm_delete': {'en': 'Confirm Delete', 'zh': '确认删除'},
    'confirm_delete_message': {'en': 'Are you sure you want to delete this configuration?', 'zh': '确定要删除此配置吗？'},
    'delete_configuration': {'en': 'Delete Configuration', 'zh': '删除配置'},
    'select_config_first': {'en': 'Please select a configuration first', 'zh': '请先选择一个配置'},
    'failed_to_disconnect': {'en': 'Failed to disconnect', 'zh': '断开连接失败'},
    'failed_to_connect': {'en': 'Failed to connect', 'zh': '连接失败'},
    'loading': {'en': 'Loading...', 'zh': '加载中...'},
    'error_preparing_vpn': {'en': 'Error preparing VPN', 'zh': 'VPN准备失败'},
    
    // 输入提示
    'enter_instance_name': {'en': 'Enter instance name', 'zh': '输入实例名称'},
    'enter_hostname': {'en': 'Enter hostname', 'zh': '输入主机名'},
    'enter_network_name': {'en': 'Enter network name', 'zh': '输入网络名称'},
    'enter_network_secret': {'en': 'Enter network secret', 'zh': '输入网络密钥'},
    'enter_ipv4_optional': {'en': 'Enter IPv4 (optional)', 'zh': '输入IPv4（可选）'},
    'auto_generated_uuid': {'en': 'Auto-generated UUID', 'zh': '自动生成的UUID'},
    'peer_url_hint': {'en': 'tcp://example.com:11010', 'zh': 'tcp://example.com:11010'},
    'optional': {'en': 'Optional', 'zh': '可选'},
    'required': {'en': 'Required', 'zh': '必填'},
    
    // DNS设置
    'dns_hint': {'en': 'e.g., 8.8.8.8', 'zh': '例如: 8.8.8.8'},
    'remove_dns': {'en': 'Remove DNS', 'zh': '移除DNS'},
    
    // 操作成功消息
    'config_saved_success': {'en': 'Configuration saved successfully', 'zh': '配置保存成功'},
    'config_updated_success': {'en': 'Configuration updated successfully', 'zh': '配置更新成功'},
    'config_deleted_success': {'en': 'Configuration deleted successfully', 'zh': '配置删除成功'},
    'settings_saved_success': {'en': 'Settings saved successfully', 'zh': '设置保存成功'},
    
    // 操作失败消息
    'failed_to_save_config': {'en': 'Failed to save configuration', 'zh': '配置保存失败'},
    'failed_to_update_config': {'en': 'Failed to update configuration', 'zh': '配置更新失败'},
    'failed_to_delete_config': {'en': 'Failed to delete configuration', 'zh': '配置删除失败'},
    'failed_to_save_settings': {'en': 'Failed to save settings', 'zh': '设置保存失败'},
    'failed_to_switch_config': {'en': 'Failed to switch configuration', 'zh': '配置切换失败'},
    
    // 确认对话框
    'delete_config_confirm': {'en': 'Are you sure you want to delete "{name}"?', 'zh': '确定要删除"{name}"吗？'},
    
    // Tooltip提示
    'cannot_edit_active': {'en': 'Cannot edit active configuration', 'zh': '无法编辑活动配置'},
    'cannot_delete_active': {'en': 'Cannot delete active configuration', 'zh': '无法删除活动配置'},
    'switching_config': {'en': 'Switching configuration...', 'zh': '正在切换配置...'},
    'disconnect_vpn': {'en': 'Disconnect VPN', 'zh': '断开VPN'},
    'connect_vpn': {'en': 'Connect VPN', 'zh': '连接VPN'},
    'peers_count': {'en': 'peers', 'zh': '个节点'},
    
    // 设置页面
    'configure_dns': {'en': 'Configure DNS servers for network resolution', 'zh': '配置用于网络解析的DNS服务器'},
    'add_dns_server': {'en': 'Add DNS Server', 'zh': '添加DNS服务器'},
    'remove_dns_server': {'en': 'Remove DNS Server', 'zh': '移除DNS服务器'},
    'dns_server_required': {'en': 'DNS server address is required', 'zh': 'DNS服务器地址为必填项'},
    'dns_server_number': {'en': 'DNS Server {number}', 'zh': 'DNS服务器 {number}'},
    'valid_ip_required': {'en': 'Please enter a valid IP address', 'zh': '请输入有效的IP地址'},
    'no_dns': {'en': 'No DNS servers configured', 'zh': '暂无DNS服务器'},
    'dns_info_title': {'en': 'DNS Information', 'zh': 'DNS信息'},
    'dns_info_desc': {'en': 'DNS servers are used to resolve domain names to IP addresses. Multiple DNS servers can be configured for redundancy.', 'zh': 'DNS服务器用于将域名解析为IP地址。可以配置多个DNS服务器以提供冗余。'},
    
    // 编辑页面提示
    'add_peer_button': {'en': 'Add Peer URL', 'zh': '添加节点URL'},
    'peer_number': {'en': 'Peer {number}', 'zh': '节点 {number}'},
    
    // app_screen主页
    'selected': {'en': 'Selected', 'zh': '已选择'},
    'no_configs_title': {'en': 'No configurations found', 'zh': '暂无配置'},
    'no_configs_desc': {'en': 'Tap the + button to add a new configuration', 'zh': '点击 + 按钮添加新配置'},
    'view_logs_tooltip': {'en': 'View Events', 'zh': '查看事件'},
    'settings_tooltip': {'en': 'Settings', 'zh': '设置'},
    'add_config_tooltip': {'en': 'Add Configuration', 'zh': '添加配置'},
    
    // 二维码功能
    'scan_qr': {'en': 'Scan QR', 'zh': '扫码'},
    'import_nearby': {'en': 'Import Nearby', 'zh': '附近设备导入'},
    'share_qr': {'en': 'Share QR Code', 'zh': '分享二维码'},
    'share_config': {'en': 'Share Configuration', 'zh': '分享配置'},
    'share_hint': {'en': 'Scan QR code or use nearby device import', 'zh': '可扫码或从附近设备导入'},
    'scan_success': {'en': 'Configuration imported successfully', 'zh': '配置导入成功'},
    'scan_failed': {'en': 'Unable to scan QR code', 'zh': '未能成功扫码'},
    'invalid_qr_data': {'en': 'Invalid QR code content', 'zh': '二维码内容无效'},
    'failed_to_generate_qr': {'en': 'Failed to generate QR code', 'zh': '生成二维码失败'},
    'feature_coming_soon': {'en': 'This feature is coming soon', 'zh': '该功能即将上线'},
    'close': {'en': 'Close', 'zh': '关闭'},
    
    // 附近设备
  'searching_devices': {'en': 'Searching for devices...', 'zh': '正在搜索设备...'},
  'no_devices_found': {'en': 'No devices found', 'zh': '未发现设备'},
  'failed_to_get_devices': {'en': 'Failed to get devices', 'zh': '获取设备列表失败'},
  'select_device': {'en': 'Select Device', 'zh': '选择设备'},
    'importing_config': {'en': 'Importing configuration...', 'zh': '正在导入配置...'},
    'config_not_available': {'en': 'Configuration not available', 'zh': '配置不可用'},
    'config_imported_from': {'en': 'Configuration imported from {name}', 'zh': '已从{name}导入配置'},
    'invalid_config_data': {'en': 'Invalid configuration data', 'zh': '配置数据无效'},
    'failed_to_import_config': {'en': 'Failed to import configuration', 'zh': '导入配置失败'},
    
    // 更多菜单
    'more': {'en': 'More', 'zh': '更多'},
    'events': {'en': 'Events', 'zh': '事件'},
    'guide': {'en': 'Guide and Knowledge', 'zh': '指南与知识'},
    'guide_and_knowledge': {'en': 'Guide and Knowledge', 'zh': '指南与知识'},
    'about': {'en': 'About', 'zh': '关于'},
    'manual_subtitle': {'en': 'A simple, secure, decentralized cross-region networking solution', 'zh': '一个简单、安全、去中心化的异地组网方案'},
    
    // 指南页面
    'configuration_guide': {'en': 'Configuration Guide', 'zh': '配置指南'},
    'configuration_guide_subtitle': {'en': 'Learn how to configure each option', 'zh': '了解每个配置选项的作用'},
    
    // VPN 和组网知识
    'vpn_and_networking_knowledge': {'en': 'VPN and Networking Knowledge', 'zh': 'VPN 与组网知识'},
    'what_is_vpn': {'en': 'What is VPN?', 'zh': '什么是 VPN？'},
    'what_is_vpn_desc': {'en': 'VPN (Virtual Private Network) is a technology that creates a secure, encrypted connection over a public network (such as the Internet). It allows users to access private networks remotely and securely, protecting data transmission from eavesdropping and tampering.', 'zh': 'VPN（虚拟专用网络）是一种在公共网络（如互联网）上创建安全、加密连接的技术。它允许用户远程、安全地访问专用网络，保护数据传输免受窃听和篡改。'},
    'what_is_networking': {'en': 'What is Networking?', 'zh': '什么是组网？'},
    'what_is_networking_desc': {'en': 'Networking refers to connecting multiple devices or networks together to form a unified network. In the context of VPN, it means creating a virtual network that connects devices in different locations, allowing them to communicate as if they were on the same local network.', 'zh': '组网是指将多个设备或网络连接在一起，形成一个统一的网络。在 VPN 的语境下，它意味着创建一个虚拟网络，连接不同位置的设备，使它们能够像在同一局域网内一样通信。'},
    'how_vpn_works': {'en': 'How VPN Works', 'zh': 'VPN 工作原理'},
    'how_vpn_works_desc': {'en': 'VPN works by creating an encrypted tunnel between your device and a VPN server. All data transmitted through this tunnel is encrypted, ensuring privacy and security. The VPN server acts as an intermediary, making your actual IP address invisible to external parties.', 'zh': 'VPN 通过在您的设备和 VPN 服务器之间创建加密隧道来工作。通过此隧道传输的所有数据都经过加密，确保隐私和安全。VPN 服务器充当中间人，使您的真实 IP 地址对外部不可见。'},
    'networking_benefits': {'en': 'Benefits of Networking', 'zh': '组网的优势'},
    'networking_benefits_desc': {'en': 'Networking allows devices in different locations to communicate securely, enables remote access to resources, supports distributed collaboration, and provides a unified network environment without physical constraints.', 'zh': '组网允许不同位置的设备安全通信，支持远程访问资源，支持分布式协作，并提供不受物理限制的统一网络环境。'},
    'vpn_security': {'en': 'VPN Security', 'zh': 'VPN 安全性'},
    'vpn_security_desc': {'en': 'VPN uses encryption protocols (such as WireGuard, OpenVPN) to protect data. It prevents man-in-the-middle attacks, data interception, and ensures that even if data is intercepted, it cannot be read without the encryption key.', 'zh': 'VPN 使用加密协议（如 WireGuard、OpenVPN）来保护数据。它可以防止中间人攻击、数据拦截，并确保即使数据被拦截，没有加密密钥也无法读取。'},
    'decentralized_networking': {'en': 'Decentralized Networking', 'zh': '去中心化组网'},
    'decentralized_networking_desc': {'en': 'Decentralized networking means that there is no central server controlling the network. Each node is equal and independent, which improves network reliability, reduces single points of failure, and enhances privacy protection.', 'zh': '去中心化组网意味着没有中央服务器控制网络。每个节点都是平等和独立的，这提高了网络可靠性，减少了单点故障，并增强了隐私保护。'},
    'what_is_ipv6': {'en': 'What is IPv6?', 'zh': '什么是 IPv6？'},
    'what_is_ipv6_desc': {'en': 'IPv6 (Internet Protocol version 6) is the latest version of the Internet Protocol, designed to replace IPv4. IPv6 uses 128-bit addresses, providing a vastly larger address space (2^128 addresses) compared to IPv4\'s 32-bit addresses. This solves the IPv4 address exhaustion problem and supports the growing number of internet-connected devices.', 'zh': 'IPv6（互联网协议第6版）是互联网协议的最新版本，旨在替代 IPv4。IPv6 使用 128 位地址，相比 IPv4 的 32 位地址提供了更大的地址空间（2^128 个地址）。这解决了 IPv4 地址耗尽的问题，并支持不断增长的互联网连接设备。'},
    'ipv6_benefits': {'en': 'IPv6 Benefits', 'zh': 'IPv6 的优势'},
    'ipv6_benefits_desc': {'en': 'IPv6 provides a much larger address space, simplified header format for better routing efficiency, built-in security features (IPsec), better support for mobile devices, and improved multicast capabilities. It is essential for the future growth of the Internet.', 'zh': 'IPv6 提供了更大的地址空间、简化的报头格式以提高路由效率、内置安全功能（IPsec）、更好的移动设备支持以及改进的多播功能。它对于互联网的未来发展至关重要。'},
    'what_is_dhcp': {'en': 'What is DHCP?', 'zh': '什么是 DHCP？'},
    'what_is_dhcp_desc': {'en': 'DHCP (Dynamic Host Configuration Protocol) is a network management protocol used to automatically assign IP addresses and other network configuration parameters to devices on a network. Instead of manually configuring each device, DHCP allows devices to automatically obtain their network settings from a DHCP server.', 'zh': 'DHCP（动态主机配置协议）是一种网络管理协议，用于自动为网络上的设备分配 IP 地址和其他网络配置参数。无需手动配置每个设备，DHCP 允许设备自动从 DHCP 服务器获取其网络设置。'},
    'dhcp_benefits': {'en': 'DHCP Benefits', 'zh': 'DHCP 的优势'},
    'dhcp_benefits_desc': {'en': 'DHCP simplifies network administration by automatically managing IP address allocation, reduces configuration errors, allows for centralized network management, supports dynamic IP address assignment, and makes it easier to add or remove devices from the network without manual configuration.', 'zh': 'DHCP 通过自动管理 IP 地址分配简化了网络管理，减少了配置错误，支持集中式网络管理，支持动态 IP 地址分配，并使添加或移除网络设备变得更加容易，无需手动配置。'},
    'basic_settings': {'en': 'Basic Settings', 'zh': '基本设置'},
    'full_configuration_docs': {'en': 'Full Configuration Documentation', 'zh': '完整配置文档'},
    'config_guide_url': {'en': 'https://easytier.cn/en/guide/network/configurations.html', 'zh': 'https://easytier.cn/guide/network/configurations.html'},
    
    // 配置选项说明
    'instance_name_guide_desc': {'en': 'Instance name to identify this VPN node on the same machine', 'zh': '实例名称，用于在同一台机器上标识此VPN节点'},
    'hostname_guide_desc': {'en': 'Hostname used to identify this device', 'zh': '用于标识此设备的主机名'},
    'network_name_guide_desc': {'en': 'Network name to identify this VPN network', 'zh': '用于标识此VPN网络的网络名称'},
    'network_secret_guide_desc': {'en': 'Network secret key to verify that this node belongs to the VPN network', 'zh': '网络密钥，用于验证此节点属于VPN网络'},
    'ipv4_guide_desc': {'en': 'IPv4 address for this VPN node. If empty, the node will only forward packets without creating a TUN device', 'zh': '此VPN节点的IPv4地址。如果为空，则此节点将仅转发数据包，不会创建TUN设备'},
    'dhcp_guide_desc': {'en': 'Automatically determine and set IP address by EasyTier, starting from 10.0.0.1 by default. Warning: When using DHCP, if IP conflicts occur in the network, the IP will automatically change', 'zh': '由EasyTier自动确定并设置IP地址，默认从10.0.0.1开始。警告：在使用DHCP时，如果网络中出现IP冲突，IP将自动更改'},
    'peers_guide_desc': {'en': 'Initial peer nodes to connect to', 'zh': '最初要连接的对等节点'},
    
    'enable_kcp_proxy_guide_desc': {'en': 'Use KCP proxy for TCP streams to improve latency and throughput on networks with UDP packet loss', 'zh': '使用KCP代理TCP流，提高在UDP丢包网络上的延迟和吞吐量'},
    'disable_kcp_input_guide_desc': {'en': 'Do not allow other nodes to use KCP proxy TCP streams to this node', 'zh': '不允许其他节点使用KCP代理TCP流到此节点'},
    'enable_quic_proxy_guide_desc': {'en': 'Use QUIC proxy for TCP streams to improve latency and throughput on networks with UDP packet loss', 'zh': '使用QUIC代理TCP流，提高在UDP丢包网络上的延迟和吞吐量'},
    'disable_quic_input_guide_desc': {'en': 'Do not allow other nodes to use QUIC proxy TCP streams to this node', 'zh': '不允许其他节点使用QUIC代理TCP流到此节点'},
    'private_mode_guide_desc': {'en': 'If true, do not allow nodes using different network names and passwords from this network to handshake or relay through this node', 'zh': '如果为true，则不允许使用了与本网络不相同的网络名称和密码的节点通过本节点进行握手或中转'},
    'latency_first_guide_desc': {'en': 'Latency-first mode, will try to use the lowest latency path to forward traffic, default uses shortest path', 'zh': '延迟优先模式，将尝试使用最低延迟路径转发流量，默认使用最短路径'},
    'use_smoltcp_guide_desc': {'en': 'Enable smoltcp stack for subnet proxy and KCP proxy', 'zh': '为子网代理和KCP代理启用smoltcp堆栈'},
    'no_tun_guide_desc': {'en': 'Do not create TUN device, can use subnet proxy to access nodes', 'zh': '不创建TUN设备，可以使用子网代理访问节点'},
    
    // 手册内容（关于页面）
    'decentralization': {'en': 'Decentralization', 'zh': '去中心化'},
    'decentralization_desc': {'en': 'Operates without reliance on centralized services; nodes are equal and independent, ensuring high availability and censorship resistance.', 'zh': '运行不依赖任何集中式服务，节点平等且独立，确保系统的高可用性和抗审查性。'},
    
    'security': {'en': 'Security', 'zh': '安全加密'},
    'security_desc': {'en': 'Supports encrypted communication using WireGuard protocol and protects relay traffic with AES-GCM encryption. Achieves high-performance, full-link zero-copy transmission.', 'zh': '支持使用 WireGuard 协议进行端到端加密，并对中继流量采用 AES-GCM 保护。实现端到端零拷贝传输，性能可与主流网络软件相媲美。'},
    
    'high_performance': {'en': 'High Performance', 'zh': '高性能传输'},
    'high_performance_desc': {'en': 'Implements full-link zero-copy transmission with performance comparable to mainstream networking software. Supports TCP/UDP/WSS/WG protocols.', 'zh': '实现端到端零拷贝（full-link zero-copy）传输，性能可与主流网络软件相媲美。支持 TCP/UDP/WSS/WG 协议。'},
    
    'no_public_ip': {'en': 'Networking Without Public IPs', 'zh': '无公网 IP 网络'},
    'no_public_ip_desc': {'en': 'Supports network formation using shared public nodes. Refer to the configuration guide for details.', 'zh': '支持通过共享公网节点组网，详情请参见配置指南。'},
    
    'nat_traversal': {'en': 'NAT Traversal', 'zh': 'NAT 穿透'},
    'nat_traversal_desc': {'en': 'Supports UDP-based NAT traversal, ensuring stable connections even in complex network environments. Can connect NAT4-NAT4 networks.', 'zh': '支持基于 UDP 的 NAT 穿透，在复杂网络环境下也能保持连接稳定。可打通 NAT4-NAT4 网络。'},
    
    'subnet': {'en': 'Subnet (Point-to-Network)', 'zh': '子网网络'},
    'subnet_desc': {'en': 'Nodes can expose accessible network segments as proxies to the virtual network, allowing other nodes to access these subnets through the node.', 'zh': '节点可将可访问的网络段作为子网IP暴露到虚拟网络，其他节点可通过该端点访问这些子网。'},
    
    'intelligent_routing': {'en': 'Intelligent Routing', 'zh': '智能路由'},
    'intelligent_routing_desc': {'en': 'Dynamically selects optimal paths based on real-time traffic to reduce latency and increase throughput.', 'zh': '基于实时流量动态选择最优路径，以减少延迟并提升吞吐。'},
    
    'tcp_support': {'en': 'TCP Support', 'zh': 'TCP 支持'},
    'tcp_support_desc': {'en': 'Provides reliable data transmission through concurrent TCP connections when UDP is restricted, optimizing performance.', 'zh': '在 UDP 受限的场景下，提供并发 TCP 连接以保证可靠传输并优化性能。'},
    
    'high_availability': {'en': 'High Availability', 'zh': '高可用性'},
    'high_availability_desc': {'en': 'Supports multi-path transmission and automatically switches to healthy paths upon detecting high packet loss or network errors.', 'zh': '支持多路径传输，检测到高丢包或网络异常时自动切换到健康路径。'},
    
    'ipv6_support': {'en': 'IPv6 Support', 'zh': 'IPv6 支持'},
    'ipv6_support_desc': {'en': 'Fully supports IPv6-based networking, compatible with IPv6 communication.', 'zh': '全面兼容并支持基于 IPv6 的网络通信。'},
    
    'network_logs': {'en': 'Network Logs', 'zh': '网络日志'},
    'network_logs_desc': {'en': 'Monitor network registration logs in real-time to track and analyze network activity.', 'zh': '实时观察网络注册日志，帮助您监控和分析网络活动。'},
    
    'related_links': {'en': 'Related Links', 'zh': '相关链接'},
    'website': {'en': 'Official Website', 'zh': '官网'},
    'website_url': {'en': 'https://easytier.cn/en/', 'zh': 'https://easytier.cn/'},
    'config_guide': {'en': 'Configuration Guide', 'zh': '配置指南'},
    'failed_to_open_url': {'en': 'Failed to open URL', 'zh': '无法打开链接'},
    
    // 文本选择菜单
    'copy': {'en': 'Copy', 'zh': '复制'},
    'cut': {'en': 'Cut', 'zh': '剪切'},
    'paste': {'en': 'Paste', 'zh': '粘贴'},
    'select_all': {'en': 'Select All', 'zh': '全选'},
    
    // 隐私政策
    'privacy_policy': {'en': 'Privacy Policy', 'zh': '隐私政策'},
    'privacy_policy_title': {'en': 'Privacy Policy Agreement', 'zh': '隐私政策协议'},
    'privacy_policy_content': {'en': 'We value your privacy and data protection. Please read and agree to our Privacy Policy to continue using the app.', 'zh': '我们非常重视您的隐私和数据保护。请阅读并同意我们的隐私政策以继续使用本应用。'},
    'privacy_policy_read': {'en': 'I have read and agree to the Privacy Policy', 'zh': '我已阅读并同意隐私政策'},
    'agree': {'en': 'Agree', 'zh': '同意'},
    'disagree': {'en': 'Disagree', 'zh': '不同意'},
    'disagree_and_exit': {'en': 'Disagree and Exit', 'zh': '不同意并退出'},
    'privacy_policy_required': {'en': 'You must agree to the Privacy Policy to use this app', 'zh': '您必须同意隐私政策才能使用本应用'},
    'revoke_privacy_consent': {'en': 'Revoke Privacy Consent', 'zh': '撤销隐私同意'},
    'revoke_privacy_consent_desc': {'en': 'Revoking privacy consent will require you to exit the app. You will need to agree to the Privacy Policy again when you restart the app.', 'zh': '撤销隐私同意后需要退出应用。重新启动应用时需要再次同意隐私政策。'},
    'revoke_consent': {'en': 'Revoke Consent', 'zh': '撤销同意'},
    'revoke_consent_confirm': {'en': 'Are you sure you want to revoke your privacy consent? The app will exit.', 'zh': '确定要撤销隐私同意吗？应用将退出。'},
    'revoke_and_exit': {'en': 'Revoke and Exit', 'zh': '撤销并退出'},
    
    // API测试
    'api_test': {'en': 'API Test', 'zh': 'API测试'},
    'enter_url': {'en': 'Enter URL', 'zh': '请输入URL'},
    'please_enter_url': {'en': 'Please enter URL', 'zh': '请输入URL'},
    'headers': {'en': 'Headers', 'zh': '请求头'},
    'add_header': {'en': 'Add Header', 'zh': '添加请求头'},
    'header_key': {'en': 'Key', 'zh': '键'},
    'header_value': {'en': 'Value', 'zh': '值'},
    'remove_header': {'en': 'Remove Header', 'zh': '移除请求头'},
    'request_body': {'en': 'Request Body', 'zh': '请求体'},
    'enter_request_body': {'en': 'Enter request body', 'zh': '输入请求体'},
    'send_request': {'en': 'Send Request', 'zh': '发送请求'},
    'response': {'en': 'Response', 'zh': '响应'},
    'response_headers': {'en': 'Response Headers', 'zh': '响应头'},
    
    // API测试增强
    'saved_requests': {'en': 'Saved', 'zh': '已保存'},
    'history': {'en': 'History', 'zh': '历史'},
    'help': {'en': 'Help', 'zh': '帮助'},
    'new_request': {'en': 'New Request', 'zh': '新建请求'},
    'no_saved_requests': {'en': 'No saved requests', 'zh': '暂无保存的请求'},
    'tap_add_to_create': {'en': 'Tap + to create a new request', 'zh': '点击 + 创建新请求'},
    'no_url_set': {'en': 'No URL set', 'zh': '未设置URL'},
    'confirm_delete_request': {'en': 'Delete "{name}"?', 'zh': '删除"{name}"?'},
    'request_deleted': {'en': 'Request deleted', 'zh': '请求已删除'},
    'no_history': {'en': 'No test history', 'zh': '暂无测试历史'},
    'just_now': {'en': 'Just now', 'zh': '刚刚'},
    'minutes_ago': {'en': '{n} min ago', 'zh': '{n}分钟前'},
    'hours_ago': {'en': '{n} hr ago', 'zh': '{n}小时前'},
    'days_ago': {'en': '{n} days ago', 'zh': '{n}天前'},
    'create_request': {'en': 'Create Request', 'zh': '创建请求'},
    'create_request_help': {'en': 'Tap the + button to create a new API request. You can save it for later use.', 'zh': '点击 + 按钮创建新的 API 请求，可以保存以便后续使用。'},
    'edit_request': {'en': 'Edit Request', 'zh': '编辑请求'},
    'edit_request_help': {'en': 'Tap on any saved request to edit its details including URL, headers, and body.', 'zh': '点击任何已保存的请求可以编辑其详情，包括 URL、请求头和请求体。'},
    'send_request_help': {'en': 'Configure your request and tap Send to execute it. Results will be shown below and saved to history.', 'zh': '配置请求后点击发送执行，结果将显示在下方并保存到历史记录。'},
    'save_request': {'en': 'Save Request', 'zh': '保存请求'},
    'save_request_help': {'en': 'Tap the save icon to save your request for future use. All your requests are stored locally.', 'zh': '点击保存图标保存请求以便将来使用，所有请求都存储在本地。'},
    'view_history': {'en': 'View History', 'zh': '查看历史'},
    'view_history_help': {'en': 'Switch to History tab to view all your previous test results including status codes and response times.', 'zh': '切换到历史标签查看之前所有的测试结果，包括状态码和响应时间。'},
    'request_saved': {'en': 'Request saved', 'zh': '请求已保存'},
    'failed_to_save': {'en': 'Failed to save', 'zh': '保存失败'},
    'api_request': {'en': 'API Request', 'zh': 'API 请求'},
    'request_name': {'en': 'Request Name', 'zh': '请求名称'},
    'unnamed_request': {'en': 'Unnamed Request', 'zh': '未命名请求'},
    
    // 底部导航
    'tab_connection': {'en': 'Connection', 'zh': '连接'},
    'tab_api': {'en': 'API', 'zh': '接口'},
    'api_help': {'en': 'API Help', 'zh': '接口测试帮助'},
    'api_help_subtitle': {'en': 'Learn how to use the API testing feature', 'zh': '了解如何使用接口测试功能'},
    'tab_more': {'en': 'More', 'zh': '更多'},
    
    // 网络工具
    'network_tools': {'en': 'Network Tools', 'zh': '网络工具'},
    'network_tools_subtitle': {'en': 'Ping and DNS lookup', 'zh': 'Ping 和 DNS 查询'},
    'ping': {'en': 'Ping', 'zh': 'Ping'},
    'dns_lookup': {'en': 'DNS Lookup', 'zh': 'DNS 查询'},
    'ping_test': {'en': 'Ping Test', 'zh': 'Ping 测试'},
    'host_or_ip': {'en': 'Host or IP', 'zh': '主机或IP'},
    'packet_count': {'en': 'Packet Count', 'zh': '数据包数量'},
    'pinging': {'en': 'Pinging...', 'zh': '正在 Ping...'},
    'start_ping': {'en': 'Start Ping', 'zh': '开始 Ping'},
    'record_type': {'en': 'Record Type', 'zh': '记录类型'},
    'querying': {'en': 'Querying...', 'zh': '正在查询...'},
    'lookup': {'en': 'Lookup', 'zh': '查询'},
    'please_enter_host': {'en': 'Please enter host', 'zh': '请输入主机'},
    
    // 代码生成
    'generate_curl': {'en': 'Generate cURL', 'zh': '生成 cURL'},
    'curl_command': {'en': 'cURL Command', 'zh': 'cURL 命令'},
    
    // 环境变量和集合
    'environment': {'en': 'Environment', 'zh': '环境'},
    'environment_manager': {'en': 'Environment Manager', 'zh': '环境管理'},
    'edit_environment': {'en': 'Edit Environment', 'zh': '编辑环境'},
    'new_environment': {'en': 'New Environment', 'zh': '新环境'},
    'environment_name': {'en': 'Environment Name', 'zh': '环境名称'},
    'no_environment': {'en': 'No environment', 'zh': '无环境'},
    'no_environments': {'en': 'No environments', 'zh': '暂无环境'},
    'tap_add_to_create_environment': {'en': 'Tap + to create a new environment', 'zh': '点击 + 创建新环境'},
    'please_enter_environment_name': {'en': 'Please enter environment name', 'zh': '请输入环境名称'},
    'environment_saved': {'en': 'Environment saved', 'zh': '环境已保存'},
    'environment_deleted': {'en': 'Environment deleted', 'zh': '环境已删除'},
    'confirm_delete_environment': {'en': 'Are you sure you want to delete environment "{name}"?', 'zh': '确定要删除环境"{name}"吗？'},
    'cannot_delete_default_environment': {'en': 'Cannot delete default environment', 'zh': '不能删除默认环境'},
    'variables': {'en': 'Variables', 'zh': '变量'},
    'variable_name': {'en': 'Variable Name', 'zh': '变量名'},
    'variable_value': {'en': 'Variable Value', 'zh': '变量值'},
    'add_variable': {'en': 'Add Variable', 'zh': '添加变量'},
    'remove_variable': {'en': 'Remove Variable', 'zh': '删除变量'},
    'environment_variable_hint': {'en': 'Use {{variableName}} in URLs, headers, or body to replace with the value', 'zh': '在 URL、请求头或请求体中使用 {{变量名}} 来替换为对应的值'},
    'default': {'en': 'Default', 'zh': '默认'},
    'current_environment': {'en': 'Current Environment', 'zh': '当前环境'},
    'switch_environment': {'en': 'Switch Environment', 'zh': '切换环境'},
    'select': {'en': 'Select', 'zh': '选择'},
    'requests': {'en': 'requests', 'zh': '个请求'},
    
    // 更多页面
    'tools': {'en': 'Tools', 'zh': '工具'},
    'help_and_about': {'en': 'Help & About', 'zh': '帮助与关于'},
    'events_subtitle': {'en': 'View connection events and logs', 'zh': '查看连接事件和日志'},
    'settings_subtitle': {'en': 'Configure app preferences', 'zh': '配置应用偏好设置'},
    'guide_subtitle': {'en': 'Learn how to use the app', 'zh': '学习如何使用应用'},
    'about_subtitle': {'en': 'App information and features', 'zh': '应用信息和功能'},
    
    // 网络工具 - 204检测和DNS
    'connectivity': {'en': 'Connectivity', 'zh': '连通性'},
    'connectivity_test': {'en': 'Connectivity Test', 'zh': '网速测试'},
    'connectivity_test_desc': {'en': 'Test network connectivity to multiple providers', 'zh': '测试到多个服务商的网络连通性/延迟'},
    'checking': {'en': 'Checking...', 'zh': '检测中...'},
    'start_check': {'en': 'Start Check', 'zh': '开始检测'},
    'routes_reachable': {'en': 'routes reachable', 'zh': '个线路可达'},
    'dns_lookup_desc': {'en': 'Query DNS records using multiple DoH providers', 'zh': '使用多个 DoH 提供商查询 DNS 记录'},
    'resolved_addresses': {'en': 'Resolved Addresses', 'zh': '解析地址'},
    'provider_results': {'en': 'Provider Results', 'zh': '各服务商结果'},
    'result': {'en': 'Result', 'zh': '结果'},
    
    // 本机 IP 查询
    'my_ip': {'en': 'My IP', 'zh': '我的 IP'},
    'my_ip_desc': {'en': 'Query your public IP address and location', 'zh': '查询您的公网 IP 地址和位置'},
    'country': {'en': 'Country', 'zh': '国家'},
    'region': {'en': 'Region', 'zh': '地区'},
    'city': {'en': 'City', 'zh': '城市'},
    'isp': {'en': 'ISP', 'zh': '运营商'},
    'organization': {'en': 'Organization', 'zh': '组织'},
    'query_failed': {'en': 'Query Failed', 'zh': '查询失败'},
    'retry': {'en': 'Retry', 'zh': '重试'},
    'copied_to_clipboard': {'en': 'Copied to clipboard', 'zh': '已复制到剪贴板'},
    
    // API 测试历史
    'records': {'en': 'records', 'zh': '条记录'},
    'clear_all': {'en': 'Clear All', 'zh': '清空'},
    'confirm_delete_history': {'en': 'Are you sure you want to delete this history record?', 'zh': '确定要删除这条历史记录吗？'},
    'confirm_clear_all_history': {'en': 'Are you sure you want to clear all history records? This action cannot be undone.', 'zh': '确定要清空所有历史记录吗？此操作不可撤销。'},
    'history_deleted': {'en': 'History record deleted', 'zh': '历史记录已删除'},
    'history_cleared': {'en': 'All history cleared', 'zh': '历史记录已清空'},
    
    // 应用说明
    'app_info': {'en': 'Application Information', 'zh': '应用说明'},
    'app_info_desc': {'en': 'This application is a third-party GUI client that integrates EasyTier-Core. It has no affiliation with the official EasyTier project. The code is fully open source and follows the license agreement. We welcome you to submit issues and feedback. Thank you for downloading and using this application.', 'zh': '本应用是集成 EasyTier-Core 的第三方 GUI 客户端，与官方 EasyTier 项目无任何关系。代码遵循协议完全开源，欢迎您提出 issue 和反馈意见。感谢您的下载与使用。'},
  };
}

/// 国际化代理
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
