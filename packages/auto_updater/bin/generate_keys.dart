import 'dart:io';

import 'src/sparkle.dart';

Future<void> main(List<String> arguments) async {
  if (!(Platform.isMacOS || Platform.isWindows)) {
    throw UnsupportedError('auto_updater:generate_keys');
  }

  final executable = Platform.isMacOS
      ? findSparkleTool(
          'generate_keys',
          binDirectory: Platform.environment['SPARKLE_BIN_DIR'],
        )
      : findWinSparkleTool('generate_keys');

  final process = await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );
  exitCode = await process.exitCode;
}
