# native_log

[![pub package](https://img.shields.io/pub/v/native_log_plus.svg)](https://pub.dev/packages/native_log_plus)

调用原生日志函数的 Flutter 插件，支持 Android 和 iOS 平台。该插件通过 FFI 直接调用原生系统日志功能，提供高性能的日志记录能力。

## 功能特点

- ✅ 支持 Android Logcat 和 iOS os_log
- ✅ 多级别日志记录 (VERBOSE, DEBUG, INFO, WARN, ERROR, FATAL)
- ✅ 高性能，通过 Dart FFI 直接调用原生代码
- ✅ 支持队列模式，避免阻塞主线程
- ✅ 自动内存管理，防止内存泄漏
- ✅ 同时输出到 Flutter 开发者控制台

## 安装

在 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  native_log_plus: ^0.0.1
```
然后运行：

```bash
flutter pub get
```
## 使用方法

### 基本使用

```
dart
import 'package:native_log_plus/native_log.dart';

// 直接打印日志
customLog(LogLevel.info, 'MyTag', '这是一条信息日志');

// 不同级别的日志
customLog(LogLevel.verbose, 'MyTag', '详细日志');
customLog(LogLevel.debug, 'MyTag', '调试日志');
customLog(LogLevel.info, 'MyTag', '信息日志');
customLog(LogLevel.warn, 'MyTag', '警告日志');
customLog(LogLevel.error, 'MyTag', '错误日志');
customLog(LogLevel.fatal, 'MyTag', '致命错误日志');
```
### 队列模式

对于频繁的日志记录，建议使用队列模式以避免阻塞主线程：

```dart
// 使用队列模式记录日志
customLog(LogLevel.info, 'MyTag', '队列模式日志1');
customLog(LogLevel.info, 'MyTag', '队列模式日志2');
customLog(LogLevel.info, 'MyTag', '队列模式日志3');
```
### 日志级别说明

| 级别 | 值 | Android | iOS |
|------|----|---------|-----|
| VERBOSE | 0 | ANDROID_LOG_VERBOSE | OS_LOG_TYPE_DEBUG |
| DEBUG | 1 | ANDROID_LOG_DEBUG | OS_LOG_TYPE_DEBUG |
| INFO | 2 | ANDROID_LOG_INFO | OS_LOG_TYPE_INFO |
| WARN | 3 | ANDROID_LOG_WARN | OS_LOG_TYPE_ERROR |
| ERROR | 4 | ANDROID_LOG_ERROR | OS_LOG_TYPE_FAULT |
| FATAL | 5 | ANDROID_LOG_FATAL | OS_LOG_TYPE_FAULT |

## 性能优化

本插件采用以下优化措施：

1. **预分配缓冲区**：避免频繁内存分配
2. **队列处理**：支持异步处理大量日志
3. **UTF-8 编码**：高效字符串处理
4. **自动内存管理**：确保内存正确释放

## 支持平台

- Android (API 16+)
- iOS (9.0+)

## API 参考

### 主要函数

- `customLog(int level, String tag, String message)` - 记录日志
- `setUseQueue(bool useQueue)` - 设置是否使用队列模式
- `customLogWithQueue(int level, String tag, String message)` - 强制使用队列模式记录日志

### 日志级别常量

```
dart
class LogLevel {
static const int verbose = 0;
static const int debug = 1;
static const int info = 2;
static const int warn = 3;
static const int error = 4;
static const int fatal = 5;
}
```
## 注意事项

1. 在生产环境中建议适当控制日志级别，避免输出过多调试信息
2. 频繁的日志记录建议使用队列模式
3. 插件会同时输出到原生日志系统和 Flutter 开发者控制台
