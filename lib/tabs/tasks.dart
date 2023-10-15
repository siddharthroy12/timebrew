import 'package:flutter/material.dart';
import 'package:timebrew/extensions/hex_color.dart';
import 'package:timebrew/models/tag.dart';
import 'package:timebrew/models/task.dart';
import 'package:timebrew/popups/confirm_delete.dart';
import 'package:timebrew/popups/create_task.dart';
import 'package:timebrew/services/isar_service.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  final isar = IsarService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
      initialData: const [],
      stream: isar.getTaskStream(),
      builder: (context, snapshot) {
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: snapshot.data!.length,
          itemBuilder: (BuildContext context, int index) {
            Task task = snapshot.data![index];
            return TaskEntry(
              name: task.name,
              id: task.id,
              milliseconds: 0,
              tags: task.tags.toList(),
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
  final isar = IsarService();

  TaskEntry({
    super.key,
    required this.name,
    required this.id,
    required this.milliseconds,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "No time spent",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: tags
                      .map(
                        (tag) => ActionChip(
                          onPressed: () {},
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          color: MaterialStateProperty.resolveWith((states) {
                            return HexColor.fromHex(tag.color);
                          }),
                          side: const BorderSide(
                              width: 0, color: Colors.transparent),
                          label: Text('#${tag.name}'),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            PopupMenuButton(
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
                            isar.deleteTask(id, false);

                            final snackBar = SnackBar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                              content: Text('Task $name deleted'),
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
