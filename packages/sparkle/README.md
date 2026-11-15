# sparkle

Dart FFI bindings for the [Sparkle 2](https://sparkle-project.org/documentation/api-reference/index.html)
Objective-C API on macOS. The bindings are generated from Sparkle 2.10.1 and
include the updater, delegates, user drivers, appcast types, and error constants.

Embed and sign the complete `Sparkle.framework` in the host app as described in
the [Sparkle setup guide](https://sparkle-project.org/documentation/). The Dart
build hook compiles the Objective-C helpers for callbacks and protocols; the
package does not ship the Sparkle framework itself.

```dart
import 'package:objective_c/objective_c.dart';
import 'package:sparkle/sparkle.dart';

void main() {
  final bindings = loadSparkle();
  print(bindings.SUSparkleErrorDomain.toDartString());
}
```

`loadSparkle()` looks in the app's `Contents/Frameworks` directory. Supply
`path:` to load a different Sparkle framework executable. If the app already
links the framework, the Objective-C classes (e.g. `SPUUpdater`) are available
directly. Call updater and user interface APIs on the macOS main thread.

## Regenerate the bindings

Run from this package on macOS with Xcode installed:

```sh
dart pub get
dart --packages=.dart_tool/package_config.json tool/ffigen.dart
```

The generator reads the headers in [src/include/Sparkle](src/include/Sparkle)
from the [Sparkle 2.10.1 release](https://github.com/sparkle-project/Sparkle/releases/tag/2.10.1).
The Sparkle 1 compatibility API and the deprecated
`SUVersionDisplay.formatVersion:andVersion:` selector are excluded.

To smoke test against the actual framework executable:

```sh
dart run tool/smoke_test.dart /path/to/Sparkle.framework/Sparkle
```
