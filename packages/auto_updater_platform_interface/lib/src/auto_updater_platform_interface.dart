import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class AutoUpdaterPlatform extends PlatformInterface {
  /// Constructs a AutoUpdaterPlatform.
  AutoUpdaterPlatform() : super(token: _token);

  static final Object _token = Object();

  static AutoUpdaterPlatform _instance = _UnsupportedAutoUpdater();

  /// The default instance of [AutoUpdaterPlatform] to use.
  ///
  /// Set by the registered platform implementation.
  static AutoUpdaterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AutoUpdaterPlatform] when
  /// they register themselves.
  static set instance(AutoUpdaterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream<Map<Object?, Object?>> get sparkleEvents {
    throw UnimplementedError('sparkleEvents getter has not been implemented.');
  }

  /// Sets the url and initialize the auto updater.
  Future<void> setFeedURL(String feedUrl) async {
    throw UnimplementedError('setFeedURL() has not been implemented.');
  }

  /// Asks the server whether there is an update. You must call setFeedURL before using this API.
  Future<void> checkForUpdates({bool? inBackground}) async {
    throw UnimplementedError('checkForUpdates() has not been implemented.');
  }

  /// Sets the auto update check interval, default 86400, minimum 3600, 0 to disable update
  Future<void> setScheduledCheckInterval(int interval) async {
    throw UnimplementedError(
      'setScheduledCheckInterval() has not been implemented.',
    );
  }

  /// Returns the last update check time in UTC, or null if there was no check.
  Future<DateTime?> getLastCheckTime() async {
    throw UnimplementedError('getLastCheckTime() has not been implemented.');
  }
}

class _UnsupportedAutoUpdater extends AutoUpdaterPlatform {
  @override
  Stream<Map<Object?, Object?>> get sparkleEvents => const Stream.empty();
}
