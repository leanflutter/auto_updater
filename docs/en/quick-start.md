# Quick Start

Follow the steps below to quickly get started with the `auto_updater` plugin:

## Installation

Add `auto_updater` and one implementation for each platform your app targets.
Use `auto_updater_sparkle` on macOS and `auto_updater_winsparkle` on Windows.
Flutter registers the selected implementation automatically.

To use the development version from a local checkout, replace
`/path/to/auto_updater` with the checkout path in your app's `pubspec.yaml`.
For an app targeting one platform, omit the other implementation and its
binding override.

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

### macOS requirements

The development version targets Flutter 3.50, Dart 3.14, and macOS 12 or later. When using `auto_updater_sparkle`, enable Swift Package Manager in Flutter to bundle Sparkle 2.10.1.

If an existing project embeds Sparkle through CocoaPods, remove that CocoaPods integration as part of switching to SwiftPM so Xcode embeds a single copy. [Flutter’s migration guide](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers)

### ⚠️ Windows requirements

- `openssl`

Run the following command:

> Use [Chocolatey](https://chocolatey.org/install)

```
choco install openssl
```

## Usage

```dart
import 'package:auto_updater/auto_updater.dart';

void main() async {
  // Must add this line.
  WidgetsFlutterBinding.ensureInitialized();

  String feedURL = 'http://localhost:5002/appcast.xml';
  await autoUpdater.setFeedURL(feedURL);

  runApp(MyApp());
}
```

Calling `setFeedURL` initializes the updater. The native updater schedules
checks according to its automatic update settings. Use
`setScheduledCheckInterval` to customize the interval and call
`checkForUpdates()` from a user action such as a Check for Updates menu item.

On macOS, Sparkle honors **Skip This Version** during automatic and background
checks. A manual `checkForUpdates()` can offer the skipped version again. If
your app explicitly checks in the background when it starts, call
`checkForUpdates(inBackground: true)` after setting the feed URL.
[Sparkle update checks](https://sparkle-project.org/documentation/api-reference/Classes/SPUUpdater.html)

> Please see the example app of this plugin for a full example.

### Using an authenticated feed

Set the request headers before the feed URL:

```dart
await autoUpdater.setHttpHeaders({'Authorization': 'Bearer $accessToken'});
await autoUpdater.setFeedURL('https://example.com/updates/appcast.xml');
```

Sparkle and WinSparkle also send the headers on update downloads, so use trusted
HTTPS URLs for the feed and its downloads. Calling `setHttpHeaders` again
replaces the previous headers. An empty map clears them.

On Windows, use the final URL for any feed or download that requires
`Authorization`. WinINet can drop this header when it follows a redirect,
including a 302 to the same origin.

### Installing updates automatically

On macOS, set `SUEnableAutomaticChecks` and `SUAutomaticallyUpdate` to
`true` in `macos/Runner/Info.plist` to enable background checks and automatic
downloads by default. Sparkle installs eligible app updates when the app quits.
It may present critical updates earlier or ask for installation authorization.
[Sparkle settings](https://sparkle-project.org/documentation/customization/)

On Windows, call `await autoUpdater.checkForUpdatesAndInstall()` after setting
the feed. WinSparkle shows progress and starts installing an available update
without showing its confirmation dialog. Installer dialogs and Windows
authorization prompts are controlled by the installer and the system.

## Publish your app

### Generate private key

Run the following command:

```bash
dart run auto_updater:generate_keys
```

> You need to run this command on `macOS` and `Windows` systems separately.

#### macOS

With SwiftPM, run `flutter build macos` before using the Sparkle commands. They use the tools from the Flutter build. For a custom build directory or a build started from Xcode, set `SPARKLE_BIN_DIR` to the directory containing the Sparkle binaries. [Sparkle setup](https://sparkle-project.org/documentation/#1-add-the-sparkle-framework-to-your-project)

Prepare signing with `EdDSA` signatures:

Output:

```
A key has been generated and saved in your keychain. Add the `SUPublicEDKey` key to
the Info.plist of each app for which you intend to use Sparkle for distributing
updates. It should appear like this:

    <key>SUPublicEDKey</key>
    <string>pfIShU4dEXqPd5ObYNfDBiQWcXozk7estwzTnF9BamQ=</string>
```

Change the file `macos/Runner/Info.plist` as follows:

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

Prepare signing with `DSA` signatures:

Output:

```
Generated two files:
dsa_priv.pem: your private key. Keep it secret and don't share it!
dsa_pub.pem: public counterpart to include in youe app.
BACK UP YOUR PRIVATE KEY AND KEEP IT SAFE!
If you lose it, your users will be unable to upgrade!
```

> command will generate the private key (`dsa_priv.pem`) and the public key (`dsa_pub.pem`) for you. Please Back up your private key and keep it safe, Add your public key to your project either as Windows resource.

Change the file `windows/runner/Runner.rc` as follows:

```diff

...

+/////////////////////////////////////////////////////////////////////////////
+//
+// WinSparkle
+//

+// And verify signature using DSA public key:
+DSAPub      DSAPEM      "../../dsa_pub.pem"
```

### Packaging

> To simplify the packaging process, [Fastforge](https://fastforge.dev) is used here, A complete tool dedicated to packaging and publishing Flutter apps.

Add `distribute_options.yaml` to your project root directory.

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
      # See full documentation: https://fastforge.dev/makers/exe
      - name: windows-exe
        package:
          platform: windows
          target: exe
          build_args:
            dart-define:
              APP_ENV: dev
```

#### macOS

Run the following command:

```
fastforge release --name prod --jobs macos-zip
```

#### Windows

Run the following command:

```
fastforge release --name prod --jobs windows-exe
```

### Generate a macOS appcast in CI

Place your macOS update archives in a release directory such as `dist/macos`.
From the Flutter project root on a macOS runner, run:

```bash
dart run auto_updater:generate_appcast \
  --download-url-prefix https://example.com/updates/macos/ \
  dist/macos
```

Sparkle signs the archives and creates or updates `dist/macos/appcast.xml`.
Publish the feed and the files it references. The tool uses the Sparkle signing
key in the macOS Keychain by default. In CI, use `--ed-key-file` with a key file
provided by your CI secret store. Run
`dart run auto_updater:generate_appcast --help` for all Sparkle options.
[Sparkle publishing guide](https://sparkle-project.org/documentation/publishing/)

### Get signature

#### macOS

Run the following command:

```
dart run auto_updater:sign_update dist/1.1.0+2/auto_updater_example-1.1.0+2-macos.zip
```

Output:

```
sparkle:edSignature="pbdyPt92pnPkzLfQ7BhS9hbjcV9/ndkzSIlWjFQIUMcaCNbAFO2fzl0tISMNJApG2POTkZY0/kJQ2yZYOSVgAA==" length="13400992"
```

Update the obtained new signature to the value of the `sparkle:edSignature` attribute of the `enclosure` node of the `appcast.xml` file.

#### Windows

Run the following command:

```
dart run auto_updater:sign_update dist/1.1.0+2/auto_updater_example-1.1.0+2-windows-setup.exe
```

Output:

```

sparkle:dsaSignature="MEUCIQCVbVzVID7H3aUzAY5znpi+ySZKznkukV8whlMFzKh66AIgREUGOmvavlcg6hwAwkb2o4IqVE/D56ipIBshIqCH8rk=" length="13400992"
```

Copy the `sparkle:dsaSignature` and `length` values to the Windows
`enclosure` in `appcast.xml`. The length is the installer size in bytes.

### Distributing

Add `appcast.xml` to your project `dist/` directory.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
    <channel>
        <title>auto_updater_example</title>
        <description>Most recent updates to auto_updater_example</description>
        <language>en</language>
        <item>
            <title>Version 1.1.0</title>
            <!-- For the macOS item, it is recommended to add 'sparkle:version' and 'sparkle:shortVersionString' to the item node, rather than as part of the enclosure. -->
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

> This example uses the same `appcast.xml` file for `macOS` and `Windows`, and you need to configure the value of the `sparkle:os` property accordingly.

An enclosure can use a relative path when the installer is hosted alongside
the appcast. On Windows, the updater resolves the path against the final
appcast URL after redirects. Use an absolute HTTPS URL to point to an
installer on another server.

Start the test update server:

```
cd dist/
serve -l 5002
```

### Publishing a beta channel on macOS

Add `<sparkle:channel>beta</sparkle:channel>` to a beta appcast item. To allow
that channel on macOS, call `await autoUpdater.setAllowedChannels(['beta'])`
before the update check. Sparkle still considers releases on the default
channel. Call `setAllowedChannels([])` to return to the default selection.
[Sparkle channels](https://sparkle-project.org/documentation/publishing/#channels)

## Troubleshooting

### Update prompts

Use `checkForUpdates(inBackground: true)` to check for updates without a
progress dialog. The native updater can show an update prompt when it finds a
new version.

Add `<sparkle:criticalUpdate />` directly inside an appcast `<item>` to mark
that release as critical. WinSparkle hides **Skip This Version** and
**Remind Me Later** for critical updates. Sparkle hides both buttons for
critical updates outside a major upgrade. Sparkle also hides **Remind Me
Later** when automatic checks are disabled.
[Sparkle critical updates](https://sparkle-project.org/documentation/publishing/#critical-updates)

To require a minimum app version, enforce the version requirement in your app
or backend. The standard update dialogs control the update flow. For a custom
macOS dialog, a platform implementation can supply a Sparkle `SPUUserDriver`.
[Sparkle custom user interfaces](https://sparkle-project.org/documentation/custom-user-interfaces/)

### Update offered but download fails

From an affected machine, download the enclosure URL and verify that the
response contains the installer archive. Check that redirects end at a valid
HTTPS URL with a certificate trusted by that machine. Verify that the
appcast's signature was generated from the exact bytes being served and that
the installed app has the matching public key.

### macOS

Await `setFeedURL` and log any exception from it. Sparkle reports configuration
errors during startup, including an invalid `SUPublicEDKey` or missing
entitlements. After `setFeedURL` and any scheduled interval setting complete,
you can call `checkForUpdates()` immediately. Use
`UpdaterListener.onUpdaterError` for errors reported during update checks.
When debugging a release build, verify that the exported
`.app` contains `Contents/Frameworks/Sparkle.framework` and that the exported
app's `Info.plist` contains the expected update configuration.

`onUpdaterError` includes the HTTP status or underlying native error codes when
Sparkle provides them. For additional signing or installation details, look for
the Sparkle log category in Console. Redact tokens in logged URLs before
sharing them.

For a sandboxed app, enable Sparkle's installer XPC service and add the
entitlements required by Sparkle to the release configuration.
[Sparkle sandboxing guide](https://sparkle-project.org/documentation/sandboxing/)

If Sparkle's standard update dialog has slipped behind other windows, a
user-initiated `checkForUpdates()` brings the existing dialog back into focus.
[Sparkle update checks](https://sparkle-project.org/documentation/api-reference/Classes/SPUUpdater.html)

The prebuilt SwiftPM framework preserves the installed `.app` filename. To
enable renaming, check out the Sparkle version pinned in the plugin's
`Package.swift` and run this command from that Sparkle checkout.

```bash
xcodebuild archive -scheme Sparkle -configuration Release \
  -archivePath "$PWD/Sparkle.xcarchive" BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  SKIP_INSTALL=NO SPARKLE_NORMALIZE_INSTALLED_APPLICATION_NAME=1
```

In the staged Flutter release app, replace `Contents/Frameworks/Sparkle.framework`
with the entire framework from `Sparkle.xcarchive/Products/Library/Frameworks/`.
Use `ditto` to preserve its symlinks and sign the app after staging.

Ship this framework in a release that keeps the old filename and sets
`SUBundleName` to the new name in that release's `Info.plist`. Then publish
the renamed update with the same bundle identifier. Sparkle reads the name
from the installed app and uses the new filename when that path is available.
[Sparkle build settings](https://github.com/sparkle-project/Sparkle/blob/2.10.1/Configurations/ConfigCommon.xcconfig)

### Windows

For MSI updates, publish a direct link to the signed `.msi` in the enclosure.
Run the same installer from Explorer on a machine with the old version to
verify that it upgrades the existing installation. To show only progress and
errors, add `sparkle:installerArguments="/passive"` to the enclosure.
[WinSparkle installer arguments](https://github.com/vslavik/winsparkle/wiki/Appcast-Feeds#installer-arguments)

WinSparkle starts the installer and requests that the app quit. Register a
listener before initializing the updater. Save any app state and exit from
`onUpdaterBeforeQuitForUpdate` on Windows. On macOS, the callback signals a
prepared update for the next regular quit.

```dart
import 'dart:io';
import 'dart:ui' show AppExitType;

import 'package:flutter/services.dart';

// In your UpdaterListener implementation.
@override
Future<void> onUpdaterBeforeQuitForUpdate(AppcastItem? item) async {
  if (Platform.isWindows) {
    // Save any pending app state here.
    await ServicesBinding.instance.exitApplication(AppExitType.required);
  }
}
```

If your Windows runner calls `CoUninitialize()` after its message loop, call
`window.Destroy()` first so Flutter releases its window and engine while COM is
still available. See the [example Windows runner](../../packages/auto_updater/example/windows/runner/main.cpp).

Windows Installer continues running after the app exits. If the upgrade
fails, add `/l*v` and a writable log path to
`sparkle:installerArguments` for a test run, then inspect the Windows
Installer log.
[Windows Installer command-line options](https://learn.microsoft.com/en-us/windows/win32/msi/command-line-options)

WinSparkle's update dialog reads a single release-notes URL per item. To
localize the notes, serve one appcast per supported locale, each with a single
`<sparkle:releaseNotesLink>` pointing directly to that locale's HTML page. Keep
the installer and its signature the same for each copy of the release. Select
the feed using the app's language before calling `setFeedURL`.

```dart
final language = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
final feedLocale = language == 'zh' ? 'zh-Hans' : 'en';
await autoUpdater.setFeedURL(
  'https://updates.example.com/windows/$feedLocale/appcast.xml',
);
```

WinSparkle can open a JavaScript redirect in the external browser after the
first page has loaded.
[WinSparkle appcast parser](https://github.com/vslavik/winsparkle/blob/v0.9.4/src/appcast.cpp)
