> **🚀 Ship Your App Faster**: Try [Fastforge](https://fastforge.dev) - The simplest way to build, package and distribute your Flutter apps.

# auto_updater

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url]

[pub-image]: https://img.shields.io/pub/v/auto_updater.svg
[pub-url]: https://pub.dev/packages/auto_updater
[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

This plugin allows Flutter **desktop** apps to automatically update themselves (based on [sparkle](https://sparkle-project.org/) and [winsparkle](https://winsparkle.org)).

<img src="https://raw.githubusercontent.com/leanflutter/auto_updater/main/screenshots/sparkle.png" width="732" alt="">

---

English | [简体中文](./README-ZH.md)

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Platform Support](#platform-support)
- [Documentation](#documentation)
- [Who's using it?](#whos-using-it)
- [API](#api)
  - [AutoUpdater](#autoupdater)
    - [Methods](#methods)
      - [setFeedURL](#setfeedurl)
      - [checkForUpdates](#checkforupdates)
      - [setScheduledCheckInterval](#setscheduledcheckinterval)
- [Related Links](#related-links)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Platform Support

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|  ➖   |  ✔️   |   ✔️    |

## Documentation

- [Quick Start](https://leanflutter.dev/documentation/auto_updater/quick-start)
- [API Reference](https://pub.dev/documentation/auto_updater/latest/auto_updater/)
- [Changelog](https://pub.dev/packages/auto_updater/changelog)

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

##### setScheduledCheckInterval

Sets the auto update check interval, default 86400, minimum 3600, 0 to disable update

<!-- README_DOC_GEN -->

## Related Links

- https://sparkle-project.org/
- https://winsparkle.org/

## License

[MIT](./LICENSE)
