import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:etohos/l10n/l10n_extensions.dart';
import 'package:etohos/models/api_request.dart';
import 'package:etohos/storage/api_request_storage.dart';
import 'package:etohos/methods.dart';
import 'package:uuid/uuid.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ApiRequest> _savedRequests = [];
  List<ApiTestHistory> _history = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final requests = await ApiRequestStorage.loadRequests();
    final history = await ApiRequestStorage.loadHistory();
    
    setState(() {
      _savedRequests = requests;
      _history = history;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _createNewRequest() {
    final newRequest = ApiRequest(
      id: const Uuid().v4(),
      name: t('new_request'),
      method: 'GET',
      url: '',
      headers: {'Content-Type': 'application/json'},
      body: '',
      createdAt: DateTime.now(),
    );
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ApiRequestEditorScreen(request: newRequest),
      ),
    ).then((_) => _loadData());
  }

  void _editRequest(ApiRequest request) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ApiRequestEditorScreen(request: request),
      ),
    ).then((_) => _loadData());
  }

  Future<void> _deleteRequest(ApiRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('delete')),
        content: Text(t('confirm_delete_request').replaceAll('{name}', request.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ApiRequestStorage.deleteRequest(request.id);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('request_deleted'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('api_test')),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.onSurface,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: [
            Tab(icon: const Icon(Icons.list), text: t('saved_requests')),
            Tab(icon: const Icon(Icons.history), text: t('history')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewRequest,
        child: const Icon(Icons.add),
        tooltip: t('new_request'),
      ),
    );
  }

  Widget _buildRequestsTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (_savedRequests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.api_outlined,
                  size: 64,
                  color: colorScheme.primary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                t('no_saved_requests'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t('tap_add_to_create'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _savedRequests.length,
      itemBuilder: (context, index) {
        final request = _savedRequests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () => _editRequest(request),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildMethodChip(request.method),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request.url.isEmpty ? t('no_url_set') : request.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20, color: colorScheme.primary),
                            const SizedBox(width: 12),
                            Text(t('edit')),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20, color: Colors.red),
                            const SizedBox(width: 12),
                            Text(
                              t('delete'),
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editRequest(request);
                      } else if (value == 'delete') {
                        _deleteRequest(request);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (_history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history_outlined,
                  size: 64,
                  color: colorScheme.secondary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                t('no_history'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t('tap_add_to_create'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _history.length,
      reverse: true,
      itemBuilder: (context, index) {
        final history = _history[_history.length - 1 - index];
        final statusColor = history.statusCode >= 200 && history.statusCode < 300
            ? Colors.green
            : (history.statusCode >= 400 ? Colors.red : Colors.orange);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.all(16),
            leading: _buildMethodChip(history.request.method),
            title: Text(
              history.request.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history.request.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              history.statusCode >= 200 && history.statusCode < 300
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${history.statusCode}',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 14,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${history.duration}ms',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_outlined,
                              size: 14,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateTime(history.timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            children: [
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.code_outlined,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t('response_body'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      history.responseBody.length > 1000
                          ? '${history.responseBody.substring(0, 1000)}...'
                          : history.responseBody,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildMethodChip(String method) {
    Color color;
    IconData icon;
    switch (method.toUpperCase()) {
      case 'GET':
        color = Colors.blue;
        icon = Icons.get_app;
        break;
      case 'POST':
        color = Colors.green;
        icon = Icons.add_circle;
        break;
      case 'PUT':
        color = Colors.orange;
        icon = Icons.edit;
        break;
      case 'DELETE':
        color = Colors.red;
        icon = Icons.delete;
        break;
      case 'PATCH':
        color = Colors.purple;
        icon = Icons.update;
        break;
      default:
        color = Colors.grey;
        icon = Icons.http;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            method.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return t('just_now');
    } else if (diff.inMinutes < 60) {
      return t('minutes_ago').replaceAll('{n}', '${diff.inMinutes}');
    } else if (diff.inHours < 24) {
      return t('hours_ago').replaceAll('{n}', '${diff.inHours}');
    } else if (diff.inDays < 7) {
      return t('days_ago').replaceAll('{n}', '${diff.inDays}');
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}

/// API 请求编辑器界面
class ApiRequestEditorScreen extends StatefulWidget {
  final ApiRequest request;

  const ApiRequestEditorScreen({super.key, required this.request});

  @override
  State<ApiRequestEditorScreen> createState() => _ApiRequestEditorScreenState();
}

class _ApiRequestEditorScreenState extends State<ApiRequestEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late TextEditingController _bodyController;
  late String _selectedMethod;
  late List<MapEntry<String, String>> _headers;
  
  String _response = '';
  int? _statusCode;
  bool _isLoading = false;
  Map<String, String>? _responseHeaders;
  int _responseDuration = 0;

  final List<String> _methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.request.name);
    _urlController = TextEditingController(text: widget.request.url);
    _bodyController = TextEditingController(text: widget.request.body);
    _selectedMethod = widget.request.method;
    _headers = widget.request.headers.entries.toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
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
      _responseDuration = 0;
    });

    final startTime = DateTime.now();

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

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds;

      setState(() {
        _statusCode = response.statusCode;
        _responseHeaders = response.headers;
        _responseDuration = duration;
        
        // Try to format JSON response
        try {
          final jsonData = jsonDecode(response.body);
          _response = const JsonEncoder.withIndent('  ').convert(jsonData);
        } catch (e) {
          _response = response.body;
        }
      });

      // Save to history
      final history = ApiTestHistory(
        id: const Uuid().v4(),
        request: _getCurrentRequest(),
        statusCode: response.statusCode,
        responseHeaders: response.headers,
        responseBody: response.body,
        timestamp: DateTime.now(),
        duration: duration,
      );

      await ApiRequestStorage.addHistory(history);

    } catch (e) {
      setState(() {
        _response = 'Error: $e';
        _statusCode = 0;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  ApiRequest _getCurrentRequest() {
    return widget.request.copyWith(
      name: _nameController.text.trim().isEmpty ? t('unnamed_request') : _nameController.text.trim(),
      method: _selectedMethod,
      url: _urlController.text.trim(),
      headers: Map.fromEntries(
        _headers.where((e) => e.key.isNotEmpty && e.value.isNotEmpty),
      ),
      body: _bodyController.text,
      lastUsedAt: DateTime.now(),
    );
  }

  Future<void> _saveRequest() async {
    try {
      final request = _getCurrentRequest();
      await ApiRequestStorage.saveRequest(request);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('request_saved'))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t('failed_to_save')}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('api_request')),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRequest,
            tooltip: t('save'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Request Name
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: t('request_name'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.label),
                    ),
                  ),
                  const SizedBox(height: 16),

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
                              child: Text(
                                method,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
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
                            prefixIcon: const Icon(Icons.link),
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

                  // Request Body
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
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _sendRequest,
                    icon: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(t('send_request')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
                          Row(
                            children: [
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
                              const SizedBox(width: 8),
                              Chip(
                                label: Text('${_responseDuration}ms'),
                              ),
                            ],
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
