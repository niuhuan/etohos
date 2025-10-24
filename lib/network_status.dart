import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:etohos/methods.dart';
import 'package:etohos/utils/logger.dart';

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

      // 获取最新的IP和主机名
      if (_networkHistory.isNotEmpty) {
        final latest = _networkHistory.last;
        _currentIp = latest.ip;
        _hostname = latest.hostname;

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
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                const Icon(Icons.network_check, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Network Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // IP信息
            if (_currentIp.isNotEmpty) ...[
              _buildInfoRow('IP Address', _currentIp),
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
                      'RX',
                      _formatBytes(_currentRxSpeed) + '/s',
                      Colors.green,
                      Icons.download,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSpeedCard(
                      'TX',
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
              const Center(
                child: Text(
                  'No network data available',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.blue),
        ),
      ],
    );
  }

  Widget _buildSpeedCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            "$title:  ",
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
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
                return Text(
                  _formatBytes(value.toInt()),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 40,
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
}

// 数据模型
class NetworkData {
  final int timestamp;
  final int rxBytes;
  final int txBytes;
  final String ip;
  final String hostname;

  NetworkData({
    required this.timestamp,
    required this.rxBytes,
    required this.txBytes,
    required this.ip,
    required this.hostname,
  });

  factory NetworkData.fromJson(Map<String, dynamic> json) {
    return NetworkData(
      timestamp: json['timestamp'] ?? 0,
      rxBytes: json['rxBytes'] ?? 0,
      txBytes: json['txBytes'] ?? 0,
      ip: json['ip'] ?? '',
      hostname: json['hostname'] ?? '',
    );
  }
}
