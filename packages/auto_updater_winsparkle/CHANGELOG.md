## 1.0.0

* First release as `auto_updater_winsparkle` with WinSparkle 0.9.4.
* Send WinSparkle callback events through a Dart native port to avoid
  platform-thread warnings from the legacy event channel.
* Require Flutter 3.50 and Dart 3.14 or later.
* Resolve relative installer URLs against the final appcast URL.
* Report completed downloads and keep native update dialogs above the application.
* Include HTTP status, WinINet error codes, and signature verification failures
  in update error events.

## 0.2.1

* chore(windows): Support before-quit-for-update event

## 0.2.0

* First release.
