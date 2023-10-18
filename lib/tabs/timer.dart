import 'dart:async' as async;
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:timebrew/models/task.dart';
import 'package:timebrew/models/timelog.dart';
import 'package:timebrew/services/isar_service.dart';

class Timer extends StatefulWidget {
  const Timer({super.key});

  @override
  State<Timer> createState() => _TimerState();
}

class _TimerState extends State<Timer> with AutomaticKeepAliveClientMixin {
  final _isar = IsarService();
  final descriptionEditorController = TextEditingController();
  Id? _selectedTask;
  int _timeSinceStart = 0;
  Timelog? _trackingTimelog;
  late async.Timer _timer;

  setSelectedTask(selectedTask) {
    setState(() {
      _selectedTask = selectedTask;
    });
  }

  void checkForRunningTask() async {
    Timelog? timelog = await _isar.getRunningTimeLog();

    if (timelog != null) {
      setState(() {
        _trackingTimelog = timelog;
        _selectedTask = timelog.task.value?.id;
      });
      descriptionEditorController.text = timelog.description;

      startUpdatingTime();
    }
  }

  void startUpdatingTime() {
    const oneSec = Duration(seconds: 1);
    _timer = async.Timer.periodic(
      oneSec,
      (async.Timer timer) {
        setState(() {
          _timeSinceStart = DateTime.now().millisecondsSinceEpoch -
              _trackingTimelog!.startTime;
        });
      },
    );
  }

  void startTracking() async {
    if (_selectedTask != null) {
      Timelog? timelog = await _isar.addTimelog(
          _selectedTask!, descriptionEditorController.text);
      if (timelog != null) {
        setState(() {
          _trackingTimelog = timelog;
        });

        startUpdatingTime();
      }
    }
  }

  void stopTracking() {
    if (_trackingTimelog != null) {
      setState(() {
        _timer.cancel();
        _trackingTimelog!.endTime = DateTime.now().millisecondsSinceEpoch;
        _trackingTimelog!.running = false;
        _isar.updateTimelog(_trackingTimelog!);
        _trackingTimelog = null;
        _timeSinceStart = 0;

        descriptionEditorController.text = "";
      });
    }
  }

  void toggleTracking() {
    if (_trackingTimelog != null) {
      stopTracking();
    } else {
      startTracking();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final running = _trackingTimelog != null;

    return Center(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  Duration(milliseconds: _timeSinceStart)
                      .toString()
                      .split('.')[0],
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton.filled(
                  iconSize: 36,
                  onPressed: _selectedTask != null ? toggleTracking : null,
                  icon: Icon(
                    running ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          enabled: !running,
                          controller: descriptionEditorController,
                          cursorHeight: 20,
                          style: const TextStyle(height: 1.2),
                          decoration: const InputDecoration(
                            labelText: 'Task Description',
                          ),
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
                              initialSelection: _selectedTask,
                              width: constraints.maxWidth,
                              enabled: !running,
                              enableFilter: false,
                              leadingIcon: const Icon(Icons.checklist_rounded),
                              label: const Text('Task'),
                              onSelected: (taskId) {
                                setSelectedTask(taskId);
                              },
                              dropdownMenuEntries: dropdownMenuEntries,
                            );
                          },
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(
                  height: 70,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
