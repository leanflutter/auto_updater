import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:winsparkle/winsparkle.dart';

Future<void> main(List<String> arguments) async {
  const auth = 'Bearer redirect-fixture';
  final updater = loadWinSparkle(path: arguments.single);
  final endpoint = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final requests = <(String, bool)>[];
  endpoint.listen((request) async {
    requests.add((
      request.uri.path,
      request.headers.value(HttpHeaders.authorizationHeader) == auth,
    ));
    if (request.uri.path == '/redirect') {
      request.response.statusCode = HttpStatus.found;
      request.response.headers.set(HttpHeaders.locationHeader, '/feed');
    } else {
      request.response.statusCode = HttpStatus.notFound;
    }
    await request.response.close();
  });

  final checked = Completer<void>();
  final callback = NativeCallable<Void Function()>.listener(() {
    if (!checked.isCompleted) checked.complete();
  });
  try {
    using((arena) {
      updater.win_sparkle_set_registry_path(
        'Software\\LeanFlutter\\RedirectHeaderSmoke-$pid'
            .toNativeUtf8(allocator: arena)
            .cast(),
      );
      updater.win_sparkle_set_appcast_url(
        'http://127.0.0.1:${endpoint.port}/redirect'
            .toNativeUtf8(allocator: arena)
            .cast(),
      );
      updater.win_sparkle_set_http_header(
        'authorization'.toNativeUtf8(allocator: arena).cast(),
        auth.toNativeUtf8(allocator: arena).cast(),
      );
    });
    updater.win_sparkle_set_automatic_check_for_updates(0);
    updater.win_sparkle_set_error_callback(callback.nativeFunction);
    updater.win_sparkle_init();
    updater.win_sparkle_check_update_without_ui();
    await checked.future.timeout(const Duration(seconds: 25));
    stdout.writeln('WinINet request paths and authentication: $requests');
    if (requests.length != 2 ||
        requests.first != ('/redirect', true) ||
        requests.last.$1 != '/feed') {
      throw StateError('Unexpected redirect trace: $requests');
    }
  } finally {
    updater.win_sparkle_cleanup();
    callback.close();
    await endpoint.close(force: true);
  }
}
