import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with UpdaterListener {
  final String _feedURL = 'http://localhost:5002/appcast.xml';

  bool _hasFeedUrl = false;

  @override
  void initState() {
    autoUpdater.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    autoUpdater.removeListener(this);
    super.dispose();
  }

  Future<void> _handleClickSetFeedURL() async {
    await autoUpdater.setFeedURL(_feedURL);
    _hasFeedUrl = true;
  }

  Future<void> _handleClickCheckForUpdates() async {
    if (!_hasFeedUrl) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please call setFeedURL method first.')),
      );
      return;
    }
    await autoUpdater.checkForUpdates();
  }

  Future<void> _handleClickCheckForUpdatesWithoutUI() async {
    await autoUpdater.checkForUpdates(inBackground: true);
  }

  Future<void> _handleClickSetScheduledCheckInterval() async {
    await autoUpdater.setScheduledCheckInterval(3600);
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
      children: <Widget>[
        Column(
          // title: const Text('METHODS'),
          children: [
            ListTile(
              title: const Text('setFeedURL'),
              trailing: Text(_feedURL),
              onTap: () {
                _handleClickSetFeedURL();
              },
            ),
            ListTile(
              title: const Text('checkForUpdates'),
              onTap: () {
                _handleClickCheckForUpdates();
              },
            ),
            ListTile(
              title: const Text('checkForUpdatesWithoutUI'),
              onTap: () {
                _handleClickCheckForUpdatesWithoutUI();
              },
            ),
            ListTile(
              title: const Text('setScheduledCheckInterval'),
              onTap: () {
                _handleClickSetScheduledCheckInterval();
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plugin example app')),
      body: _buildBody(context),
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
  void onUpdaterBeforeQuitForUpdate(AppcastItem? item) {
    if (kDebugMode) {
      print('onUpdaterBeforeQuitForUpdate: ${item?.toJson()}');
    }
  }
}
