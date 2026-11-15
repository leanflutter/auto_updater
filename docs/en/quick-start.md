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
  await autoUpdater.checkForUpdates();
  await autoUpdater.setScheduledCheckInterval(3600);

  runApp(MyApp());
}
```

> Please see the example app of this plugin for a full example.

## Publish your app

### Generate private key

Run the following command:

```bash
dart run auto_updater:generate_keys
```

> You need to run this command on `macOS` and `Windows` systems separately.

#### macOS

With SwiftPM, run `flutter build macos` before using `auto_updater:generate_keys` or `auto_updater:sign_update`. The commands use the Sparkle tools from the Flutter build. For a custom build directory or a build started from Xcode, set `SPARKLE_BIN_DIR` to the directory containing `generate_keys` and `sign_update`. [Sparkle setup](https://sparkle-project.org/documentation/#1-add-the-sparkle-framework-to-your-project)

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

Update the obtained new signature to the value of the `sparkle:dsaSignature` attribute of the `enclosure` node of the `appcast.xml` file.

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

> This example uses the same `appcast.xml` file for `macOS` and `Windows`, and you need to configure the value of the `sparkle:os` property accordingly.

Start the test update server:

```
cd dist/
serve -l 5002
```

## Troubleshooting

### Update offered but download fails

From an affected machine, download the enclosure URL and verify that the
response contains the installer archive. Check that redirects end at a valid
HTTPS URL with a certificate trusted by that machine. Verify that the
appcast's signature was generated from the exact bytes being served and that
the installed app has the matching public key.

### macOS

Await `setFeedURL` and log any exception from it. Sparkle reports configuration
errors during startup, including an invalid `SUPublicEDKey` or missing
entitlements. Use `UpdaterListener.onUpdaterError` for errors reported during
update checks. When debugging a release build, verify that the exported
`.app` contains `Contents/Frameworks/Sparkle.framework` and that the exported
app's `Info.plist` contains the expected update configuration.

For a sandboxed app, enable Sparkle's installer XPC service and add the
entitlements required by Sparkle to the release configuration.
[Sparkle sandboxing guide](https://sparkle-project.org/documentation/sandboxing/)

If Sparkle's standard update dialog has slipped behind other windows, a
user-initiated `checkForUpdates()` brings the existing dialog back into focus.
[Sparkle update checks](https://sparkle-project.org/documentation/api-reference/Classes/SPUUpdater.html)

To change an installed `.app` filename during an update, the installed version
must already use Sparkle built with `SPARKLE_NORMALIZE_INSTALLED_APPLICATION_NAME=1`
and set `SUBundleName` to the new name. The prebuilt SwiftPM framework keeps
the existing file path. To use normalization, build Sparkle itself with that
setting and include that framework in the app before rolling out the rename.
[Sparkle build settings](https://github.com/sparkle-project/Sparkle/blob/2.10.1/Configurations/ConfigCommon.xcconfig)

### Windows

For MSI updates, publish a direct link to the signed `.msi` in the enclosure.
Run the same installer from Explorer on a machine with the old version to
verify that it upgrades the existing installation. To show only progress and
errors, add `sparkle:installerArguments="/passive"` to the enclosure.
[WinSparkle installer arguments](https://github.com/vslavik/winsparkle/wiki/Appcast-Feeds#installer-arguments)

WinSparkle controls downloading and running the installer.
Use `onUpdaterBeforeQuitForUpdate` to save app state when WinSparkle requests
shutdown. Windows Installer continues running after the app exits. If the
upgrade fails, add `/l*v` and a writable log path to
`sparkle:installerArguments` for a test run, then inspect the Windows
Installer log.
[Windows Installer command-line options](https://learn.microsoft.com/en-us/windows/win32/msi/command-line-options)

WinSparkle's update dialog reads a single release-notes URL per item. To
localize the notes, serve one appcast per supported locale, each with a single
`<sparkle:releaseNotesLink>` for that locale. Choose the feed in the app before
calling `setFeedURL`.
[WinSparkle appcast parser](https://github.com/vslavik/winsparkle/blob/v0.9.4/src/appcast.cpp)
