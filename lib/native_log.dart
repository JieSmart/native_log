import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
// 添加developer导入以支持Flutter控制台日志
import 'dart:developer' as developer;
import 'dart:convert'; // 添加utf8编码支持

import 'native_log_bindings_generated.dart';

// 添加日志级别的常量定义
class LogLevel {
  static const int verbose = 0;
  static const int debug = 1;
  static const int info = 2;
  static const int warn = 3;
  static const int error = 4;
  static const int fatal = 5;
}

// 预分配缓冲区大小
const int _MAX_TAG_LENGTH = 256;
const int _MAX_MESSAGE_LENGTH = 4096;

// 预分配的缓冲区
final Pointer<Char> _tagBuffer = _bindings.malloc(_MAX_TAG_LENGTH).cast<Char>();
final Pointer<Char> _messageBuffer = _bindings.malloc(_MAX_MESSAGE_LENGTH).cast<Char>();

// 添加队列相关变量
final List<_LogEntry> _logQueue = [];
bool _isProcessing = false;

// 日志条目类
class _LogEntry {
  final int level;
  final String tag;
  final String message;
  
  _LogEntry(this.level, this.tag, this.message);
}

// 添加调用 native custom_log 函数的方法
void customLog(int level, String tag, String message) {
  // 直接打印日志
  _printLog(level, tag, message);
}

// 新增: 专门用于队列模式的日志打印方法
void customLogWithQueue(int level, String tag, String message) {
  // 添加到队列中
  _logQueue.add(_LogEntry(level, tag, message));
  // 如果没有在处理，则开始处理
  if (!_isProcessing) {
    _processLogQueue();
  }
}

// 处理日志队列
void _processLogQueue() async {
  if (_logQueue.isEmpty) {
    _isProcessing = false;
    return;
  }
  
  _isProcessing = true;
  
  // 使用微任务队列避免阻塞主线程
  await Future.microtask(() {
    // 处理所有排队的日志条目
    while (_logQueue.isNotEmpty) {
      final entry = _logQueue.removeAt(0);
      _printLog(entry.level, entry.tag, entry.message);
    }
  });
  
  // 确保在所有日志处理完后重置处理状态
  _isProcessing = false;
}

// 实际打印日志的方法
void _printLog(int level, String tag, String message) {
  // 将Dart字符串转换为UTF-8编码的字节列表
  final tagBytes = utf8.encode(tag);
  final messageBytes = utf8.encode(message);
  
  // 检查字符串长度是否超过预分配的缓冲区大小
  if (tagBytes.length >= _MAX_TAG_LENGTH || messageBytes.length >= _MAX_MESSAGE_LENGTH) {
    // 如果超过预分配的缓冲区大小，使用原来的方式
    final tagPtr = _bindings.malloc(tagBytes.length + 1).cast<Char>();
    final messagePtr = _bindings.malloc(messageBytes.length + 1).cast<Char>();
    
    try {
      // 复制tag字节数据
      tagPtr.cast<Uint8>().asTypedList(tagBytes.length + 1)
        ..setAll(0, tagBytes)
        ..[tagBytes.length] = 0; // null终止符
        
      // 复制message字节数据
      messagePtr.cast<Uint8>().asTypedList(messageBytes.length + 1)
        ..setAll(0, messageBytes)
        ..[messageBytes.length] = 0; // null终止符
        
      _bindings.custom_log(level, tagPtr, messagePtr);
    } finally {
      _bindings.free(tagPtr.cast());
      _bindings.free(messagePtr.cast());
    }
  } else {
    // 使用预分配的缓冲区
    try {
      // 复制tag字节数据到预分配的缓冲区
      _tagBuffer.cast<Uint8>().asTypedList(tagBytes.length + 1)
        ..setAll(0, tagBytes)
        ..[tagBytes.length] = 0; // null终止符
        
      // 复制message字节数据到预分配的缓冲区
      _messageBuffer.cast<Uint8>().asTypedList(messageBytes.length + 1)
        ..setAll(0, messageBytes)
        ..[messageBytes.length] = 0; // null终止符
        
      _bindings.custom_log(level, _tagBuffer, _messageBuffer);
    } catch (e) {
      // 如果预分配缓冲区方式出现问题，回退到原来的方式
      final tagPtr = _bindings.malloc(tagBytes.length + 1).cast<Char>();
      final messagePtr = _bindings.malloc(messageBytes.length + 1).cast<Char>();
      
      try {
        // 复制tag字节数据
        tagPtr.cast<Uint8>().asTypedList(tagBytes.length + 1)
          ..setAll(0, tagBytes)
          ..[tagBytes.length] = 0; // null终止符
          
        // 复制message字节数据
        messagePtr.cast<Uint8>().asTypedList(messageBytes.length + 1)
          ..setAll(0, messageBytes)
          ..[messageBytes.length] = 0; // null终止符
          
        _bindings.custom_log(level, tagPtr, messagePtr);
      } finally {
        _bindings.free(tagPtr.cast());
        _bindings.free(messagePtr.cast());
      }
    }
  }

  if (Platform.isAndroid) return;
  
  // 添加与iOS原生日志相同格式的Flutter开发者日志
  final logLevelMap = {
    0: 'V',
    1: 'D',
    2: 'I',
    3: 'W',
    4: 'E',
    5: 'F'
  };

  final now = DateTime.now();
  // 修改时间格式为与native端一致的格式: YYYY-MM-DDTHH:MM:SS.SSS
  final timeStr = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${(now.millisecond).toString().padLeft(3, '0')}";
  final levelStr = logLevelMap[level] ?? 'D';

  developer.log(message, name: "$timeStr] [$levelStr] [$tag", level: level);
}

const String _libName = 'native_log';

/// The dynamic library in which the symbols for [NativeLogBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('${_libName}_plus.framework/${_libName}_plus');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final NativeLog _bindings = NativeLog(_dylib);