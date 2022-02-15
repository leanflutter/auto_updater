# auto_updater

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url]

[pub-image]: https://img.shields.io/pub/v/auto_updater.svg
[pub-url]: https://pub.dev/packages/auto_updater

[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

This plugin allows Flutter **desktop** apps to automatically update themselves (based on [sparkle](https://sparkle-project.org/) and [winsparkle](https://winsparkle.com)).

---

English | [简体中文](./README-ZH.md)

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [auto_updater](#auto_updater)
  - [Platform Support](#platform-support)
  - [Quick Start](#quick-start)
    - [Installation](#installation)
    - [Usage](#usage)
  - [Who's using it?](#whos-using-it)
  - [API](#api)
    - [AutoUpdater](#autoupdater)
      - [Methods](#methods)
        - [setFeedURL](#setfeedurl)
        - [checkForUpdates](#checkforupdates)
  - [Related Links](#related-links)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Platform Support

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|   ➖   |   ✔️   |    ✔️    |

## Quick Start

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  auto_updater: ^0.1.0
```

Or

```yaml
dependencies:
  auto_updater:
    git:
      url: https://github.com/leanflutter/auto_updater.git
      ref: main
```

### Usage

```dart
import 'package:auto_updater/auto_updater.dart';

void main() async {
  // Must add this line.
  WidgetsFlutterBinding.ensureInitialized();

  String feedURL = 'http://localhost:5000/appcast.xml';
  await autoUpdater.setFeedURL(feedURL);
  await autoUpdater.checkForUpdates();

  runApp(MyApp());
}
```

> Please see the example app of this plugin for a full example.

## Who's using it?

- [Biyi](https://biyidev.com/) - A convenient translation and dictionary app.

## API

<!-- README_DOC_GEN -->
### AutoUpdater

#### Methods

##### setFeedURL

Sets the url and initialize the auto updater.

##### checkForUpdates

Asks the server whether there is an update. You must call setFeedURL before using this API.


<!-- README_DOC_GEN -->

## Related Links

- https://sparkle-project.org/
- https://winsparkle.org/

## License

[MIT](./LICENSE)
