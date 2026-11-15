import 'dart:async';
import 'dart:io';

import 'package:auto_updater/auto_updater.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/widgets.dart';
import 'package:winsparkle/winsparkle.dart';

class _Probe with UpdaterListener {
  final outcome = Completer<bool>();

  @override
  void onUpdaterError(UpdaterError? error) {
    if (!outcome.isCompleted) outcome.complete(false);
  }

  @override
  void onUpdaterBeforeQuitForUpdate(AppcastItem? appcastItem) {}

  @override
  void onUpdaterCheckingForUpdate(Appcast? appcast) {}

  @override
  void onUpdaterUpdateAvailable(AppcastItem? appcastItem) {}

  @override
  void onUpdaterUpdateDownloaded(AppcastItem? appcastItem) {
    if (!outcome.isCompleted) outcome.complete(true);
  }

  @override
  void onUpdaterUpdateNotAvailable(UpdaterError? error) =>
      onUpdaterError(error);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final output = File('download-event.result');
  HttpServer? server;
  try {
    final native = loadWinSparkle();
    using((arena) {
      native.win_sparkle_set_registry_path(
        'Software\\LeanFlutter\\DownloadEventSmoke-$pid'
            .toNativeUtf8(allocator: arena)
            .cast(),
      );
      native.win_sparkle_set_eddsa_public_key(
        'PUAXw+hDiVqStwqnTRt+vJyYLM8uxJaMwM1V8Sr0Zgw='
            .toNativeUtf8(allocator: arena)
            .cast(),
      );
    });
    native.win_sparkle_set_automatic_check_for_updates(0);
    final probe = _Probe();
    autoUpdater.addListener(probe);
    final endpoint = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server = endpoint;
    endpoint.listen((request) async {
      if (request.uri.path == '/installer.exe') {
        // RFC 8032, Ed25519 TEST 2. This byte is not an executable.
        request.response.add([0x72]);
      } else {
        request.response.headers.contentType = ContentType(
          'application',
          'xml',
        );
        request.response.write('''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
<channel><title>Fixture</title><item><title>Fixture</title>
<enclosure url="installer.exe" sparkle:version="999.0.0" sparkle:os="windows"
sparkle:edSignature="kqAJqfDUyrhyDoILX2QlQKKye1QWUD+Ps3YiI+vbadoIWsHkPhWZbkWPNhPQ8R2MOHsurrQwKu6wDSkWErsMAA=="
type="application/octet-stream" /></item></channel></rss>
''');
      }
      await request.response.close();
    });
    await autoUpdater.setFeedURL(
      'http://127.0.0.1:${endpoint.port}/appcast.xml',
    );
    native.win_sparkle_check_update_with_ui_and_install();
    if (!await probe.outcome.future.timeout(const Duration(seconds: 20))) {
      throw StateError(
        'Flutter received an error instead of the download event.',
      );
    }
    output.writeAsStringSync(
      'Flutter UpdaterListener received the download event.',
    );
    await endpoint.close(force: true);
    exit(0);
  } catch (error, stack) {
    output.writeAsStringSync('$error\n$stack');
    await server?.close(force: true);
    exit(1);
  }
}
