import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import './utils.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const GroupHeading(heading: 'Appearance'),
          ListTile(
            leading: const Icon(Icons.color_lens_rounded),
            title: const Text('Accent Color'),
            subtitle: const Text('System'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded),
            title: const Text('UI Style'),
            subtitle: const Text('Material You'),
            onTap: () {},
          ),
          const Divider(
            height: 1,
          ),
          const GroupHeading(heading: 'Data'),
          ListTile(
            leading: const Icon(Icons.download_rounded),
            title: const Text('Export timelogs'),
            subtitle: const Text('As CSV'),
            onTap: () async {
              final csvString = await convertTimelogsToCSV();
              Directory? downloadDirectory = await getDownloadsDirectory();
              if (Platform.isAndroid) {
                downloadDirectory = Directory('/storage/emulated/0/Download');
              }
              final csvFile = File('${downloadDirectory?.path}/timelogs.csv');
              csvFile.writeAsString(csvString);
              const snackBar = SnackBar(
                content: Text(
                  'Timelogs exported to your downloads directory',
                ),
              );
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup_rounded),
            title: const Text('Backup'),
            subtitle: const Text('Backup your data locally'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.restore_rounded),
            title: const Text('Backup'),
            subtitle: const Text('Backup your data locally'),
            onTap: () {},
          ),
          const Divider(
            height: 1,
          ),
          const GroupHeading(heading: 'About'),
          ListTile(
            leading: const Icon(Icons.code_rounded),
            title: const Text('Source code'),
            subtitle: const Text('https://github.com/siddharthroy12/timebrew'),
            onTap: () {
              launchUrl(
                Uri.parse('https://github.com/siddharthroy12/timebrew'),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_rounded),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
            onTap: () {
              launchUrl(
                Uri.parse(
                    'https://github.com/siddharthroy12/timebrew/releases'),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logo_dev_rounded),
            title: const Text('Made by Siddharth Roy'),
            subtitle: const Text('https://github.com/siddharthroy12'),
            onTap: () {
              launchUrl(Uri.parse('https://github.com/siddharthroy12'));
            },
          ),
          ListTile(
            leading: const Icon(Icons.flutter_dash_rounded),
            title: const Text('Made using Flutter'),
            subtitle: const Text('https://flutter.dev'),
            onTap: () {
              launchUrl(Uri.parse('https://flutter.dev'));
            },
          ),
        ],
      ),
    );
  }
}

class GroupHeading extends StatelessWidget {
  final String heading;
  const GroupHeading({super.key, required this.heading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Text(
        heading,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
