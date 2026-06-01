import 'dart:io';

import 'package:auto_updater/src/sparkle_tools.dart';
import 'package:path/path.dart' as p;

class SignUpdateResult {
  const SignUpdateResult({required this.signature, required this.length});

  final String signature;
  final int length;
}

SignUpdateResult signUpdate(List<String> args) {
  final executable = sparkleToolExecutable(SparkleTool.signUpdate);
  final arguments = List<String>.from(args);
  if (Platform.isWindows) {
    if (arguments.length == 1) {
      arguments.add(p.join('dsa_priv.pem'));
    }
  }

  final processResult = Process.runSync(executable, arguments);

  final exitCode = processResult.exitCode;

  if (exitCode != 0) {
    stderr.write(processResult.stderr);
    throw Exception('Failed to sign update');
  }

  var signUpdateOutput = processResult.stdout.toString();
  if (Platform.isWindows) {
    signUpdateOutput = signUpdateOutput.replaceFirst('\r\n', '').trim();
    signUpdateOutput = 'sparkle:dsaSignature="$signUpdateOutput" length="0"';
  }
  stdout.write(signUpdateOutput);

  final regex = RegExp(r'sparkle:(dsa|ed)Signature="([^"]+)" length="(\d+)"');
  final match = regex.firstMatch(signUpdateOutput);

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
