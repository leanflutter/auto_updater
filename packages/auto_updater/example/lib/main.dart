import 'dart:io';
import 'dart:ui' show AppExitType;

import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xff416ff4),
        canvasColor: Colors.white,
        scaffoldBackgroundColor: const Color(0xffF7F9FB),
        dividerColor: Colors.grey.withValues(alpha: 0.3),
      ),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> with UpdaterListener {
  static const _feedUrl = 'http://localhost:5002/appcast.xml';
  bool _hasFeedUrl = false;

  @override
  void initState() {
    super.initState();
    autoUpdater.addListener(this);
  }

  @override
  void dispose() {
    autoUpdater.removeListener(this);
    super.dispose();
  }

  Future<void> _setFeedUrl() async {
    await autoUpdater.setFeedURL(_feedUrl);
    _hasFeedUrl = true;
  }

  Future<void> _checkForUpdates() async {
    if (_hasFeedUrl) {
      await autoUpdater.checkForUpdates();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please call setFeedURL method first.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plugin example app')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('setFeedURL'),
            trailing: const Text(_feedUrl),
            onTap: _setFeedUrl,
          ),
          ListTile(
            title: const Text('checkForUpdates'),
            onTap: _checkForUpdates,
          ),
          ListTile(
            title: const Text('checkForUpdatesWithoutUI'),
            onTap: () => autoUpdater.checkForUpdates(inBackground: true),
          ),
          ListTile(
            title: const Text('setScheduledCheckInterval'),
            onTap: () => autoUpdater.setScheduledCheckInterval(3600),
          ),
        ],
      ),
    );
  }

  @override
  void onUpdaterError(UpdaterError? error) {
    if (kDebugMode) {
      print('onUpdaterError: $error');
    }
  }

  @override
  void onUpdaterCheckingForUpdate(Appcast? appcast) {
    if (kDebugMode) {
      print('onUpdaterCheckingForUpdate: ${appcast?.toJson()}');
    }
  }

  @override
  void onUpdaterUpdateAvailable(AppcastItem? item) {
    if (kDebugMode) {
      print('onUpdaterUpdateAvailable: ${item?.toJson()}');
    }
  }

  @override
  void onUpdaterUpdateNotAvailable(UpdaterError? error) {
    if (kDebugMode) {
      print('onUpdaterUpdateNotAvailable: $error');
    }
  }

  @override
  void onUpdaterUpdateDownloaded(AppcastItem? item) {
    if (kDebugMode) {
      print('onUpdaterUpdateDownloaded: ${item?.toJson()}');
    }
  }

  @override
  Future<void> onUpdaterBeforeQuitForUpdate(AppcastItem? item) async {
    if (kDebugMode) {
      print('onUpdaterBeforeQuitForUpdate: ${item?.toJson()}');
    }
    if (Platform.isWindows) {
      await ServicesBinding.instance.exitApplication(AppExitType.required);
    }
  }
}
