import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:etohos/l10n/l10n_extensions.dart';
import 'package:etohos/methods.dart';

/// 本机 IP 查询页面
class MyIpScreen extends StatefulWidget {
  const MyIpScreen({super.key});

  @override
  State<MyIpScreen> createState() => _MyIpScreenState();
}

class _MyIpScreenState extends State<MyIpScreen> {
  bool _isQuerying = false;
  IpInfoResult? _result;

  @override
  void initState() {
    super.initState();
    _performQuery();
  }

  Future<void> _performQuery() async {
    setState(() {
      _isQuerying = true;
      _result = null;
    });

    try {
      final result = await methods.getMyIpInfo();
      setState(() {
        _result = result;
        _isQuerying = false;
      });
    } catch (e) {
      setState(() {
        _result = IpInfoResult(
          success: false,
          results: [],
          message: 'Error: $e',
        );
        _isQuerying = false;
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t('copied_to_clipboard'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('my_ip')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isQuerying ? null : _performQuery,
          ),
        ],
      ),
      body: _isQuerying
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_result != null && _result!.success) ...[
                    ..._result!.results.map((info) => _buildIpInfoCard(info, colorScheme)),
                  ] else ...[
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              t('query_failed'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _result?.message ?? 'Unknown error',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _performQuery,
                              icon: const Icon(Icons.refresh),
                              label: Text(t('retry')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildIpInfoCard(IpProviderResult info, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: info.success
              ? colorScheme.outline.withOpacity(0.2)
              : Colors.red.withOpacity(0.3),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: info.success
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    info.success ? Icons.public : Icons.error_outline,
                    color: info.success ? Colors.green : Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.provider,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      if (info.success) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${info.latency}ms',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (info.success && info.ip.isNotEmpty) ...[
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () => _copyToClipboard(info.ip),
                    tooltip: t('copy'),
                  ),
                ],
              ],
            ),
            if (info.success) ...[
              const SizedBox(height: 16),
              // IP 地址
              _buildInfoRow(t('ip_address'), info.ip, colorScheme, isLarge: true),
              if (info.country.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildInfoRow(t('country'), info.country, colorScheme),
              ],
              if (info.region.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(t('region'), info.region, colorScheme),
              ],
              if (info.city.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(t('city'), info.city, colorScheme),
              ],
              if (info.isp.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(t('isp'), info.isp, colorScheme),
              ],
              if (info.org.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(t('organization'), info.org, colorScheme),
              ],
            ] else ...[
              const SizedBox(height: 12),
              Text(
                info.message,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme colorScheme, {bool isLarge = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: TextStyle(
              fontSize: isLarge ? 18 : 14,
              fontWeight: isLarge ? FontWeight.w600 : FontWeight.normal,
              fontFamily: isLarge ? 'monospace' : null,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
