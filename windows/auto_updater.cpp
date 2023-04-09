#include "WinSparkle-0.8.0/include/winsparkle.h"

#include <sstream>

namespace {
// Forward declarations for WinSparkle callbacks
void __onErrorCallback();
void __onShutdownRequestCallback();
void __onDidFindUpdateCallback();
void __onDidNotFindUpdateCallback();
void __onUpdateCancelledCallback();
void __onUpdateSkippedCallback();
void __onUpdatePostponedCallback();
void __onUpdateDismissedCallback();
void __onUserRunInstallerCallback();

    
class AutoUpdater {
  public:
    static AutoUpdater* GetInstance();  
 
    AutoUpdater();

    virtual ~AutoUpdater();

    void AutoUpdater::SetFeedURL(std::string feedURL);
    void AutoUpdater::CheckForUpdates();
    void AutoUpdater::CheckForUpdatesWithoutUI();
    void AutoUpdater::SetScheduledCheckInterval(int interval);

    void AutoUpdater::RegisterCallbacks(
        std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> ptr);
    void AutoUpdater::OnWinSparkleEvent(std::string eventName);

  private:
    static AutoUpdater* lazySingleton;
   std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> _channel;
};

AutoUpdater* AutoUpdater::lazySingleton = nullptr;

AutoUpdater* AutoUpdater::GetInstance() {
  return lazySingleton;
}

AutoUpdater::AutoUpdater() {
  if (lazySingleton != nullptr) {
    throw std::invalid_argument("AutoUpdater has already been initialized");
  }

  lazySingleton = this;
}

AutoUpdater::~AutoUpdater() {}

void AutoUpdater::SetFeedURL(std::string feedURL) {
  win_sparkle_set_appcast_url(feedURL.c_str());
  win_sparkle_init();

  win_sparkle_set_error_callback(__onErrorCallback);
  win_sparkle_set_shutdown_request_callback(__onShutdownRequestCallback);
  win_sparkle_set_did_find_update_callback(__onDidFindUpdateCallback);
  win_sparkle_set_did_not_find_update_callback(__onDidNotFindUpdateCallback);
  win_sparkle_set_update_cancelled_callback(__onUpdateCancelledCallback);

  // TODO: These will be supported once we update WinSparkle to >0.8.0
  // win_sparkle_set_update_skipped_callback(__onUpdateSkippedCallback);
  // win_sparkle_set_update_postponed_callback(__onUpdatePostponedCallback);
  // win_sparkle_set_update_dismissed_callback(__onUpdateDismissedCallback);
  // win_sparkle_set_user_run_installer_callback(__onUserRunInstallerCallback);
}

void AutoUpdater::CheckForUpdates() {
  win_sparkle_check_update_with_ui();
}

void AutoUpdater::CheckForUpdatesWithoutUI() {
  win_sparkle_check_update_without_ui();
}

void AutoUpdater::SetScheduledCheckInterval(int interval) {
  win_sparkle_set_update_check_interval(interval);
}

void AutoUpdater::RegisterCallbacks(
    std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> ptr) {
  _channel = std::move(ptr);
}

void AutoUpdater::OnWinSparkleEvent(std::string eventName) {
  if (_channel == nullptr) return;

  this->_channel->InvokeMethod(
    "onEvent",
    std::make_unique<flutter::EncodableValue>(
      flutter::EncodableMap({
        {
          flutter::EncodableValue("eventName"),
          flutter::EncodableValue(eventName)
        }
      })));
}


void __onErrorCallback() {
  AutoUpdater* autoUpdater = AutoUpdater::GetInstance();
  if (autoUpdater == nullptr) return;
  autoUpdater->OnWinSparkleEvent("error");
}

void __onShutdownRequestCallback() {
  AutoUpdater* autoUpdater = AutoUpdater::GetInstance();
  if (autoUpdater == nullptr) return;
  autoUpdater->OnWinSparkleEvent("shutdownRequest");
}

void __onDidFindUpdateCallback() {
  AutoUpdater* autoUpdater = AutoUpdater::GetInstance();
  if (autoUpdater == nullptr) return;
  autoUpdater->OnWinSparkleEvent("didFindUpdate");
}

void __onDidNotFindUpdateCallback() {
  AutoUpdater* autoUpdater = AutoUpdater::GetInstance();
  if (autoUpdater == nullptr) return;
  autoUpdater->OnWinSparkleEvent("didNotFindUpdate");
}

void __onUpdateCancelledCallback() {
  AutoUpdater* autoUpdater = AutoUpdater::GetInstance();
  if (autoUpdater == nullptr) return;
  autoUpdater->OnWinSparkleEvent("updateCancelled");
}

void __onUpdateSkippedCallback() {
  AutoUpdater* autoUpdater = AutoUpdater::GetInstance();
  if (autoUpdater == nullptr) return;
  autoUpdater->OnWinSparkleEvent("updateSkipped");
}

void __onUpdatePostponedCallback() {
  AutoUpdater* autoUpdater = AutoUpdater::GetInstance();
  if (autoUpdater == nullptr) return;
  autoUpdater->OnWinSparkleEvent("updatePostponed");
}

void __onUpdateDismissedCallback() {
  AutoUpdater* autoUpdater = AutoUpdater::GetInstance();
  if (autoUpdater == nullptr) return;
  autoUpdater->OnWinSparkleEvent("updateDismissed");
}

void __onUserRunInstallerCallback() {
  AutoUpdater* autoUpdater = AutoUpdater::GetInstance();
  if (autoUpdater == nullptr) return;
  autoUpdater->OnWinSparkleEvent("userRunInstaller");
}
}  // namespace
