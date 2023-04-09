import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  // ignore: prefer_function_declarations_over_variables
  var onProcessStdOutOrErr = (data) {
    String message = utf8.decoder.convert(data);
    stdout.write(message);
  };

  if (!(Platform.isMacOS || Platform.isWindows)) {
    throw UnsupportedError('auto_updater:sign_update');
  }

  String executable = Platform.isMacOS
      ? '${Directory.current.path}/macos/Pods/Sparkle/bin/sign_update'
      : '${Directory.current.path}\\windows\\flutter\\ephemeral\\.plugin_symlinks\\auto_updater\\windows\\WinSparkle-0.8.0\\bin\\sign_update.bat';

  if (Platform.isWindows) {
    if (arguments.length == 1) {
      arguments.add('.\\dsa_priv.pem');
    }
  }

  Process process = await Process.start(
    executable,
    arguments,
  );

  process.stdout.listen(onProcessStdOutOrErr);
  process.stderr.listen(onProcessStdOutOrErr);
}
