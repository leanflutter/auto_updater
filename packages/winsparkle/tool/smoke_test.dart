import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:winsparkle/winsparkle.dart';

void main(List<String> args) {
  if (args.length != 1) {
    throw ArgumentError('Pass the path to WinSparkle.dll.');
  }

  final winSparkle = loadWinSparkle(path: args.single);
  var configReads = 0;
  // This smoke test does not start WinSparkle's background threads. Its
  // settings getters invoke config_read synchronously on this thread.
  final read =
      NativeCallable<
        Int Function(Pointer<Char>, Pointer<WChar>, Size, Pointer<Void>)
      >.isolateLocal((
        Pointer<Char> _,
        Pointer<WChar> _,
        int _,
        Pointer<Void> _,
      ) {
        configReads++;
        return 0;
      }, exceptionalReturn: 0);
  final config = calloc<win_sparkle_config_methods_t>();
  try {
    config.ref.config_read = read.nativeFunction;
    winSparkle.win_sparkle_set_config_methods(config);
    final lastCheck = winSparkle.win_sparkle_get_last_check_time();
    if (configReads == 0 || lastCheck != -1) {
      throw StateError('Unexpected WinSparkle last check time: $lastCheck');
    }
  } finally {
    winSparkle.win_sparkle_set_config_methods(nullptr);
    read.close();
    calloc.free(config);
  }
  stdout.writeln('WinSparkle FFI smoke test passed.');
}
