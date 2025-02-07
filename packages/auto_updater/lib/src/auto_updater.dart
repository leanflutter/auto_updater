import 'dart:async';

import 'package:auto_updater/src/appcast.dart';
import 'package:auto_updater/src/events.dart';
import 'package:auto_updater/src/updater_error.dart';
import 'package:auto_updater/src/updater_listener.dart';
import 'package:auto_updater/src/user_update_choice.dart';
import 'package:auto_updater_platform_interface/auto_updater_platform_interface.dart';

class AutoUpdater {
  AutoUpdater._() {
    _platform.sparkleEvents.listen(_handleSparkleEvents);
  }

  /// The shared instance of [AutoUpdater].
  static final AutoUpdater instance = AutoUpdater._();

  AutoUpdaterPlatform get _platform => AutoUpdaterPlatform.instance;

  final List<UpdaterListener> _listeners = [];

  /// Adds a listener to the auto updater.
  void addListener(UpdaterListener listener) => _listeners.add(listener);

  /// Removes a listener from the auto updater.
  void removeListener(UpdaterListener listener) => _listeners.remove(listener);

  /// Sets the url and initialize the auto updater.
  Future<void> setFeedURL(String feedUrl) => _platform.setFeedURL(feedUrl);

  /// Asks the server whether there is an update. You must call setFeedURL before using this API.
  Future<void> checkForUpdates({bool? inBackground}) =>
      _platform.checkForUpdates(inBackground: inBackground);

  /// Sets the auto update check interval, default 86400, minimum 3600, 0 to disable update
  Future<void> setScheduledCheckInterval(int interval) =>
      _platform.setScheduledCheckInterval(interval);

  /// Checks for update information.
  Future<void> checkForUpdateInformation() =>
      _platform.checkForUpdateInformation();

  void _handleSparkleEvents(dynamic event) {
    final type = event['type'] as String;
    final eventType = UpdaterEvent.fromString(type);
    final eventData = event['data'] as Map<Object?, Object?>?;

    if (eventData == null) return;

    // Parse event data
    final updaterError = eventData['error'] != null
        ? UpdaterError(eventData['error'].toString())
        : null;

    final appcast = eventData['appcast'] is Map
        ? Appcast.fromJson(
            Map<String, dynamic>.from(
              (eventData['appcast'] as Map).cast<String, dynamic>(),
            ),
          )
        : null;

    final appcastItem = eventData['appcastItem'] is Map
        ? AppcastItem.fromJson(
            Map<String, dynamic>.from(
              (eventData['appcastItem'] as Map).cast<String, dynamic>(),
            ),
          )
        : null;

    final userUpdateChoice = eventData['choice'] is int
        ? UserUpdateChoice.values[eventData['choice'] as int]
        : null;

    // Notify listeners
    for (final listener in _listeners) {
      switch (eventType) {
        case UpdaterEvent.error:
          listener.onUpdaterError(updaterError);
        case UpdaterEvent.checkingForUpdate:
          listener.onUpdaterCheckingForUpdate(appcast);
        case UpdaterEvent.updateAvailable:
          listener.onUpdaterUpdateAvailable(appcastItem);
        case UpdaterEvent.updateNotAvailable:
          listener.onUpdaterUpdateNotAvailable(updaterError);
        case UpdaterEvent.updateDownloaded:
          listener.onUpdaterUpdateDownloaded(appcastItem);
        case UpdaterEvent.beforeQuitForUpdate:
          listener.onUpdaterBeforeQuitForUpdate(appcastItem);
        case UpdaterEvent.userUpdateChoice:
          // this function is only available on macOS
          final choice = userUpdateChoice;
          if (choice == null) return;
          switch (choice) {
            case UserUpdateChoice.skip:
              listener.onUpdaterUpdateSkipped(appcastItem);
            case UserUpdateChoice.install:
              listener.onUpdaterUpdateInstalled(appcastItem);
            case UserUpdateChoice.dismiss:
              listener.onUpdaterUpdateCancelled(appcastItem);
          }
        case UpdaterEvent.updateCancelled:
          // this event is only available on Windows
          listener.onUpdaterUpdateCancelled(appcastItem);
        case UpdaterEvent.updateSkipped:
          // this event is only available on Windows
          listener.onUpdaterUpdateSkipped(appcastItem);
        case UpdaterEvent.updateInstalled:
          // this event is only available on Windows
          listener.onUpdaterUpdateInstalled(appcastItem);
        case UpdaterEvent.updateDismissed:
          // this event is only available on Windows
          listener.onUpdaterUpdateCancelled(appcastItem);
        case UpdaterEvent.updatePostponed:
        case UpdaterEvent.userRunInstaller:
          // this event is only available on Windows, ignore it
          break;
      }
    }
  }
}

final autoUpdater = AutoUpdater.instance;
