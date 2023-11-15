import 'dart:async' as async;
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:timebrew/models/task.dart';
import 'package:timebrew/models/timelog.dart';
import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/utils.dart';

enum TimerState { stopped, running, paused }

class Timer extends StatefulWidget {
  final Map<Id, bool> selectedTags;

  const Timer({super.key, required this.selectedTags});

  @override
  State<Timer> createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  final _isar = IsarService();
  final _descriptionEditorController = TextEditingController();
  Id? _selectedTask;
  int _timeSinceStart = 0;
  Timelog? _trackingTimelog;
  async.Timer? _timer;
  TimerState _timerState = TimerState.stopped;
  int _pausedTimelogsTimespent = 0;

  @override
  initState() {
    super.initState();
    _initTimerState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }

  _setSelectedTask(selectedTask) {
    setState(() {
      _selectedTask = selectedTask;
    });
  }

  void _initTimerState() async {
    var pausedTimelogs = await _isar.getPausedTimelogs();
    if (pausedTimelogs.isNotEmpty) {
      Timelog latestTimelog = pausedTimelogs.first;

      for (var timelog in pausedTimelogs) {
        _pausedTimelogsTimespent += getTimelogTimeSpent(timelog);
        if (timelog.endTime > latestTimelog.endTime) {
          latestTimelog = timelog;
        }
      }
      setState(() {
        _trackingTimelog = latestTimelog;
        _selectedTask = latestTimelog.task.value?.id;
        _timerState = TimerState.paused;
        _timeSinceStart = _pausedTimelogsTimespent;
      });
    }

    Timelog? runningTimelog = await _isar.getRunningTimelog();

    if (runningTimelog != null) {
      setState(() {
        _trackingTimelog = runningTimelog;
        _selectedTask = runningTimelog.task.value?.id;
        _timerState = TimerState.running;
      });
      _descriptionEditorController.text = runningTimelog.description;

      _startUpdatingTime();
    }
  }

  void _updateTime() {
    setState(() {
      _timeSinceStart = _pausedTimelogsTimespent +
          DateTime.now().millisecondsSinceEpoch -
          _trackingTimelog!.startTime;
    });
  }

  void _startUpdatingTime() {
    const oneSec = Duration(seconds: 1);
    _timer = async.Timer.periodic(
      oneSec,
      (async.Timer timer) {
        _updateTime();
      },
    );
  }

  void _startTracking() async {
    if (_selectedTask != null) {
      var now = DateTime.now().millisecondsSinceEpoch;
      Timelog? timelog = await _isar.addTimelog(
        _selectedTask!,
        _descriptionEditorController.text,
        now,
        now,
        true,
      );
      if (timelog != null) {
        setState(() {
          _trackingTimelog = timelog;
          _timerState = TimerState.running;
        });

        _startUpdatingTime();
      }
    }
  }

  void _stopTracking() async {
    if (_trackingTimelog != null) {
      setState(() {
        if (_timer != null && _timer!.isActive) {
          _timer!.cancel();
        }
        _pausedTimelogsTimespent = 0;
        _trackingTimelog!.endTime = DateTime.now().millisecondsSinceEpoch;
        _trackingTimelog!.running = false;
        _trackingTimelog!.paused = false;

        _timeSinceStart = 0;
        _timerState = TimerState.stopped;
        _descriptionEditorController.text = "";
      });
      await _isar.updateTimelog(_trackingTimelog!);
      _trackingTimelog = null;
      await _isar.unPauseAllTimelogs();
    }
  }

  void _pauseTracking() async {
    if (_trackingTimelog != null) {
      setState(() {
        if (_timer != null && _timer!.isActive) {
          _timer!.cancel();
        }
        _pausedTimelogsTimespent += _timeSinceStart;
        _trackingTimelog!.endTime = DateTime.now().millisecondsSinceEpoch;
        _trackingTimelog!.running = false;
        _trackingTimelog!.paused = true;

        _timerState = TimerState.paused;
      });
      await _isar.updateTimelog(_trackingTimelog!);
    }
  }

