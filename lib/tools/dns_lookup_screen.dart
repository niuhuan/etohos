import 'package:flutter/material.dart';
import 'package:etohos/l10n/l10n_extensions.dart';
import 'package:etohos/methods.dart';

/// DNS 查询页面
class DnsLookupScreen extends StatefulWidget {
  const DnsLookupScreen({super.key});

  @override
  State<DnsLookupScreen> createState() => _DnsLookupScreenState();
}

class _DnsLookupScreenState extends State<DnsLookupScreen> {
  final TextEditingController _hostController = TextEditingController();
  String _dnsType = 'A';
  bool _isQuerying = false;
  DnsResult? _result;

  @override
  void dispose() {
    _hostController.dispose();
    super.dispose();
  }

  Future<void> _performLookup() async {
    if (_hostController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('please_enter_host'))),
      );
      return;
    }

    setState(() {
      _isQuerying = true;
      _result = null;
    });

    try {
      final result = await methods.dnsLookup(_hostController.text.trim(), type: _dnsType);
      setState(() {
        _result = result;
        _isQuerying = false;
      });
    } catch (e) {
      setState(() {
        _result = DnsResult(
          host: _hostController.text.trim(),
          type: _dnsType,
          success: false,
          addresses: [],
          results: [],
          message: 'Error: $e',
        );
        _isQuerying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('dns_lookup')),
      ),
      body: SingleChildScrollView(
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.dns,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
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
                              const SizedBox(height: 4),
                              Text(
                                t('dns_lookup_desc'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _hostController,
                      decoration: InputDecoration(
                        labelText: t('hostname'),
                        hintText: 'example.com',
                        prefixIcon: const Icon(Icons.link),
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isQuerying ? null : _performLookup,
                        icon: _isQuerying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.search),
                        label: Text(_isQuerying ? t('querying') : t('lookup')),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_result != null) ...[
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
                            _result!.success ? Icons.check_circle : Icons.error,
                            color: _result!.success ? Colors.green : Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'DNS: ${_result!.host}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      if (_result!.addresses.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t('resolved_addresses'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ..._result!.addresses.map((addr) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: SelectableText(
                                  addr,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 14,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        t('provider_results'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._result!.results.map((provider) => _buildProviderResultItem(provider, colorScheme)),
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

  Widget _buildProviderResultItem(DnsProviderResult provider, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: provider.success 
              ? Colors.green.withOpacity(0.3)
              : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            provider.success ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: provider.success ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.provider,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (provider.success && provider.addresses.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    provider.addresses.join(', '),
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (!provider.success && provider.message.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    provider.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (provider.success) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${provider.latency}ms',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
