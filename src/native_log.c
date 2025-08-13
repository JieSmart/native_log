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
    const char* log_type_str = "";
    
    // 合并两个switch语句，同时设置log_type和log_type_str
    switch (level) {
        case 0: 
            log_type = OS_LOG_TYPE_DEBUG;
            log_type_str = "V";
            break;
        case 1: 
            log_type = OS_LOG_TYPE_DEBUG;
            log_type_str = "D";
            break;
        case 2: 
            log_type = OS_LOG_TYPE_INFO;
            log_type_str = "I";
            break;
        case 3: 
            log_type = OS_LOG_TYPE_ERROR;
            log_type_str = "W";
            break;
        case 4: 
            log_type = OS_LOG_TYPE_FAULT;
            log_type_str = "E";
            break;
        case 5: 
            log_type = OS_LOG_TYPE_FAULT;
            log_type_str = "F";
            break;
        default: 
            log_type = OS_LOG_TYPE_DEFAULT;
            log_type_str = "D";
            break;
    }
    
    // 获取当前时间
    time_t now;
    time(&now);
    struct tm* timeinfo = localtime(&now);
    // 修改时间格式为不带时区的格式
    char time_buffer[25];
    strftime(time_buffer, sizeof(time_buffer), "%Y-%m-%d %H:%M:%S", timeinfo);
    // 添加毫秒信息
    struct timeval tv;
    gettimeofday(&tv, NULL);
    int millis = tv.tv_usec / 1000;
    char final_time_buffer[30];
    snprintf(final_time_buffer, sizeof(final_time_buffer), "%s.%03d", time_buffer, millis);
    
    os_log_with_type(OS_LOG_DEFAULT, log_type, "[%{public}s] [%{public}s] [%{public}s] %{public}s", final_time_buffer, log_type_str, tag, message);
#else
    // Fallback for other platforms
    // 获取当前时间
    time_t now;
    time(&now);
    struct tm* timeinfo = localtime(&now);
    // 修改时间格式为不带时区的格式
    char time_buffer[25];
    strftime(time_buffer, sizeof(time_buffer), "%Y-%m-%d %H:%M:%S", timeinfo);
    // 添加毫秒信息
    struct timeval tv;
    gettimeofday(&tv, NULL);
    int millis = tv.tv_usec / 1000;
    char final_time_buffer[30];
    snprintf(final_time_buffer, sizeof(final_time_buffer), "%s.%03d", time_buffer, millis);
    
    printf("[%s] [%s] %s\n", final_time_buffer, tag, message);
    fflush(stdout); // 确保输出立即刷新
#endif
}
