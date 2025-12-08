import 'package:flutter/material.dart';
import 'package:etohos/l10n/l10n_extensions.dart';
import 'package:etohos/methods.dart';

/// 网络诊断工具页面
class NetworkToolsScreen extends StatefulWidget {
  const NetworkToolsScreen({super.key});

  @override
  State<NetworkToolsScreen> createState() => _NetworkToolsScreenState();
}

class _NetworkToolsScreenState extends State<NetworkToolsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Ping 相关
  final TextEditingController _pingHostController = TextEditingController();
  int _pingCount = 4;
  bool _isPinging = false;
  String? _pingResult;

  // DNS 相关
  final TextEditingController _dnsHostController = TextEditingController();
  String _dnsType = 'A';
  bool _isDnsQuerying = false;
  String? _dnsResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pingHostController.dispose();
    _dnsHostController.dispose();
    super.dispose();
  }

  Future<void> _performPing() async {
    if (_pingHostController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('please_enter_host'))),
      );
      return;
    }

    setState(() {
      _isPinging = true;
      _pingResult = null;
    });

    try {
      final result = await methods.ping(_pingHostController.text.trim(), count: _pingCount);
      
      setState(() {
        _pingResult = _formatPingResult(result);
        _isPinging = false;
      });
    } catch (e) {
      setState(() {
        _pingResult = 'Error: $e';
        _isPinging = false;
      });
    }
  }

  String _formatPingResult(PingResult result) {
    if (!result.success) {
      return result.message;
    }

    final buffer = StringBuffer();
    buffer.writeln('PING ${result.host}');
    buffer.writeln('');
    
    if (result.packetsReceived > 0) {
      buffer.writeln('Packets: Sent = ${result.packetsSent}, Received = ${result.packetsReceived}, Lost = ${result.packetsSent - result.packetsReceived} (${((result.packetsSent - result.packetsReceived) / result.packetsSent * 100).toStringAsFixed(1)}% loss)');
      buffer.writeln('');
      
      if (result.minTime != null && result.maxTime != null && result.avgTime != null) {
        buffer.writeln('Approximate round trip times in milli-seconds:');
        buffer.writeln('    Minimum = ${result.minTime}ms, Maximum = ${result.maxTime}ms, Average = ${result.avgTime}ms');
      }
    } else {
      buffer.writeln('Request timed out.');
    }

    return buffer.toString();
  }

  Future<void> _performDnsLookup() async {
    if (_dnsHostController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('please_enter_host'))),
      );
      return;
    }

    setState(() {
      _isDnsQuerying = true;
      _dnsResult = null;
    });

    try {
      final result = await methods.dnsLookup(_dnsHostController.text.trim(), type: _dnsType);
      
      setState(() {
        _dnsResult = _formatDnsResult(result);
        _isDnsQuerying = false;
      });
    } catch (e) {
      setState(() {
        _dnsResult = 'Error: $e';
        _isDnsQuerying = false;
      });
    }
  }

  String _formatDnsResult(DnsResult result) {
    if (!result.success) {
      return result.message;
    }

    final buffer = StringBuffer();
    buffer.writeln('DNS Lookup: ${result.host}');
    buffer.writeln('Type: $_dnsType');
    buffer.writeln('');
    
    if (result.addresses.isEmpty) {
      buffer.writeln('No addresses found');
    } else {
      buffer.writeln('Addresses:');
      for (final address in result.addresses) {
        buffer.writeln('  $address');
      }
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('network_tools')),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.onSurface,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: colorScheme.primary,
          tabs: [
            Tab(icon: const Icon(Icons.network_ping), text: t('ping')),
            Tab(icon: const Icon(Icons.dns), text: t('dns_lookup')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPingTab(),
          _buildDnsTab(),
        ],
      ),
    );
  }

  Widget _buildPingTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('ping_test'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _pingHostController,
                    decoration: InputDecoration(
                      labelText: t('host_or_ip'),
                      hintText: 'example.com or 8.8.8.8',
                      prefixIcon: const Icon(Icons.link),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        t('packet_count'),
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Slider(
                          value: _pingCount.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: '$_pingCount',
                          onChanged: (value) {
                            setState(() {
                              _pingCount = value.toInt();
                            });
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_pingCount',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _isPinging ? null : _performPing,
                    icon: _isPinging
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(_isPinging ? t('pinging') : t('start_ping')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_pingResult != null) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t('result'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: SelectableText(
                        _pingResult!,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDnsTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('dns_lookup'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dnsHostController,
                    decoration: InputDecoration(
                      labelText: t('hostname'),
                      hintText: 'example.com',
                      prefixIcon: const Icon(Icons.dns),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _dnsType,
                    decoration: InputDecoration(
                      labelText: t('record_type'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'A', child: Text('A (IPv4)')),
                      DropdownMenuItem(value: 'AAAA', child: Text('AAAA (IPv6)')),
                      DropdownMenuItem(value: 'CNAME', child: Text('CNAME')),
                      DropdownMenuItem(value: 'MX', child: Text('MX')),
                      DropdownMenuItem(value: 'TXT', child: Text('TXT')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _dnsType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _isDnsQuerying ? null : _performDnsLookup,
                    icon: _isDnsQuerying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(_isDnsQuerying ? t('querying') : t('lookup')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_dnsResult != null) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t('result'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: SelectableText(
                        _dnsResult!,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: colorScheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

