import 'dart:io';
import 'package:path/path.dart' as p;

class SignUpdateResult {
  const SignUpdateResult({
    required this.signature,
    required this.length,
  });

  final String signature;
  final int length;
}

SignUpdateResult signUpdate(List<String> args) {
  String executable = Platform.isMacOS
      ? '${Directory.current.path}/macos/Pods/Sparkle/bin/sign_update'
      : p.joinAll(
          [
            Directory.current.path,
            'windows',
            'flutter',
            'ephemeral',
            '.plugin_symlinks',
            'auto_updater_windows',
            'windows',
            'WinSparkle-0.8.1',
            'bin',
            'sign_update.bat',
          ],
        );
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

  String? signUpdateOutput;
  if (exitCode == 0) {
    signUpdateOutput = processResult.stdout.toString();
    if (Platform.isWindows) {
      signUpdateOutput = signUpdateOutput.replaceFirst('\r\n', '').trim();
      signUpdateOutput = 'sparkle:dsaSignature="$signUpdateOutput" length="0"';
    }
    stdout.write(signUpdateOutput);
  } else {
    stderr.write(processResult.stderr);
  }

  RegExp regex = RegExp(r'sparkle:(dsa|ed)Signature="([^"]+)" length="(\d+)"');
  RegExpMatch? match = regex.firstMatch(signUpdateOutput!);

  if (match == null) {
    throw Exception('Failed to sign update');
  }
  return SignUpdateResult(
    signature: match.group(2)!,
    length: int.tryParse(match.group(3)!)!,
  );
}

Future<void> main(List<String> args) async {
  if (!(Platform.isMacOS || Platform.isWindows)) {
    throw UnsupportedError('auto_updater:sign_update');
  }
  signUpdate(args);
}
