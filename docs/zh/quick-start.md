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

  runApp(MyApp());
}
```

调用 `setFeedURL` 即可初始化更新器。原生更新器根据自动更新设置安排检查。
可使用 `setScheduledCheckInterval` 自定义检查间隔，并在用户点击「检查更新」
菜单项时调用 `checkForUpdates()`。

在 macOS 上，Sparkle 的自动检查和后台检查会遵循「跳过此版本」的选择。
手动调用 `checkForUpdates()` 时，仍可能显示已跳过的版本。如果应用需要在启动时
主动进行后台检查，请在设置 feed URL 后调用 `checkForUpdates(inBackground: true)`。
[Sparkle 检查更新文档](https://sparkle-project.org/documentation/api-reference/Classes/SPUUpdater.html)

> 请看这个插件的示例应用，以了解完整的例子。

### 使用需要认证的更新源

先设置请求头，再设置 feed URL。

```dart
await autoUpdater.setHttpHeaders({'Authorization': 'Bearer $accessToken'});
await autoUpdater.setFeedURL('https://example.com/updates/appcast.xml');
```

Sparkle 和 WinSparkle 下载更新时也会发送这些请求头，请为 feed 和安装包使用
可信的 HTTPS 地址。再次调用 `setHttpHeaders` 会替换已有的请求头，传入空
Map 可清除这些请求头。

### 自动安装更新

在 macOS 上，将 `macos/Runner/Info.plist` 中的 `SUEnableAutomaticChecks`
和 `SUAutomaticallyUpdate` 设置为 `true`，即可默认启用后台检查和自动安装。
安装更新时，Sparkle 仍可能要求系统授权。
[Sparkle 配置文档](https://sparkle-project.org/documentation/customization/)

在 Windows 上，设置 feed 后调用
`await autoUpdater.checkForUpdatesAndInstall()`。WinSparkle 会显示进度，
并在发现新版本时直接开始安装，跳过 WinSparkle 的确认对话框。安装器界面和
Windows 授权提示由安装器和系统控制。

## 发布你的应用

### 生成私钥

运行以下命令：

```bash
dart run auto_updater:generate_keys
```

> 需要分别在 `macOS` 和 `Windows` 系统中运行该命令。

#### macOS

使用 SwiftPM 时，先运行 `flutter build macos`，再使用 Sparkle 命令。命令会从 Flutter 构建目录查找 Sparkle 工具。使用自定义构建目录或直接在 Xcode 中构建时，可将 `SPARKLE_BIN_DIR` 设为包含 Sparkle 可执行文件的目录。[Sparkle 集成文档](https://sparkle-project.org/documentation/#1-add-the-sparkle-framework-to-your-project)

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

### 在 CI 中生成 macOS appcast

将 macOS 更新归档放入发布目录，例如 `dist/macos`。在 macOS CI
运行器上，从 Flutter 项目根目录执行以下命令。

```bash
dart run auto_updater:generate_appcast \
  --download-url-prefix https://example.com/updates/macos/ \
  dist/macos
```

Sparkle 会为归档签名，并创建或更新 `dist/macos/appcast.xml`。
发布时上传此文件及其引用的文件。默认使用 macOS 钥匙串中的 Sparkle
签名密钥。CI 可以通过 `--ed-key-file` 指定由 CI 密钥存储提供的私钥文件。
运行 `dart run auto_updater:generate_appcast --help` 可查看全部 Sparkle 选项。
[Sparkle 发布文档](https://sparkle-project.org/documentation/publishing/)

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

将输出中的 `sparkle:dsaSignature` 和 `length` 填到 `appcast.xml` 中 Windows 的
`enclosure` 节点。`length` 是安装包的字节数。

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
            <enclosure url="1.1.0+2/auto_updater_example-1.1.0+2-windows-setup.exe"
                       sparkle:dsaSignature="MEUCIQCVbVzVID7H3aUzAY5znpi+ySZKznkukV8whlMFzKh66AIgREUGOmvavlcg6hwAwkb2o4IqVE/D56ipIBshIqCH8rk="
                       sparkle:version="1.1.0+2"
                       sparkle:os="windows"
                       length="13400992"
                       type="application/octet-stream" />
        </item>
    </channel>
</rss>
```

