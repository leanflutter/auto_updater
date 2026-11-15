import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:auto_updater/auto_updater.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/widgets.dart';
import 'package:winsparkle/winsparkle.dart';

const _previousWindow = 3; // GW_HWNDPREV
const _buttonClick = 0x00F5; // BM_CLICK
const _moveInZOrderOnly = 0x0013; // SWP_NOSIZE | SWP_NOMOVE | SWP_NOACTIVATE
final _user = DynamicLibrary.open('user32.dll');
final _findWindow = _user
    .lookupFunction<
      IntPtr Function(Pointer<Utf16>, Pointer<Utf16>),
      int Function(Pointer<Utf16>, Pointer<Utf16>)
    >('FindWindowW');
final _findChild = _user
    .lookupFunction<
      IntPtr Function(IntPtr, IntPtr, Pointer<Utf16>, Pointer<Utf16>),
      int Function(int, int, Pointer<Utf16>, Pointer<Utf16>)
    >('FindWindowExW');
final _visible = _user
    .lookupFunction<Int32 Function(IntPtr), int Function(int)>(
      'IsWindowVisible',
    );
final _getWindow = _user
    .lookupFunction<IntPtr Function(IntPtr, Uint32), int Function(int, int)>(
      'GetWindow',
    );
final _post = _user
    .lookupFunction<
      Int32 Function(IntPtr, Uint32, UintPtr, IntPtr),
      int Function(int, int, int, int)
    >('PostMessageW');
final _setPosition = _user
    .lookupFunction<
      Int32 Function(IntPtr, IntPtr, Int32, Int32, Int32, Int32, Uint32),
      int Function(int, int, int, int, int, int, int)
    >('SetWindowPos');

int _window(String title, {String? windowClass}) => using(
  (arena) => _findWindow(
    windowClass?.toNativeUtf16(allocator: arena) ?? nullptr,
    title.toNativeUtf16(allocator: arena),
  ),
);

int _visibleChild(int window, String title) => using((arena) {
  final name = title.toNativeUtf16(allocator: arena);
  for (
    var child = _findChild(window, 0, nullptr, name);
    child != 0;
    child = _findChild(window, child, nullptr, name)
  ) {
    if (_visible(child) != 0) return child;
  }
  return 0;
});

bool _isAbove(int window, int other) {
  for (
    var current = _getWindow(other, _previousWindow);
    current != 0;
    current = _getWindow(current, _previousWindow)
  ) {
    if (current == window) return true;
  }
  return false;
}

Future<int> _waitForWindow(int Function() find, String description) async {
  final until = Stopwatch()..start();
  while (until.elapsed < const Duration(seconds: 15)) {
    final window = find();
    if (window != 0 && _visible(window) != 0) return window;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  throw StateError('Could not see $description');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SizedBox.expand());
  final result = File('install-window.result');
  HttpServer? server;
  try {
    final host = await _waitForWindow(
      () => _window(
        'auto_updater_example',
        windowClass: 'FLUTTER_RUNNER_WIN32_WINDOW',
      ),
      'the Flutter host',
    );
    final native = loadWinSparkle();
    using((arena) {
      native.win_sparkle_set_registry_path(
        'Software\\LeanFlutter\\InstallWindowSmoke-$pid'
            .toNativeUtf8(allocator: arena)
            .cast(),
      );
      native.win_sparkle_set_lang('en'.toNativeUtf8(allocator: arena).cast());
      native.win_sparkle_set_eddsa_public_key(
        'PUAXw+hDiVqStwqnTRt+vJyYLM8uxJaMwM1V8Sr0Zgw='
            .toNativeUtf8(allocator: arena)
            .cast(),
      );
    });
    native.win_sparkle_set_automatic_check_for_updates(0);
    final endpoint = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server = endpoint;
    final downloadStarted = Completer<void>();
    final completeDownload = Completer<void>();
    endpoint.listen((request) async {
      final response = request.response;
      if (request.uri.path == '/installer.exe') {
        if (!downloadStarted.isCompleted) downloadStarted.complete();
        await completeDownload.future;
        response.headers.add(HttpHeaders.contentLengthHeader, '1');
        response.add([0x72]); // RFC 8032 Ed25519 test vector 2.
      } else {
        response.headers.contentType = ContentType('application', 'xml');
        response.write('''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
<channel><title>Fixture</title><item><title>Fixture</title>
<enclosure url="installer.exe" sparkle:version="999.0.0" sparkle:os="windows"
sparkle:edSignature="kqAJqfDUyrhyDoILX2QlQKKye1QWUD+Ps3YiI+vbadoIWsHkPhWZbkWPNhPQ8R2MOHsurrQwKu6wDSkWErsMAA=="
type="application/octet-stream" /></item></channel></rss>''');
      }
      await response.close();
    });
    await autoUpdater.setFeedURL(
      'http://127.0.0.1:${endpoint.port}/appcast.xml',
    );
    await autoUpdater.checkForUpdates();
    final dialog = await _waitForWindow(
      () => _window('Software Update'),
      'the update dialog',
    );
    final install = await _waitForWindow(
      () => _visibleChild(dialog, 'Install update'),
      'the first Install update button',
    );
    if (_post(install, _buttonClick, 0, 0) == 0) {
      throw StateError('The update button did not receive BM_CLICK');
    }
    await downloadStarted.future.timeout(const Duration(seconds: 10));
    if (_setPosition(host, 0, 0, 0, 0, 0, _moveInZOrderOnly) == 0) {
      throw StateError('Could not move the host window to HWND_TOP');
    }
    if (!_isAbove(host, dialog)) {
      throw StateError('The host is already behind the update dialog');
    }
    completeDownload.complete();
    await _waitForWindow(
      () => _visibleChild(dialog, 'Ready to install.'),
      'the Ready to install state',
    );
    if (!_isAbove(host, dialog)) {
      throw StateError(
        'The dialog already appears above the host when it is ready',
      );
    }
    result.writeAsStringSync(
      'Reproduced: ready-to-install dialog remains below the host.',
    );
    await endpoint.close(force: true);
    exit(0);
  } catch (error, stack) {
    result.writeAsStringSync('$error\n$stack');
    await server?.close(force: true);
    exit(1);
  }
}
