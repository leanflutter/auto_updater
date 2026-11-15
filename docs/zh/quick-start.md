# 快速开始

按照以下步骤快速开始使用 `auto_updater` 插件：

## 安装

在应用的 `pubspec.yaml` 中添加 `auto_updater`，并为每个目标平台选择一个实现。
macOS 可使用 `auto_updater_sparkle`，Windows 可使用 `auto_updater_winsparkle`。
Flutter 会自动注册选定的实现。

要从本地仓库使用开发版，请将下面的 `/path/to/auto_updater` 替换为仓库路径。
如果应用只面向一个平台，可以省略另一个平台的实现和对应的绑定覆盖项。

```yaml
dependencies:
  auto_updater:
    path: /path/to/auto_updater/packages/auto_updater
  auto_updater_sparkle:
    path: /path/to/auto_updater/packages/auto_updater_sparkle
  auto_updater_winsparkle:
    path: /path/to/auto_updater/packages/auto_updater_winsparkle

dependency_overrides:
  auto_updater_platform_interface:
    path: /path/to/auto_updater/packages/auto_updater_platform_interface
  sparkle:
    path: /path/to/auto_updater/packages/sparkle
  winsparkle:
    path: /path/to/auto_updater/packages/winsparkle
```

### macOS 要求

开发版本要求 Flutter 3.50、Dart 3.14 和 macOS 12 或更高版本。使用 `auto_updater_sparkle` 时，请在 Flutter 中启用 Swift Package Manager 以打包 Sparkle 2.10.1。

如果项目原先通过 CocoaPods 嵌入 Sparkle，切换到 SwiftPM 时请移除原有的 Sparkle 集成，避免 Xcode 重复打包同一个 framework。[Flutter 迁移指南](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers)

### ⚠️ Windows requirements

- `openssl`

运行以下命令：

