#include "native_log.h"

#if defined(__ANDROID__)
#include <android/log.h>
#elif defined(__APPLE__)
#include <os/log.h>
#endif

// Custom log function with level, tag and message
FFI_PLUGIN_EXPORT void custom_log(int level, const char* tag, const char* message) {
#if defined(__ANDROID__)
    android_LogPriority android_level = ANDROID_LOG_DEBUG;
    switch (level) {
        case 0: android_level = ANDROID_LOG_VERBOSE; break;
        case 1: android_level = ANDROID_LOG_DEBUG; break;
        case 2: android_level = ANDROID_LOG_INFO; break;
        case 3: android_level = ANDROID_LOG_WARN; break;
        case 4: android_level = ANDROID_LOG_ERROR; break;
        case 5: android_level = ANDROID_LOG_FATAL; break;
        default: android_level = ANDROID_LOG_DEBUG; break;
    }
    __android_log_print(android_level, tag, "%s", message);
#elif defined(__APPLE__)
    // iOS/macOS logging
    os_log_type_t log_type = OS_LOG_TYPE_DEFAULT;
    switch (level) {
        case 0: 
        case 1: log_type = OS_LOG_TYPE_DEBUG; break;
        case 2: log_type = OS_LOG_TYPE_INFO; break;
        case 3: log_type = OS_LOG_TYPE_ERROR; break;
        case 4: 
        case 5: log_type = OS_LOG_TYPE_FAULT; break;
        default: log_type = OS_LOG_TYPE_DEFAULT; break;
    }
    os_log_with_type(OS_LOG_DEFAULT, log_type, "[%{public}s] %{public}s", tag, message);
#else
    // Fallback for other platforms
    printf("[%s] %s\n", tag, message);
    fflush(stdout); // 确保输出立即刷新
#endif
}