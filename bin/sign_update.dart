import 'dart:io';
import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  if (!(Platform.isMacOS || Platform.isWindows)) {
    throw UnsupportedError('auto_updater:sign_update');
  }

  String executable = Platform.isMacOS
      ? '${Directory.current.path}/macos/Pods/Sparkle/bin/sign_update'
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
          'sign_update.bat'
        ]);
  List<String> arguments = List<String>.from(args);
  if (Platform.isWindows) {
    if (arguments.length == 1) {
      arguments.add(p.join('dsa_priv.pem'));
    }
  }

  ProcessResult processResult = Process.runSync(
    executable,
    arguments,
  );

  int exitCode = processResult.exitCode;
  if (exitCode == 0) {
    String signature = processResult.stdout.toString();
    if (Platform.isWindows) {
      signature = signature.replaceFirst('\r\n', '').trim();
      signature = 'sparkle:dsaSignature="$signature" length="0"';
    }
    stdout.write(signature);
  } else {
    stderr.write(processResult.stderr);
  }
}
