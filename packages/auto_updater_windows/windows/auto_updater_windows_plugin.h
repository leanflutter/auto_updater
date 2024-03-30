#ifndef FLUTTER_PLUGIN_AUTO_UPDATER_WINDOWS_PLUGIN_H_
#define FLUTTER_PLUGIN_AUTO_UPDATER_WINDOWS_PLUGIN_H_

#include <flutter/event_channel.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

#include "auto_updater.cpp"

namespace auto_updater_windows {

class AutoUpdaterWindowsPlugin
    : public flutter::Plugin,
      flutter::StreamHandler<flutter::EncodableValue> {
 private:
  flutter::PluginRegistrarWindows* registrar_;
  std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink_;
  AutoUpdater auto_updater = AutoUpdater();

 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  AutoUpdaterWindowsPlugin(flutter::PluginRegistrarWindows* registrar);

  virtual ~AutoUpdaterWindowsPlugin();

  // Disallow copy and assign.
  AutoUpdaterWindowsPlugin(const AutoUpdaterWindowsPlugin&) = delete;
  AutoUpdaterWindowsPlugin& operator=(const AutoUpdaterWindowsPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  std::unique_ptr<flutter::StreamHandlerError<>> OnListenInternal(
      const flutter::EncodableValue* arguments,
      std::unique_ptr<flutter::EventSink<>>&& events) override;

  std::unique_ptr<flutter::StreamHandlerError<>> OnCancelInternal(
      const flutter::EncodableValue* arguments) override;
};

}  // namespace auto_updater_windows

#endif  // FLUTTER_PLUGIN_AUTO_UPDATER_WINDOWS_PLUGIN_H_
