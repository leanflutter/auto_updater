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
      : '..\\windows\\WinSparkle-0.7.0\\bin\\sign_update.bat';

  Process process = await Process.start(
    executable,
    arguments,
  );

  process.stdout.listen(onProcessStdOutOrErr);
  process.stderr.listen(onProcessStdOutOrErr);
}
