import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:timebrew/extensions/hex_color.dart';
import 'package:timebrew/models/tag.dart';
import 'package:timebrew/services/isar_service.dart';

class CreateTaskDialog extends StatefulWidget {
  const CreateTaskDialog({super.key, this.id});

  final Id? id;

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final isar = IsarService();
  var textFieldController = TextEditingController();

  String name = "";
  List<int> selectedTags = [];
  List<Tag> tags = [];

  @override
  void initState() {
    super.initState();
    isar.getTagList().then((value) {
      setState(() {
        tags = value;
      });
    });
    if (widget.id != null) {
      loadTaskData();
    }
  }

  void loadTaskData() async {
    var task = await isar.getTaskById(widget.id!);
    if (task != null) {
      setState(() {
        name = task.name;
        selectedTags = task.tags.map((e) => e.id).toList();
        textFieldController.text = name;
      });
    }
  }

  void _onSave(BuildContext context) async {
    if (widget.id != null) {
      isar.updateTask(widget.id!, name, selectedTags);
    } else {
      isar.addTask(name, selectedTags);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
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
            controller: textFieldController,
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
          Builder(builder: (context) {
            List<Widget> dropdownMenuEntries = [];
            for (Tag tag in tags) {
              bool selected = selectedTags.contains(tag.id);
              dropdownMenuEntries.add(
                FilterChip(
                  visualDensity: VisualDensity.standard,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  color: MaterialStateProperty.resolveWith((states) {
                    return HexColor.fromHex(tag.color);
                  }),
                  side: const BorderSide(width: 0, color: Colors.transparent),
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
                  label: Text('#${tag.name}'),
                ),
              );
            }

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: dropdownMenuEntries,
            );
          }),
        ],
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
