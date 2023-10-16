import 'dart:async' as async;

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:timebrew/models/timelog.dart';
import 'package:timebrew/services/isar_service.dart';

class TimerNotifier extends ChangeNotifier {
  final _isar = IsarService();
  final descriptionEditorController = TextEditingController();
  Id? _selectedTask;
  int _timeSinceStart = 0;
  Timelog? _trackingTimelog;

  late async.Timer _timer;

  TimerNotifier() {
    checkForRunningTask();
  }

  get timeSinceStart {
    return _timeSinceStart;
  }

  Id? get selectedTask {
    return _selectedTask;
  }

  get running {
    return _trackingTimelog != null;
  }

  setSelectedTask(selectedTask) {
    _selectedTask = selectedTask;
    notifyListeners();
  }

  void checkForRunningTask() async {
    Timelog? timelog = await _isar.getRunningTimeLog();

    if (timelog != null) {
      _trackingTimelog = timelog;
      _selectedTask = timelog.task.value?.id;
      descriptionEditorController.text = timelog.description;
      notifyListeners();

      startUpdatingTime();
    }
  }

  void startUpdatingTime() {
    const oneSec = Duration(seconds: 1);
    _timer = async.Timer.periodic(
      oneSec,
      (async.Timer timer) {
        _timeSinceStart =
            DateTime.now().millisecondsSinceEpoch - _trackingTimelog!.startTime;
        notifyListeners();
      },
    );
  }

  void startTracking() async {
    if (_selectedTask != null) {
      Timelog? timelog = await _isar.addTimelog(
          _selectedTask!, descriptionEditorController.text);
      if (timelog != null) {
        _trackingTimelog = timelog;

        notifyListeners();

        startUpdatingTime();
      }
    }
  }

  void stopTracking() {
    if (_trackingTimelog != null) {
      _timer.cancel();
      _trackingTimelog!.endTime = DateTime.now().millisecondsSinceEpoch;
      _trackingTimelog!.running = false;
      _isar.updateTimelog(_trackingTimelog!);
      _trackingTimelog = null;
      _timeSinceStart = 0;

      notifyListeners();

      descriptionEditorController.text = "";
    }
  }

  void toggleTracking() {
    if (_trackingTimelog != null) {
      stopTracking();
    } else {
      startTracking();
    }
  }
}
