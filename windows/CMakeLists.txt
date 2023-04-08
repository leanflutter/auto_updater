cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "auto_updater")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "auto_updater_plugin")

# WinSparkle
set(WIN_SPARKLE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/WinSparkle-0.8.0")
set(WIN_SPARKLE_BINARIES "${WIN_SPARKLE_DIR}/x64/Release/WinSparkle.dll")
set(WIN_SPARKLE_LIBRARIES "${WIN_SPARKLE_DIR}/x64/Release/WinSparkle.lib")

add_library(${PLUGIN_NAME} SHARED
  "auto_updater_plugin.cpp"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  "${WIN_SPARKLE_DIR}/include"
)
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)
target_link_libraries(${PLUGIN_NAME} PRIVATE ${WIN_SPARKLE_LIBRARIES})

# List of absolute paths to libraries that should be bundled with the plugin
set(auto_updater_bundled_libraries
  ""
  ${WIN_SPARKLE_BINARIES}
  PARENT_SCOPE
)
