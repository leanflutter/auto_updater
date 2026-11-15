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
typedef _NativeCallback = Pointer<NativeFunction<Void Function()>>;
typedef _ErrorDetailsCallback =
    Pointer<NativeFunction<Void Function(Pointer<Utf8>)>>;

class AutoUpdaterWinSparkle extends AutoUpdaterPlatform {
  static void registerWith() {
    AutoUpdaterPlatform.instance = AutoUpdaterWinSparkle();
  }

  final _events = StreamController<Map<Object?, Object?>>.broadcast();
  late final _appDirectory = File(Platform.resolvedExecutable).parent.uri;
  late final _winSparkle = _openLibrary('WinSparkle.dll');
  late final _updater = WinSparkle(_winSparkle);
  late final _eventBridge = _openLibrary('auto_updater_winsparkle_plugin.dll');
  late final _setEventPort = _eventBridge
      .lookupFunction<
        Void Function(Int64, _PostCObject),
        void Function(int, _PostCObject)
      >('auto_updater_set_event_port');
  static const _downloadedCallbackSymbol =
      'auto_updater_winsparkle_set_downloaded_callback';
  static const _errorDetailsCallbackSymbol =
      'auto_updater_winsparkle_set_error_details_callback';

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
  Future<void> setHttpHeaders(Map<String, String> headers) async {
    using((arena) {
      _updater.win_sparkle_clear_http_headers();
      for (final MapEntry(:key, :value) in headers.entries) {
        _updater.win_sparkle_set_http_header(
          key.toNativeUtf8(allocator: arena).cast(),
          value.toNativeUtf8(allocator: arena).cast(),
        );
      }
    });
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
  Future<void> checkForUpdatesAndInstall() async {
    if (!_initialized) {
      throw StateError('Call setFeedURL before checkForUpdatesAndInstall().');
    }
    _updater.win_sparkle_check_update_with_ui_and_install();
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

    final port = RawReceivePort(_handleNativeEvent)..keepIsolateAlive = false;
    _setEventPort(port.sendPort.nativePort, NativeApi.postCObject);
    _eventPort = port;
    _lifecycle = AppLifecycleListener(onDetach: _detach);

    if (_winSparkle.providesSymbol(_errorDetailsCallbackSymbol)) {
      final setErrorDetailsCallback = _winSparkle
          .lookupFunction<
            Void Function(_ErrorDetailsCallback),
            void Function(_ErrorDetailsCallback)
          >(_errorDetailsCallbackSymbol);
      setErrorDetailsCallback(
        _eventBridge.lookup('auto_updater_on_error_details'),
      );
    } else {
      _updater.win_sparkle_set_error_callback(_callback('error'));
    }
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
    if (_winSparkle.providesSymbol(_downloadedCallbackSymbol)) {
      final setDownloadedCallback = _winSparkle
          .lookupFunction<
            Void Function(_NativeCallback),
            void Function(_NativeCallback)
          >(_downloadedCallbackSymbol);
      setDownloadedCallback(_callback('update_downloaded'));
    }
  }

  DynamicLibrary _openLibrary(String name) {
    return DynamicLibrary.open(_appDirectory.resolve(name).toFilePath());
  }

  _NativeCallback _callback(String name) {
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

  void _handleNativeEvent(Object? event) {
    switch (event) {
      case String type:
        _emit(type);
      case ['error', final String message]:
        _events.add({
          'type': 'error',
          'data': {'error': message},
        });
    }
  }
}
