import 'package:auto_updater/auto_updater.dart';
import 'package:flutter/material.dart';
import 'package:preference_list/preference_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    String feedURL = 'http://localhost:5000/appcast.xml';
    await autoUpdater.setFeedURL(feedURL);
    await autoUpdater.checkForUpdates();
  }

  void _handleClickCheckForUpdates() async {
    AutoUpdater.instance.checkForUpdates();
  }

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        PreferenceListSection(
          title: const Text('METHODS'),
          children: [
            PreferenceListItem(
              title: const Text('checkForUpdates'),
              onTap: () {
                _handleClickCheckForUpdates();
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
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: _buildBody(context),
    );
  }
}
