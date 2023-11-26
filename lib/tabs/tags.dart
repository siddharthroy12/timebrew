import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:timebrew/extensions/hex_color.dart';
import 'package:timebrew/models/tag.dart';
import 'package:timebrew/popups/confirm_delete.dart';
import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/popups/create_tag.dart';
import 'package:timebrew/tabs/tasks.dart';
import 'package:timebrew/utils.dart';
import 'package:timebrew/widgets/no_data_emoji.dart';

class Tags extends StatefulWidget {
  final String searchString;

  const Tags({
    super.key,
    required this.searchString,
  });

  @override
  State<Tags> createState() => _TagsState();
}

class _TagsState extends State<Tags> {
  final _isar = IsarService();
  final Map<Id, int> _millisecondsOnTags = {};
  List<Tag>? _tags = [];
  bool _isLoading = true;
  late StreamSubscription _tagStreamSubscription;

  @override
  void initState() {
    super.initState();
    _tagStreamSubscription = _isar.getTagStream().listen((tags) {
      setState(() {
        _tags = tags;
        _isLoading = false;
      });
    });

    _isar.getTimelogStream().first.then((timelogs) {
      setState(() {
        for (var timelog in timelogs) {
          final milliseconds = timelog.endTime - timelog.startTime;
          if (timelog.task.value != null) {
            for (var tag in timelog.task.value!.tags) {
              if (_millisecondsOnTags.containsKey(tag.id)) {
                _millisecondsOnTags[tag.id] =
                    _millisecondsOnTags[tag.id]! + milliseconds;
              } else {
                _millisecondsOnTags[tag.id] = milliseconds;
              }
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tagStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_tags == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    final filteredList = _tags!
        .where(
          (element) => element.name.toLowerCase().contains(
                widget.searchString.toLowerCase(),
              ),
        )
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
        Tag tag = filteredList[index];
        return TagEntry(
          name: tag.name,
          id: tag.id,
          milliseconds: _millisecondsOnTags[tag.id] ?? 0,
          color: HexColor.fromHex(tag.color),
        );
      },
    );
  }
}

class TagEntry extends StatelessWidget {
  final String name;
  final int id;
  final int milliseconds;
  final Color color;

  const TagEntry({
    super.key,
    required this.name,
    required this.id,
    required this.milliseconds,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text('$name Tasks')),
              body: const TasksPage(
                searchString: "",
              ),
            ),
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      leading: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: color,
        ),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Text(
              "#",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color.computeLuminance() >= 0.5
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            millisecondsToReadable(milliseconds),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      trailing: PopupMenuButton(
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
          PopupMenuItem(
            value: 'edit',
            child: const Text('Edit'),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return CreateTagDialog(
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
              final isar = IsarService();

              showDialog<void>(
                context: context,
                builder: (context) {
                  return ConfirmDeleteDialog(
                    description: 'Are you sure you want to delete tag "$name"',
                    extraDescription: FutureBuilder(
                        future: isar.getTasksWithOnlyOneTag(id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.isEmpty) {
                              return const SizedBox(
                                height: 0,
                              );
                            }
                            return SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'This will delete these tasks and it\'s timelogs',
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  ...snapshot.data!
                                      .map((e) => Text(e.name))
                                      .toList()
                                ],
                              ),
                            );
                          }
                          return const CircularProgressIndicator();
                        }),
                    onConfirm: () {
                      isar.deleteTag(id);

                      final snackBar = SnackBar(
                        content: Text('Tag $name deleted'),
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
    );
  }
}