> 本示例中 `macOS` 和 `Windows` 使用同一个 `appcast.xml` 文件，你需根据配置 `sparkle:os` 属性的值。

安装包和 appcast 一起托管时，`enclosure` 可以使用相对路径。在 Windows 上，
更新器以重定向后的最终 appcast URL 为基准解析该路径。如果安装包在另一台
服务器上，请使用绝对 HTTPS URL。

启动测试更新服务器：

```
cd dist/
serve -l 5002
```

## 故障排除

### 更新提示

调用 `checkForUpdates(inBackground: true)` 可以在检查期间隐藏进度窗口。
找到新版本时，原生更新器仍可显示更新提示。

在 appcast 的 `<item>` 中直接添加 `<sparkle:criticalUpdate />`，即可将该版本标为
关键更新。WinSparkle 会对关键更新隐藏「跳过此版本」和「稍后提醒我」。
对于不属于主要升级的关键更新，Sparkle 也会隐藏这两个按钮。关闭自动检查时，
Sparkle 也会隐藏「稍后提醒我」。
[Sparkle 关键更新文档](https://sparkle-project.org/documentation/publishing/#critical-updates)

如需限制旧版本继续使用，请在应用或后端检查最低支持版本。
标准更新对话框负责呈现更新流程。要自定义 macOS 对话框，可以在平台实现中
提供 Sparkle `SPUUserDriver`。
[Sparkle 自定义界面文档](https://sparkle-project.org/documentation/custom-user-interfaces/)

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

如应用启用了沙盒，请启用 Sparkle 的安装器 XPC 服务，并在 release 配置中添加
所需的授权。[Sparkle 沙盒配置文档](https://sparkle-project.org/documentation/sandboxing/)

如果 Sparkle 的标准更新窗口被其他窗口遮挡，用户可以再次点击「检查更新」。
前台 `checkForUpdates()` 会将已有的更新窗口带到前台。
[Sparkle 检查更新文档](https://sparkle-project.org/documentation/api-reference/Classes/SPUUpdater.html)

如需在更新时更改已安装的 `.app` 文件名，旧版应用需提前使用启用了
`SPARKLE_NORMALIZE_INSTALLED_APPLICATION_NAME=1` 的 Sparkle，并将
`SUBundleName` 设为新名称。SwiftPM 提供的预编译 framework 会保留原路径。
若需启用重命名，请使用该设置构建 Sparkle，并在发布改名版本之前将自定义 framework
随应用发布。[Sparkle 构建设置](https://github.com/sparkle-project/Sparkle/blob/2.10.1/Configurations/ConfigCommon.xcconfig)

### Windows

使用 MSI 更新时，请在 `enclosure` 中填写已签名 `.msi` 文件的直接下载地址。
先在装有旧版本的机器上从资源管理器运行同一安装包，确认能升级现有安装。
如只需显示安装进度和错误，可在 `enclosure` 中添加
`sparkle:installerArguments="/passive"`。
[WinSparkle 安装参数文档](https://github.com/vslavik/winsparkle/wiki/Appcast-Feeds#installer-arguments)

WinSparkle 负责下载安装包并运行安装器。WinSparkle 请求退出应用时，可以通过
`onUpdaterBeforeQuitForUpdate` 保存应用状态。应用退出后，Windows Installer 会
继续运行。如果升级失败，可在测试时通过 `sparkle:installerArguments` 传入
`/l*v` 和一个可写的日志路径，再查看 Windows Installer 的日志。
[Windows Installer 命令行选项](https://learn.microsoft.com/en-us/windows/win32/msi/command-line-options)

WinSparkle 对每个更新项读取一个发行说明 URL。如需本地化发行说明，可以为每种
语言提供一份 appcast，每个更新项只放一个对应语言的
`<sparkle:releaseNotesLink>`。在应用内选好对应语言的 feed，再调用 `setFeedURL`。
[WinSparkle appcast 解析器](https://github.com/vslavik/winsparkle/blob/v0.9.4/src/appcast.cpp)
