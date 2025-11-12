import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:etohos/methods.dart';
import 'package:etohos/utils/logger.dart';
import 'package:etohos/l10n/l10n_extensions.dart';
import 'package:signals_flutter/signals_flutter.dart';

class NetworkStatus extends StatefulWidget {
  const NetworkStatus({super.key});

  @override
  State<NetworkStatus> createState() => _NetworkStatusState();
}

class _NetworkStatusState extends State<NetworkStatus> {
  List<NetworkData> _networkHistory = [];
  String _currentIp = '';
  String _hostname = '';
  int _currentRxSpeed = 0; // 当前接收速度 (bytes/s)
  int _currentTxSpeed = 0; // 当前发送速度 (bytes/s)
  Timer? _updateTimer;
  int _peerCount = 0; // 节点数量
  List<PeerInfo> _peers = []; // 节点列表
  List<Route> _routes = []; // 路由列表

  @override
  void initState() {
    super.initState();
    _startNetworkMonitoring();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startNetworkMonitoring() {
    // 每3秒调用一次获取网络历史数据
    _updateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateNetworkData();
    });
  }

  Future<void> _updateNetworkData() async {
    try {
      final result = await methods.getNetworkHistory();
      AppLogger.debug('Received network history data: ${result.length} items',
          tag: 'NETWORK_STATUS');
      if (result.isNotEmpty) {
        _processNetworkData(result);
      }
    } catch (e) {
      AppLogger.error('Error getting network history', error: e);
    }
  }

  void _processNetworkData(List<dynamic> historyData) {
    AppLogger.debug('Processing ${historyData.length} network data items',
        tag: 'NETWORK_STATUS');

    setState(() {
      _networkHistory = historyData
          .map((data) {
            // 确保data是Map<String, dynamic>类型
            final Map<String, dynamic> jsonData;
            if (data is Map<String, dynamic>) {
              jsonData = data;
            } else if (data is Map) {
              // 如果是Map<Object?, Object?>，转换为Map<String, dynamic>
              jsonData = Map<String, dynamic>.from(data);
            } else {
              // 如果都不是，跳过这条数据
              AppLogger.warning('Invalid network data format: $data',
                  tag: 'NETWORK_STATUS');
              return null;
            }

            try {
              final networkData = NetworkData.fromJson(jsonData);
              AppLogger.debug(
                  'Parsed network data: IP=${networkData.ip}, RX=${networkData.rxBytes}, TX=${networkData.txBytes}',
                  tag: 'NETWORK_STATUS');
              return networkData;
            } catch (e) {
              AppLogger.error('Failed to parse network data: $jsonData',
                  error: e, tag: 'NETWORK_STATUS');
              return null;
            }
          })
          .where((data) => data != null)
          .cast<NetworkData>()
          .toList();

      AppLogger.info(
          'Successfully processed ${_networkHistory.length} network data items',
          tag: 'NETWORK_STATUS');

      // 获取最新的IP、主机名、节点信息和路由信息
      if (_networkHistory.isNotEmpty) {
        final latest = _networkHistory.last;
        _currentIp = latest.ip;
        _hostname = latest.hostname;
        _peers = latest.peers;
        _peerCount = latest.peers.length;
        _routes = latest.routes;

        // 计算实时网速（最新数据点的速度）
        _currentRxSpeed = latest.rxBytes.abs(); // 取绝对值，避免负数
        _currentTxSpeed = latest.txBytes.abs(); // 取绝对值，避免负数

        AppLogger.info('Current IP: $_currentIp, Hostname: $_hostname',
            tag: 'NETWORK_STATUS');
        AppLogger.info(
            'Current Speed - RX: ${_formatBytes(_currentRxSpeed)}/s, TX: ${_formatBytes(_currentTxSpeed)}/s',
            tag: 'NETWORK_STATUS');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) => _build(context));
  }

  Widget _build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.3),
            colorScheme.secondaryContainer.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.06),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题 - 现代化设计
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.speed, color: colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          t('network_status'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // 节点信息按钮
                  InkWell(
                    onTap: () => _showPeerInfoDialog(),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${t('peer')}: $_peerCount',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 路由信息按钮
                  InkWell(
                    onTap: () => _showRouteInfoDialog(),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${t('routes')}: ${_routes.length}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.secondary.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

            // IP信息
            if (_currentIp.isNotEmpty) ...[
              _buildInfoRow(t('ip_address'), _currentIp),
              const SizedBox(height: 8),
            ],
            // if (_hostname.isNotEmpty) ...[
            //   _buildInfoRow('Hostname', _hostname),
            //   const SizedBox(height: 8),
            // ],

            // 实时网速显示
            if (_networkHistory.isNotEmpty) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildSpeedCard(
                      t('rx_speed'),
                      _formatBytes(_currentRxSpeed) + '/s',
                      Colors.green,
                      Icons.download,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSpeedCard(
                      t('tx_speed'),
                      _formatBytes(_currentTxSpeed) + '/s',
                      Colors.orange,
                      Icons.upload,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // 网络速度图表
            if (_networkHistory.isNotEmpty) ...[
              // const Text(
              //   'Network Speed (Last 20 seconds)',
              //   style: TextStyle(
              //     fontSize: 16,
              //     fontWeight: FontWeight.w600,
              //   ),
              // ),
              // const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: _buildNetworkChart(),
              ),
            ] else ...[
              Center(
                child: Text(
                  t('no_network_data'),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            label.contains('IP') ? Icons.language : Icons.devices,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: color.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkChart() {
    if (_networkHistory.isEmpty) {
      return const Center(
        child: Text('No network data available'),
      );
    }

    // 计算最大值用于缩放
    final maxRx = _networkHistory.map((e) => e.rxBytes).reduce(max);
    final maxTx = _networkHistory.map((e) => e.txBytes).reduce(max);
    final maxValue = max(maxRx, maxTx).toDouble();

    // 使用更保守的边距计算，确保折线完全在容器内
    final adjustedMaxValue = maxValue > 0 ? maxValue * 1.3 : 1.0; // 增加30%的顶部边距
    final gridInterval = adjustedMaxValue / 4; // 4个网格线

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: gridInterval,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}s',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: gridInterval,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Text(
                    _formatYAxisLabel(value, adjustedMaxValue),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
              reservedSize: 25,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        minX: 0,
        maxX: (_networkHistory.length - 1).toDouble(),
        minY: 0, // 最小值始终为0
        maxY: adjustedMaxValue, // 最大值动态调整，增加20%边距
        // 使用clipData确保折线不会超出边界
        clipData: FlClipData.all(),
        lineBarsData: [
          // Download line
          LineChartBarData(
            spots: _networkHistory.asMap().entries.map((entry) {
              return FlSpot(
                  entry.key.toDouble(), entry.value.rxBytes.abs().toDouble());
            }).toList(),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.1),
            ),
          ),
          // Upload line
          LineChartBarData(
            spots: _networkHistory.asMap().entries.map((entry) {
              return FlSpot(
                  entry.key.toDouble(), entry.value.txBytes.abs().toDouble());
            }).toList(),
            isCurved: true,
            color: Colors.orange,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Y轴标签格式化：在0位置显示单位，其他位置只显示整数
  String _formatYAxisLabel(double value, double maxValue) {
    if (value == 0) {
      // 在0的位置显示单位
      if (maxValue < 1024) {
        return 'B';
      } else if (maxValue < 1024 * 1024) {
        return 'KB';
      } else {
        return 'MB';
      }
    } else {
      // 其他位置只显示整数
      int displayValue;
      if (maxValue < 1024) {
        displayValue = value.toInt();
      } else if (maxValue < 1024 * 1024) {
        displayValue = (value / 1024).toInt();
      } else {
        displayValue = (value / (1024 * 1024)).toInt();
      }
      return displayValue.toString();
    }
  }

  void _showPeerInfoDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.devices, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              t('peer_info'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: _peers.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      t('no_peers'),
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _peers.length,
                  itemBuilder: (context, index) {
                    final peer = _peers[index];
                    final peerId = peer.peerId;
                    final conns = peer.conns;
                    final connCount = conns.length;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.device_hub,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${t('peer')} $peerId',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$connCount ${t('connections')}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (conns.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              ...conns.map<Widget>((conn) {
                                final connId = conn.connId;
                                final connIdStr = connId;
                                final isClient = conn.isClient;
                                final lossRate = conn.lossRate;
                                final stats = conn.stats;
                                final latency = stats?.latencyUs ?? 0;
                                final displayId = connIdStr.length > 12 
                                    ? '${connIdStr.substring(0, 12)}...' 
                                    : connIdStr;
                                
                                return Padding(
                                  padding: const EdgeInsets.only(left: 8, top: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isClient ? Icons.arrow_upward : Icons.arrow_downward,
                                        size: 14,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'ID: $displayId',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      if (latency > 0)
                                        Text(
                                          '${(latency / 1000).toStringAsFixed(1)}ms',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      if (lossRate > 0) ...[
                                        const SizedBox(width: 4),
                                        Text(
                                          '${(lossRate * 100).toStringAsFixed(1)}%',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: lossRate > 0.1
                                                ? Colors.red
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t('close')),
          ),
        ],
      ),
    );
  }

  void _showRouteInfoDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.route, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              t('route_info'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: _routes.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      t('no_routes'),
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _routes.length,
                  itemBuilder: (context, index) {
                    final route = _routes[index];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.route,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${t('peer')} ${route.peerId}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            if (route.hostname.isNotEmpty || route.ipv4Addr != null) ...[
                              const SizedBox(height: 8),
                              if (route.hostname.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.computer,
                                      size: 14,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        route.hostname,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (route.ipv4Addr != null) ...[
                                if (route.hostname.isNotEmpty) const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.language,
                                      size: 14,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        route.ipv4Addr!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colorScheme.onSurfaceVariant,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                            // if (route.cost > 0) ...[
                            //   const SizedBox(height: 4),
                            //   Text(
                            //     '${t('cost')}: ${route.cost}',
                            //     style: TextStyle(
                            //       fontSize: 11,
                            //       color: colorScheme.onSurfaceVariant,
                            //     ),
                            //   ),
                            // ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t('close')),
          ),
        ],
      ),
    );
  }
}

// 数据模型
class NetworkData {
  final int timestamp;
  final int rxBytes;
  final int txBytes;
  final String ip;
  final String hostname;
  final List<PeerInfo> peers;
  final List<Route> routes;

  NetworkData({
    required this.timestamp,
    required this.rxBytes,
    required this.txBytes,
    required this.ip,
    required this.hostname,
    required this.peers,
    required this.routes,
  });

  factory NetworkData.fromJson(Map<String, dynamic> json) {
    final peersData = json['peers'] as List<dynamic>? ?? [];
    final peers = peersData
        .map((data) {
          try {
            if (data is Map<String, dynamic>) {
              return PeerInfo.fromJson(data);
            } else if (data is Map) {
              return PeerInfo.fromJson(Map<String, dynamic>.from(data));
            }
            return null;
          } catch (e) {
            return null;
          }
        })
        .where((peer) => peer != null)
        .cast<PeerInfo>()
        .toList();

    final routesData = json['routes'] as List<dynamic>? ?? [];
    final routes = routesData
        .map((data) {
          try {
            if (data is Map<String, dynamic>) {
              return Route.fromJson(data);
            } else if (data is Map) {
              return Route.fromJson(Map<String, dynamic>.from(data));
            }
            return null;
          } catch (e) {
            return null;
          }
        })
        .where((route) => route != null)
        .cast<Route>()
        .toList();

    return NetworkData(
      timestamp: json['timestamp'] ?? 0,
      rxBytes: json['rxBytes'] ?? 0,
      txBytes: json['txBytes'] ?? 0,
      ip: json['ip'] ?? '',
      hostname: json['hostname'] ?? '',
      peers: peers,
      routes: routes,
    );
  }
}

// PeerInfo 数据模型 - 对应 TypeScript 的 PeerInfo 接口
class PeerInfo {
  final int peerId;
  final List<PeerConnInfo> conns;

  PeerInfo({
    required this.peerId,
    required this.conns,
  });

  factory PeerInfo.fromJson(Map<String, dynamic> json) {
    final connsData = json['conns'] as List<dynamic>? ?? [];
    final conns = connsData
        .map((data) {
          try {
            if (data is Map<String, dynamic>) {
              return PeerConnInfo.fromJson(data);
            } else if (data is Map) {
              return PeerConnInfo.fromJson(Map<String, dynamic>.from(data));
            }
            return null;
          } catch (e) {
            return null;
          }
        })
        .where((conn) => conn != null)
        .cast<PeerConnInfo>()
        .toList();

    return PeerInfo(
      peerId: json['peer_id'] ?? 0,
      conns: conns,
    );
  }
}

// PeerConnInfo 数据模型 - 对应 TypeScript 的 PeerConnInfo 接口
class PeerConnInfo {
  final String connId;
  final int myPeerId;
  final bool isClient;
  final int peerId;
  final List<String> features;
  final TunnelInfo? tunnel;
  final PeerConnStats? stats;
  final double lossRate;

  PeerConnInfo({
    required this.connId,
    required this.myPeerId,
    required this.isClient,
    required this.peerId,
    required this.features,
    this.tunnel,
    this.stats,
    required this.lossRate,
  });

  factory PeerConnInfo.fromJson(Map<String, dynamic> json) {
    final featuresData = json['features'] as List<dynamic>? ?? [];
    final features = featuresData.map((f) => f.toString()).toList();

    return PeerConnInfo(
      connId: json['conn_id'] ?? '',
      myPeerId: json['my_peer_id'] ?? 0,
      isClient: json['is_client'] ?? false,
      peerId: json['peer_id'] ?? 0,
      features: features,
      tunnel: json['tunnel'] != null
          ? TunnelInfo.fromJson(json['tunnel'] as Map<String, dynamic>)
          : null,
      stats: json['stats'] != null
          ? PeerConnStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
      lossRate: (json['loss_rate'] ?? 0.0).toDouble(),
    );
  }
}

// TunnelInfo 数据模型 - 对应 TypeScript 的 TunnelInfo 接口
class TunnelInfo {
  final String tunnelType;
  final String localAddr;
  final String remoteAddr;

  TunnelInfo({
    required this.tunnelType,
    required this.localAddr,
    required this.remoteAddr,
  });

  factory TunnelInfo.fromJson(Map<String, dynamic> json) {
    return TunnelInfo(
      tunnelType: json['tunnel_type'] ?? '',
      localAddr: json['local_addr'] ?? '',
      remoteAddr: json['remote_addr'] ?? '',
    );
  }
}

// PeerConnStats 数据模型 - 对应 TypeScript 的 PeerConnStats 接口
class PeerConnStats {
  final int rxBytes;
  final int txBytes;
  final int rxPackets;
  final int txPackets;
  final int latencyUs;

  PeerConnStats({
    required this.rxBytes,
    required this.txBytes,
    required this.rxPackets,
    required this.txPackets,
    required this.latencyUs,
  });

  factory PeerConnStats.fromJson(Map<String, dynamic> json) {
    return PeerConnStats(
      rxBytes: json['rx_bytes'] ?? 0,
      txBytes: json['tx_bytes'] ?? 0,
      rxPackets: json['rx_packets'] ?? 0,
      txPackets: json['tx_packets'] ?? 0,
      latencyUs: json['latency_us'] ?? 0,
    );
  }
}

// Route 数据模型 - 对应 TypeScript 的 Route 接口
class Route {
  final int peerId;
  final String? ipv4Addr;
  final int nextHopPeerId;
  final int cost;
  final List<String> proxyCidrs;
  final String hostname;
  final String instId;
  final String version;

  Route({
    required this.peerId,
    this.ipv4Addr,
    required this.nextHopPeerId,
    required this.cost,
    required this.proxyCidrs,
    required this.hostname,
    required this.instId,
    required this.version,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    // 处理 ipv4_addr，可能是 Ipv4Inet 对象、字符串或 null
    String? ipv4Addr;
    final ipv4AddrData = json['ipv4_addr'];
    if (ipv4AddrData != null) {
      if (ipv4AddrData is String) {
        ipv4Addr = ipv4AddrData;
      } else if (ipv4AddrData is Map) {
        // 如果是 Ipv4Inet 对象，提取 address.addr
        final address = ipv4AddrData['address'];
        if (address is Map && address['addr'] != null) {
          final addr = address['addr'] as int;
          // 转换为 IPv4 字符串
          ipv4Addr = _convertAddrToIp(addr);
        }
      }
    }

    final proxyCidrsData = json['proxy_cidrs'] as List<dynamic>? ?? [];
    final proxyCidrs = proxyCidrsData.map((c) => c.toString()).toList();

    return Route(
      peerId: json['peer_id'] ?? 0,
      ipv4Addr: ipv4Addr,
      nextHopPeerId: json['next_hop_peer_id'] ?? 0,
      cost: json['cost'] ?? 0,
      proxyCidrs: proxyCidrs,
      hostname: json['hostname'] ?? '',
      instId: json['inst_id'] ?? '',
      version: json['version'] ?? '',
    );
  }

  // 将数字地址转换为 IPv4 字符串
  static String _convertAddrToIp(int addr) {
    final byte1 = (addr >> 24) & 0xFF;
    final byte2 = (addr >> 16) & 0xFF;
    final byte3 = (addr >> 8) & 0xFF;
    final byte4 = addr & 0xFF;
    return '$byte1.$byte2.$byte3.$byte4';
  }
}
