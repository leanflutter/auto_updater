#include "WinSparkle-0.7.0/include/winsparkle.h"

#include <sstream>

namespace {
class AutoUpdater {
 public:
  AutoUpdater();

  virtual ~AutoUpdater();

  void AutoUpdater::SetFeedURL(std::string feedURL);
  void AutoUpdater::CheckForUpdates();

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

}  // namespace
