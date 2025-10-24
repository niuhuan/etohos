import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:etohos/utils/logger.dart';

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
      const SnackBar(
        content: Text('Logs cleared successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _exportLogs() {
    final logText = AppLogger.exportLogs();
    Clipboard.setData(ClipboardData(text: logText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logs copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = _filteredLogs;
    final stats = AppLogger.getLogStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearLogs,
            tooltip: 'Clear logs',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _exportLogs,
            tooltip: 'Copy logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Container(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search logs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchText = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Log Level: '),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildLogLevelChip('All', Colors.grey, null),
                            _buildLogLevelChip('Debug', Colors.blue, LogLevel.debug),
                            _buildLogLevelChip('Info', Colors.green, LogLevel.info),
                            _buildLogLevelChip('Warning', Colors.orange, LogLevel.warning),
                            _buildLogLevelChip('Error', Colors.red, LogLevel.error),
                            _buildLogLevelChip('Fatal', Colors.purple, LogLevel.fatal),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 统计信息 - 折行显示
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Text('Total: ${AppLogger.getLogs().length}'),
                    Text('Filtered: ${filteredLogs.length}'),
                    Text('Debug: ${stats[LogLevel.debug]}'),
                    Text('Info: ${stats[LogLevel.info]}'),
                    Text('Warn: ${stats[LogLevel.warning]}'),
                    Text('Error: ${stats[LogLevel.error]}'),
                    Text('Fatal: ${stats[LogLevel.fatal]}'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          
          // 日志列表
          Expanded(
            child: filteredLogs.isEmpty
                ? const Center(
                    child: Text(
                      'No logs available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getLogColor(log.level).withOpacity(0.1),
                          border: Border(
                            left: BorderSide(
                              color: _getLogColor(log.level),
                              width: 3,
                            ),
                          ),
                        ),
                        child: SelectableText(
                          log.toString(),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: _getLogColor(log.level),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // 底部操作栏
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Showing ${filteredLogs.length} of ${AppLogger.getLogs().length} logs',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    AppLogger.info('Test log message ${DateTime.now().millisecondsSinceEpoch}');
                    setState(() {});
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Test Log'),
                ),
              ],
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