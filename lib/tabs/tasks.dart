import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:timebrew/extensions/hex_color.dart';
import 'package:timebrew/models/tag.dart';
import 'package:timebrew/models/task.dart';
import 'package:timebrew/models/timelog.dart';
import 'package:timebrew/popups/confirm_delete.dart';
import 'package:timebrew/popups/create_task.dart';
import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> with AutomaticKeepAliveClientMixin {
  final isar = IsarService();

  @override
  bool get wantKeepAlive => true; //Set to true

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<List<Task>>(
      initialData: const [],
      stream: isar.getTaskStream(),
      builder: (context, snapshot) {
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: snapshot.data!.length,
          itemBuilder: (BuildContext context, int index) {
            Task task = snapshot.data![index];
            return StreamBuilder<List<Timelog>>(
              initialData: const [],
              stream: isar.getTaskTimelogStream(task.id),
              builder: (context, snapshot) {
                int milliseconds = 0;
                if (snapshot.data!.isNotEmpty) {
                  milliseconds = snapshot.data!
                      .map((timelog) => timelog.endTime - timelog.startTime)
                      .reduce((value, element) => value + element);
                }
                return TaskEntry(
                  name: task.name,
                  link: task.link,
                  id: task.id,
                  milliseconds: milliseconds,
                  tags: task.tags.toList(),
                );
              },
            );
          },
        );
      },
    );
  }
}

class TaskEntry extends StatelessWidget {
  final String name;
  final String link;
  final int id;
  final int milliseconds;
  final List<Tag> tags;
  final isar = IsarService();

  TaskEntry({
    super.key,
    required this.name,
    required this.link,
    required this.id,
    required this.milliseconds,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig(
            "Edit",
            onPressed: () {
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
          ContextMenuButtonConfig(
            "Delete",
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return ConfirmDeleteDialog(
                    description: 'Are you sure you want to delete $name',
                    onConfirm: () {
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
          )
        ],
      ),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            if (link.isNotEmpty) {
              launchUrl(
                Uri.parse(link),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Builder(builder: (context) {
                        if (tags.isEmpty) {
                          return Container();
                        }
                        return const SizedBox(
                          height: 10,
                        );
                      }),
                      Wrap(
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
                                color:
                                    MaterialStateProperty.resolveWith((states) {
                                  return HexColor.fromHex(tag.color);
                                }),
                                side: const BorderSide(
                                  width: 0,
                                  color: Colors.transparent,
                                ),
                                label: Text(
                                  '#${tag.name}',
                                  style: TextStyle(
                                    color: HexColor.fromHex(tag.color)
                                                .computeLuminance() >=
                                            0.5
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Text(
                  millisecondsToReadable(milliseconds),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.end,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
