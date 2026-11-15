import 'package:auto_updater/auto_updater.dart';

abstract mixin class UpdaterListener {
  void onUpdaterError(UpdaterError? error);
  void onUpdaterCheckingForUpdate(Appcast? appcast);
  void onUpdaterUpdateAvailable(AppcastItem? appcastItem);
  void onUpdaterUpdateNotAvailable(UpdaterError? error);

  /// Called on macOS after Sparkle downloads an update.
  void onUpdaterUpdateDownloaded(AppcastItem? appcastItem);

  /// Called when the native updater prepares to install an update on quit.
  void onUpdaterBeforeQuitForUpdate(AppcastItem? appcastItem);
}
