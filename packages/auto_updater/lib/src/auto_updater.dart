import 'dart:async';

import 'package:auto_updater/src/appcast.dart';
import 'package:auto_updater/src/updater_error.dart';
import 'package:auto_updater/src/updater_listener.dart';
import 'package:auto_updater_platform_interface/auto_updater_platform_interface.dart';

class AutoUpdater {
  AutoUpdater._() {
    _platform.sparkleEvents.listen(_handleSparkleEvents);
  }

  /// The shared instance of [AutoUpdater].
  static final AutoUpdater instance = AutoUpdater._();

  AutoUpdaterPlatform get _platform => AutoUpdaterPlatform.instance;

  final List<UpdaterListener> _listeners = [];

  void _handleSparkleEvents(event) {
    print(event);
    UpdaterError? updaterError;
    Appcast? appcast;
    AppcastItem? appcastItem;

    String type = event['type'] as String;
    Map<Object?, Object?>? data;
    if (event['data'] != null) {
      data = event['data'] as Map;
      if (data['error'] != null) {
        updaterError = UpdaterError(
          data['error'].toString(),
        );
      }
      if (data['appcast'] != null) {
        appcast = Appcast.fromJson(
          Map<String, dynamic>.from(
            (data['appcast'] as Map).cast<String, dynamic>(),
          ),
        );
      }
      if (data['appcastItem'] != null) {
        appcastItem = AppcastItem.fromJson(
          Map<String, dynamic>.from(
            (data['appcastItem'] as Map).cast<String, dynamic>(),
          ),
        );
      }
    }
    for (var listener in _listeners) {
      switch (type) {
        case 'error':
          listener.onUpdaterError(updaterError);
          break;
        case 'checking-for-update':
          listener.onUpdaterCheckingForUpdate(appcast);
          break;
        case 'update-available':
          listener.onUpdaterUpdateAvailable(appcastItem);
          break;
        case 'update-not-available':
          listener.onUpdaterUpdateNotAvailable(updaterError);
          break;
        case 'update-downloaded':
          listener.onUpdaterUpdateDownloaded(appcastItem);
          break;
        case 'before-quit-for-update':
          listener.onUpdaterBeforeQuitForUpdate(appcastItem);
          break;
      }
    }
  }

  /// Adds a listener to the auto updater.
  void addListener(UpdaterListener listener) {
    _listeners.add(listener);
  }

  /// Removes a listener from the auto updater.
  void removeListener(UpdaterListener listener) {
    _listeners.remove(listener);
  }

  /// Sets the url and initialize the auto updater.
  Future<void> setFeedURL(String feedUrl) {
    return _platform.setFeedURL(feedUrl);
  }

  /// Asks the server whether there is an update. You must call setFeedURL before using this API.
  Future<void> checkForUpdates({bool? inBackground}) {
    return _platform.checkForUpdates(
      inBackground: inBackground,
    );
  }

  /// Sets the auto update check interval, default 86400, minimum 3600, 0 to disable update
  Future<void> setScheduledCheckInterval(int interval) {
    return _platform.setScheduledCheckInterval(interval);
  }
}

final autoUpdater = AutoUpdater.instance;
