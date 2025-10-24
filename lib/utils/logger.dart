import 'dart:collection';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? tag;
  final dynamic error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    this.error,
    this.stackTrace,
  });

  String get levelString {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.fatal:
        return 'FATAL';
    }
  }

  String get emoji {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.fatal:
        return '💀';
    }
  }

  @override
  String toString() {
    final timeStr = timestamp.toString().substring(11, 19);
    final tagStr = tag != null ? '[$tag] ' : '';
    final errorStr = error != null ? ' - Error: $error' : '';
    return '$emoji $timeStr [$levelString] $tagStr$message$errorStr';
  }
}

class AppLogger {
  static final Queue<LogEntry> _logs = Queue<LogEntry>();
  static const int _maxLogs = 1000;
  static LogLevel _minLevel = LogLevel.debug;

  // 设置最小日志级别
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  // 获取所有日志
  static List<LogEntry> getLogs() {
    return _logs.toList();
  }

  // 获取指定级别的日志
  static List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logs.where((log) => log.level == level).toList();
  }

  // 清空日志
  static void clearLogs() {
    _logs.clear();
  }

  // 添加日志
  static void _addLog(LogLevel level, String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    if (level.index < _minLevel.index) {
      return; // 低于最小级别，不记录
    }

    final logEntry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );

    _logs.add(logEntry);

    // 保持最多1000条日志
    if (_logs.length > _maxLogs) {
      _logs.removeFirst();
    }

    // 同时输出到控制台（开发时使用）
    print(logEntry.toString());
  }

  // Debug日志
  static void debug(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _addLog(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  // Info日志
  static void info(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _addLog(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  // Warning日志
  static void warning(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _addLog(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  // Error日志
  static void error(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _addLog(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  // Fatal日志
  static void fatal(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _addLog(LogLevel.fatal, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  // 网络请求日志
  static void network(String method, String url, {Map<String, dynamic>? data, int? statusCode, String? response}) {
    final message = '$method $url';
    if (statusCode != null) {
      info('$message - Status: $statusCode', tag: 'NETWORK');
    } else {
      info(message, tag: 'NETWORK');
    }
    
    if (data != null) {
      debug('Request data: $data', tag: 'NETWORK');
    }
    
    if (response != null) {
      debug('Response: $response', tag: 'NETWORK');
    }
  }

  // VPN连接日志
  static void vpn(String action, {String? instanceId, String? status, dynamic error}) {
    final message = 'VPN $action';
    if (instanceId != null) {
      info('$message - Instance: $instanceId', tag: 'VPN');
    } else {
      info(message, tag: 'VPN');
    }
    
    if (status != null) {
      info('Status: $status', tag: 'VPN');
    }
    
    if (error != null) {
      AppLogger.error('Error: $error', tag: 'VPN');
    }
  }

  // 网络状态日志
  static void networkStatus(String action, {String? ip, String? hostname, int? rxBytes, int? txBytes}) {
    final message = 'Network $action';
    if (ip != null) {
      info('$message - IP: $ip', tag: 'NETWORK_STATUS');
    } else {
      info(message, tag: 'NETWORK_STATUS');
    }
    
    if (hostname != null) {
      info('Hostname: $hostname', tag: 'NETWORK_STATUS');
    }
    
    if (rxBytes != null && txBytes != null) {
      debug('Traffic - RX: $rxBytes bytes, TX: $txBytes bytes', tag: 'NETWORK_STATUS');
    }
  }

  // 获取日志统计信息
  static Map<LogLevel, int> getLogStats() {
    final stats = <LogLevel, int>{};
    for (final level in LogLevel.values) {
      stats[level] = _logs.where((log) => log.level == level).length;
    }
    return stats;
  }

  // 导出日志为文本
  static String exportLogs() {
    return _logs.map((log) => log.toString()).join('\n');
  }
}

void _addTestLogs() {
  // 添加一些测试日志
  AppLogger.info('Log viewer initialized');
  AppLogger.debug('Debug message test');
  AppLogger.warning('Warning message test');
  AppLogger.error('Error message test');
  AppLogger.network('GET', 'https://api.example.com');
  AppLogger.vpn('connect', instanceId: 'test-instance');
  AppLogger.networkStatus('update', ip: '192.168.1.1', hostname: 'test-host');
}

var a = _addTestLogs();
