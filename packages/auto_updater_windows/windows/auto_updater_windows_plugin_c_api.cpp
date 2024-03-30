#include "include/auto_updater_windows/auto_updater_windows_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "auto_updater_windows_plugin.h"

void AutoUpdaterWindowsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  auto_updater_windows::AutoUpdaterWindowsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
