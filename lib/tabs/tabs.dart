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
  bool _desktopView = true;
  bool _searchMode = false;
  final TextEditingController _searchInputController = TextEditingController();
  String _searchString = "";

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

  void _toggleSearchMode(bool searchMode) {
    setState(() {
      _searchString = "";
      _searchInputController.text = "";
      _searchMode = searchMode;
    });
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
    _desktopView = MediaQuery.of(context).size.width > 500;
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
    return Row(
      children: [
        ..._desktopView
            ? [
                Card(
                  margin: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.zero),
                  ),
                  child: NavigationRail(
                    selectedIndex: _tabIndex,
                    groupAlignment: 0,
                    backgroundColor: Colors.transparent,
                    onDestinationSelected: (int index) {
                      setState(() {
                        _tabIndex = index;
                      });
                      _toggleSearchMode(false);
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
                ),
              ]
            : [],
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              leading: _searchMode
                  ? IconButton(
                      onPressed: () => _toggleSearchMode(false),
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                    )
                  : null,
              title: _searchMode
                  ? TextField(
                      controller: _searchInputController,
                      onChanged: (text) {
                        setState(() {
                          _searchString = text;
                        });
                      },
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  : Text(tabs[_tabIndex].title),
              actions: [
                !_searchMode && _tabIndex > 1 && _tabIndex < 4
                    ? IconButton(
                        onPressed: () => _toggleSearchMode(true),
                        icon: Icon(
                          _searchMode ? Icons.cancel : Icons.search_rounded,
                        ),
                      )
                    : Container(),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: settingsButton,
                )
              ],
            ),
            body: [
              const Timer(),
              const Timelogs(),
              Tasks(
                searchString: _searchString,
              ),
              Tags(
                searchString: _searchString,
              ),
              const Stats(),
            ][_tabIndex],
            bottomNavigationBar: !_desktopView
                ? NavigationBar(
                    onDestinationSelected: (int index) {
                      setState(() {
                        _tabIndex = index;
                      });
                      _toggleSearchMode(false);
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
                if (_tabIndex < 4) {
                  return FloatingActionButton.extended(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onPressed: _action,
                    label: Text(
                        'Create ${_tabIndex == 0 ? "Task" : tabs[_tabIndex].title.substring(0, tabs[_tabIndex].title.length - 1)}'),
                    icon: const Icon(Icons.add_rounded),
                  );
                }
                return Container();
              },
            ),
          ),
        ),
      ],
    );
  }
}
