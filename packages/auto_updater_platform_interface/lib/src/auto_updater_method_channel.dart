import 'package:auto_updater_platform_interface/src/auto_updater_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// An implementation of [AutoUpdaterPlatform] that uses method channels.
class MethodChannelAutoUpdater extends AutoUpdaterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(
    'dev.leanflutter.plugins/auto_updater',
  );

  /// The event channel used to receive events from the native platform.
  @visibleForTesting
  final eventChannel = const EventChannel(
    'dev.leanflutter.plugins/auto_updater_event',
  );

  @override
  Stream<Map<Object?, Object?>> get sparkleEvents {
    return eventChannel.receiveBroadcastStream().cast<Map<Object?, Object?>>();
  }

  @override
  Future<void> setFeedURL(String feedUrl) async {
    final Map<String, dynamic> arguments = {
      'feedURL': feedUrl,
    };
    await methodChannel.invokeMethod('setFeedURL', arguments);
  }

  @override
  Future<void> checkForUpdates({bool? inBackground}) async {
    final Map<String, dynamic> arguments = {
      'inBackground': inBackground ?? false,
    };
    await methodChannel.invokeMethod('checkForUpdates', arguments);
  }

  @override
  Future<void> setScheduledCheckInterval(int interval) async {
    final Map<String, dynamic> arguments = {
      'interval': interval,
    };
    await methodChannel.invokeMethod('setScheduledCheckInterval', arguments);
  }
}
