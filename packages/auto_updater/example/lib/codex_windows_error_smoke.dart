import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:auto_updater/auto_updater.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/widgets.dart';
import 'package:winsparkle/winsparkle.dart';

const _publicKey = 'PUAXw+hDiVqStwqnTRt+vJyYLM8uxJaMwM1V8Sr0Zgw=';
const _signature =
    'kqAJqfDUyrhyDoILX2QlQKKye1QWUD+Ps3YiI+vbadoIWsHkPhWZbkWPNhPQ8R2MO'
    'HsurrQwKu6wDSkWErsMAA==';

class _Probe with UpdaterListener {
  final error = Completer<UpdaterError?>();
  int errorCount = 0;
  bool downloaded = false;

  @override
  void onUpdaterError(UpdaterError? value) {
    errorCount++;
    if (!error.isCompleted) error.complete(value);
  }

  @override
  void onUpdaterUpdateDownloaded(AppcastItem? item) => downloaded = true;

  @override
  void onUpdaterBeforeQuitForUpdate(AppcastItem? item) {}
  @override
  void onUpdaterCheckingForUpdate(Appcast? appcast) {}
  @override
  void onUpdaterUpdateAvailable(AppcastItem? item) {}
  @override
  void onUpdaterUpdateNotAvailable(UpdaterError? error) {}
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SizedBox.expand());
  final scenario = Platform.environment['UPDATER_SMOKE_CASE']!;
  final resultFile = File('updater-error.result');
  HttpServer? server;
  try {
    final native = loadWinSparkle();
    final probe = _Probe();
    autoUpdater.addListener(probe);
    using((arena) {
      native.win_sparkle_set_registry_path(
        'Software\\LeanFlutter\\WinSparkleErrorSmoke-$pid'
            .toNativeUtf8(allocator: arena)
            .cast(),
      );
      if (native.win_sparkle_set_eddsa_public_key(
            _publicKey.toNativeUtf8(allocator: arena).cast(),
          ) !=
          1) {
        throw StateError('WinSparkle rejected the fixture public key');
      }
    });
    native.win_sparkle_set_automatic_check_for_updates(0);

    final tls = scenario == 'untrustedTls';
    final expectInstaller =
        scenario == 'installer403' || scenario == 'tampered';
    final endpoint = server = tls
        ? await HttpServer.bindSecure(
            InternetAddress.loopbackIPv4,
            0,
            SecurityContext()
              ..useCertificateChain('test-cert.pem')
              ..usePrivateKey('test-key.pem'),
          )
        : await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final origin = '${tls ? 'https' : 'http'}://127.0.0.1:${endpoint.port}';
    var installerRequests = 0;
    var appcastRequests = 0;
    endpoint.listen((request) async {
      final response = request.response;
      if (request.uri.path == '/installer.exe') {
        installerRequests++;
        if (scenario == 'installer403') {
          response.statusCode = HttpStatus.forbidden;
        } else {
          response.headers.contentType = ContentType.binary;
          response.add([0x73]); // The Ed25519 signature is for 0x72.
        }
      } else {
        appcastRequests++;
        if (!expectInstaller) {
          response.statusCode = HttpStatus.notFound;
        } else {
          response.headers.contentType = ContentType('application', 'xml');
          response.write(
            '''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
<channel><title>Fixture</title><item><title>Fixture</title>
<enclosure url="$origin/installer.exe" sparkle:version="999.0.0" sparkle:os="windows"
sparkle:edSignature="$_signature" type="application/octet-stream" /></item></channel></rss>''',
          );
        }
      }
      await response.close();
    });

    await autoUpdater.setFeedURL('$origin/appcast.xml?auth=secret-fixture');
    if (expectInstaller) {
      // Enter the download path without requiring a manual dialog click.
      native.win_sparkle_check_update_with_ui_and_install();
    } else {
      await autoUpdater.checkForUpdates(inBackground: true);
    }
    final error = await probe.error.future.timeout(const Duration(seconds: 25));
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final expected = switch (scenario) {
      'appcast404' => 'Appcast request failed. Server returned HTTP 404.',
      'installer403' => 'Installer request failed. Server returned HTTP 403.',
      'tampered' => 'The update signature could not be verified.',
      'untrustedTls' => 'Appcast request failed. Untrusted TLS certificate authority (WinINet 12045).',
      'legacy' => null,
      _ => throw ArgumentError.value(scenario),
    };
    if (error?.message != expected ||
        probe.errorCount != 1 ||
        probe.downloaded) {
      throw StateError(
        'Expected "$expected" exactly once and no download event. '
        'Received "${error?.message}", ${probe.errorCount} times, downloaded=${probe.downloaded}.',
      );
    }
    if (appcastRequests != (tls ? 0 : 1) ||
        installerRequests != (expectInstaller ? 1 : 0)) {
      throw StateError(
        'Unexpected number of requests: appcast=$appcastRequests installer=$installerRequests',
      );
    }
    resultFile.writeAsStringSync(
      '$scenario: ${error?.message ?? '(legacy callback)'}',
    );
    await endpoint.close(force: true);
    exit(0);
  } catch (error, stack) {
    resultFile.writeAsStringSync('$error\n$stack');
    await server?.close(force: true);
    exit(1);
  }
}
