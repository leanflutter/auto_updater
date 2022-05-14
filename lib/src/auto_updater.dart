import 'dart:async';

import 'package:flutter/services.dart';

class AutoUpdater {
  AutoUpdater._() {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  /// The shared instance of [AutoUpdater].
  static final AutoUpdater instance = AutoUpdater._();

  final MethodChannel _channel = const MethodChannel('auto_updater');

  Future<void> _methodCallHandler(MethodCall call) async {
    if (call.method != 'onEvent') throw UnimplementedError();
    // print(call.arguments['eventName']);
  }

  /// Sets the url and initialize the auto updater.
  Future<void> setFeedURL(String feedUrl) async {
    final Map<String, dynamic> arguments = {
      'feedURL': feedUrl,
    };
    await _channel.invokeMethod('setFeedURL', arguments);
  }

  /// Asks the server whether there is an update. You must call setFeedURL before using this API.
  Future<void> checkForUpdates({bool? inBackground}) async {
    final Map<String, dynamic> arguments = {
      'inBackground': inBackground ?? false,
    };
    await _channel.invokeMethod('checkForUpdates', arguments);
  }
}

final autoUpdater = AutoUpdater.instance;
