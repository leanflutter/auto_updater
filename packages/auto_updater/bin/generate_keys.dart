import 'dart:convert';
import 'dart:io';

import 'src/sparkle.dart';

Future<void> main(List<String> arguments) async {
  if (!(Platform.isMacOS || Platform.isWindows)) {
    throw UnsupportedError('auto_updater:generate_keys');
  }

  String executable = Platform.isMacOS
      ? findSparkleTool(
          'generate_keys',
          binDirectory: Platform.environment['SPARKLE_BIN_DIR'],
        )
      : findWinSparkleTool('generate_keys');

  Process process = await Process.start(executable, arguments);

  process.stdout.transform(utf8.decoder).listen(stdout.write);
  process.stderr.transform(utf8.decoder).listen(stderr.write);
}
