import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/widgets/restart.dart';
import 'package:url_launcher/url_launcher.dart';
import './utils.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final isar = IsarService();

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
              String? selectedDirectory =
                  await FilePicker.platform.getDirectoryPath();

              if (selectedDirectory != null) {
                final csvString = await convertTimelogsToCSV();

                final csvFile = File('$selectedDirectory/timelogs.csv');
                await csvFile.writeAsString(csvString);
                var snackBar = SnackBar(
                  content: Text(
                    'Timelogs exported to $selectedDirectory',
                  ),
                );
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup_rounded),
            title: const Text('Backup'),
            subtitle: const Text('Backup your data locally'),
            onTap: () async {
              String? selectedDirectory =
                  await FilePicker.platform.getDirectoryPath();

              if (selectedDirectory != null) {
                final db = await isar.db;
                db.copyToFile('$selectedDirectory/backuo.tb');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore_rounded),
            title: const Text('Restore'),
            subtitle: const Text('Restore your backup'),
            onTap: () async {
              FilePickerResult? selectedFile =
                  await FilePicker.platform.pickFiles(
                dialogTitle: 'Pick Timebrew backup file',
                allowedExtensions: ['tb'],
                type: FileType.custom,
              );
              if (selectedFile != null) {
                if (selectedFile.files.single.path != null) {
                  // ignore: use_build_context_synchronously
                  await showDialog<void>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Warning'),
                        content: const Text(
                          'You could loose data if the selected file is corrupted or invalid.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              File file = File(selectedFile.files.single.path!);
                              final dir =
                                  await getApplicationDocumentsDirectory();
                              await (await isar.db).close(deleteFromDisk: true);
                              var bytes = await file.readAsBytes();
                              File destFile = File('${dir.path}/default.isar');
                              await destFile.writeAsBytes(
                                bytes,
                              );
                              // ignore: use_build_context_synchronously
                              RestartWidget.restartApp(context);
                            },
                            child: const Text('Proceed'),
                          )
                        ],
                      );
                    },
                  );
                }
              }
            },
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
                  'https://github.com/siddharthroy12/timebrew/releases',
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15),
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
