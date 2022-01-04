
import 'dart:async';

import 'package:flutter/services.dart';

class AutoUpdater {
  static const MethodChannel _channel = MethodChannel('auto_updater');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
