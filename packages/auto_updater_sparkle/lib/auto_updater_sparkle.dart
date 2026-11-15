import 'dart:async';

import 'package:auto_updater_platform_interface/auto_updater_platform_interface.dart';
import 'package:objective_c/objective_c.dart';
import 'package:sparkle/sparkle.dart';

class AutoUpdaterSparkle extends AutoUpdaterPlatform {
  static void registerWith() {
    final platform = AutoUpdaterSparkle();
    AutoUpdaterPlatform.instance = platform;
    // Start at registration so Sparkle can schedule checks from Info.plist.
    try {
      autoReleasePool(platform._start);
    } on NSErrorException {
      // An explicit setFeedURL call retries startup and reports the error.
    }
  }

  final _events = StreamController<Map<Object?, Object?>>.broadcast();
  NSString? _feedUrl;
  Set<String> _allowedChannels = const {};
  bool _started = false;

  // Sparkle holds its delegate weakly. Keep it alive for the life of the updater.
  late final _delegate = SPUUpdaterDelegate$Builder.implement(
    feedURLStringForUpdater_: (_) => _feedUrl,
    allowedChannelsForUpdater_: (_) => _allowedChannels.toNSSet(),
    updater_didAbortWithError_: (_, error) =>
        _emit('error', {'error': error.localizedDescription.toDartString()}),
    updater_didFinishLoadingAppcast_: (_, appcast) =>
        _emit('checking-for-update', {
          'appcast': {
            'items': appcast.items
                .asDart()
                .map((item) => _appcastItemData(SUAppcastItem.as(item)))
                .toList(),
          },
        }),
    updater_didFindValidUpdate_: (_, item) =>
        _emit('update-available', {'appcastItem': _appcastItemData(item)}),
    updaterDidNotFindUpdate_error_: (_, error) => _emit(
      'update-not-available',
      {'error': error.localizedDescription.toDartString()},
    ),
    updater_didDownloadUpdate_: (_, item) =>
        _emit('update-downloaded', {'appcastItem': _appcastItemData(item)}),
    updater_willInstallUpdateOnQuit_immediateInstallationBlock_: (_, item, _) {
      _emit('before-quit-for-update', {'appcastItem': _appcastItemData(item)});
      // Let Sparkle keep scheduling checks while the update waits for app quit.
      return false;
    },
    $keepIsolateAlive: false,
  );

  late final SPUUpdater _updater = _createUpdater();

  SPUUpdater _createUpdater() {
    loadSparkle();
    final bundle = NSBundle.getMainBundle();
    final driver = SPUStandardUserDriver.alloc().initWithHostBundle(bundle);
    return SPUUpdater.alloc().initWithHostBundle(
      bundle,
      applicationBundle: bundle,
      userDriver: driver,
      delegate: _delegate,
    )..clearFeedURLFromUserDefaults();
  }

  void _start() {
    if (_started) return;
    _started = _updater.startUpdater();
  }

  @override
  Stream<Map<Object?, Object?>> get sparkleEvents => _events.stream;

  @override
  Future<void> setFeedURL(String feedUrl) async {
    autoReleasePool(() {
      _feedUrl = NSURL.URLWithString(feedUrl.toNSString())?.absoluteString;
      _start();
    });
  }

  @override
  Future<void> setHttpHeaders(Map<String, String> headers) async {
    autoReleasePool(() => _updater.httpHeaders = headers.toNSDictionary());
  }

  @override
  Future<void> setAllowedChannels(List<String> channels) async {
    _allowedChannels = channels.toSet();
    if (_started) {
      autoReleasePool(_updater.resetUpdateCycleAfterShortDelay);
    }
  }

  @override
  Future<void> checkForUpdates({bool? inBackground}) async {
    autoReleasePool(() {
      if (inBackground ?? false) {
        _updater.checkForUpdatesInBackground();
      } else {
        _updater.checkForUpdates();
      }
    });
  }

  @override
  Future<void> setScheduledCheckInterval(int interval) async {
    autoReleasePool(() => _updater.updateCheckInterval = interval.toDouble());
  }

  @override
  Future<DateTime?> getLastCheckTime() async {
    return autoReleasePool(
      () => _updater.lastUpdateCheckDate?.toDateTime().toUtc(),
    );
  }

  void _emit(String type, Map<String, Object?> data) {
    _events.add({'type': type, 'data': data});
  }

  Map<String, Object?> _appcastItemData(SUAppcastItem item) => {
    'versionString': item.versionString.toDartString(),
    'displayVersionString': item.displayVersionString.toDartString(),
    'fileURL': item.fileURL?.absoluteString?.toDartString() ?? '',
    'contentLength': item.contentLength,
    'infoURL': item.infoURL?.absoluteString?.toDartString() ?? '',
    'title': item.title?.toDartString() ?? '',
    'dateString': item.dateString?.toDartString() ?? '',
    'releaseNotesURL':
        item.releaseNotesURL?.absoluteString?.toDartString() ?? '',
    'itemDescription': item.itemDescription?.toDartString() ?? '',
    'itemDescriptionFormat': item.itemDescriptionFormat?.toDartString() ?? '',
    'fullReleaseNotesURL':
        item.fullReleaseNotesURL?.absoluteString?.toDartString() ?? '',
    'minimumSystemVersion': item.minimumSystemVersion?.toDartString() ?? '',
    'minimumOperatingSystemVersionIsOK': item.minimumOperatingSystemVersionIsOK,
    'maximumSystemVersion': item.maximumSystemVersion?.toDartString() ?? '',
    'maximumOperatingSystemVersionIsOK': item.maximumOperatingSystemVersionIsOK,
    'channel': item.channel?.toDartString() ?? '',
  };
}
