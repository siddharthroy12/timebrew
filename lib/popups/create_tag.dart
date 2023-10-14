import 'package:flutter/material.dart';
import 'package:timebrew/extensions/hex_color.dart';

class CreateTagDialog extends StatefulWidget {
  const CreateTagDialog({super.key});

  @override
  State<CreateTagDialog> createState() => _CreateTagDialogState();
}

class _CreateTagDialogState extends State<CreateTagDialog> {
  String name = "";
  List<String> options = [
    Colors.orange.toHex(),
    Colors.red.toHex(),
    Colors.blue.toHex(),
    Colors.green.toHex(),
    Colors.white.toHex()
  ];
  late String? color;

  @override
  void initState() {
    super.initState();
    color = options[0];
  }

  List<Widget> _buidColorOptions() {
    final widgets = <Widget>[];
    for (String option in options) {
      widgets.add(Radio<String>(
        value: option,
        groupValue: color,
        onChanged: (String? value) {
          setState(() {
            color = value;
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 10,
          ),
          TextField(
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
          onPressed: name.isNotEmpty ? () => Navigator.of(context).pop() : null,
          child: const Text('ADD'),
        ),
      ],
    );
  }
}
