import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:winsparkle/winsparkle.dart';

const _feedPath = '/feeds/stable/appcast.xml';
const _token = 'token=a%2Fb%2B+c';

enum _EnclosureCase {
  relative,
  redirected,
  rootRelative,
  absolute;

  bool get redirectsFeed => this == redirected;

  String url(String origin) => switch (this) {
    relative => 'updates/installer.exe?$_token',
    redirected => '../updates/installer.exe?$_token',
    rootRelative => '/updates/installer.exe?$_token',
    absolute => '$origin/updates/installer.exe?$_token',
  };

  String get expectedPath => switch (this) {
    relative => '/feeds/stable/updates/installer.exe',
    redirected => '/feeds/updates/installer.exe',
    rootRelative || absolute => '/updates/installer.exe',
  };
}

Future<void> main(List<String> arguments) async {
  if (arguments.length == 1) {
    // WinSparkle has process-global settings and native UI. Use a fresh
    // process for each scenario.
    for (final testCase in _EnclosureCase.values) {
      final child = await Process.start(Platform.resolvedExecutable, [
        Platform.script.toFilePath(),
        File(arguments.single).absolute.path,
        testCase.name,
      ]);
      final output = Future.wait([
        stdout.addStream(child.stdout),
        stderr.addStream(child.stderr),
      ]);
      final status = await child.exitCode.timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          child.kill();
          throw TimeoutException('WinSparkle test timed out: ${testCase.name}');
        },
      );
      await output;
      if (status != 0) {
        exitCode = status;
        return;
      }
    }
    return;
  }
  if (arguments.length != 2) {
    throw ArgumentError('Pass the path to WinSparkle.dll.');
  }
  await _checkDownload(
    arguments.first,
    _EnclosureCase.values.byName(arguments.last),
  );
}

Future<void> _checkDownload(String dllPath, _EnclosureCase testCase) async {
  final winSparkle = loadWinSparkle(path: dllPath);
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final origin = 'http://127.0.0.1:${server.port}';
  final registryPath = 'Software\\LeanFlutter\\WinSparkleRelativeTest-$pid';
  final installerRequest = Completer<Uri>();
  final errorCallback = NativeCallable<Void Function()>.listener(() {
    if (!installerRequest.isCompleted) {
      installerRequest.completeError(
        StateError('WinSparkle failed before requesting the installer'),
      );
    }
  });

  server.listen((request) async {
    final response = request.response;
    switch (request.uri.path) {
      case '/redirect':
        response.statusCode = HttpStatus.found;
        response.headers.set(HttpHeaders.locationHeader, '$_feedPath?feed=yes');
      case _feedPath:
        response.headers.contentType = ContentType('application', 'xml');
        response.headers.set(
          'Content-Disposition',
          'attachment; filename="appcast.xml"',
        );
        response.write('''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel><title>Fixture</title>
    <item><title>Test Update</title><enclosure
      url="${testCase.url(origin)}" sparkle:version="2.0.0" sparkle:os="windows"
      type="application/octet-stream" /></item>
  </channel>
</rss>''');
      default:
        if (!installerRequest.isCompleted) {
          installerRequest.complete(request.uri);
        }
        // Verify WinSparkle reaches this URL without launching any installer.
        response.statusCode = HttpStatus.notFound;
    }
    await response.close();
  });

  try {
    using((arena) {
      winSparkle.win_sparkle_set_registry_path(
        registryPath.toNativeUtf8(allocator: arena).cast(),
      );
      winSparkle.win_sparkle_set_app_details(
        'LeanFlutter'.toNativeUtf16(allocator: arena).cast(),
        'WinSparkle Relative URL Test'.toNativeUtf16(allocator: arena).cast(),
        '1.0.0'.toNativeUtf16(allocator: arena).cast(),
      );
      winSparkle.win_sparkle_set_appcast_url(
        '$origin${testCase.redirectsFeed ? '/redirect' : _feedPath}'
            .toNativeUtf8(allocator: arena)
            .cast(),
      );
    });
    winSparkle.win_sparkle_set_automatic_check_for_updates(0);
    winSparkle.win_sparkle_set_error_callback(errorCallback.nativeFunction);
    winSparkle.win_sparkle_init();
    winSparkle.win_sparkle_check_update_with_ui_and_install();

    final request = await installerRequest.future.timeout(
      const Duration(seconds: 20),
    );
    if (request.path != testCase.expectedPath || request.query != _token) {
      throw StateError(
        '${testCase.name} requested $request, expected '
        '${testCase.expectedPath}?$_token',
      );
    }
    stdout.writeln('${testCase.name} requested $request');
  } finally {
    winSparkle.win_sparkle_cleanup();
    winSparkle.win_sparkle_set_error_callback(nullptr);
    errorCallback.close();
    await server.close(force: true);
    await Process.run('reg.exe', ['delete', 'HKCU\\$registryPath', '/f']);
  }
}
