# winsparkle

Dart FFI bindings for the [WinSparkle](https://winsparkle.org/) C API on
Windows, generated from WinSparkle 0.8.1. The package exposes the native
functions, callback types, constants, and configuration struct.

Ship the matching architecture of `WinSparkle.dll` from the
[0.8.1 release](https://github.com/vslavik/winsparkle/releases/tag/v0.8.1)
beside the host application's executable. To load it from another location,
pass its path explicitly.

```dart
import 'package:winsparkle/winsparkle.dart';

void main() {
  final winSparkle = loadWinSparkle();
  print(winSparkle.win_sparkle_get_update_check_interval());
}
```

Configure the updater and register callbacks before calling
`win_sparkle_init()`. Call `win_sparkle_cleanup()` when the app shuts down.
WinSparkle can invoke callbacks on its own threads: use a
`NativeCallable.listener` for asynchronous notifications with a void return
type. A callback that must return a value or write to a caller-owned buffer
synchronously needs a native implementation when invoked on a WinSparkle
thread.

## Regenerate the bindings

Run from this package with LLVM/libclang installed:

```sh
dart pub get
dart run tool/ffigen.dart
```

The generator targets the Windows ABI with the headers in
[tool/WinSparkle](tool/WinSparkle). A Windows SDK is not required.

To smoke test on Windows against an actual DLL:

```powershell
dart run tool/smoke_test.dart C:\path\to\WinSparkle.dll
```
