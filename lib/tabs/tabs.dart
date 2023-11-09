import 'package:flutter/material.dart';
import 'package:timebrew/popups/create_timelog.dart';
import 'package:timebrew/settings.dart';
import 'package:timebrew/tabs/stats.dart';
import 'package:timebrew/tabs/tags.dart';
import 'package:timebrew/tabs/tasks.dart';
import 'package:timebrew/tabs/timelogs.dart';
import 'timer.dart';
import '../popups/create_tag.dart';
import '../popups/create_task.dart';

class TabEntry {
  String title;
  IconData icon;
  TabEntry({required this.title, required this.icon});
}

enum Dialog { tag, task, timelog }

class Tabs extends StatefulWidget {
  const Tabs({
    super.key,
  });

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  bool desktopView = true;

  List<TabEntry> tabs = [
    TabEntry(title: 'Timer', icon: Icons.hourglass_bottom_rounded),
    TabEntry(title: 'Logs', icon: Icons.history_rounded),
    TabEntry(title: 'Tasks', icon: Icons.checklist_rounded),
    TabEntry(title: 'Tags', icon: Icons.local_offer_rounded),
    TabEntry(title: 'Stats', icon: Icons.analytics_rounded),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _showAction(BuildContext context, Dialog dialog) {
    showDialog<void>(
      context: context,
      builder: (context) {
        switch (dialog) {
          case Dialog.tag:
            return const CreateTagDialog();
          case Dialog.task:
            return const CreateTaskDialog();
          case Dialog.timelog:
            return const CreateTimelogDialog();
        }
      },
    );
  }

  void _action() {
    switch (_tabIndex) {
      case 0:
      case 2:
        _showAction(context, Dialog.task);
        break;
      case 3:
        _showAction(context, Dialog.tag);
        break;
      case 1:
        _showAction(context, Dialog.timelog);
    }
  }

  @override
  Widget build(BuildContext context) {
    desktopView = MediaQuery.of(context).size.width > 500;
    final settingsButton = IconButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const Settings(),
          ),
        );
      },
      icon: const Icon(Icons.settings_outlined),
    );
    return Scaffold(
      appBar: !desktopView
          ? AppBar(
              title: Text(tabs[_tabIndex].title),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: settingsButton,
                )
              ],
            )
          : null,
      body: Row(
        children: [
          ...desktopView
              ? [
                  Stack(
                    children: [
                      NavigationRail(
                        selectedIndex: _tabIndex,
                        groupAlignment: 0,
                        onDestinationSelected: (int index) {
                          setState(() {
                            _tabIndex = index;
                          });
                        },
                        labelType: NavigationRailLabelType.all,
                        destinations: tabs
                            .map(
                              (e) => NavigationRailDestination(
                                icon: Icon(e.icon),
                                label: Text(e.title),
                              ),
                            )
                            .toList(),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(child: settingsButton),
                      ),
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                            child: _tabIndex < 4
                                ? SizedBox(
                                    height: 45.0,
                                    width: 45.0,
                                    child: FittedBox(
                                      child: FloatingActionButton(
                                        elevation: 0,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10),
                                          ),
                                        ),
                                        onPressed: _action,
                                        child: const Icon(Icons.add),
                                      ),
                                    ),
                                  )
                                : Container()),
                      ),
                    ],
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                ]
              : [],
          Expanded(
            child: const [
              Timer(),
              Timelogs(),
              Tasks(),
              Tags(),
              Stats(),
            ][_tabIndex],
          ),
        ],
      ),
      bottomNavigationBar: !desktopView
          ? NavigationBar(
              onDestinationSelected: (int index) {
                setState(() {
                  _tabIndex = index;
                });
              },
              selectedIndex: _tabIndex,
              destinations: tabs
                  .map(
                    (e) => NavigationDestination(
                      icon: Icon(e.icon),
                      label: e.title,
                    ),
                  )
                  .toList(),
            )
          : null,
      floatingActionButton: Builder(
        builder: (context) {
          if (_tabIndex < 4 && !desktopView) {
            return FloatingActionButton.extended(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              onPressed: _action,
              label: Text(
                  'Add ${_tabIndex == 0 ? "Task" : tabs[_tabIndex].title.substring(0, tabs[_tabIndex].title.length - 1)}'),
              icon: const Icon(Icons.add_rounded),
            );
          }
          return Container();
        },
      ),
    );
  }
}
