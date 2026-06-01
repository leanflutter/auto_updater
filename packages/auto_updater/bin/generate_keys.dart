import 'dart:convert';
import 'dart:io';

import 'package:auto_updater/src/sparkle_tools.dart';

Future<void> main(List<String> arguments) async {
  if (!(Platform.isMacOS || Platform.isWindows)) {
    throw UnsupportedError('auto_updater:generate_keys');
  }

  final executable = sparkleToolExecutable(SparkleTool.generateKeys);

  final process = await Process.start(executable, arguments);

  process.stdout.transform(utf8.decoder).listen(stdout.write);
  process.stderr.transform(utf8.decoder).listen(stderr.write);
}
