import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:timebrew/extensions/date_time.dart';
import 'package:timebrew/extensions/hex_color.dart';
import 'package:timebrew/models/tag.dart';
import 'package:timebrew/models/task.dart';
import 'package:timebrew/models/timelog.dart';
import 'package:timebrew/popups/confirm_delete.dart';
import 'package:timebrew/popups/create_task.dart';
import 'package:timebrew/popups/create_timelog.dart';
import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/tabs/timelogs.dart';
import 'package:timebrew/utils.dart';
import 'package:timebrew/widgets/app_bar_menu_button.dart';
import 'package:timebrew/widgets/conditional.dart';
import 'package:timebrew/widgets/no_data_emoji.dart';
import 'package:timebrew/widgets/tag_filter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TasksPage extends StatefulWidget {
  final String searchString;
  const TasksPage({
    super.key,
    required this.searchString,
  });

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _searchQuery = "";
  bool _searchMode = false;
  Id? _selectedTag;
  final TextEditingController _searchInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        titleSpacing: _searchMode ? 5 : null,
        title: Conditional(
          condition: _searchMode,
          ifFalse: const Text('Tasks'),
          ifTrue: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _searchMode = false;
                    _searchQuery = "";
                    _searchInputController.text = "";
                  });
                },
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: TextField(
                  controller: _searchInputController,
                  onChanged: (text) {
                    setState(() {
                      _searchQuery = text;
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
                ),
              )
            ],
          ),
        ),
        actions: [
          Conditional(
            condition: _searchMode,
            ifFalse: IconButton(
              onPressed: () {
                setState(() {
                  _searchMode = true;
                });
              },
              icon: const Icon(Icons.search_rounded),
            ),
          ),
          const AppBarMenuButton(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: SizedBox(
            height: 55,
            child: Column(
              children: [
                Expanded(
                  child: TagFilter(
                    initialSelectedTag: _selectedTag,
                    onSelectedTagChange: (tag) {
                      setState(() {
                        _selectedTag = tag;
                      });
                    },
                  ),
                ),
                const Divider(
                  height: 0,
                )
              ],
            ),
          ),
        ),
      ),
      body: TaskList(
        searchQuery: _searchQuery,
        selectedTag: _selectedTag,
      ),
    );
  }
}

class TaskEntry extends StatelessWidget {
  final String name;
  final int id;
  final int milliseconds;
  final List<Tag> tags;
  final String link;
  final List<Timelog> timelogs;
  final bool showExpansion;

  const TaskEntry({
    super.key,
    required this.name,
    required this.id,
    required this.milliseconds,
    required this.tags,
    required this.link,
    this.timelogs = const [],
    this.showExpansion = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget title = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          millisecondsToReadable(milliseconds),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );

    Widget? subtitle;
    if (tags.isNotEmpty) {
      subtitle = Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tags
              .map(
                (tag) => ActionChip(
                  onPressed: () {},
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(4),
                    ),
                  ),
                  color: MaterialStateProperty.resolveWith((states) {
                    return HexColor.fromHex(tag.color);
                  }),
                  side: const BorderSide(
                    width: 0,
                    color: Colors.transparent,
                  ),
                  label: Text(
                    tag.name,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );
    } else {
      subtitle = null;
    }

    EdgeInsets padding =
        const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 10);

    Widget icon = const Padding(
      padding: EdgeInsets.only(right: 5),
      child: Icon(
        Icons.task_alt,
        size: 30,
      ),
    );

