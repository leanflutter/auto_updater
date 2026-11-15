import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show AppExitType;

import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _authorization = 'Bearer hosted-updater-fixture';
const _feedPath = '/feeds/releases/appcast.xml';
const _downloadPath = '/installer/update.msi';
const _query = 'token=a%2Fb%2B+c';

class _UpdateListener with UpdaterListener {
  _UpdateListener(this.requests, this.result);

  final List<String> requests;
  final File result;
  final finished = Completer<void>();
  final events = <String>[];

  @override
  void onUpdaterError(UpdaterError? error) {
    if (!finished.isCompleted) {
      finished.completeError(error ?? StateError('Missing updater error'));
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
  Future<void> onUpdaterBeforeQuitForUpdate(AppcastItem? item) async {
    events.add('shutdown');
    if (events.join(',') != 'available,downloaded,shutdown' ||
        requests.join(',') != '$_feedPath,$_downloadPath?$_query') {
      onUpdaterError(
        UpdaterError('Unexpected events $events and requests $requests'),
      );
      return;
    }
    result.writeAsStringSync(
      'Hosted packages delivered available, downloaded, and shutdown.',
    );
    finished.complete();
    await ServicesBinding.instance.exitApplication(AppExitType.required);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final result = File('hosted-updater.result');
  final installer = File(Platform.environment['TEST_MSI_PATH']!);
  final signature = Platform.environment['TEST_MSI_SIGNATURE']!;
  final logPath = Platform.environment['TEST_MSI_LOG']!;
  final installerArgs = const HtmlEscape(HtmlEscapeMode.attribute)
      .convert('/qn /norestart /l*v "$logPath"');
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final requests = <String>[];
  server.listen((request) async {
    final response = request.response;
    if (request.headers.value(HttpHeaders.authorizationHeader) !=
        _authorization) {
      response.statusCode = HttpStatus.unauthorized;
    } else {
      requests.add(request.uri.toString());
      switch (request.uri.path) {
        case _downloadPath when request.uri.query == _query:
          response.headers.contentType = ContentType('application', 'x-msi');
          response.contentLength = installer.lengthSync();
          await installer.openRead().pipe(response);
          return;
        case _feedPath:
          response.headers.contentType = ContentType('application', 'xml');
          response.write('''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
<channel><title>Fixture</title><item><title>Fixture Release</title>
<enclosure url="../../installer/update.msi?$_query" sparkle:version="2.0.0" sparkle:os="windows"
sparkle:dsaSignature="$signature" sparkle:installerArguments="$installerArgs"
length="${installer.lengthSync()}" type="application/x-msi" />
</item></channel></rss>''');
        default:
          response.statusCode = HttpStatus.notFound;
      }
    }
    await response.close();
  });
  final listener = _UpdateListener(requests, result);
  try {
    autoUpdater.addListener(listener);
    runApp(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: Text('Hosted updater test')),
      ),
    );
    await WidgetsBinding.instance.endOfFrame;
    await autoUpdater.setHttpHeaders({'Authorization': _authorization});
    await autoUpdater.setFeedURL('http://127.0.0.1:${server.port}$_feedPath');
    await Future.wait([
      autoUpdater.checkForUpdatesAndInstall(),
      listener.finished.future,
    ], eagerError: true).timeout(const Duration(seconds: 35));
    await Future<void>.delayed(const Duration(seconds: 5));
    throw StateError('The Flutter runner did not exit');
  } catch (error, trace) {
    result.writeAsStringSync('$error\n$trace');
    await server.close(force: true);
    exit(1);
  }
}
