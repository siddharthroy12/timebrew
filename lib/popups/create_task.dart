import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:timebrew/extensions/hex_color.dart';
import 'package:timebrew/models/tag.dart';
import 'package:timebrew/popups/create_tag.dart';
import 'package:timebrew/services/isar_service.dart';

class CreateTaskDialog extends StatefulWidget {
  const CreateTaskDialog({super.key, this.id});

  final Id? id;

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final isar = IsarService();
  var nameFieldController = TextEditingController();
  var linkFieldContoller = TextEditingController();

  String name = "";
  String link = "";
  List<int> selectedTags = [];

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      loadTaskData();
    }
  }

  void loadTaskData() async {
    var task = await isar.getTaskById(widget.id!);
    if (task != null) {
      setState(() {
        name = task.name;
        link = task.link;
        selectedTags = task.tags.map((e) => e.id).toList();
        nameFieldController.text = name;
        linkFieldContoller.text = link;
      });
    }
  }

  void _onSave(BuildContext context) async {
    if (widget.id != null) {
      isar.updateTask(widget.id!, name, link, selectedTags);
    } else {
      isar.addTask(name, link, selectedTags);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Text(
              widget.id == null ? 'Create Task' : 'Update Task',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: nameFieldController,
              cursorHeight: 20,
              style: const TextStyle(height: 1.2),
              decoration: const InputDecoration(label: Text('Task name')),
              onChanged: (String value) {
                setState(() {
                  name = value;
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: linkFieldContoller,
              cursorHeight: 20,
              style: const TextStyle(height: 1.2),
              decoration: const InputDecoration(label: Text('Link')),
              onChanged: (String value) {
                setState(() {
                  link = value;
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            StreamBuilder(
              stream: isar.getTagStream(),
              initialData: const [],
              builder: (context, snapshot) {
                List<Widget> chips = [];
                for (Tag tag in snapshot.data!) {
                  bool selected = selectedTags.contains(tag.id);
                  chips.add(
                    FilterChip(
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
                      selected: selected,
                      onSelected: (newSelected) {
                        setState(() {
                          if (selected) {
                            selectedTags.remove(tag.id);
                          } else {
                            selectedTags.add(tag.id);
                          }
                        });
                      },
                      label: Text(
                        '#${tag.name}',
                        style: TextStyle(
                          color:
                              HexColor.fromHex(tag.color).computeLuminance() >=
                                      0.5
                                  ? Colors.black
                                  : Colors.white,
                        ),
                      ),
                    ),
                  );
                }
                chips.add(
                  ActionChip(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      ),
                    ),
                    color: MaterialStateProperty.resolveWith((states) {
                      return Theme.of(context).colorScheme.onSecondary;
                    }),
                    label: const Text('Add tag'),
                    avatar: const Icon(Icons.add),
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) {
                          return const CreateTagDialog();
                        },
                      );
                    },
                  ),
                );
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: chips,
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CLOSE'),
        ),
        TextButton(
          onPressed: name.isNotEmpty ? () => _onSave(context) : null,
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}