    if (showExpansion) {
      return ExpansionTile(
        title: title,
        subtitle: subtitle,
        leading: icon,
        tilePadding: padding,
        children: timelogs
            .map(
              (element) => AltTimelogEntry(
                id: element.id,
                task: (element.task.value?.name ?? ''),
                description: element.description,
                milliseconds: element.endTime - element.startTime,
                startTime: element.startTime,
                endTime: element.endTime,
                running: element.running,
                showOptions: false,
              ),
            )
            .toList(),
      );
    }
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text('$name Timelogs')),
              body: TimelogList(
                taskId: id,
              ),
            ),
          ),
        );
      },
      contentPadding: padding,
      subtitle: subtitle,
      leading: icon,
      trailing: PopupMenuButton(
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
          PopupMenuItem(
            value: 'openlink',
            child: const Text('Open Link'),
            onTap: () {
              launchUrlString(link);
            },
          ),
          PopupMenuItem(
            value: 'edit',
            child: const Text('Edit'),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return CreateTaskDialog(
                    id: id,
                  );
                },
              );
            },
          ),
          PopupMenuItem(
            value: 'delete',
            child: const Text('Delete'),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return ConfirmDeleteDialog(
                    description:
                        'Are you sure you want to delete task "$name" and all it\'s timelogs?',
                    onConfirm: () {
                      final isar = IsarService();

                      isar.deleteTask(id, true);

                      final snackBar = SnackBar(
                        content: Text('Task $name deleted'),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      title: title,
    );
  }
}

class TaskList extends StatefulWidget {
  final Id? selectedTag;
  final String searchQuery;
  const TaskList({
    super.key,
    required this.selectedTag,
    required this.searchQuery,
  });

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final _isar = IsarService();
  final Map<Id, int> _millisecondsOnTasks = {};
  List<Task>? _tasks = [];
  late StreamSubscription _tasksStreamSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tasksStreamSubscription = _isar.getTaskStream().listen((tasks) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    });

    _isar.getTimelogStream().first.then((timelogs) {
      setState(() {
        for (var timelog in timelogs) {
          final milliseconds = timelog.endTime - timelog.startTime;

          if (timelog.task.value != null) {
            if (_millisecondsOnTasks.containsKey(timelog.task.value!.id)) {
              _millisecondsOnTasks[timelog.task.value!.id] =
                  _millisecondsOnTasks[timelog.task.value!.id]! + milliseconds;
            } else {
              _millisecondsOnTasks[timelog.task.value!.id] = milliseconds;
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tasksStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // Search Filter
    var filteredList = _tasks!
        .where(
          (element) =>
              element.name.toLowerCase().contains(
                    widget.searchQuery.toLowerCase(),
                  ) ||
              element.tags
                  .where(
                    (element) => element.name.toLowerCase().contains(
                          widget.searchQuery.toLowerCase(),
                        ),
                  )
                  .isNotEmpty,
        )
        .toList();

    if (widget.selectedTag != null) {
      // Filter tag
      filteredList = filteredList
          .where((element) => element.tags
              .where((element) => element.id == widget.selectedTag)
              .isNotEmpty)
          .toList();
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (filteredList.isEmpty) {
      return const NoDataEmoji();
    }

    return ListView.separated(
      itemCount: filteredList.length,
      separatorBuilder: (context, index) {
        return const Divider(
          height: 0,
        );
      },
      padding: const EdgeInsets.only(bottom: 60),
      itemBuilder: (BuildContext context, int index) {
        Task task = filteredList[index];
        return TaskEntry(
          name: task.name,
          id: task.id,
          milliseconds: _millisecondsOnTasks[task.id] ?? 0,
          tags: task.tags.toList(),
          link: task.link,
        );
      },
    );
  }
}

class TimelogList extends StatefulWidget {
  final Id taskId;
  const TimelogList({super.key, required this.taskId});

  @override
  State<TimelogList> createState() => _TimelogListState();
}

class _TimelogListState extends State<TimelogList> {
  final _isar = IsarService();
  List<Timelog> _timelogs = [];

  void _loadTimelogs() {
    _isar.getTaskTimelogStream(widget.taskId).first.then((value) {
      setState(() {
        _timelogs = value;
        if (_timelogs.isNotEmpty) {
          _timelogs.sort((a, b) => b.startTime.compareTo(a.startTime));
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTimelogs();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _timelogs.length,
      separatorBuilder: (c, i) => const Divider(
        height: 0,
      ),
      itemBuilder: (context, index) {
        Timelog timelog = _timelogs[index];
        return AltTimelogEntry(
          id: timelog.id,
          running: timelog.running,
          task: timelog.task.value?.name ?? '',
          description: timelog.description,
          startTime: timelog.startTime,
          endTime: timelog.endTime,
          milliseconds: timelog.endTime - timelog.startTime,
        );
      },
    );
  }
}

class AltTimelogEntry extends StatelessWidget {
  final Id id;
  final String task;
  final String description;
  final int startTime;
  final int endTime;
  final int milliseconds;
  final bool running;
  final bool showOptions;

  const AltTimelogEntry({
    super.key,
    required this.id,
    required this.running,
    required this.task,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.milliseconds,
    this.showOptions = true,
  });

  @override
  Widget build(BuildContext context) {
    final [month, date] = DateTime.fromMillisecondsSinceEpoch(startTime)
        .toDateString()
        .split(',')
        .first
        .split(' ');
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 15, left: 0, right: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Center(
                      child: Column(
                        children: [
                          Text(date),
                          Text(month),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${millisecondsToTime(startTime)} - ${millisecondsToTime(endTime)} · ${millisecondsToReadable(milliseconds)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          description.isEmpty ? 'No description' : description,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  showOptions
                      ? SizedBox(
                          width: 50,
                          child: Center(
                            child: PopupMenuButton(
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry>[
                                PopupMenuItem(
                                  value: 'edit',
                                  enabled: !running,
                                  onTap: () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (context) {
                                        return CreateTimelogDialog(
                                          id: id,
                                        );
                                      },
                                    );
                                  },
                                  child: const Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  enabled: !running,
                                  onTap: () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (context) {
                                        return ConfirmDeleteDialog(
                                          description:
                                              'Are you sure you want to delete this timelog for task "$task"',
                                          onConfirm: () {
                                            final isar = IsarService();

                                            isar.deleteTimelog(id);

                                            const snackBar = SnackBar(
                                              content: Text('Timelog deleted'),
                                            );

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
