import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

Future<void> main(List<String> arguments) async {
  if (!(Platform.isMacOS || Platform.isWindows)) {
    throw UnsupportedError('auto_updater:generate_keys');
  }

  String executable = Platform.isMacOS
      ? '${Directory.current.path}/macos/Pods/Sparkle/bin/generate_keys'
      : p.joinAll([
          Directory.current.path,
          'windows',
          'flutter',
          'ephemeral',
          '.plugin_symlinks',
          'auto_updater',
          'windows',
          'WinSparkle-0.8.0',
          'bin',
          'generate_keys.bat'
        ]);

  Process process = await Process.start(
    executable,
    arguments,
  );

  process.stdout.transform(utf8.decoder).listen(stdout.write);
  process.stderr.transform(utf8.decoder).listen(stderr.write);
}
