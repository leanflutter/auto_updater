# auto_updater

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url] ![][visits-count-image] 

[pub-image]: https://img.shields.io/pub/v/auto_updater.svg
[pub-url]: https://pub.dev/packages/auto_updater

[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

[visits-count-image]: https://img.shields.io/badge/dynamic/json?label=Visits%20Count&query=value&url=https://api.countapi.xyz/hit/leanflutter.auto_updater/visits

This plugin allows Flutter **desktop** apps to automatically update themselves (based on [sparkle](https://sparkle-project.org/) and [winsparkle](https://winsparkle.com)).

<img src="screenshots/sparkle.png" width="732" alt="">

---

English | [简体中文](./README-ZH.md)

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [auto_updater](#auto_updater)
  - [Platform Support](#platform-support)
  - [Quick Start](#quick-start)
    - [Installation](#installation)
      - [⚠️ Windows requirements](#️-windows-requirements)
    - [Usage](#usage)
    - [Publish your app](#publish-your-app)
      - [Generate private key](#generate-private-key)
        - [macOS](#macos)
        - [Windows](#windows)
      - [Packaging](#packaging)
        - [macOS](#macos-1)
        - [Windows](#windows-1)
      - [Get signature](#get-signature)
        - [macOS](#macos-2)
        - [Windows](#windows-2)
      - [Distributing](#distributing)
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
  auto_updater: ^0.1.6
```

Or

```yaml
dependencies:
  auto_updater:
    git:
      url: https://github.com/leanflutter/auto_updater.git
      ref: main
```

#### ⚠️ Windows requirements

- `openssl`

Run the following command:

> Use [Chocolatey](https://chocolatey.org/install)

```
choco install openssl
```

### Usage

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

### Publish your app

#### Generate private key

Run the following command:

```bash
flutter pub run auto_updater:generate_keys
```

> You need to run this command on `macOS` and `Windows` systems separately.

##### macOS

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

##### Windows

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

#### Packaging

> To simplify the packaging process, [Flutter Distributor](https://github.com/leanflutter/flutter_distributor) is used here, A complete tool dedicated to packaging and publishing Flutter apps.

Add `distribute_options.yaml` to your project root directory.

```yaml
output: dist/
releases:
  - name: dev
    jobs:
      - name: release-macos
        package:
          platform: macos
          target: zip
          build_args:
            dart-define:
              APP_ENV: dev
      # See full documentation: https://distributor.leanflutter.org/configuration/makers/exe
      - name: release-windows
        package:
          platform: windows
          target: exe
          build_args:
            dart-define:
              APP_ENV: dev
```

##### macOS

Run the following command:

```
flutter_distributor release --name dev --jobs release-macos
```

##### Windows

Run the following command:

```
flutter_distributor release --name dev --jobs release-windows
```

#### Get signature

##### macOS

Run the following command:

```
flutter pub run auto_updater:sign_update dist/1.1.0+2/auto_updater_example-1.1.0+2-macos.zip
```

Output:

```
sparkle:edSignature="pbdyPt92pnPkzLfQ7BhS9hbjcV9/ndkzSIlWjFQIUMcaCNbAFO2fzl0tISMNJApG2POTkZY0/kJQ2yZYOSVgAA==" length="13400992"
```

Update the obtained new signature to the value of the `sparkle:edSignature` attribute of the `enclosure` node of the `appcast.xml` file.

##### Windows

Run the following command:

```
flutter pub run auto_updater:sign_update dist/1.1.0+2/auto_updater_example-1.1.0+2-windows-setup.exe
```

Output:

```

MEUCIQCVbVzVID7H3aUzAY5znpi+ySZKznkukV8whlMFzKh66AIgREUGOmvavlcg
6hwAwkb2o4IqVE/D56ipIBshIqCH8rk=
```

Update the obtained new signature to the value of the `sparkle:dsaSignature` attribute of the `enclosure` node of the `appcast.xml` file.

#### Distributing

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
                       sparkle:version="1.1.0"
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
