import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:etohos/l10n/l10n_extensions.dart';
import 'package:etohos/models/api_request.dart';
import 'package:etohos/models/environment.dart';
import 'package:etohos/models/api_collection.dart';
import 'package:etohos/storage/api_request_storage.dart';
import 'package:etohos/storage/environment_storage.dart';
import 'package:etohos/storage/collection_storage.dart';
import 'package:etohos/environment_manager_screen.dart' show EnvironmentEditorScreen;
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
  List<Environment> _environments = [];
  Environment? _selectedEnvironment;
  List<ApiCollection> _collections = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // 更新 FloatingActionButton
    });
    _loadData();
  }

  Future<void> _loadData() async {
    final requests = await ApiRequestStorage.loadRequests();
    final history = await ApiRequestStorage.loadHistory();
    final environments = await EnvironmentStorage.loadEnvironments();
    final collections = await CollectionStorage.loadCollections();
    final defaultEnv = await EnvironmentStorage.getDefaultEnvironment();
    
    setState(() {
      _savedRequests = requests;
      _history = history;
      _environments = environments;
      _selectedEnvironment = defaultEnv;
      _collections = collections;
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('api_test')),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.onSurface,
          unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: colorScheme.primary,
          tabs: [
            Tab(icon: const Icon(Icons.list), text: t('saved_requests')),
            Tab(icon: const Icon(Icons.history), text: t('history')),
            Tab(icon: const Icon(Icons.settings_applications), text: t('environment')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsTab(),
          _buildHistoryTab(),
          _buildEnvironmentTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _createNewRequest,
              child: const Icon(Icons.add),
              tooltip: t('new_request'),
            )
          : _tabController.index == 2
              ? FloatingActionButton(
                  onPressed: () async {
                    final result = await Navigator.of(context).push<Environment>(
                      MaterialPageRoute(
                        builder: (context) => EnvironmentEditorScreen(
                          environment: Environment(
                            id: const Uuid().v4(),
                            name: t('new_environment'),
                            variables: {},
                            isDefault: false,
                          ),
                        ),
                      ),
                    );
                    if (result != null) {
                      await EnvironmentStorage.saveEnvironment(result);
                      _loadData();
                    }
                  },
                  child: const Icon(Icons.add),
                  tooltip: t('new_environment'),
                )
              : null,
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

    // 按集合分组
    final rootCollections = _collections.where((c) => c.parentId == null).toList();
    final requestsWithoutCollection = _savedRequests.where((r) => r.collectionId == null).toList();
    
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: rootCollections.length + requestsWithoutCollection.length,
      itemBuilder: (context, index) {
        // 先显示集合
        if (index < rootCollections.length) {
          final collection = rootCollections[index];
          final collectionRequests = _savedRequests.where((r) => r.collectionId == collection.id).toList();
          
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
              leading: Icon(Icons.folder, color: Colors.orange),
              title: Text(
                collection.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${collectionRequests.length} ${t('requests')}',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              children: collectionRequests.map((request) {
                return _buildRequestCard(request, colorScheme);
              }).toList(),
            ),
          );
        }
        
        // 然后显示没有集合的请求
        final requestIndex = index - rootCollections.length;
        final request = requestsWithoutCollection[requestIndex];
        return _buildRequestCard(request, colorScheme);
      },
    );
  }

  Widget _buildRequestCard(ApiRequest request, ColorScheme colorScheme) {
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
  }

  Widget _buildEnvironmentTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // 当前选择的环境显示
        if (_selectedEnvironment != null)
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('current_environment'),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedEnvironment!.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<Environment>(
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: colorScheme.primary,
                  ),
                  tooltip: t('switch_environment'),
                  itemBuilder: (context) => _environments.map((env) {
                    return PopupMenuItem(
                      value: env,
                      child: Row(
                        children: [
                          if (env.id == _selectedEnvironment?.id)
                            Icon(Icons.check, size: 20, color: colorScheme.primary),
                          if (env.id != _selectedEnvironment?.id)
                            const SizedBox(width: 20),
                          Expanded(child: Text(env.name)),
                          if (env.isDefault)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                t('default'),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  onSelected: (env) {
                    setState(() {
                      _selectedEnvironment = env;
                    });
                  },
                ),
              ],
            ),
          ),
        
        // 环境列表
        Expanded(
          child: _environments.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.settings_applications_outlined,
                          size: 64,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t('no_environments'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t('tap_add_to_create_environment'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.of(context).push<Environment>(
                              MaterialPageRoute(
                                builder: (context) => EnvironmentEditorScreen(
                                  environment: Environment(
                                    id: const Uuid().v4(),
                                    name: t('new_environment'),
                                    variables: {},
                                    isDefault: false,
                                  ),
                                ),
                              ),
                            );
                            if (result != null) {
                              await EnvironmentStorage.saveEnvironment(result);
                              _loadData();
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: Text(t('new_environment')),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _environments.length,
                  itemBuilder: (context, index) {
                    final environment = _environments[index];
                    final isSelected = environment.id == _selectedEnvironment?.id;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected
                              ? colorScheme.primary.withOpacity(0.5)
                              : colorScheme.outline.withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () async {
                          final result = await Navigator.of(context).push<Environment>(
                            MaterialPageRoute(
                              builder: (context) => EnvironmentEditorScreen(environment: environment),
                            ),
                          );
                          if (result != null) {
                            await EnvironmentStorage.saveEnvironment(result);
                            _loadData();
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (isSelected
                                          ? colorScheme.primary
                                          : (environment.isDefault
                                              ? colorScheme.primary
                                              : Colors.blue))
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.settings_applications,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : (environment.isDefault
                                          ? colorScheme.primary
                                          : Colors.blue),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          environment.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                        if (environment.isDefault) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primaryContainer
                                                  .withOpacity(0.5),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              t('default'),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (isSelected) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primaryContainer
                                                  .withOpacity(0.5),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              t('selected'),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${environment.variables.length} ${t('variables')}',
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
                                    value: 'select',
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle_outline,
                                            size: 20, color: colorScheme.primary),
                                        const SizedBox(width: 12),
                                        Text(t('select')),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined,
                                            size: 20, color: colorScheme.primary),
                                        const SizedBox(width: 12),
                                        Text(t('edit')),
                                      ],
                                    ),
                                  ),
                                  if (!environment.isDefault)
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline,
                                              size: 20, color: Colors.red),
                                          const SizedBox(width: 12),
                                          Text(
                                            t('delete'),
                                            style: const TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                                onSelected: (value) async {
                                  if (value == 'select') {
                                    setState(() {
                                      _selectedEnvironment = environment;
                                    });
                                  } else if (value == 'edit') {
                                    final result = await Navigator.of(context).push<Environment>(
                                      MaterialPageRoute(
                                        builder: (context) => EnvironmentEditorScreen(environment: environment),
                                      ),
                                    );
                                    if (result != null) {
                                      await EnvironmentStorage.saveEnvironment(result);
                                      _loadData();
                                    }
                                  } else if (value == 'delete') {
                                    await EnvironmentStorage.deleteEnvironment(environment.id);
                                    _loadData();
                                    if (environment.id == _selectedEnvironment?.id) {
                                      final defaultEnv = await EnvironmentStorage.getDefaultEnvironment();
                                      setState(() {
                                        _selectedEnvironment = defaultEnv;
                                      });
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(t('environment_deleted'))),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
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

    return Column(
      children: [
        // 顶部操作栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_history.length} ${t('records')}',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              InkWell(
                onTap: _clearAllHistory,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 14,
                        color: colorScheme.onSurface.withOpacity(0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        t('clear_all'),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: colorScheme.outline.withOpacity(0.1)),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _history.length,
            reverse: true,
            itemBuilder: (context, index) {
              final history = _history[_history.length - 1 - index];
              final statusColor = history.statusCode >= 200 && history.statusCode < 300
                  ? Colors.green
                  : (history.statusCode >= 400 ? Colors.red : Colors.orange);

              return Dismissible(
                key: Key('${history.timestamp.millisecondsSinceEpoch}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  _deleteHistoryItem(history);
                },
                child: Card(
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
                    onTap: () => _showHistoryDetail(history),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildMethodChip(history.request.method),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  history.request.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // IconButton(
                              //   icon: Icon(
                              //     Icons.delete_outline,
                              //     size: 20,
                              //     color: colorScheme.onSurface.withOpacity(0.5),
                              //   ),
                              //   onPressed: () => _confirmDeleteHistory(history),
                              //   padding: EdgeInsets.zero,
                              //   constraints: const BoxConstraints(),
                              // ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            history.request.url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 12),
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
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showHistoryDetail(ApiTestHistory history) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = history.statusCode >= 200 && history.statusCode < 300
        ? Colors.green
        : (history.statusCode >= 400 ? Colors.red : Colors.orange);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(history.request.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  Navigator.of(context).pop();
                  _confirmDeleteHistory(history);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 概览卡片
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildMethodChip(history.request.method),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${history.statusCode}',
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${history.duration}ms',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SelectableText(
                          history.request.url,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDateTime(history.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 请求头
                if (history.request.headers.isNotEmpty) ...[
                  _buildDetailSection(
                    title: t('headers'),
                    icon: Icons.list_alt,
                    child: Column(
                      children: history.request.headers.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${e.key}: ',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                            Expanded(
                              child: SelectableText(
                                e.value,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // 请求体
                if (history.request.body.isNotEmpty) ...[
                  _buildDetailSection(
                    title: t('request_body'),
                    icon: Icons.send,
                    child: SelectableText(
                      history.request.body,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // 响应体
                _buildDetailSection(
                  title: t('response_body'),
                  icon: Icons.code,
                  child: SelectableText(
                    history.responseBody,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  void _confirmDeleteHistory(ApiTestHistory history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('confirm_delete')),
        content: Text(t('confirm_delete_history')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteHistoryItem(history);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t('delete')),
          ),
        ],
      ),
    );
  }

  void _deleteHistoryItem(ApiTestHistory history) async {
    setState(() {
      _history.removeWhere((h) => h.timestamp == history.timestamp);
    });
    await ApiRequestStorage.saveHistory(_history);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('history_deleted'))),
      );
    }
  }

  void _clearAllHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('confirm_delete')),
        content: Text(t('confirm_clear_all_history')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t('cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() {
                _history.clear();
              });
              await ApiRequestStorage.clearHistory();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(t('history_cleared'))),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(t('clear')),
          ),
        ],
      ),
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
  
  List<Environment> _environments = [];
  Environment? _selectedEnvironment;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.request.name);
    _urlController = TextEditingController(text: widget.request.url);
    _bodyController = TextEditingController(text: widget.request.body);
    _selectedMethod = widget.request.method;
    _headers = widget.request.headers.entries.toList();
    _loadEnvironments();
  }
  
  Future<void> _loadEnvironments() async {
    final environments = await EnvironmentStorage.loadEnvironments();
    final defaultEnv = await EnvironmentStorage.getDefaultEnvironment();
    setState(() {
      _environments = environments;
      _selectedEnvironment = defaultEnv;
    });
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
      // 替换环境变量
      String finalUrl = _urlController.text.trim();
      String finalBody = _bodyController.text;
      Map<String, String> finalHeaders = Map.fromEntries(
        _headers.where((e) => e.key.isNotEmpty && e.value.isNotEmpty),
      );
      
      if (_selectedEnvironment != null) {
        finalUrl = _selectedEnvironment!.replaceVariables(finalUrl);
        finalBody = _selectedEnvironment!.replaceVariables(finalBody);
        finalHeaders = finalHeaders.map((key, value) => MapEntry(
          _selectedEnvironment!.replaceVariables(key),
          _selectedEnvironment!.replaceVariables(value),
        ));
      }

      final response = await methods.httpRequest(
        method: _selectedMethod,
        url: finalUrl,
        headers: finalHeaders,
        body: finalBody,
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

  void _showCurlCode() {
    final request = _getCurrentRequest();
    final curlCommand = _generateCurlCommand(request);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('curl_command')),
        content: SelectableText(
          curlCommand,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
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

  String _generateCurlCommand(ApiRequest request) {
    final buffer = StringBuffer();
    buffer.write('curl -X $request.method');
    
    // Headers
    request.headers.forEach((key, value) {
      buffer.write(' \\\n  -H "$key: $value"');
    });
    
    // Body
    if (request.body.isNotEmpty && 
        (request.method == 'POST' || request.method == 'PUT' || request.method == 'PATCH')) {
      buffer.write(' \\\n  -d \'${request.body.replaceAll("'", "\\'")}\'');
    }
    
    // URL
    buffer.write(' \\\n  "${request.url}"');
    
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t('api_request')),
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            onPressed: _showCurlCode,
            tooltip: t('generate_curl'),
          ),
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
                  // Environment selector
                  if (_environments.isNotEmpty) ...[
                    Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.settings_applications, color: Theme.of(context).colorScheme.primary),
                        title: Text(t('environment')),
                        subtitle: Text(_selectedEnvironment?.name ?? t('no_environment')),
                        trailing: PopupMenuButton<Environment>(
                          icon: const Icon(Icons.arrow_drop_down),
                          itemBuilder: (context) => _environments.map((env) {
                            return PopupMenuItem(
                              value: env,
                              child: Row(
                                children: [
                                  if (env.id == _selectedEnvironment?.id)
                                    Icon(Icons.check, size: 20, color: Theme.of(context).colorScheme.primary),
                                  if (env.id != _selectedEnvironment?.id)
                                    const SizedBox(width: 20),
                                  Expanded(child: Text(env.name)),
                                ],
                              ),
                            );
                          }).toList(),
                          onSelected: (env) {
                            setState(() {
                              _selectedEnvironment = env;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
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
