# auto_updater

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url]

[pub-image]: https://img.shields.io/pub/v/auto_updater.svg
[pub-url]: https://pub.dev/packages/auto_updater
[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

这个插件允许 Flutter **桌面** 应用自动更新自己 (基于 [sparkle](https://sparkle-project.org/) 和 [winsparkle](https://winsparkle.com))。

<img src="screenshots/sparkle.png" width="732" alt="">

---

[English](./README.md) | 简体中文

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [平台支持](#%E5%B9%B3%E5%8F%B0%E6%94%AF%E6%8C%81)
- [快速开始](#%E5%BF%AB%E9%80%9F%E5%BC%80%E5%A7%8B)
  - [安装](#%E5%AE%89%E8%A3%85)
    - [⚠️ Windows requirements](#-windows-requirements)
  - [用法](#%E7%94%A8%E6%B3%95)
  - [发布你的应用](#%E5%8F%91%E5%B8%83%E4%BD%A0%E7%9A%84%E5%BA%94%E7%94%A8)
    - [生成私钥](#%E7%94%9F%E6%88%90%E7%A7%81%E9%92%A5)
      - [macOS](#macos)
      - [Windows](#windows)
    - [打包应用](#%E6%89%93%E5%8C%85%E5%BA%94%E7%94%A8)
      - [macOS](#macos-1)
      - [Windows](#windows-1)
    - [获取签名](#%E8%8E%B7%E5%8F%96%E7%AD%BE%E5%90%8D)
      - [macOS](#macos-2)
      - [Windows](#windows-2)
    - [分发应用](#%E5%88%86%E5%8F%91%E5%BA%94%E7%94%A8)
- [故障排除](#%E6%95%85%E9%9A%9C%E6%8E%92%E9%99%A4)
  - [macOS](#macos-3)
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

## 快速开始

### 安装

将此添加到你的软件包的 pubspec.yaml 文件：

```yaml
dependencies:
  auto_updater: ^0.2.0
```

或

```yaml
dependencies:
  auto_updater:
    git:
      path: packages/auto_updater
      url: https://github.com/leanflutter/auto_updater.git
      ref: main
```

#### ⚠️ Windows requirements

- `openssl`

运行以下命令：

> 使用 [Chocolatey](https://chocolatey.org/install)

```
choco install openssl
```

### 用法

```dart
import 'package:auto_updater/auto_updater.dart';

void main() async {
  // 必须加上这一行。
  WidgetsFlutterBinding.ensureInitialized();

  String feedURL = 'http://localhost:5002/appcast.xml';
  await autoUpdater.setFeedURL(feedURL);
  await autoUpdater.checkForUpdates();
  await autoUpdater.setScheduledCheckInterval(3600);

  runApp(MyApp());
}
```

> 请看这个插件的示例应用，以了解完整的例子。

### 发布你的应用

#### 生成私钥

运行以下命令：

```bash
dart run auto_updater:generate_keys
```

> 需要分别在 `macOS` 和 `Windows` 系统中运行该命令。

##### macOS

准备使用 `EdDSA` 签名算法进行签名：

输出：

```
A key has been generated and saved in your keychain. Add the `SUPublicEDKey` key to
the Info.plist of each app for which you intend to use Sparkle for distributing
updates. It should appear like this:

    <key>SUPublicEDKey</key>
    <string>pfIShU4dEXqPd5ObYNfDBiQWcXozk7estwzTnF9BamQ=</string>
```

更改文件 `macos/Runner/Info.plist` 如下：

```diff
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>

  ...

+	<key>SUPublicEDKey</key>
+	<string>bHaXClrRGMmKoKP/3HJnr/jn2ODTRPAM3VZhhkI9ZvY=</string>
</dict>
</plist>
```

##### Windows

准备使用 `DSA` 签名算法进行签名：

输出：

```
Generated two files:
dsa_priv.pem: your private key. Keep it secret and don't share it!
dsa_pub.pem: public counterpart to include in youe app.
BACK UP YOUR PRIVATE KEY AND KEEP IT SAFE!
If you lose it, your users will be unable to upgrade!
```

> 命令将为你生成私钥（`dsa_priv.pem`）及公钥（`dsa_pub.pem`），请备份你的私钥并确保其安全，并将公钥作为 Windows 资源添加到项目中。

更改文件 `windows/runner/Runner.rc` 如下：

```diff

...

+/////////////////////////////////////////////////////////////////////////////
+//
+// WinSparkle
+//

+// And verify signature using DSA public key:
+DSAPub      DSAPEM      "../../dsa_pub.pem"
```

#### 打包应用

> 为了简化打包的过程，这里使用了 [Flutter Distributor](https://github.com/leanflutter/flutter_distributor) ，一个专门用于打包和发布 Flutter 应用的完整工具。

将 `distribute_options.yaml` 添加到你的项目根目录。

```yaml
output: dist/
releases:
  - name: prod
    jobs:
      - name: macos-zip
        package:
          platform: macos
          target: zip
          build_args:
            dart-define:
              APP_ENV: dev
      # 查看完整文档：https://distributor.leanflutter.org/configuration/makers/exe
      - name: windows-exe
        package:
          platform: windows
          target: exe
          build_args:
            dart-define:
              APP_ENV: dev
```

##### macOS

运行以下命令：

```
flutter_distributor release --name prod --jobs macos-zip
```

##### Windows

运行以下命令：

```
flutter_distributor release --name prod --jobs windows-exe
```

#### 获取签名

##### macOS

运行以下命令：

```
dart run auto_updater:sign_update dist/1.1.0+2/auto_updater_example-1.1.0+2-macos.zip
```

输出：

```
sparkle:edSignature="pbdyPt92pnPkzLfQ7BhS9hbjcV9/ndkzSIlWjFQIUMcaCNbAFO2fzl0tISMNJApG2POTkZY0/kJQ2yZYOSVgAA==" length="13400992"
```

将获得的新签名更新到 `appcast.xml` 文件 `enclosure` 节点的 `sparkle:edSignature` 属性值。

##### Windows

运行以下命令：

```
dart run auto_updater:sign_update dist/1.1.0+2/auto_updater_example-1.1.0+2-windows-setup.exe
```

输出：

```

sparkle:dsaSignature="MEUCIQCVbVzVID7H3aUzAY5znpi+ySZKznkukV8whlMFzKh66AIgREUGOmvavlcg6hwAwkb2o4IqVE/D56ipIBshIqCH8rk=" length="13400992"
```

将获得的新签名更新到 `appcast.xml` 文件 `enclosure` 节点的 `sparkle:dsaSignature` 属性值。

#### 分发应用

将 `appcast.xml` 添加到你的项目 `dist/` 目录。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
    <channel>
        <title>auto_updater_example</title>
        <description>Most recent updates to auto_updater_example</description>
        <language>en</language>
        <item>
            <title>Version 1.1.0</title>
            <sparkle:releaseNotesLink>
                https://your_domain/your_path/release_notes.html
            </sparkle:releaseNotesLink>
            <pubDate>Sun, 16 Feb 2022 12:00:00 +0800</pubDate>
            <enclosure url="1.1.0+2/auto_updater_example-1.1.0+2-macos.zip"
                       sparkle:edSignature="pbdyPt92pnPkzLfQ7BhS9hbjcV9/ndkzSIlWjFQIUMcaCNbAFO2fzl0tISMNJApG2POTkZY0/kJQ2yZYOSVgAA=="
                       sparkle:version="1.1.0"
                       sparkle:os="macos"
                       length="13400992"
                       type="application/octet-stream" />
        </item>
        <item>
            <title>Version 1.1.0</title>
            <sparkle:releaseNotesLink>
                https://your_domain/your_path/release_notes.html
            </sparkle:releaseNotesLink>
            <pubDate>Sun, 16 Feb 2022 12:00:00 +0800</pubDate>
            <enclosure url="1.1.0+2/auto_updater_example-1.1.0+2-windows.exe"
                       sparkle:dsaSignature="MEUCIQCVbVzVID7H3aUzAY5znpi+ySZKznkukV8whlMFzKh66AIgREUGOmvavlcg6hwAwkb2o4IqVE/D56ipIBshIqCH8rk="
                       sparkle:version="1.1.0+2"
                       sparkle:os="windows"
                       length="0"
                       type="application/octet-stream" />
        </item>
    </channel>
</rss>
```

> 本示例中 `macOS` 和 `Windows` 使用同一个 `appcast.xml` 文件，你需根据配置 `sparkle:os` 属性的值。

启动测试更新服务器：

```
cd dist/
serve -l 5002
```

## 故障排除

### macOS

- 确保按照 [Sparkle 文档](https://sparkle-project.org/documentation/)中的说明添加了 sparkle pod
- 通过将以下内容添加到您的授权文件以进行调试和发布，确保您已添加并启用应用程序的网络功能并禁用沙箱以进行发布

```
<key>com.apple.security.network.client</key>
  <true/>
<key>com.apple.security.network.server</key>
  <true/>
<key>com.apple.security.app-sandbox</key>
  <false/>
```

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

<!-- README_DOC_GEN -->

## 相关链接

- https://sparkle-project.org/
- https://winsparkle.org/

## 许可证

[MIT](./LICENSE)
