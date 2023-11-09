import 'package:flutter/material.dart';
import 'package:timebrew/extensions/hex_color.dart';
import 'package:timebrew/models/tag.dart';
import 'package:timebrew/models/task.dart';
import 'package:timebrew/models/timelog.dart';
import 'package:timebrew/popups/confirm_delete.dart';
import 'package:timebrew/popups/create_task.dart';
import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/utils.dart';

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
        return ListView.separated(
          itemCount: snapshot.data!.length,
          separatorBuilder: (context, index) {
            return const Divider(
              height: 0,
            );
          },
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
  final int id;
  final int milliseconds;
  final List<Tag> tags;

  TaskEntry({
    super.key,
    required this.name,
    required this.id,
    required this.milliseconds,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      subtitle: tags.isNotEmpty
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
                          '#${tag.name}',
                          style: TextStyle(
                            color: HexColor.fromHex(tag.color)
                                        .computeLuminance() >=
                                    0.5
                                ? Colors.black
                                : Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
          : null,
      trailing: PopupMenuButton(
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
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
      title: Wrap(
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
      ),
    );
  }
}
