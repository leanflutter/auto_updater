import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:auto_updater_platform_interface/auto_updater_platform_interface.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/widgets.dart';
import 'package:winsparkle/winsparkle.dart';

typedef _PostCObject =
    Pointer<NativeFunction<Int8 Function(Int64, Pointer<Dart_CObject>)>>;

class AutoUpdaterWinSparkle extends AutoUpdaterPlatform {
  static void registerWith() {
    AutoUpdaterPlatform.instance = AutoUpdaterWinSparkle();
  }

  final _events = StreamController<Map<Object?, Object?>>.broadcast();
  late final _updater = loadWinSparkle();
  late final _eventBridge = DynamicLibrary.open(
    File(Platform.resolvedExecutable).parent.uri
        .resolve('auto_updater_winsparkle_plugin.dll')
        .toFilePath(),
  );
  late final _setEventPort = _eventBridge
      .lookupFunction<
        Void Function(Int64, _PostCObject),
        void Function(int, _PostCObject)
      >('auto_updater_set_event_port');

  RawReceivePort? _eventPort;
  AppLifecycleListener? _lifecycle;
  bool _initialized = false;

  @override
  Stream<Map<Object?, Object?>> get sparkleEvents => _events.stream;

  @override
  Future<void> setFeedURL(String feedUrl) async {
    _listenForNativeEvents();
    final url = feedUrl.toNativeUtf8();
    try {
      _updater.win_sparkle_set_appcast_url(url.cast());
    } finally {
      malloc.free(url);
    }
    if (!_initialized) {
      _updater.win_sparkle_init();
      _initialized = true;
    }
  }

  @override
  Future<void> checkForUpdates({bool? inBackground}) async {
    _listenForNativeEvents();
    if (inBackground ?? false) {
      _updater.win_sparkle_check_update_without_ui();
    } else {
      _updater.win_sparkle_check_update_with_ui();
    }
    _emit('checking-for-update');
  }

  @override
  Future<void> setScheduledCheckInterval(int interval) async {
    _updater.win_sparkle_set_update_check_interval(interval);
  }

  @override
  Future<DateTime?> getLastCheckTime() async {
    final seconds = _updater.win_sparkle_get_last_check_time();
    if (seconds == -1) return null;

    return DateTime.fromMillisecondsSinceEpoch(
      seconds * Duration.millisecondsPerSecond,
      isUtc: true,
    );
  }

  void _listenForNativeEvents() {
    if (_eventPort != null) return;

    final port = RawReceivePort(_emit)..keepIsolateAlive = false;
    _setEventPort(port.sendPort.nativePort, NativeApi.postCObject);
    _eventPort = port;
    _lifecycle = AppLifecycleListener(onDetach: _detach);

    _updater.win_sparkle_set_error_callback(_callback('error'));
    _updater.win_sparkle_set_shutdown_request_callback(
      _callback('shutdown_request'),
    );
    _updater.win_sparkle_set_did_find_update_callback(
      _callback('did_find_update'),
    );
    _updater.win_sparkle_set_did_not_find_update_callback(
      _callback('did_not_find_update'),
    );
    _updater.win_sparkle_set_update_cancelled_callback(
      _callback('update_cancelled'),
    );
  }

  Pointer<NativeFunction<Void Function()>> _callback(String name) {
    return _eventBridge.lookup('auto_updater_on_$name');
  }

  void _detach() {
    _setEventPort(0, NativeApi.postCObject);
    _eventPort?.close();
    _eventPort = null;
    _updater.win_sparkle_cleanup();
    _initialized = false;
    _lifecycle?.dispose();
    _lifecycle = null;
  }

  void _emit(String type) {
    _events.add({'type': type});
  }
}
