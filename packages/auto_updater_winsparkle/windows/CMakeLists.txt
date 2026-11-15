cmake_minimum_required(VERSION 3.14)
project(auto_updater_winsparkle LANGUAGES CXX)

# The event bridge uses the Dart SDK's native port ABI.
include("${CMAKE_SOURCE_DIR}/flutter/ephemeral/generated_config.cmake")
set(PLUGIN_NAME "auto_updater_winsparkle_plugin")
add_library(${PLUGIN_NAME} SHARED event_bridge.cpp)
apply_standard_settings(${PLUGIN_NAME})
target_include_directories(${PLUGIN_NAME} PRIVATE
  "${FLUTTER_ROOT}/bin/cache/dart-sdk/include"
)

set(WINSPARKLE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/WinSparkle-0.9.4")
if(FLUTTER_TARGET_PLATFORM STREQUAL "windows-arm64")
  set(WINSPARKLE_ARCH "ARM64")
else()
  set(WINSPARKLE_ARCH "x64")
endif()

set(auto_updater_winsparkle_bundled_libraries
  "$<TARGET_FILE:${PLUGIN_NAME}>"
  "${WINSPARKLE_DIRECTORY}/${WINSPARKLE_ARCH}/Release/WinSparkle.dll"
  PARENT_SCOPE
)
