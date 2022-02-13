#include "include/auto_updater/auto_updater_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>

#include "auto_updater.cpp"

namespace {

class AutoUpdaterPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  AutoUpdaterPlugin();

  virtual ~AutoUpdaterPlugin();

 private:
  AutoUpdater* auto_updater;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

// static
void AutoUpdaterPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "auto_updater",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<AutoUpdaterPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

AutoUpdaterPlugin::AutoUpdaterPlugin() {}

AutoUpdaterPlugin::~AutoUpdaterPlugin() {}

void AutoUpdaterPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  std::string method_name = method_call.method_name();

  if (method_name.compare("setFeedURL") == 0) {
    const flutter::EncodableMap& args =
        std::get<flutter::EncodableMap>(*method_call.arguments());
    std::string feedURL =
        std::get<std::string>(args.at(flutter::EncodableValue("feedURL")));
    auto_updater->SetFeedURL(feedURL);
    result->Success(flutter::EncodableValue(true));
  } else if (method_name.compare("getFeedURL") == 0) {
    auto_updater->GetFeedURL();
    result->Success(flutter::EncodableValue(true));
  } else if (method_name.compare("checkForUpdates") == 0) {
    auto_updater->CheckForUpdates();
    result->Success(flutter::EncodableValue(true));
  } else {
    result->NotImplemented();
  }
}

}  // namespace

void AutoUpdaterPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  AutoUpdaterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
