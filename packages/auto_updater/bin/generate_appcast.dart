import 'dart:io';

import 'src/sparkle.dart';

Future<void> main(List<String> arguments) async {
  if (!Platform.isMacOS) {
    throw UnsupportedError(
      'auto_updater:generate_appcast is available on macOS.',
    );
  }

  final executable = findSparkleTool(
    'generate_appcast',
    binDirectory: Platform.environment['SPARKLE_BIN_DIR'],
  );
  final process = await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );
  exitCode = await process.exitCode;
}