> 使用 [Chocolatey](https://chocolatey.org/install)

```
choco install openssl
```

## 用法

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

## 发布你的应用

### 生成私钥

运行以下命令：

```bash
dart run auto_updater:generate_keys
```

> 需要分别在 `macOS` 和 `Windows` 系统中运行该命令。

#### macOS

使用 SwiftPM 时，先运行 `flutter build macos`，再使用 `auto_updater:generate_keys` 或 `auto_updater:sign_update`。命令会从 Flutter 构建目录查找 Sparkle 工具。使用自定义构建目录或直接在 Xcode 中构建时，可将 `SPARKLE_BIN_DIR` 设为包含 `generate_keys` 和 `sign_update` 的目录。[Sparkle 集成文档](https://sparkle-project.org/documentation/#1-add-the-sparkle-framework-to-your-project)

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

#### Windows

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

### 打包应用

> 为了简化打包的过程，这里使用了 [Fastforge](https://fastforge.dev) ，一个专门用于打包和发布 Flutter 应用的完整工具。

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
      # 查看完整文档：https://fastforge.dev/makers/exe
      - name: windows-exe
        package:
          platform: windows
          target: exe
          build_args:
            dart-define:
              APP_ENV: dev
```

#### macOS

运行以下命令：

```
fastforge release --name prod --jobs macos-zip
```

#### Windows

运行以下命令：

```
fastforge release --name prod --jobs windows-exe
```

### 获取签名

#### macOS

运行以下命令：

```
dart run auto_updater:sign_update dist/1.1.0+2/auto_updater_example-1.1.0+2-macos.zip
```

输出：

```
sparkle:edSignature="pbdyPt92pnPkzLfQ7BhS9hbjcV9/ndkzSIlWjFQIUMcaCNbAFO2fzl0tISMNJApG2POTkZY0/kJQ2yZYOSVgAA==" length="13400992"
```

将获得的新签名更新到 `appcast.xml` 文件 `enclosure` 节点的 `sparkle:edSignature` 属性值。

#### Windows

运行以下命令：

```
dart run auto_updater:sign_update dist/1.1.0+2/auto_updater_example-1.1.0+2-windows-setup.exe
```

输出：

```

sparkle:dsaSignature="MEUCIQCVbVzVID7H3aUzAY5znpi+ySZKznkukV8whlMFzKh66AIgREUGOmvavlcg6hwAwkb2o4IqVE/D56ipIBshIqCH8rk=" length="13400992"
```

将获得的新签名更新到 `appcast.xml` 文件 `enclosure` 节点的 `sparkle:dsaSignature` 属性值。

### 分发应用

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
            <!-- 对于 macOS 项目，建议将 'sparkle:version' 和 'sparkle:shortVersionString' 添加到项目节点中，而不是作为 'enclosure' 的一部分。 -->
            <sparkle:version>2</sparkle:version>
            <sparkle:shortVersionString>1.1.0</sparkle:shortVersionString>
            <sparkle:releaseNotesLink>
                https://your_domain/your_path/release_notes.html
            </sparkle:releaseNotesLink>
            <pubDate>Sun, 16 Feb 2022 12:00:00 +0800</pubDate>
            <enclosure url="1.1.0+2/auto_updater_example-1.1.0+2-macos.zip"
                       sparkle:edSignature="pbdyPt92pnPkzLfQ7BhS9hbjcV9/ndkzSIlWjFQIUMcaCNbAFO2fzl0tISMNJApG2POTkZY0/kJQ2yZYOSVgAA=="
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

### 找到更新但无法下载

在出现问题的机器上下载 `enclosure` 中的 URL，确认响应是安装包文件。
如果 URL 有重定向，请检查最终的 HTTPS 地址和证书是否受到该机器信任。
确认 appcast 中的签名由实际提供下载的文件生成，并检查已安装应用的公钥是否匹配。

### macOS

等待 `setFeedURL` 完成，并记录它抛出的异常。Sparkle 会报告启动时的配置错误，
例如无效的 `SUPublicEDKey` 或缺失的授权。设置好 feed 和所需的检查间隔后，
可以立即调用 `checkForUpdates()`。检查更新期间的错误可通过
`UpdaterListener.onUpdaterError` 获取。排查 release 版本时，请确认导出的
`.app` 包含 `Contents/Frameworks/Sparkle.framework`，并检查导出包的
`Info.plist` 是否包含预期的更新配置。

如果 Sparkle 提供了 HTTP 状态码或底层原生错误码，`onUpdaterError` 会一并返回。
若需查看更详细的签名或安装信息，请在「控制台」应用中查看 Sparkle 类别的日志。
分享日志前，请删去 URL 中的令牌。

如应用启用了沙盒，请启用 Sparkle 的安装器 XPC 服务，并在 release 配置中添加
所需的授权。[Sparkle 沙盒配置文档](https://sparkle-project.org/documentation/sandboxing/)

如果 Sparkle 的标准更新窗口被其他窗口遮挡，用户可以再次点击「检查更新」。
前台 `checkForUpdates()` 会将已有的更新窗口带到前台。
[Sparkle 检查更新文档](https://sparkle-project.org/documentation/api-reference/Classes/SPUUpdater.html)

SwiftPM 提供的预编译 framework 会保留已安装应用的 `.app` 文件名。
如需启用重命名，请检出插件 `Package.swift` 固定的 Sparkle 版本，并在 Sparkle 源码目录运行以下命令。

```bash
xcodebuild archive -scheme Sparkle -configuration Release \
  -archivePath "$PWD/Sparkle.xcarchive" BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO SPARKLE_NORMALIZE_INSTALLED_APPLICATION_NAME=1
```

打包 Flutter release 应用时，将 `Contents/Frameworks/Sparkle.framework` 整个替换为
`Sparkle.xcarchive/Products/Library/Frameworks/` 下构建出的 framework。
使用 `ditto` 保留符号链接，再按常规流程签名应用。

先发布一个保留旧文件名的过渡版本，随包提供自定义 framework，并将
`SUBundleName` 设为新名称，无需加上 `.app` 后缀。Sparkle 会从已安装的
过渡版本读取名称，并在目标路径可用时使用新文件名。改名版本保留原有的
bundle identifier，并更新 `CFBundleDisplayName` 和 `CFBundleName` 及其本地化值。
[Sparkle 构建设置](https://github.com/sparkle-project/Sparkle/blob/2.10.1/Configurations/ConfigCommon.xcconfig)

保留过渡版本，确保旧版应用会先收到它。如果已安装的版本都使用 Sparkle 2.9
或更高版本，可将两个版本放在同一份 appcast 中，并在改名更新项中将
`sparkle:minimumUpdateVersion` 设为过渡版本的 `CFBundleVersion`。如果仍有
应用使用更早的 Sparkle，请将过渡版本保留为原 appcast 的最新项，并让过渡版本
使用单独的 appcast 获取改名更新，同时更新传给 `setFeedURL` 的地址。
[Sparkle appcast 迁移指南](https://sparkle-project.org/documentation/publishing/#upgrading-to-newer-features)

如果固定在程序坞上的图标仍显示旧应用，可移除该图标，再从访达添加改名后的应用。
[Apple 程序坞指南](https://support.apple.com/en-au/guide/mac-help/-mh35859/mac)

### Windows

使用 MSI 更新时，请在 `enclosure` 中填写已签名 `.msi` 文件的直接下载地址。
先在装有旧版本的机器上从资源管理器运行同一安装包，确认能升级现有安装。
如只需显示安装进度和错误，可在 `enclosure` 中添加
`sparkle:installerArguments="/passive"`。
[WinSparkle 安装参数文档](https://github.com/vslavik/winsparkle/wiki/Appcast-Feeds#installer-arguments)

WinSparkle 会启动安装器并请求退出应用。请在初始化更新器之前注册监听器。
在 Windows 上，通过 `onUpdaterBeforeQuitForUpdate` 保存应用状态并退出。
在 macOS 上，此回调表示自动更新已就绪，将在应用下次正常退出时安装。

```dart
import 'dart:io';
import 'dart:ui' show AppExitType;

import 'package:flutter/services.dart';

// 在 UpdaterListener 的实现中。
@override
Future<void> onUpdaterBeforeQuitForUpdate(AppcastItem? item) async {
  if (Platform.isWindows) {
    // 在此保存待处理的应用状态。
    await ServicesBinding.instance.exitApplication(AppExitType.required);
  }
}
```

如果 Windows runner 在消息循环结束后调用 `CoUninitialize()`，请先调用
`window.Destroy()`，让 Flutter 在 COM 仍可用时释放窗口和引擎。
见 [Windows runner 示例](../../packages/auto_updater/example/windows/runner/main.cpp)。

应用退出后，Windows Installer 会继续运行。如果升级失败，可在测试时通过
`sparkle:installerArguments` 传入
`/l*v` 和一个可写的日志路径，再查看 Windows Installer 的日志。
[Windows Installer 命令行选项](https://learn.microsoft.com/en-us/windows/win32/msi/command-line-options)

WinSparkle 对每个更新项读取一个发行说明 URL。如需本地化发行说明，可以为每种
语言提供一份 appcast，每个更新项只放一个对应语言的
`<sparkle:releaseNotesLink>`，直接指向该语言的 HTML 页面。同一版本的各语言 feed
使用相同的安装包和签名。在应用内按语言选好 feed，再调用 `setFeedURL`。

```dart
final language = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
final feedLocale = language == 'zh' ? 'zh-Hans' : 'en';
await autoUpdater.setFeedURL(
  'https://updates.example.com/windows/$feedLocale/appcast.xml',
);
```

页面加载后的 JavaScript 重定向可能会在系统浏览器中打开。
[WinSparkle appcast 解析器](https://github.com/vslavik/winsparkle/blob/v0.9.4/src/appcast.cpp)
