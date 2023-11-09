import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:timebrew/extensions/hex_color.dart';
import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/tabs/tasks.dart';
import 'package:timebrew/utils.dart';

enum GroupBy { daysInMonth, weeksInMonth }

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  final isar = IsarService();
  List<List<MomentHours>> daysInWeeks = [];
  List<List<MomentHours>> monthsInQuaters = [];
  int outerIndex = 0;
  int innerIndex = 0;
  GroupBy groupBy = GroupBy.weeksInMonth;

  @override
  void initState() {
    super.initState();
    isar.getTimelogStream().listen((timelogs) {
      final (daysInWeeks, monthsInQuaters) = getStatsHours(timelogs);
      setState(() {
        this.daysInWeeks = daysInWeeks;
        if (daysInWeeks.isNotEmpty) {
          int finalInnerIndex = 0;

          outerIndex = daysInWeeks.length - 1;

          for (var i = 0; i < daysInWeeks[outerIndex].length; i++) {
            if (daysInWeeks[outerIndex][i].totalHours != 0) {
              finalInnerIndex = i;
            }
          }
          innerIndex = finalInnerIndex;
        }

        this.monthsInQuaters = monthsInQuaters;
      });
    });
  }

  void _selectNextMoment() {
    setState(() {
      if (innerIndex == daysInWeeks[outerIndex].length - 1) {
        if (outerIndex < daysInWeeks.length - 1) {
          outerIndex += 1;
          int finalInnerIndex = daysInWeeks[outerIndex].length - 1;
          for (var i = finalInnerIndex; i > 0; i--) {
            if (daysInWeeks[outerIndex][i].totalHours != 0) {
              finalInnerIndex = i;
            }
          }
          innerIndex = finalInnerIndex;
        }
      } else {
        if (innerIndex < daysInWeeks[outerIndex].length - 1) {
          int oldIndex = innerIndex;
          innerIndex += 1;

          while (innerIndex < daysInWeeks[outerIndex].length - 1 &&
              daysInWeeks[outerIndex][innerIndex].totalHours == 0.0) {
            innerIndex += 1;
          }
          if (daysInWeeks[outerIndex][innerIndex].totalHours == 0.0) {
            if (outerIndex < daysInWeeks.length - 1) {
              outerIndex += 1;
              int finalInnerIndex = daysInWeeks[outerIndex].length - 1;
              for (var i = finalInnerIndex; i > 0; i--) {
                if (daysInWeeks[outerIndex][i].totalHours != 0) {
                  finalInnerIndex = i;
                }
              }
              innerIndex = finalInnerIndex;
            } else {
              innerIndex = oldIndex;
            }
          }
        }
      }
    });
  }

  void _selectPreviousMoment() {
    setState(() {
      if (innerIndex == 0) {
        if (outerIndex > 0) {
          outerIndex -= 1;
          int finalInnerIndex = 0;
          for (var i = finalInnerIndex;
              i < daysInWeeks[outerIndex].length;
              i++) {
            if (daysInWeeks[outerIndex][i].totalHours != 0) {
              finalInnerIndex = i;
            }
          }
          innerIndex = finalInnerIndex;
        }
      } else {
        if (innerIndex > 0) {
          int oldIndex = innerIndex;

          innerIndex -= 1;

          while (innerIndex > 0 &&
              daysInWeeks[outerIndex][innerIndex].totalHours == 0.0) {
            innerIndex -= 1;
          }
          if (daysInWeeks[outerIndex][innerIndex].totalHours == 0.0) {
            if (outerIndex > 0) {
              outerIndex -= 1;
              int finalInnerIndex = 0;
              for (var i = finalInnerIndex;
                  i < daysInWeeks[outerIndex].length;
                  i++) {
                if (daysInWeeks[outerIndex][i].totalHours != 0) {
                  finalInnerIndex = i;
                }
              }
              innerIndex = finalInnerIndex;
            } else {
              innerIndex = oldIndex;
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String moment = '';
    List<MomentHours> moments = [];
    String timeSpent = '';
    if (daysInWeeks.isNotEmpty && daysInWeeks[outerIndex].isNotEmpty) {
      moment = daysInWeeks[outerIndex][innerIndex].moment;
      moments = daysInWeeks[outerIndex];
      timeSpent = millisecondsToReadable(
          hoursToMilliseconds(daysInWeeks[outerIndex][innerIndex].totalHours));
    }
    return ListView(
      children: [
        const SizedBox(
          height: 20,
        ),
        Center(
            child: Text(
          timeSpent,
          style: const TextStyle(
            fontSize: 25,
          ),
        )),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _selectPreviousMoment,
              icon: const Icon(Icons.arrow_left),
            ),
            Text(moment),
            IconButton(
              onPressed: _selectNextMoment,
              icon: const Icon(Icons.arrow_right),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          height: 150,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: BarChart(
              moments: moments,
              selectedMoment: innerIndex,
              onSelectedMomentChange: (moment) {
                setState(() {
                  innerIndex = moment;
                });
              },
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Builder(
          builder: (context) {
            if (daysInWeeks.isNotEmpty && daysInWeeks[outerIndex].isNotEmpty) {
              return MomentTasks(
                  momentHours: daysInWeeks[outerIndex][innerIndex]);
            } else {
              return Container();
            }
          },
        )
      ],
    );
  }
}

class MomentTasks extends StatefulWidget {
  final MomentHours momentHours;
  const MomentTasks({super.key, required this.momentHours});

  @override
  State<MomentTasks> createState() => _MomentTasksState();
}

class _MomentTasksState extends State<MomentTasks> {
  final isar = IsarService();

  @override
  Widget build(BuildContext context) {
    final taskHours = widget.momentHours.taskHours.entries
        .map((e) => (e.value, e.key))
        .toList();

    if (taskHours.isNotEmpty) {
      taskHours.sort((a, b) => b.$1.compareTo(a.$1));
    }
    return Column(children: [
      const Divider(
        height: 0,
      ),
      ...taskHours
          .map(
            (e) => FutureBuilder(
              future: isar.getTaskById(e.$2),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final task = snapshot.data!;
                  return Column(
                    children: [
                      TaskEntry(
                          name: task.name,
                          id: task.id,
                          milliseconds: hoursToMilliseconds(e.$1),
                          tags: task.tags.toList()),
                      const Divider(
                        height: 0,
                      )
                    ],
                  );
                }
                return Container();
              },
            ),
          )
          .toList()
    ]);
  }
}

class BarChart extends StatefulWidget {
  final List<MomentHours> moments;
  final Function(int) onSelectedMomentChange;
  final int selectedMoment;
  const BarChart({
    super.key,
    required this.selectedMoment,
    required this.moments,
    required this.onSelectedMomentChange,
  });

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var maxHours = 0.0;
    for (var moment in widget.moments) {
      if (moment.totalHours > maxHours) {
        maxHours = moment.totalHours;
      }
    }
    maxHours = roundToNearestMultipleOf5(maxHours.ceil()).toDouble();
    if (maxHours < 5) {
      maxHours = 5;
    }
    return Stack(children: [
      Transform.translate(
        offset: const Offset(0, -8),
        child: Transform.scale(
          scaleY: 1.05,
          child: Column(
            children: List.generate(
              5,
              (index) => Expanded(
                child: Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        height: 0,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${((maxHours / 5) * (5 - index)).toStringAsFixed(1)}h',
                      style: const TextStyle(fontSize: 9),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 35),
        child: Row(
          children: widget.moments
              .asMap()
              .entries
              .map(
                (entry) => Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Stack(
                            alignment: AlignmentDirectional.bottomStart,
                            clipBehavior: Clip.none,
                            children: [
                              const SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              FractionallySizedBox(
                                heightFactor:
                                    (entry.value.totalHours / maxHours),
                                widthFactor: 1,
                                child: Container(
                                  transform: Matrix4.translationValues(
                                    0.0,
                                    -22.0,
                                    0.0,
                                  ),
                                  child: Text(
                                    '${entry.value.totalHours.toStringAsFixed(1)}h',
                                    style: const TextStyle(fontSize: 9),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ),
                              FractionallySizedBox(
                                heightFactor: entry.value.totalHours / maxHours,
                                child: InkWell(
                                  onTap: () {
                                    widget.onSelectedMomentChange(entry.key);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        topRight: Radius.circular(4),
                                      ),
                                      color: widget.selectedMoment == entry.key
                                          ? Theme.of(context)
                                              .colorScheme
                                              .inversePrimary
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        entry.value.moment.split(',')[0],
                        style: const TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    ]);
  }
}
