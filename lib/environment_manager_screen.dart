import 'package:flutter/material.dart';
import 'package:etohos/l10n/l10n_extensions.dart';
import 'package:etohos/models/environment.dart';
import 'package:etohos/storage/environment_storage.dart';
import 'package:uuid/uuid.dart';

/// 环境变量管理页面
class EnvironmentManagerScreen extends StatefulWidget {
  const EnvironmentManagerScreen({super.key});

  @override
  State<EnvironmentManagerScreen> createState() => _EnvironmentManagerScreenState();
}

class _EnvironmentManagerScreenState extends State<EnvironmentManagerScreen> {
  List<Environment> _environments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEnvironments();
  }

  Future<void> _loadEnvironments() async {
    setState(() {
      _isLoading = true;
    });
    
    final environments = await EnvironmentStorage.loadEnvironments();
    
    setState(() {
      _environments = environments;
      _isLoading = false;
    });
  }

  Future<void> _createEnvironment() async {
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
      _loadEnvironments();
    }
  }

  Future<void> _editEnvironment(Environment environment) async {
    final result = await Navigator.of(context).push<Environment>(
      MaterialPageRoute(
        builder: (context) => EnvironmentEditorScreen(environment: environment),
      ),
    );

    if (result != null) {
      await EnvironmentStorage.saveEnvironment(result);
      _loadEnvironments();
    }
  }

  Future<void> _deleteEnvironment(Environment environment) async {
    if (environment.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('cannot_delete_default_environment'))),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('delete')),
        content: Text(t('confirm_delete_environment').replaceAll('{name}', environment.name)),
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
      await EnvironmentStorage.deleteEnvironment(environment.id);
      _loadEnvironments();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('environment_deleted'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('environment_manager')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createEnvironment,
            tooltip: t('new_environment'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _environments.isEmpty
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
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _environments.length,
                  itemBuilder: (context, index) {
                    final environment = _environments[index];
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
                        onTap: () => _editEnvironment(environment),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (environment.isDefault
                                          ? colorScheme.primary
                                          : Colors.blue)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.settings_applications,
                                  color: environment.isDefault
                                      ? colorScheme.primary
                                      : Colors.blue,
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
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
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
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editEnvironment(environment);
                                  } else if (value == 'delete') {
                                    _deleteEnvironment(environment);
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
    );
  }
}

/// 环境编辑器页面
class EnvironmentEditorScreen extends StatefulWidget {
  final Environment environment;

  const EnvironmentEditorScreen({super.key, required this.environment});

  @override
  State<EnvironmentEditorScreen> createState() => _EnvironmentEditorScreenState();
}

class _EnvironmentEditorScreenState extends State<EnvironmentEditorScreen> {
  late TextEditingController _nameController;
  late List<MapEntry<String, String>> _variables;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.environment.name);
    _variables = widget.environment.variables.entries.toList();
    if (_variables.isEmpty) {
      _variables.add(const MapEntry('', ''));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addVariable() {
    setState(() {
      _variables.add(const MapEntry('', ''));
    });
  }

  void _removeVariable(int index) {
    setState(() {
      _variables.removeAt(index);
    });
  }

  void _updateVariable(int index, String key, String value) {
    setState(() {
      _variables[index] = MapEntry(key, value);
    });
  }

  Future<void> _saveEnvironment() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('please_enter_environment_name'))),
      );
      return;
    }

    final variables = Map.fromEntries(
      _variables.where((e) => e.key.isNotEmpty && e.value.isNotEmpty),
    );

    final environment = widget.environment.copyWith(
      name: _nameController.text.trim(),
      variables: variables,
    );

    await EnvironmentStorage.saveEnvironment(environment);
    
    if (mounted) {
      Navigator.of(context).pop(environment);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('environment_saved'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('edit_environment')),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEnvironment,
            tooltip: t('save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 环境名称
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: t('environment_name'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 24),

            // 变量列表
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t('variables'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addVariable,
                  tooltip: t('add_variable'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._variables.asMap().entries.map((entry) {
              final index = entry.key;
              final variable = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: t('variable_name'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        controller: TextEditingController(text: variable.key)
                          ..selection = TextSelection.collapsed(
                            offset: variable.key.length,
                          ),
                        onChanged: (value) {
                          _updateVariable(index, value, variable.value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: t('variable_value'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        controller: TextEditingController(text: variable.value)
                          ..selection = TextSelection.collapsed(
                            offset: variable.value.length,
                          ),
                        onChanged: (value) {
                          _updateVariable(index, variable.key, value);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => _removeVariable(index),
                      tooltip: t('remove_variable'),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 24),
            
            // 提示信息
            Card(
              elevation: 0,
              color: colorScheme.primaryContainer.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t('environment_variable_hint'),
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

