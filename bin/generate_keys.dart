import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  // ignore: prefer_function_declarations_over_variables
  var onProcessStdOutOrErr = (data) {
    String message = utf8.decoder.convert(data);
    stdout.write(message);
  };

  if (!(Platform.isMacOS || Platform.isWindows)) {
    throw UnsupportedError('auto_updater:generate_keys');
  }

  String executable = Platform.isMacOS
      ? ''
      : '..\\windows\\WinSparkle-0.7.0\\bin\\generate_keys.bat';

  Process process = await Process.start(
    executable,
    [],
  );

  process.stdout.listen(onProcessStdOutOrErr);
  process.stderr.listen(onProcessStdOutOrErr);
}
