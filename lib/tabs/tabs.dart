import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:timebrew/models/tag.dart';
import 'package:timebrew/popups/create_timelog.dart';
import 'package:timebrew/services/isar_service.dart';
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
  final _isar = IsarService();
  int _tabIndex = 0;
  bool _desktopView = true;
  bool _hasSpaceForRightPanel = false;
  bool _searchMode = false;
  final TextEditingController _searchInputController = TextEditingController();
  String _searchString = "";
  List<Tag> _tags = [];
  Map<Id, bool> _selectedTags = {};
  bool _stickyFilterPanelOpen = false;

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
    _loadTags();
  }

  void _loadTags() {
    _isar.getTagStream().listen((value) {
      setState(() {
        for (var tag in value) {
          if (!_selectedTags.containsKey(tag.id)) {
            _selectedTags[tag.id] = true;
          }
        }
        _tags = value;
      });
    });
  }

  void _onDestinationChange(int index) {
    setState(() {
      _tabIndex = index;
    });
    _toggleSearchMode(false);
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

  void _showFilterSheet() {
    if (_hasSpaceForRightPanel) {
      setState(() {
        _stickyFilterPanelOpen = !_stickyFilterPanelOpen;
      });
    } else {
      SideSheet.right(
        transitionDuration: const Duration(milliseconds: 200),
        body: TagFilter(
          tags: _tags,
          initialSelectedTags: _selectedTags,
          onTagSelectionChange: (selectedTags) {
            setState(() {
              _selectedTags = selectedTags;
            });
          },
          onClose: () {
            Navigator.pop(context);
          },
        ),
        width: 250,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _desktopView = MediaQuery.of(context).size.width > 500;
    _hasSpaceForRightPanel = MediaQuery.of(context).size.width > 700;
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
                ..._tabIndex != 3
                    ? [
                        _stickyFilterPanelOpen
                            ? IconButton.filledTonal(
                                isSelected: _selectedTags.containsValue(false),
                                onPressed: _showFilterSheet,
                                selectedIcon: Icon(
                                  Icons.filter_alt_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                icon: const Icon(Icons.filter_alt_outlined),
                              )
                            : IconButton(
                                isSelected: _selectedTags.containsValue(false),
                                onPressed: _showFilterSheet,
                                selectedIcon: Icon(
                                  Icons.filter_alt_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                icon: const Icon(Icons.filter_alt_outlined),
                              )
                      ]
                    : [],
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: settingsButton,
                )
              ],
            ),
            body: [
              Timer(
                selectedTags: _selectedTags,
              ),
              Timelogs(
                selectedTags: _selectedTags,
              ),
              Tasks(
                searchString: _searchString,
                selectedTags: _selectedTags,
              ),
              Tags(
                searchString: _searchString,
              ),
              Stats(
                selectedTags: _selectedTags,
              ),
            ][_tabIndex],
            bottomNavigationBar: !_desktopView
                ? NavigationBar(
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
        ..._stickyFilterPanelOpen && _hasSpaceForRightPanel
            ? [
                const VerticalDivider(
                  width: 1,
                ),
                SizedBox(
                  width: 250,
                  child: TagFilter(
                    tags: _tags,
                    initialSelectedTags: _selectedTags,
                    onTagSelectionChange: (selectedTags) {
                      setState(() {
                        _selectedTags = selectedTags;
                      });
                    },
                    onClose: () {
                      setState(() {
                        _stickyFilterPanelOpen = false;
                      });
                    },
                  ),
                )
              ]
            : [],
      ],
    );
  }
}

class TagFilter extends StatefulWidget {
  final List<Tag> tags;
  final Map<Id, bool> initialSelectedTags;
  final Function(Map<Id, bool>) onTagSelectionChange;
  final Function() onClose;
  const TagFilter({
    super.key,
    required this.tags,
    required this.initialSelectedTags,
    required this.onTagSelectionChange,
    required this.onClose,
  });

  @override
  State<TagFilter> createState() => _TagFilterState();
}

class _TagFilterState extends State<TagFilter> {
  Map<Id, bool> _selectedTags = {};

  @override
  void initState() {
    super.initState();
    _selectedTags = widget.initialSelectedTags;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    widget.onClose();
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text(
                  'Filter Tags',
                  style: TextStyle(fontSize: 20),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.tags.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    leading: Checkbox(
                      value: !_selectedTags.containsValue(false),
                      onChanged: (event) {
                        if (event != null) {
                          setState(() {
                            for (var tag in widget.tags) {
                              _selectedTags[tag.id] = event;
                              widget.onTagSelectionChange(_selectedTags);
                            }
                          });
                        }
                      },
                    ),
                    title: const Text('Select all'),
                  );
                }
                return ListTile(
                  leading: Checkbox(
                    value: _selectedTags[widget.tags[index - 1].id] ?? false,
                    onChanged: (event) {
                      if (event != null) {
                        setState(() {
                          _selectedTags[widget.tags[index - 1].id] = event;
                          widget.onTagSelectionChange(_selectedTags);
                        });
                      }
                    },
                  ),
                  title: Text(widget.tags[index - 1].name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
