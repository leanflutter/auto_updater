> **🚀 快速发布您的应用**: 试试 [Fastforge](https://fastforge.dev) - 构建、打包和分发您的 Flutter 应用最简单的方式。

# auto_updater

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url]

[pub-image]: https://img.shields.io/pub/v/auto_updater.svg
[pub-url]: https://pub.dev/packages/auto_updater
[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

这个插件允许 Flutter **桌面** 应用自动更新自己 (基于 [sparkle](https://sparkle-project.org/) 和 [winsparkle](https://winsparkle.org))。

<img src="https://raw.githubusercontent.com/leanflutter/auto_updater/main/screenshots/sparkle.png" width="732" alt="">

---

[English](./README.md) | 简体中文

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [平台支持](#%E5%B9%B3%E5%8F%B0%E6%94%AF%E6%8C%81)
- [文档](#%E6%96%87%E6%A1%A3)
- [谁在用使用它？](#%E8%B0%81%E5%9C%A8%E7%94%A8%E4%BD%BF%E7%94%A8%E5%AE%83)
- [API](#api)
  - [AutoUpdater](#autoupdater)
    - [Methods](#methods)
      - [setFeedURL](#setfeedurl)
      - [checkForUpdates](#checkforupdates)
      - [setScheduledCheckInterval](#setscheduledcheckinterval)
- [相关链接](#%E7%9B%B8%E5%85%B3%E9%93%BE%E6%8E%A5)
- [许可证](#%E8%AE%B8%E5%8F%AF%E8%AF%81)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 平台支持

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|  ➖   |  ✔️   |   ✔️    |

## 文档

- [快速开始](https://leanflutter.dev/zh/documentation/auto_updater/quick-start)
- [API 参考](https://pub.dev/documentation/auto_updater/latest/auto_updater/)
- [更新日志](https://pub.dev/packages/auto_updater/changelog)

## 谁在用使用它？

- [比译](https://biyidev.com/) - 一个便捷的翻译和词典应用程序。

## API

<!-- README_DOC_GEN -->

### AutoUpdater

#### Methods

##### setFeedURL

设置 url 并初始化 auto updater.

##### checkForUpdates

检查更新，在此之前必须先调用 setFeedURL.

##### setScheduledCheckInterval

设置检查时间间隔，默认 86400，最少 3600, 0 不更新

##### installUpdateNow

当原生 updater 已准备好下载的更新时，立即安装更新。

<!-- README_DOC_GEN -->

## 相关链接

- https://sparkle-project.org/
- https://winsparkle.org/

## 许可证

[MIT](./LICENSE)
