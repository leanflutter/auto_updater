import 'dart:io';

import 'package:objective_c/objective_c.dart' as objc;
import 'package:sparkle/sparkle.dart';

void main(List<String> args) {
  if (args.length != 1) {
    throw ArgumentError('Pass the path to Sparkle.framework/Sparkle.');
  }

  final bindings = loadSparkle(path: args.single);
  if (bindings.SUSparkleErrorDomain.toDartString().isEmpty) {
    throw StateError('The Sparkle error domain is empty.');
  }

  final nativeComparator = SUStandardVersionComparator.getDefaultComparator();
  final dartComparator = SUVersionComparison$Builder.implement(
    compareVersion_toVersion_: (a, b) =>
        nativeComparator.compareVersion(a, toVersion: b),
    $keepIsolateAlive: false,
  );
  final result = dartComparator.compareVersion(
    '1.9'.toNSString(),
    toVersion: '1.10'.toNSString(),
  );
  if (result != objc.NSComparisonResult.NSOrderedAscending) {
    throw StateError('Unexpected Sparkle version comparison: $result');
  }

  // The generated callback keeps the isolate alive while ObjC can call it.
  stdout.writeln('Sparkle FFI smoke test passed.');
  exit(0);
}
