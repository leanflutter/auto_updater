import 'package:auto_updater/auto_updater.dart';

abstract mixin class UpdaterListener {
  void onUpdaterError(UpdaterError? error);
  void onUpdaterCheckingForUpdate(Appcast? appcast);
  void onUpdaterUpdateAvailable(AppcastItem? appcastItem);
  void onUpdaterUpdateNotAvailable(UpdaterError? error);
  void onUpdaterUpdateDownloaded(AppcastItem? appcastItem);

  /// Called when an update is ready to be installed on app exit.
  ///
  /// On Windows, the installer has started. Save any pending state, then quit
  /// the app. On macOS, an automatic update is ready for the next regular quit.
  void onUpdaterBeforeQuitForUpdate(AppcastItem? appcastItem);
}
