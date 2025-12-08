import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:etohos/l10n/l10n_extensions.dart';
import 'package:etohos/methods.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final _urlController = TextEditingController();
  final _bodyController = TextEditingController();
  String _selectedMethod = 'GET';
  final List<MapEntry<String, String>> _headers = [
    const MapEntry('Content-Type', 'application/json'),
  ];
  
  String _response = '';
  int? _statusCode;
  bool _isLoading = false;
  Map<String, String>? _responseHeaders;

  final List<String> _methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'];

  @override
  void dispose() {
    _urlController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _addHeader() {
    setState(() {
      _headers.add(const MapEntry('', ''));
    });
  }

  void _removeHeader(int index) {
    setState(() {
      _headers.removeAt(index);
    });
  }

  void _updateHeader(int index, String key, String value) {
    setState(() {
      _headers[index] = MapEntry(key, value);
    });
  }

  Future<void> _sendRequest() async {
    if (_urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('please_enter_url'))),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _response = '';
      _statusCode = null;
      _responseHeaders = null;
    });

    try {
      final headers = Map.fromEntries(
        _headers.where((e) => e.key.isNotEmpty && e.value.isNotEmpty),
      );

      final response = await methods.httpRequest(
        method: _selectedMethod,
        url: _urlController.text.trim(),
        headers: headers,
        body: _bodyController.text,
      );

      setState(() {
        _statusCode = response.statusCode;
        _responseHeaders = response.headers;
        
        // Try to format JSON response
        try {
          final jsonData = jsonDecode(response.body);
          _response = const JsonEncoder.withIndent('  ').convert(jsonData);
        } catch (e) {
          _response = response.body;
        }
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('api_test')),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Method and URL
                  Row(
                    children: [
                      // Method dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedMethod,
                          underline: const SizedBox(),
                          items: _methods.map((method) {
                            return DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedMethod = value;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // URL input
                      Expanded(
                        child: TextField(
                          controller: _urlController,
                          decoration: InputDecoration(
                            hintText: t('enter_url'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Headers section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t('headers'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addHeader,
                        tooltip: t('add_header'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._headers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final header = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: t('header_key'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              controller: TextEditingController(text: header.key)
                                ..selection = TextSelection.collapsed(
                                  offset: header.key.length,
                                ),
                              onChanged: (value) {
                                _updateHeader(index, value, header.value);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: t('header_value'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              controller: TextEditingController(text: header.value)
                                ..selection = TextSelection.collapsed(
                                  offset: header.value.length,
                                ),
                              onChanged: (value) {
                                _updateHeader(index, header.key, value);
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () => _removeHeader(index),
                            tooltip: t('remove_header'),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),

                  // Request Body (only for POST, PUT, PATCH)
                  if (_selectedMethod == 'POST' ||
                      _selectedMethod == 'PUT' ||
                      _selectedMethod == 'PATCH') ...[
                    Text(
                      t('request_body'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bodyController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: t('enter_request_body'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Send button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendRequest,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(t('send_request')),
                  ),
                  const SizedBox(height: 24),

                  // Response section
                  if (_response.isNotEmpty || _statusCode != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          t('response'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_statusCode != null)
                          Chip(
                            label: Text(
                              'Status: $_statusCode',
                              style: TextStyle(
                                color: _statusCode! >= 200 && _statusCode! < 300
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Response headers
                    if (_responseHeaders != null && _responseHeaders!.isNotEmpty) ...[
                      ExpansionTile(
                        title: Text(t('response_headers')),
                        children: _responseHeaders!.entries.map((entry) {
                          return ListTile(
                            dense: true,
                            title: Text(entry.key),
                            subtitle: Text(entry.value),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: SelectableText(
                        _response,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
