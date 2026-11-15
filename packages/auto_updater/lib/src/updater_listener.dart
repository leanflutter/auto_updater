import 'package:auto_updater/auto_updater.dart';

abstract mixin class UpdaterListener {
  /// Called when the native updater fails to check for or prepare an update.
  ///
  /// The bundled Windows updater includes request and signature diagnostics in
  /// [UpdaterError.message]. A custom WinSparkle DLL may report an error
  /// without a message, in which case [error] is null.
  void onUpdaterError(UpdaterError? error);
  void onUpdaterCheckingForUpdate(Appcast? appcast);
  void onUpdaterUpdateAvailable(AppcastItem? appcastItem);
  void onUpdaterUpdateNotAvailable(UpdaterError? error);

  /// Called once the native updater has downloaded an update.
  ///
  /// The Windows callback does not include the appcast item.
  void onUpdaterUpdateDownloaded(AppcastItem? appcastItem);

  /// Called when an update is ready to be installed on app exit.
  ///
  /// On Windows, the installer has started. Save any pending state, then quit
  /// the app. On macOS, an automatic update is ready for the next regular quit.
  void onUpdaterBeforeQuitForUpdate(AppcastItem? appcastItem);
}
