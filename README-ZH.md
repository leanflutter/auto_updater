# auto_updater

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url]

[pub-image]: https://img.shields.io/pub/v/auto_updater.svg
[pub-url]: https://pub.dev/packages/auto_updater

[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

这个插件允许 Flutter **桌面** 应用自动更新自己。

---

[English](./README.md) | 简体中文

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [auto_updater](#auto_updater)
  - [平台支持](#平台支持)
  - [快速开始](#快速开始)
    - [安装](#安装)
    - [用法](#用法)
  - [谁在用使用它？](#谁在用使用它)
  - [API](#api)
    - [AutoUpdater](#autoupdater)
      - [Methods](#methods)
        - [setFeedURL](#setfeedurl)
        - [getFeedURL](#getfeedurl)
        - [checkForUpdates](#checkforupdates)
  - [相关链接](#相关链接)
  - [许可证](#许可证)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 平台支持

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|   ➖   |   ✔️   |    ✔️    |

## 快速开始

### 安装

将此添加到你的软件包的 pubspec.yaml 文件：

```yaml
dependencies:
  auto_updater: ^0.1.0
```

或

```yaml
dependencies:
  auto_updater:
    git:
      url: https://github.com/leanflutter/auto_updater.git
      ref: main
```

### 用法

```dart
import 'package:auto_updater/auto_updater.dart';

void main() async {
  // 必须加上这一行。
  WidgetsFlutterBinding.ensureInitialized();

  String feedURL = 'http://localhost:5000/appcast.xml';
  await autoUpdater.setFeedURL(feedURL);
  await autoUpdater.checkForUpdates();

  runApp(MyApp());
}
```

> 请看这个插件的示例应用，以了解完整的例子。

## 谁在用使用它？

- [比译](https://biyidev.com/) - 一个便捷的翻译和词典应用程序。

## API

<!-- README_DOC_GEN -->
### AutoUpdater

#### Methods

##### setFeedURL

Sets the url and initialize the auto updater.

##### getFeedURL

Returns `String` - The current update feed URL.

##### checkForUpdates

Asks the server whether there is an update. You must call setFeedURL before using this API.


<!-- README_DOC_GEN -->

## 相关链接

- https://sparkle-project.org/
- https://winsparkle.org/

## 许可证

[MIT](./LICENSE)
