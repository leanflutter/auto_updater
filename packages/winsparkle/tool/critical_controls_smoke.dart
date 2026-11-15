import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:winsparkle/winsparkle.dart';

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

int _dialog() => using((arena) {
  final window = _findWindow(
    nullptr,
    'Software Update'.toNativeUtf16(allocator: arena),
  );
  return window != 0 && _visible(window) != 0 ? window : 0;
});

bool _visibleButton(int window, String label) => using((arena) {
  final name = label.toNativeUtf16(allocator: arena);
  for (
    var child = _findChild(window, 0, nullptr, name);
    child != 0;
    child = _findChild(window, child, nullptr, name)
  ) {
    if (_visible(child) != 0) return true;
  }
  return false;
});

Future<void> main(List<String> args) async {
  final critical = args.last == 'critical';
  final language = critical ? 'zh-Hans' : 'en';
  final feedPath = '/appcast-$language.xml';
  final notesPath = '/release-notes-$language.html';
  final assetPath = '/notes-visible-$language.png';
  final native = loadWinSparkle(path: args.first);
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final origin = 'http://127.0.0.1:${server.port}';
  final requested = Completer<void>();
  final sendFeed = Completer<void>();
  final notesAssetRequested = Completer<void>();
  final notesRequests = <String>[];
  final outcome = Completer<bool>();
  final found = NativeCallable<Void Function()>.listener(() {
    if (!outcome.isCompleted) outcome.complete(true);
  });
  final failed = NativeCallable<Void Function()>.listener(() {
    if (!outcome.isCompleted) outcome.complete(false);
  });
  server.listen((request) async {
    if (request.uri.path == feedPath) {
      if (!requested.isCompleted) requested.complete();
      await sendFeed.future;
      final criticalElement = critical ? '<sparkle:criticalUpdate />' : '';
      request.response.headers.contentType = ContentType('application', 'xml');
      request.response.write('''
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
<channel><title>Fixture</title><item><title>Updated fixture</title>
$criticalElement
<sparkle:releaseNotesLink>$origin$notesPath</sparkle:releaseNotesLink>
<enclosure url="$origin/update.exe" sparkle:version="2.0.0" sparkle:os="windows"
type="application/octet-stream" /></item></channel></rss>''');
    } else if (request.uri.path == notesPath) {
      notesRequests.add(request.uri.path);
      request.response.headers.contentType = ContentType.html;
      final description = language == 'en' ? 'Release notes' : '发行说明';
      request.response.write(
        '<!doctype html><p>$description</p><img src="$assetPath">',
      );
    } else if (request.uri.path == assetPath) {
      if (!notesAssetRequested.isCompleted) notesAssetRequested.complete();
      request.response.statusCode = HttpStatus.noContent;
    } else {
      request.response.statusCode = HttpStatus.notFound;
    }
    await request.response.close();
  });
  try {
    using((arena) {
      native.win_sparkle_set_registry_path(
        'Software\\LeanFlutter\\WinSparkleCriticalSmoke-$pid'
            .toNativeUtf8(allocator: arena)
            .cast(),
      );
      native.win_sparkle_set_app_details(
        'LeanFlutter'.toNativeUtf16(allocator: arena).cast(),
        'WinSparkle Controls Smoke'.toNativeUtf16(allocator: arena).cast(),
        '1.0.0'.toNativeUtf16(allocator: arena).cast(),
      );
      native.win_sparkle_set_lang('en'.toNativeUtf8(allocator: arena).cast());
      native.win_sparkle_set_appcast_url(
        '$origin$feedPath'.toNativeUtf8(allocator: arena).cast(),
      );
    });
    native.win_sparkle_set_automatic_check_for_updates(0);
    native.win_sparkle_set_did_find_update_callback(found.nativeFunction);
    native.win_sparkle_set_error_callback(failed.nativeFunction);
    native.win_sparkle_init();
    native.win_sparkle_check_update_without_ui();
    await requested.future.timeout(const Duration(seconds: 15));
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (_dialog() != 0)
      throw StateError('A background check showed a progress window');
    sendFeed.complete();
    if (!await outcome.future.timeout(const Duration(seconds: 15))) {
      throw StateError('WinSparkle failed to check the fixture feed');
    }
    final timer = Stopwatch()..start();
    while (true) {
      final dialog = _dialog();
      if (dialog != 0 && _visibleButton(dialog, 'Install update')) {
        final skip = _visibleButton(dialog, 'Skip this version');
        final later = _visibleButton(dialog, 'Remind me later');
        if (skip == critical || later == critical) {
          throw StateError(
            'Unexpected controls. Critical=$critical, skip=$skip, later=$later',
          );
        }
        stdout.writeln(
          'The background check showed no progress dialog. Critical=$critical, skip=$skip, later=$later.',
        );
        break;
      }
      if (timer.elapsed >= const Duration(seconds: 15)) {
        throw StateError('WinSparkle did not display the available update');
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    await notesAssetRequested.future.timeout(const Duration(seconds: 25));
    if (notesRequests.join(',') != notesPath) {
      throw StateError('Unexpected release note requests: $notesRequests');
    }
    stdout.writeln(
      'The native update dialog loaded and parsed $notesPath using $feedPath.',
    );
  } finally {
    if (!sendFeed.isCompleted) sendFeed.complete();
    native.win_sparkle_cleanup();
    found.close();
    failed.close();
    await server.close(force: true);
  }
}
