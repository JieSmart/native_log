# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(native_log_library VERSION 0.0.1 LANGUAGES C)

add_library(native_log SHARED
  "native_log.c"
)

set_target_properties(native_log PROPERTIES
  PUBLIC_HEADER native_log.h
  OUTPUT_NAME "native_log"
)

target_compile_definitions(native_log PUBLIC DART_SHARED_LIB)

if (ANDROID)
  # Support Android 15 16k page size
  target_link_options(native_log PRIVATE "-Wl,-z,max-page-size=16384")
  # 添加 Android 日志库支持
  find_library(log-lib log)
  target_link_libraries(native_log PRIVATE ${log-lib})
endif()
