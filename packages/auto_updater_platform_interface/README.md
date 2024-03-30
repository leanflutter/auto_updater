# auto_updater_platform_interface

[![pub version][pub-image]][pub-url]

[pub-image]: https://img.shields.io/pub/v/auto_updater_platform_interface.svg
[pub-url]: https://pub.dev/packages/auto_updater_platform_interface

A common platform interface for the [auto_updater](https://pub.dev/packages/auto_updater) plugin.

## Usage

To implement a new platform-specific implementation of auto_updater, extend `AutoUpdaterPlatform` with an implementation that performs the platform-specific behavior, and when you register your plugin, set the default `AutoUpdaterPlatform` by calling `AutoUpdaterPlatform.instance = MyPlatformAutoUpdater()`.

## License

[MIT](./LICENSE)
