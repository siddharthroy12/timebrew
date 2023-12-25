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
import 'package:timebrew/widgets/app_bar_menu_button.dart';
import 'package:timebrew/widgets/conditional.dart';
import 'package:timebrew/widgets/no_data_emoji.dart';

class Tags extends StatefulWidget {
  const Tags({
    super.key,
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
  String _searchQuery = "";
  bool _searchMode = false;
  final TextEditingController _searchInputController = TextEditingController();

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
    final filteredList = _tags!
        .where(
          (element) => element.name.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
          scrolledUnderElevation: 0,
          titleSpacing: _searchMode ? 5 : null,
          title: Conditional(
            condition: _searchMode,
            ifFalse: const Text('Tags'),
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
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.grid_view_rounded),
            ),
            const AppBarMenuButton(),
          ]),
      body: Builder(builder: (context) {
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
      }),
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
    EdgeInsets padding =
        const EdgeInsets.only(top: 10, bottom: 10, left: 15, right: 10);

    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text('$name Tasks')),
              body: TaskList(
                searchQuery: "",
                selectedTag: id,
              ),
            ),
          ),
        );
      },
      contentPadding: padding,
      leading: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: color,
        ),
        child: SizedBox(
          width: 45,
          height: 45,
          child: Center(
            child: Icon(
              Icons.local_offer_rounded,
              color: Colors.black.withOpacity(0.8),
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
