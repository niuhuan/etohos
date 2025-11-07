import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:etohos/utils/logger.dart';
import 'package:etohos/utils/text_field_utils.dart';
import 'package:etohos/l10n/l10n_extensions.dart';
import 'package:signals_flutter/signals_flutter.dart';

class LogViewer extends StatefulWidget {
  const LogViewer({super.key});

  @override
  State<LogViewer> createState() => _LogViewerState();
}

class _LogViewerState extends State<LogViewer> {
  final ScrollController _scrollController = ScrollController();
  LogLevel? _selectedLevel;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LogEntry> get _filteredLogs {
    var logs = AppLogger.getLogs();
    
    // 按级别过滤
    if (_selectedLevel != null) {
      logs = logs.where((log) => log.level == _selectedLevel).toList();
    }
    
    // 按搜索文本过滤
    if (_searchText.isNotEmpty) {
      logs = logs.where((log) => 
        log.message.toLowerCase().contains(_searchText.toLowerCase()) ||
        (log.tag?.toLowerCase().contains(_searchText.toLowerCase()) ?? false)
      ).toList();
    }
    
    return logs;
  }

  void _clearLogs() {
    AppLogger.clearLogs();
    setState(() {});
    AppLogger.info('Logs cleared');
    
    // 显示清除成功的提示
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t('logs_cleared')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _exportLogs() {
    final logText = AppLogger.exportLogs();
    Clipboard.setData(ClipboardData(text: logText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t('logs_copied'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) => _build(context));
  }

  Widget _build(BuildContext context) {
    final filteredLogs = _filteredLogs;
    final stats = AppLogger.getLogStats();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.list_alt, size: 20),
            ),
            const SizedBox(width: 12),
            Text(t('log_viewer')),
          ],
        ),
        // 移除渐变色，使用主题定义的backgroundColor
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearLogs,
              tooltip: t('clear_logs'),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.copy_all),
              onPressed: _exportLogs,
              tooltip: t('copy_logs'),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surface,
              colorScheme.primaryContainer.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
        children: [
          // 搜索栏 - 现代化设计
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              enableInteractiveSelection: TextFieldConfig.enableInteractiveSelection,
              textCapitalization: TextFieldConfig.textCapitalization,
              contextMenuBuilder: TextFieldConfig.contextMenuBuilder,
              decoration: InputDecoration(
                hintText: t('search_logs'),
                hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: colorScheme.error),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchText = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
          
          // 日志级别过滤器和统计
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 过滤器标题
                Row(
                  children: [
                    Icon(Icons.filter_list, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      t('log_filter'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 级别筛选
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildLogLevelChip(t('log_level_all'), Colors.grey, null),
                      _buildLogLevelChip(t('log_level_debug'), Colors.blue, LogLevel.debug),
                      _buildLogLevelChip(t('log_level_info'), Colors.green, LogLevel.info),
                      _buildLogLevelChip(t('log_level_warning'), Colors.orange, LogLevel.warning),
                      _buildLogLevelChip(t('log_level_error'), Colors.red, LogLevel.error),
                      _buildLogLevelChip(t('log_level_fatal'), Colors.purple, LogLevel.fatal),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                // 统计信息 - 美化显示
                Row(
                  children: [
                    Icon(Icons.bar_chart, size: 18, color: colorScheme.secondary),
                    const SizedBox(width: 8),
                    Text(
                      t('statistics'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildStatChip(t('total'), AppLogger.getLogs().length, Colors.grey),
                    _buildStatChip(t('filtered'), filteredLogs.length, colorScheme.primary),
                    _buildStatChip(t('log_level_debug'), stats[LogLevel.debug] ?? 0, Colors.blue),
                    _buildStatChip(t('log_level_info'), stats[LogLevel.info] ?? 0, Colors.green),
                    _buildStatChip(t('log_level_warning'), stats[LogLevel.warning] ?? 0, Colors.orange),
                    _buildStatChip(t('log_level_error'), stats[LogLevel.error] ?? 0, Colors.red),
                    _buildStatChip(t('log_level_fatal'), stats[LogLevel.fatal] ?? 0, Colors.purple),
                  ],
                ),
              ],
            ),
          ),
          
          // 日志列表
          Expanded(
            child: filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t('no_logs'),
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return _buildLogItem(log, colorScheme);
                    },
                  ),
          ),
        ],
      ),
      ),
    );
  }
  
  Widget _buildLogItem(LogEntry log, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getLogColor(log.level).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _getLogColor(log.level).withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 左侧彩色条
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _getLogColor(log.level),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            // 日志内容
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 日志级别和标签
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getLogColor(log.level).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getLogLevelText(log.level),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getLogColor(log.level),
                            ),
                          ),
                        ),
                        if (log.tag != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              log.tag!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          _formatTime(log.timestamp),
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 日志消息
                    SelectableText(
                      log.message,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                    // 错误信息
                    if (log.error != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          'Error: ${log.error}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.red,
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
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
  
  String _getLogLevelText(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return t('log_level_debug');
      case LogLevel.info:
        return t('log_level_info');
      case LogLevel.warning:
        return t('log_level_warning');
      case LogLevel.error:
        return t('log_level_error');
      case LogLevel.fatal:
        return t('log_level_fatal');
    }
  }
  
  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogLevelChip(String label, Color color, LogLevel? level) {
    final isSelected = _selectedLevel == level;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedLevel = selected ? level : null;
          });
        },
        selectedColor: color.withOpacity(0.2),
        checkmarkColor: color,
      ),
    );
  }

  Color _getLogColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return Colors.blue;
      case LogLevel.info:
        return Colors.green;
      case LogLevel.warning:
        return Colors.orange;
      case LogLevel.error:
        return Colors.red;
      case LogLevel.fatal:
        return Colors.purple;
    }
  }
}