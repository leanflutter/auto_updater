import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:auto_updater/auto_updater.dart';
// ignore: depend_on_referenced_packages
import 'package:ffi/ffi.dart';
import 'package:flutter/widgets.dart';
// ignore: depend_on_referenced_packages
import 'package:winsparkle/winsparkle.dart';

const _token = 'token=a%2Fb%2B+c';
const _auth = 'Bearer msi-integration-token';

class _Probe with UpdaterListener {
  final completed = Completer<void>();
  final events = <String>[];

  @override
  void onUpdaterError(UpdaterError? error) {
    if (!completed.isCompleted) {
      completed.completeError(error ?? StateError('Native error'));
    }
  }

  @override
  void onUpdaterCheckingForUpdate(Appcast? appcast) {}

  @override
  void onUpdaterUpdateAvailable(AppcastItem? item) => events.add('available');

  @override
  void onUpdaterUpdateNotAvailable(UpdaterError? error) => onUpdaterError(
    error ?? UpdaterError('The fixture did not offer an update'),
  );

  @override
  void onUpdaterUpdateDownloaded(AppcastItem? item) => events.add('downloaded');

  @override
  void onUpdaterBeforeQuitForUpdate(AppcastItem? item) {
    events.add('shutdown');
    if (!completed.isCompleted) completed.complete();
  }
}

void _closeFlutterWindow() {
  final user = DynamicLibrary.open('user32.dll');
  final find = user
      .lookupFunction<
        IntPtr Function(Pointer<Utf16>, Pointer<Utf16>),
        int Function(Pointer<Utf16>, Pointer<Utf16>)
      >('FindWindowW');
  final post = user
      .lookupFunction<
        Int32 Function(IntPtr, Uint32, UintPtr, IntPtr),
        int Function(int, int, int, int)
      >('PostMessageW');
  final window = using(
    (arena) => find(
      'FLUTTER_RUNNER_WIN32_WINDOW'.toNativeUtf16(allocator: arena),
      'auto_updater_example'.toNativeUtf16(allocator: arena),
    ),
  );
  const wmClose = 0x0010;
  if (window == 0 || post(window, wmClose, 0, 0) == 0) {
    throw StateError('Could not close the Flutter window normally');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SizedBox.expand());
  final result = File('msi-integration.result');
  HttpServer? server;
  try {
    final env = Platform.environment;
    final installer = File(env['CODEX_MSI_PATH']!);
    final signature = env['CODEX_MSI_SIGNATURE']!;
    final logPath = env['CODEX_MSI_LOG']!;
    final installerArgs = const HtmlEscape(HtmlEscapeMode.attribute)
        .convert('/qn /norestart /l*v "$logPath"');
    final endpoint = server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    final origin = 'http://127.0.0.1:${endpoint.port}';
    final requests = <String>[];
    final denied = <String>[];
    endpoint.listen((request) async {
      final response = request.response;
      if (request.headers.value(HttpHeaders.authorizationHeader) != _auth) {
        denied.add(request.uri.path);
        response.statusCode = HttpStatus.unauthorized;
        await response.close();
        return;
      }
      requests.add(request.uri.toString());
      switch (request.uri.path) {
        case '/installer/update.msi':
          if (request.uri.query != _token) {
            response.statusCode = HttpStatus.badRequest;
            await response.close();
            return;
          }
          response.headers.contentType = ContentType('application', 'x-msi');
          response.contentLength = installer.lengthSync();
          await installer.openRead().pipe(response);
          return;
        case '/feeds/releases/appcast.xml':
          response.headers.contentType = ContentType('application', 'xml');
          response.write('''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
<channel><title>Fixture</title><item><title>Fixture Release</title>
<enclosure url="../../installer/update.msi?$_token" sparkle:version="2.0.0" sparkle:os="windows"
sparkle:edSignature="$signature" sparkle:installerArguments="$installerArgs"
length="${installer.lengthSync()}" type="application/x-msi" />
</item></channel></rss>''');
        default:
          response.statusCode = HttpStatus.notFound;
      }
      await response.close();
    });

    final native = loadWinSparkle();
    using((arena) {
      native.win_sparkle_set_registry_path(
        'Software\\LeanFlutter\\IntegratedMsiUpdateTest-$pid'
            .toNativeUtf8(allocator: arena)
            .cast(),
      );
      native.win_sparkle_set_app_details(
        'LeanFlutter'.toNativeUtf16(allocator: arena).cast(),
        'Flutter WinSparkle MSI Test'.toNativeUtf16(allocator: arena).cast(),
        '1.0.0'.toNativeUtf16(allocator: arena).cast(),
      );
      if (native.win_sparkle_set_eddsa_public_key(
            env['CODEX_MSI_PUBLIC']!.toNativeUtf8(allocator: arena).cast(),
          ) !=
          1) {
        throw StateError('WinSparkle rejected the fixture public key');
      }
    });
    native.win_sparkle_set_automatic_check_for_updates(0);
    final probe = _Probe();
    autoUpdater.addListener(probe);
    await autoUpdater.setHttpHeaders({'Authorization': _auth});
    await autoUpdater.setFeedURL('$origin/feeds/releases/appcast.xml');
    final before = DateTime.now().toUtc().subtract(const Duration(seconds: 2));
    final finished = probe.completed.future.timeout(
      const Duration(seconds: 40),
    );
    await autoUpdater.checkForUpdatesAndInstall();
    try {
      await finished;
    } catch (error) {
      throw StateError(
        '$error. Authorized paths $requests. Rejected paths $denied.',
      );
    }
    final checked = await autoUpdater.getLastCheckTime();
    if (checked == null || checked.isBefore(before)) {
      throw StateError('No recent update check time. Received: $checked');
    }
    if (probe.events.join(',') != 'available,downloaded,shutdown' ||
        requests.join(',') !=
            '/feeds/releases/appcast.xml,/installer/update.msi?$_token') {
      throw StateError(
        'Unexpected events ${probe.events} or requests $requests',
      );
    }
    result.writeAsStringSync(
      'WinSparkle fetched the authenticated feed and verified its relative signed MSI, '
      'and Flutter received ${probe.events} events. Last check: $checked.',
    );
    await endpoint.close(force: true);
    _closeFlutterWindow();
  } catch (error, stack) {
    result.writeAsStringSync('$error\n$stack');
    await server?.close(force: true);
    exit(1);
  }
}
