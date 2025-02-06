#include "auto_updater_windows_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// #include <flutter/event_channel.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>

namespace auto_updater_windows {

// static
void AutoUpdaterWindowsPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "dev.leanflutter.plugins/auto_updater",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<AutoUpdaterWindowsPlugin>(registrar);

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });
  auto event_channel =
      std::make_unique<flutter::EventChannel<flutter::EncodableValue>>(
          registrar->messenger(), "dev.leanflutter.plugins/auto_updater_event",
          &flutter::StandardMethodCodec::GetInstance());
  auto streamHandler = std::make_unique<flutter::StreamHandlerFunctions<>>(
      [plugin_pointer = plugin.get()](
          const flutter::EncodableValue* arguments,
          std::unique_ptr<flutter::EventSink<>>&& events)
          -> std::unique_ptr<flutter::StreamHandlerError<>> {
        return plugin_pointer->OnListen(arguments, std::move(events));
      },
      [plugin_pointer = plugin.get()](const flutter::EncodableValue* arguments)
          -> std::unique_ptr<flutter::StreamHandlerError<>> {
        return plugin_pointer->OnCancel(arguments);
      });
  event_channel->SetStreamHandler(std::move(streamHandler));
  registrar->AddPlugin(std::move(plugin));
}

AutoUpdaterWindowsPlugin::AutoUpdaterWindowsPlugin(
    flutter::PluginRegistrarWindows* registrar) {
  registrar_ = registrar;
}

AutoUpdaterWindowsPlugin::~AutoUpdaterWindowsPlugin() {}

void AutoUpdaterWindowsPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  std::string method_name = method_call.method_name();

  if (method_name.compare("setFeedURL") == 0) {
    const flutter::EncodableMap& args =
        std::get<flutter::EncodableMap>(*method_call.arguments());
    std::string feedURL =
        std::get<std::string>(args.at(flutter::EncodableValue("feedURL")));
    auto_updater.SetFeedURL(feedURL);
    auto_updater.RegisterEventSink(std::move(event_sink_));
    result->Success(flutter::EncodableValue(true));

  } else if (method_name.compare("checkForUpdates") == 0) {
    const flutter::EncodableMap& args =
        std::get<flutter::EncodableMap>(*method_call.arguments());
    bool inBackground =
        std::get<bool>(args.at(flutter::EncodableValue("inBackground")));
    if (inBackground) {
      auto_updater.CheckForUpdatesWithoutUI();
    } else {
      auto_updater.CheckForUpdates();
    }
    result->Success(flutter::EncodableValue(true));

  } else if (method_name.compare("setScheduledCheckInterval") == 0) {
    const flutter::EncodableMap& args =
        std::get<flutter::EncodableMap>(*method_call.arguments());
    int interval = std::get<int>(args.at(flutter::EncodableValue("interval")));
    auto_updater.SetScheduledCheckInterval(interval);
    result->Success(flutter::EncodableValue(true));

  } else if (method_name.compare("checkForUpdateInformation") == 0) {
    const flutter::EncodableMap& args =
        std::get<flutter::EncodableMap>(*method_call.arguments());
    auto_updater.CheckForUpdatesWithoutUI();
    result->Success(flutter::EncodableValue(true));
  } else {
    result->NotImplemented();
  }
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
AutoUpdaterWindowsPlugin::OnListenInternal(
    const flutter::EncodableValue* arguments,
    std::unique_ptr<flutter::EventSink<flutter::EncodableValue>>&& events) {
  event_sink_ = std::move(events);
  return nullptr;
}

std::unique_ptr<flutter::StreamHandlerError<flutter::EncodableValue>>
AutoUpdaterWindowsPlugin::OnCancelInternal(
    const flutter::EncodableValue* arguments) {
  event_sink_ = nullptr;
  return nullptr;
}
}  // namespace auto_updater_windows
