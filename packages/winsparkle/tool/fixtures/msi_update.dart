import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:winsparkle/winsparkle.dart';

Future<void> main(List<String> args) async {
  final native = loadWinSparkle(path: args.single);
  final env = Platform.environment;
  final installer = File(env['CODEX_MSI_PATH']!);
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final origin = 'http://127.0.0.1:${server.port}';
  final signature = env['CODEX_MSI_SIGNATURE']!;
  final logPath = env['CODEX_MSI_LOG']!;
  final installerArgs = const HtmlEscape(HtmlEscapeMode.attribute)
      .convert('/qn /norestart /l*v "$logPath"');
  server.listen((request) async {
    final response = request.response;
    if (request.uri.path == '/installer.msi') {
      response.headers.contentType = ContentType('application', 'x-msi');
      response.contentLength = installer.lengthSync();
      await installer.openRead().pipe(response);
      return;
    }
    response.headers.contentType = ContentType('application', 'xml');
    response.write('''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
<channel><title>Fixture</title><item><title>Fixture Release</title>
<enclosure url="$origin/installer.msi" sparkle:version="2.0.0" sparkle:os="windows"
sparkle:edSignature="$signature" sparkle:installerArguments="$installerArgs"
length="${installer.lengthSync()}" type="application/x-msi" />
</item></channel></rss>''');
    await response.close();
  });
  final finished = Completer<bool>();
  final shutdown = NativeCallable<Void Function()>.listener(() {
    if (!finished.isCompleted) finished.complete(true);
  });
  final error = NativeCallable<Void Function()>.listener(() {
    if (!finished.isCompleted) finished.complete(false);
  });
  using((arena) {
    native.win_sparkle_set_registry_path(
      'Software\\LeanFlutter\\MsiUpdateTest-$pid'
          .toNativeUtf8(allocator: arena)
          .cast(),
    );
    native.win_sparkle_set_app_details(
      'LeanFlutter'.toNativeUtf16(allocator: arena).cast(),
      'WinSparkle MSI Test'.toNativeUtf16(allocator: arena).cast(),
      '1.0.0'.toNativeUtf16(allocator: arena).cast(),
    );
    native.win_sparkle_set_eddsa_public_key(
      env['CODEX_MSI_PUBLIC']!.toNativeUtf8(allocator: arena).cast(),
    );
    native.win_sparkle_set_appcast_url(
      '$origin/appcast.xml'.toNativeUtf8(allocator: arena).cast(),
    );
  });
  native.win_sparkle_set_automatic_check_for_updates(0);
  native.win_sparkle_set_shutdown_request_callback(shutdown.nativeFunction);
  native.win_sparkle_set_error_callback(error.nativeFunction);
  native.win_sparkle_init();
  native.win_sparkle_check_update_with_ui_and_install();
  try {
    if (!await finished.future.timeout(const Duration(seconds: 30))) {
      throw StateError('WinSparkle reported a download or verification error');
    }
    stdout.writeln(
      'WinSparkle launched the installer and requested app shutdown.',
    );
    await server.close(force: true);
    exit(0);
  } catch (error, stack) {
    stderr.writeln('$error\n$stack');
    await server.close(force: true);
    exit(1);
  }
}
