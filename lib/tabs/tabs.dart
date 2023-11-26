import 'package:flutter/material.dart';
import 'package:timebrew/popups/create_timelog.dart';
import 'package:timebrew/tabs/stats.dart';
import 'package:timebrew/tabs/tags.dart';
import 'package:timebrew/tabs/tasks.dart';
import 'package:timebrew/tabs/timelogs.dart';
import 'package:timebrew/widgets/conditional.dart';
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
  final PageController _pageController = PageController(initialPage: 0);

  List<TabEntry> tabs = [
    TabEntry(title: 'Timer', icon: Icons.hourglass_bottom_rounded),
    TabEntry(title: 'Logs', icon: Icons.history_rounded),
    TabEntry(title: 'Tasks', icon: Icons.task_alt),
    TabEntry(title: 'Tags', icon: Icons.local_offer_rounded),
    TabEntry(title: 'Stats', icon: Icons.analytics_rounded),
  ];

  void _onDestinationChange(int index) {
    setState(() {
      _pageController.jumpToPage(index);
      _tabIndex = index;
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
    NavigationBar? bottomNavigationBar;

    if (!_desktopView) {
      bottomNavigationBar = NavigationBar(
        onDestinationSelected: _onDestinationChange,
        selectedIndex: _tabIndex,
        destinations: tabs
            .map(
              (e) => NavigationDestination(
                icon: Icon(e.icon),
                label: e.title,
              ),
            )
            .toList(),
      );
    }
    return Row(
      children: [
        Conditional(
          condition: _desktopView,
          ifTrue: Card(
            margin: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.zero),
            ),
            child: NavigationRail(
              selectedIndex: _tabIndex,
              groupAlignment: 0,
              backgroundColor: Colors.transparent,
              onDestinationSelected: _onDestinationChange,
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
        ),
        Expanded(
          child: Scaffold(
            body: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: const [
                Timer(),
                Timelogs(),
                TasksPage(
                  searchString: '',
                ),
                Tags(
                  searchString: '',
                ),
                Stats(),
              ],
            ),
            bottomNavigationBar: bottomNavigationBar,
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
