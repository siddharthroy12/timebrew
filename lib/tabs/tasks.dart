import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:timebrew/extensions/hex_color.dart';
import 'package:timebrew/models/tag.dart';
import 'package:timebrew/models/task.dart';
import 'package:timebrew/models/timelog.dart';
import 'package:timebrew/popups/confirm_delete.dart';
import 'package:timebrew/popups/create_task.dart';
import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/tabs/timelogs.dart';
import 'package:timebrew/utils.dart';
import 'package:timebrew/widgets/no_data_emoji.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Tasks extends StatefulWidget {
  final String searchString;
  final Map<Id, bool> selectedTags;
  const Tasks({
    super.key,
    required this.searchString,
    required this.selectedTags,
  });

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  final _isar = IsarService();
  final Map<Id, int> _millisecondsOnTasks = {};
  List<Task>? _tasks = [];
  bool _isLoading = true;
  late StreamSubscription _tasksStreamSubscription;

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
    if (_tasks == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Search Filter
    var filteredList = _tasks!
        .where(
          (element) =>
              element.name.toLowerCase().contains(
                    widget.searchString.toLowerCase(),
                  ) ||
              element.tags
                  .where(
                    (element) => element.name.toLowerCase().contains(
                          widget.searchString.toLowerCase(),
                        ),
                  )
                  .isNotEmpty,
        )
        .toList();

    // Filter tag
    filteredList = filteredList
        .where((element) => element.tags
            .where((element) => widget.selectedTags[element.id] ?? false)
            .isNotEmpty)
        .toList();

    if (filteredList.isEmpty) {
      return const NoDataEmoji();
    }

    return ListView.separated(
      itemCount: filteredList.length,
      separatorBuilder: (context, index) {
        return Container();
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

    Widget? subtitle = tags.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: tags
                  .map(
                    (tag) => ActionChip(
                      onPressed: () {},
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(50),
                        ),
                      ),
                      color: MaterialStateProperty.resolveWith((states) {
                        return HexColor.fromHex(tag.color).withOpacity(0.2);
                      }),
                      side: BorderSide(
                        width: 1,
                        color: HexColor.fromHex(tag.color),
                      ),
                      label: Text(
                        tag.name,
                      ),
                    ),
                  )
                  .toList(),
            ),
          )
        : null;

    EdgeInsets padding =
        const EdgeInsets.symmetric(vertical: 10, horizontal: 20);

    if (showExpansion) {
      return ExpansionTile(
        title: title,
        subtitle: subtitle,
        tilePadding: padding,
        children: timelogs
            .map(
              (element) => TimelogEntry(
                id: element.id,
                task: (element.task.value?.name ?? ''),
                description: element.description,
                milliseconds: element.endTime - element.startTime,
                startTime: element.startTime,
                endTime: element.endTime,
                running: element.running,
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
              body: Timelogs(
                selectedTask: id,
              ),
            ),
          ),
        );
      },
      contentPadding: padding,
      subtitle: subtitle,
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
                    description: 'Are you sure you want to delete $name',
                    onConfirm: () {
                      final isar = IsarService();

                      isar.deleteTask(id, false);

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
