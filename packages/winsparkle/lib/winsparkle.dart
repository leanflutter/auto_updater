import 'dart:ffi';
import 'dart:io';

import 'package:winsparkle/src/winsparkle_bindings.g.dart';

export 'src/winsparkle_bindings.g.dart';

/// Opens WinSparkle from [path] or from beside the running app's executable.
WinSparkle loadWinSparkle({String? path}) {
  if (!Platform.isWindows) {
    throw UnsupportedError('WinSparkle is supported only on Windows.');
  }

  final executable = File(Platform.resolvedExecutable);
  final libraryPath =
      path ?? executable.parent.uri.resolve('WinSparkle.dll').toFilePath();
  return WinSparkle(DynamicLibrary.open(libraryPath));
}
