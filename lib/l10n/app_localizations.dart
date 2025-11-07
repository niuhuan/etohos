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
    'app_name': {'en': 'EasytierOHOS', 'zh': 'EasytierOHOS'},
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
    'manual': {'en': 'Manual', 'zh': '手册'},
    'manual_subtitle': {'en': 'A simple, secure, decentralized cross-region networking solution', 'zh': '一个简单、安全、去中心化的异地组网方案'},
    
    // 手册内容
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
    'config_guide_url': {'en': 'https://easytier.cn/en/guide/introduction.html', 'zh': 'https://easytier.cn/guide/introduction.html'},
    'failed_to_open_url': {'en': 'Failed to open URL', 'zh': '无法打开链接'},
    
    // 文本选择菜单
    'copy': {'en': 'Copy', 'zh': '复制'},
    'cut': {'en': 'Cut', 'zh': '剪切'},
    'paste': {'en': 'Paste', 'zh': '粘贴'},
    'select_all': {'en': 'Select All', 'zh': '全选'},
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

