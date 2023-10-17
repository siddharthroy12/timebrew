import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timebrew/models/task.dart';
import 'package:timebrew/notifiers/timer_notifier.dart';
import 'package:timebrew/services/isar_service.dart';

class Timer extends StatefulWidget {
  const Timer({super.key});

  @override
  State<Timer> createState() => _TimerState();
}

class _TimerState extends State<Timer> with AutomaticKeepAliveClientMixin {
  final _isar = IsarService();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final running = context.watch<TimerNotifier>().running;
    final timeSinceStart = context.watch<TimerNotifier>().timeSinceStart;
    final toggleTracking = context.watch<TimerNotifier>().toggleTracking;
    final descriptionEditorController =
        context.watch<TimerNotifier>().descriptionEditorController;
    final selectedTask = context.watch<TimerNotifier>().selectedTask;
    final setSelectedTask = context.watch<TimerNotifier>().setSelectedTask;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                Duration(milliseconds: timeSinceStart).toString().split('.')[0],
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton.filled(
                iconSize: 36,
                onPressed: selectedTask != null ? toggleTracking : null,
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
                                  value: task.id, label: task.name),
                            );
                          }

                          return DropdownMenu(
                            initialSelection: selectedTask,
                            width: constraints.maxWidth,
                            enabled: !running,
                            enableFilter: false,
                            leadingIcon: const Icon(Icons.checklist_rounded),
                            label: const Text('Task'),
                            onSelected: (taskId) {
                              setSelectedTask(taskId);
                            },
                            dropdownMenuEntries: dropdownMenuEntries,
                            inputDecorationTheme: const InputDecorationTheme(
                              isDense: true,
                            ),
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
    );
  }
}
