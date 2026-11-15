import 'dart:convert';
import 'dart:io';

import 'src/sparkle.dart';

class SignUpdateResult {
  const SignUpdateResult({required this.signature, required this.length});

  final String signature;
  final int length;
}

SignUpdateResult signUpdate(List<String> args) {
  final executable = Platform.isMacOS
      ? findSparkleTool(
          'sign_update',
          binDirectory: Platform.environment['SPARKLE_BIN_DIR'],
        )
      : findWinSparkleTool('sign_update');
  final arguments = List<String>.of(args);
  if (Platform.isWindows && arguments.length == 1) {
    arguments.add('dsa_priv.pem');
  }

  final processResult = Process.runSync(
    executable,
    arguments,
    stderrEncoding: null,
  );
  stderr.add(processResult.stderr as List<int>);
  if (processResult.exitCode != 0) {
    throw ProcessException(
      executable,
      arguments,
      'Failed to sign update',
      processResult.exitCode,
    );
  }

  final signUpdateOutput = processResult.stdout as String;
  if (Platform.isWindows) {
    final signature = signUpdateOutput.replaceAll(RegExp(r'\s+'), '');
    if (base64.decode(signature).isEmpty) {
      throw const FormatException('The signing tool returned no signature.');
    }
    final length = File(arguments.first).lengthSync();
    stdout.write('sparkle:dsaSignature="$signature" length="$length"');
    return SignUpdateResult(signature: signature, length: length);
  }

  stdout.write(signUpdateOutput);
  final regex = RegExp(r'sparkle:(dsa|ed)Signature="([^"]+)" length="(\d+)"');
  final match = regex.firstMatch(signUpdateOutput);
  if (match == null) {
    throw const FormatException('The signing tool returned no signature.');
  }
  return SignUpdateResult(
    signature: match.group(2)!,
    length: int.parse(match.group(3)!),
  );
}

Future<void> main(List<String> args) async {
  if (!(Platform.isMacOS || Platform.isWindows)) {
    throw UnsupportedError('auto_updater:sign_update');
  }
  try {
    signUpdate(args);
  } on ProcessException catch (error) {
    stderr.writeln(error.message);
    exitCode = error.errorCode == 0 ? 1 : error.errorCode;
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}
