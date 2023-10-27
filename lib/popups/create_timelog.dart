import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:timebrew/extensions/date_time.dart';
import 'package:timebrew/models/task.dart';
import 'package:timebrew/models/timelog.dart';
import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/utils.dart';

class CreateTimelogDialog extends StatefulWidget {
  const CreateTimelogDialog({super.key, this.id});

  final Id? id;

  @override
  State<CreateTimelogDialog> createState() => _CreateTimelogDialogState();
}

class _CreateTimelogDialogState extends State<CreateTimelogDialog> {
  Task? _task;
  int _startTime = DateTime.now().millisecondsSinceEpoch;
  int _endTime = DateTime.now().millisecondsSinceEpoch;
  final _isar = IsarService();
  final _descriptionFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.id != null) {
      loadTimelogData();
    }
  }

  void loadTimelogData() async {
    var timelog = await _isar.getTimelogById(widget.id!);
    if (timelog != null) {
      setState(() {
        _descriptionFieldController.text = timelog.description;
        _task = timelog.task.value;
        _startTime = timelog.startTime;
        _endTime = timelog.endTime;
      });
    }
  }

  void _onSave(BuildContext context) {
    if (widget.id != null) {
      _isar.updateTimelog(Timelog()
        ..id = widget.id!
        ..description = _descriptionFieldController.text
        ..task.value = _task
        ..startTime = _startTime
        ..endTime = _endTime
        ..running = false);
    } else {
      if (_task != null) {
        _isar.addTimelog(_task!.id, _descriptionFieldController.text,
            _startTime, _endTime, false);
      }
    }
    Navigator.of(context).pop();
  }

  void _setDate(DateTime? date) {
    if (date != null) {
      var startTime = DateTime.fromMillisecondsSinceEpoch(_startTime);
      startTime = startTime.copyWith(
        year: date.year,
        month: date.month,
        day: date.day,
      );
      var endTime = DateTime.fromMillisecondsSinceEpoch(_startTime);
      endTime = endTime.copyWith(
        year: date.year,
        month: date.month,
        day: date.day,
      );

      setState(() {
        _startTime = startTime.millisecondsSinceEpoch;
        _endTime = endTime.millisecondsSinceEpoch;
      });
    }
  }

  void _setStartTime(TimeOfDay? timeOfDay) {
    if (timeOfDay != null) {
      setState(() {
        _startTime = DateTime.fromMillisecondsSinceEpoch(_startTime)
            .copyWith(
                hour: timeOfDay.hour,
                minute: timeOfDay.minute,
                second: 0,
                millisecond: 0,
                microsecond: 0)
            .millisecondsSinceEpoch;
      });
    }
  }

  void _setEndTime(TimeOfDay? timeOfDay) {
    if (timeOfDay != null) {
      setState(() {
        _endTime = DateTime.fromMillisecondsSinceEpoch(_endTime)
            .copyWith(
                hour: timeOfDay.hour,
                minute: timeOfDay.minute,
                second: 0,
                millisecond: 0,
                microsecond: 0)
            .millisecondsSinceEpoch;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: LayoutBuilder(builder: (context, constrains) {
            bool shouldShowTimeIcon = MediaQuery.of(context).size.width > 450;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  widget.id == null ? 'Add Timelog' : 'Update Timelog',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 20,
                ),
                StreamBuilder<List<Task>>(
                  initialData: const [],
                  stream: _isar.getTaskStream(),
                  builder: (context, tasks) {
                    List<DropdownMenuEntry> dropdownMenuEntries = [];

                    for (var task in tasks.data!) {
                      dropdownMenuEntries.add(
                        DropdownMenuEntry(
                          value: task.id,
                          label: task.name,
                          style: ButtonStyle(
                            padding: MaterialStateProperty.resolveWith(
                              (states) => const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return DropdownMenu(
                      initialSelection: _task?.id,
                      width: constrains.maxWidth,
                      menuHeight: 300,
                      enableFilter: false,
                      leadingIcon: const Icon(Icons.checklist_rounded),
                      label: const Text('Task'),
                      onSelected: (taskId) async {
                        var task = await _isar.getTaskById(taskId);

                        setState(() => _task = task);
                      },
                      dropdownMenuEntries: dropdownMenuEntries,
                    );
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: _descriptionFieldController,
                  cursorHeight: 20,
                  style: const TextStyle(height: 1.2),
                  decoration: const InputDecoration(label: Text('Description')),
                  onChanged: (String value) {
                    setState(() {
                      _descriptionFieldController.text = value;
                    });
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: DateTime.fromMillisecondsSinceEpoch(
                        _endTime,
                      ),
                      firstDate: DateTime.fromMillisecondsSinceEpoch(
                        _endTime,
                      ).subtract(
                        const Duration(days: 30),
                      ),
                      lastDate: DateTime.now(),
                    ).then(_setDate);
                  },
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: Text(
                    DateTime.fromMillisecondsSinceEpoch(_endTime)
                        .toDateString(),
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.resolveWith(
                      (states) => const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                    ),
                    minimumSize: MaterialStateProperty.resolveWith(
                      (states) => const Size.fromHeight(50),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              DateTime.fromMillisecondsSinceEpoch(_startTime),
                            ),
                          ).then(_setStartTime);
                        },
                        icon: shouldShowTimeIcon
                            ? const Icon(Icons.access_time_rounded)
                            : Container(),
                        label: Text(millisecondsToTime(_startTime)),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.resolveWith(
                            (states) => const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                          ),
                          minimumSize: MaterialStateProperty.resolveWith(
                            (states) => const Size.fromHeight(50),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                      child: Icon(Icons.arrow_forward_rounded),
                    ),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                              DateTime.fromMillisecondsSinceEpoch(_endTime),
                            ),
                          ).then(_setEndTime);
                        },
                        icon: shouldShowTimeIcon
                            ? const Icon(Icons.access_time_rounded)
                            : Container(),
                        label: Text(millisecondsToTime(_endTime)),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.resolveWith(
                            (states) => const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                          ),
                          minimumSize: MaterialStateProperty.resolveWith(
                            (states) => const Size.fromHeight(50),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            );
          }),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CLOSE'),
        ),
        TextButton(
          onPressed: _task != null ? () => _onSave(context) : null,
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}
