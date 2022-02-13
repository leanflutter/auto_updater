#include "WinSparkle-0.7.0/include/winsparkle.h"

#include <sstream>

namespace {
class AutoUpdater {
 public:
  AutoUpdater();

  virtual ~AutoUpdater();

  void AutoUpdater::SetFeedURL(std::string feedURL);
  void AutoUpdater::GetFeedURL();
  void AutoUpdater::CheckForUpdates();

 private:
};

AutoUpdater::AutoUpdater() {}

AutoUpdater::~AutoUpdater() {}

void AutoUpdater::SetFeedURL(std::string feedURL) {
  win_sparkle_set_automatic_check_for_updates(0);
  win_sparkle_set_appcast_url(feedURL.c_str());
}

void AutoUpdater::GetFeedURL() {}

void AutoUpdater::CheckForUpdates() {
  win_sparkle_check_update_with_ui();
}

}  // namespace
