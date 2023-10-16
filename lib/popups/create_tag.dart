import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:timebrew/extensions/hex_color.dart';
import 'package:timebrew/models/tag.dart';
import 'package:timebrew/services/isar_service.dart';

class CreateTagDialog extends StatefulWidget {
  const CreateTagDialog({super.key, this.id});

  final Id? id;

  @override
  State<CreateTagDialog> createState() => _CreateTagDialogState();
}

class _CreateTagDialogState extends State<CreateTagDialog> {
  String name = "";
  List<String> options = [
    Colors.orange.toHex(),
    Colors.red.toHex(),
    Colors.pink.toHex(),
    Colors.green.toHex(),
    Colors.indigo.toHex()
  ];
  late String color;
  final isar = IsarService();
  var textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    color = options[0];

    if (widget.id != null) {
      loadTagData();
    }
  }

  void loadTagData() async {
    var tag = await isar.getTagById(widget.id!);
    if (tag != null) {
      setState(() {
        name = tag.name;
        color = tag.color;
        textFieldController.text = name;
      });
    }
  }

  List<Widget> _buidColorOptions() {
    final widgets = <Widget>[];
    for (String option in options) {
      widgets.add(Radio<String>(
        value: option,
        groupValue: color,
        onChanged: (String? value) {
          setState(() {
            color = value ?? '#ffffff';
          });
        },
        fillColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          return HexColor.fromHex(option);
        }),
      ));
    }
    return widgets;
  }

  void _onSave(BuildContext context) {
    if (widget.id != null) {
      isar.updateTag(Tag()
        ..id = widget.id!
        ..name = name
        ..color = color);
    } else {
      isar.addTag(name, color);
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
            widget.id == null ? 'Create Tag' : 'Update Tag',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(
            height: 20,
          ),
          TextField(
            controller: textFieldController,
            cursorHeight: 20,
            style: const TextStyle(height: 1.2),
            decoration: const InputDecoration(label: Text('Tag name')),
            onChanged: (String value) {
              setState(() {
                name = value;
              });
            },
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buidColorOptions(),
          )
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
