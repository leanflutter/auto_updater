#include "WinSparkle-0.7.0/include/winsparkle.h"

#include <sstream>

namespace {
class AutoUpdater {
 public:
  AutoUpdater();

  virtual ~AutoUpdater();

  void AutoUpdater::SetFeedURL(std::string feedURL);
  void AutoUpdater::CheckForUpdates();
  void AutoUpdater::CheckForUpdatesWithoutUI();
  void AutoUpdater::SetScheduledCheckInterval(int interval);

 private:
};

AutoUpdater::AutoUpdater() {}

AutoUpdater::~AutoUpdater() {}

void AutoUpdater::SetFeedURL(std::string feedURL) {
  win_sparkle_set_appcast_url(feedURL.c_str());
  win_sparkle_init();
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

}  // namespace
