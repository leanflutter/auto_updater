import 'package:auto_updater/auto_updater.dart';

abstract mixin class UpdaterListener {
  void onUpdaterError(UpdaterError? error);
  void onUpdaterCheckingForUpdate(Appcast? appcast);
  void onUpdaterUpdateAvailable(AppcastItem? appcastItem);
  void onUpdaterUpdateNotAvailable(UpdaterError? error);

  /// Called once the native updater has downloaded an update.
  ///
  /// The Windows callback does not include the appcast item.
  void onUpdaterUpdateDownloaded(AppcastItem? appcastItem);
  void onUpdaterBeforeQuitForUpdate(AppcastItem? appcastItem);
}
