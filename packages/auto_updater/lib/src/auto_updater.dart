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

  void _handleSparkleEvents(Map<Object?, Object?> event) {
    UpdaterError? updaterError;
    Appcast? appcast;
    AppcastItem? appcastItem;

    String type = event['type'] as String;
    Map<Object?, Object?>? data;
    if (event['data'] != null) {
      data = event['data'] as Map;
      if (data['error'] != null) {
        updaterError = UpdaterError(data['error'].toString());
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

  /// Sets additional Sparkle channels allowed on macOS.
  ///
  /// Updates on the default channel are always eligible. Pass an empty list
  /// to restore the default channel selection.
  Future<void> setAllowedChannels(List<String> channels) {
    return _platform.setAllowedChannels(channels);
  }

  static final _invalidHeaderName = RegExp(r"[^!#$%&'*+.^_\x60|~0-9A-Za-z-]");
  static final _invalidHeaderValue = RegExp(r'[\x00-\x08\x0A-\x1F\x7F]');

  /// Replaces the custom HTTP headers used by the updater.
  ///
  /// Configure headers before calling [setFeedURL]. Pass an empty map to
  /// clear them. The native updater can send these headers to both the feed
  /// and the URLs referenced by it.
  Future<void> setHttpHeaders(Map<String, String> headers) async {
    final normalized = <String, String>{};
    for (final MapEntry(:key, :value) in headers.entries) {
      if (key.isEmpty || _invalidHeaderName.hasMatch(key)) {
        throw ArgumentError('Invalid HTTP header name');
      }
      if (_invalidHeaderValue.hasMatch(value)) {
        throw ArgumentError('Invalid HTTP header value');
      }
      normalized[key.toLowerCase()] = value;
    }
    await _platform.setHttpHeaders(normalized);
  }

  /// Checks for updates after [setFeedURL] has been called.
  ///
  /// Set [inBackground] to true for a background check. On macOS, foreground
  /// checks can offer skipped versions again, while background checks honor
  /// the user's choice to skip.
  Future<void> checkForUpdates({bool? inBackground}) {
    return _platform.checkForUpdates(inBackground: inBackground);
  }

  /// On Windows, checks for and installs an update with progress UI.
  ///
  /// Call [setFeedURL] first. WinSparkle skips its update confirmation prompt.
  /// The return value indicates only that the check has been started.
  Future<void> checkForUpdatesAndInstall() {
    return _platform.checkForUpdatesAndInstall();
  }

  /// Sets the auto update check interval, default 86400, minimum 3600, 0 to disable update
  Future<void> setScheduledCheckInterval(int interval) {
    return _platform.setScheduledCheckInterval(interval);
  }

  /// Returns the last update check time in UTC, or null if there was no check.
  Future<DateTime?> getLastCheckTime() {
    return _platform.getLastCheckTime();
  }
}

final autoUpdater = AutoUpdater.instance;