  void _resumeTracking() async {
    if (_selectedTask != null) {
      var now = DateTime.now().millisecondsSinceEpoch;
      Timelog? timelog = await _isar.addTimelog(
        _selectedTask!,
        _descriptionEditorController.text,
        now,
        now,
        true,
      );
      await _isar.updateTimelog(_trackingTimelog!);
      setState(() {
        _trackingTimelog = timelog;
        _timerState = TimerState.running;
      });
      _startUpdatingTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonPadding = MaterialStateProperty.resolveWith(
      (states) => const EdgeInsets.only(
        top: 16,
        bottom: 16,
        left: 16,
        right: 6 + 16,
      ),
    );

    return Center(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Builder(builder: (context) {
                  final durations = Duration(milliseconds: _timeSinceStart)
                      .toString()
                      .split('.')[0]
                      .split(':');

                  const durationTextStyle = TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  );
                  const duration = Duration(milliseconds: 200);
                  const curve = Curves.decelerate;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedFlipCounter(
                        duration: duration,
                        curve: curve,
                        value: int.parse(durations[0]),
                        wholeDigits: 2,
                        textStyle: durationTextStyle,
                      ),
                      const Text(':', style: durationTextStyle),
                      AnimatedFlipCounter(
                        duration: duration,
                        curve: curve,
                        value: int.parse(durations[1]),
                        wholeDigits: 2,
                        textStyle: durationTextStyle,
                      ),
                      const Text(':', style: durationTextStyle),
                      AnimatedFlipCounter(
                        duration: duration,
                        curve: curve,
                        value: int.parse(durations[2]),
                        wholeDigits: 2,
                        textStyle: durationTextStyle,
                      ),
                    ],
                  );
                }),
                ..._timerState != TimerState.stopped
                    ? [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _timerState == TimerState.paused
                                ? FilledButton.icon(
                                    style: ButtonStyle(
                                      padding: buttonPadding,
                                    ),
                                    onPressed: _resumeTracking,
                                    icon: const Icon(
                                      Icons.play_arrow_rounded,
                                    ),
                                    label: const Text('Resume'),
                                  )
                                : FilledButton.icon(
                                    style: ButtonStyle(
                                      padding: buttonPadding,
                                    ),
                                    onPressed: _pauseTracking,
                                    icon: const Icon(
                                      Icons.pause_rounded,
                                    ),
                                    label: const Text('Pause'),
                                  ),
                            const SizedBox(
                              width: 10,
                            ),
                            FilledButton.icon(
                              style: ButtonStyle(
                                padding: buttonPadding,
                                backgroundColor:
                                    MaterialStateProperty.resolveWith(
                                  (states) =>
                                      Theme.of(context).colorScheme.error,
                                ),
                                foregroundColor:
                                    MaterialStateProperty.resolveWith(
                                  (states) =>
                                      Theme.of(context).colorScheme.onError,
                                ),
                              ),
                              onPressed: _stopTracking,
                              icon: const Icon(
                                Icons.stop_rounded,
                              ),
                              label: const Text('Stop'),
                            ),
                          ],
                        ),
                      ]
                    : [
                        FilledButton.icon(
                          style: ButtonStyle(
                            padding: buttonPadding,
                          ),
                          onPressed:
                              _selectedTask != null ? _startTracking : null,
                          icon: const Icon(
                            Icons.play_arrow_rounded,
                          ),
                          label: const Text('Start'),
                        ),
                      ],
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          StreamBuilder<List<Task>>(
                            initialData: const [],
                            stream: _isar.getTaskStream(),
                            builder: (context, tasks) {
                              List<DropdownMenuEntry> dropdownMenuEntries = [];

                              for (var task in tasks.data!) {
                                if (task.tags
                                    .where((element) =>
                                        widget.selectedTags[element.id] ??
                                        false)
                                    .isNotEmpty) {
                                  dropdownMenuEntries.add(
                                    DropdownMenuEntry(
                                      value: task.id,
                                      label: task.name,
                                      style: ButtonStyle(
                                        padding:
                                            MaterialStateProperty.resolveWith(
                                          (states) =>
                                              const EdgeInsets.symmetric(
                                            horizontal: 40,
                                            vertical: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }

                              if (dropdownMenuEntries.isEmpty) {
                                dropdownMenuEntries.add(
                                  DropdownMenuEntry(
                                    enabled: false,
                                    value: -1,
                                    label: 'No task available',
                                    style: ButtonStyle(
                                      padding:
                                          MaterialStateProperty.resolveWith(
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
                                menuHeight: 300,
                                enabled: _timerState == TimerState.stopped,
                                enableFilter: false,
                                leadingIcon:
                                    const Icon(Icons.checklist_rounded),
                                label: const Text('Task'),
                                onSelected: (taskId) {
                                  _setSelectedTask(taskId);
                                },
                                dropdownMenuEntries: dropdownMenuEntries,
                              );
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextField(
                            enabled: _timerState == TimerState.stopped,
                            controller: _descriptionEditorController,
                            cursorHeight: 20,
                            style: const TextStyle(height: 1.2),
                            decoration: const InputDecoration(
                              labelText: 'Task Description',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
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
