import 'dart:ffi';
import 'dart:io';

import 'package:sparkle/src/sparkle_bindings.g.dart';

export 'src/sparkle_bindings.g.dart' hide NSComparisonResult;

/// Loads the Sparkle framework and returns bindings for its exported symbols.
///
/// By default, loads Sparkle from the running app's `Contents/Frameworks`
/// directory. [path] can point to a different Sparkle framework executable.
/// Call this before using the Objective-C bindings unless the host app has
/// already linked Sparkle.
SparkleBindings loadSparkle({String? path}) {
  if (!Platform.isMacOS) {
    throw UnsupportedError('Sparkle is supported only on macOS.');
  }

  final executable = File(Platform.resolvedExecutable);
  final libraryPath =
      path ??
      executable.parent.parent.uri
          .resolve('Frameworks/Sparkle.framework/Sparkle')
          .toFilePath();
  return SparkleBindings(DynamicLibrary.open(libraryPath));
}
