import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/tabs/tasks.dart';
import 'package:timebrew/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:timebrew/widgets/no_data_emoji.dart';

enum GroupBy { daysInMonth, weeksInMonth }

class Stats extends StatefulWidget {
  final Map<Id, bool> selectedTags;

  const Stats({super.key, required this.selectedTags});

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  final _isar = IsarService();
  List<List<MomentHours>> _daysInWeeks = [];
  int _outerIndex = 0;
  int _innerIndex = 0;
  PageController _controller = PageController();

  @override
  void initState() {
    super.initState();

    _isar.getTimelogStream().first.then(_loadDaysInWeeks);
  }

  void _loadDaysInWeeks(timelogs) {
    var (daysInWeeks, _) = getStatsHours(timelogs, widget.selectedTags);
    setState(() {
      _daysInWeeks = daysInWeeks;
      if (daysInWeeks.isNotEmpty) {
        int finalInnerIndex = 0;

        _outerIndex = daysInWeeks.length - 1;
        _controller = PageController(initialPage: _outerIndex);

        for (var i = 0; i < daysInWeeks[_outerIndex].length; i++) {
          if (daysInWeeks[_outerIndex][i].totalHours != 0) {
            finalInnerIndex = i;
          }
        }
        _innerIndex = finalInnerIndex;
      }
    });
  }

  @override
  void didUpdateWidget(covariant Stats oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isar.getTimelogStream().first.then(_loadDaysInWeeks);
  }

  void _selectNextMoment() {
    setState(() {
      if (_innerIndex == _daysInWeeks[_outerIndex].length - 1) {
        if (_outerIndex < _daysInWeeks.length - 1) {
          _outerIndex += 1;
        }
      } else {
        if (_innerIndex < _daysInWeeks[_outerIndex].length - 1) {
          int oldIndex = _innerIndex;
          _innerIndex += 1;

          while (_innerIndex < _daysInWeeks[_outerIndex].length - 1 &&
              _daysInWeeks[_outerIndex][_innerIndex].totalHours == 0.0) {
            _innerIndex += 1;
          }
          if (_daysInWeeks[_outerIndex][_innerIndex].totalHours == 0.0) {
            if (_outerIndex < _daysInWeeks.length - 1) {
              _outerIndex += 1;
              int finalInnerIndex = _daysInWeeks[_outerIndex].length - 1;
              for (var i = finalInnerIndex; i > 0; i--) {
                if (_daysInWeeks[_outerIndex][i].totalHours != 0) {
                  finalInnerIndex = i;
                }
              }
              _innerIndex = finalInnerIndex;
            } else {
              _innerIndex = oldIndex;
            }
          }
        }
      }
      _controller.animateToPage(
        _outerIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.linear,
      );
    });
  }

  void _selectPreviousMoment() {
    setState(() {
      if (_innerIndex == 0) {
        if (_outerIndex > 0) {
          _outerIndex -= 1;
        }
      } else {
        if (_innerIndex > 0) {
          int oldIndex = _innerIndex;

          _innerIndex -= 1;

          while (_innerIndex > 0 &&
              _daysInWeeks[_outerIndex][_innerIndex].totalHours == 0.0) {
            _innerIndex -= 1;
          }
          if (_daysInWeeks[_outerIndex][_innerIndex].totalHours == 0.0) {
            if (_outerIndex > 0) {
              _outerIndex -= 1;
              int finalInnerIndex = 0;
              for (var i = finalInnerIndex;
                  i < _daysInWeeks[_outerIndex].length;
                  i++) {
                if (_daysInWeeks[_outerIndex][i].totalHours != 0) {
                  finalInnerIndex = i;
                }
              }
              _innerIndex = finalInnerIndex;
            } else {
              _innerIndex = oldIndex;
            }
          }
        }
      }
      _controller.animateToPage(
        _outerIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.linear,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    String moment = '';
    String timeSpent = '';
    Widget? chart;
    if (_daysInWeeks.isNotEmpty && _daysInWeeks[_outerIndex].isNotEmpty) {
      moment = _daysInWeeks[_outerIndex][_innerIndex].moment;
      timeSpent = millisecondsToReadable(hoursToMilliseconds(
          _daysInWeeks[_outerIndex][_innerIndex].totalHours));
      chart = MomentRingChart(
        momentHours: _daysInWeeks[_outerIndex][_innerIndex],
      );
    }

    if (_daysInWeeks.isEmpty) {
      return const NoDataEmoji();
    }

    return ListView(
      children: [
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              chart ?? Container(),
              Center(
                child: Text(
                  timeSpent,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
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
            Text(
              moment,
              style: const TextStyle(fontSize: 18),
            ),
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
          height: 150, // Card height
          child: PageView.builder(
            itemCount: _daysInWeeks.length,
            controller: _controller,
            onPageChanged: (value) {
              if (_outerIndex < value) {
                setState(() {
                  _outerIndex = value;

                  int finalInnerIndex = _daysInWeeks[_outerIndex].length - 1;
                  for (var i = finalInnerIndex; i > 0; i--) {
                    if (_daysInWeeks[_outerIndex][i].totalHours != 0) {
                      finalInnerIndex = i;
                    }
                  }
                  _innerIndex = finalInnerIndex;
                });
              } else if (_outerIndex > value) {
                setState(() {
                  _outerIndex = value;
                  int finalInnerIndex = 0;
                  for (var i = finalInnerIndex;
                      i < _daysInWeeks[_outerIndex].length;
                      i++) {
                    if (_daysInWeeks[_outerIndex][i].totalHours != 0) {
                      finalInnerIndex = i;
                    }
                  }
                  _innerIndex = finalInnerIndex;
                });
              }
            },
            itemBuilder: (context, index) {
              return ListenableBuilder(
                listenable: _controller,
                builder: (context, child) {
                  List<MomentHours> moments = _daysInWeeks[index];

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BarChart(
                      moments: moments,
                      selectedMoment: _outerIndex == index ? _innerIndex : -1,
                      onSelectedMomentChange: (moment) {
                        setState(() {
                          _innerIndex = moment;
                        });
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Builder(
          builder: (context) {
            if (_daysInWeeks.isNotEmpty &&
                _daysInWeeks[_outerIndex].isNotEmpty) {
              return MomentTasks(
                momentHours: _daysInWeeks[_outerIndex][_innerIndex],
              );
            } else {
              return Container();
            }
          },
        )
      ],
    );
  }
}

class MomentRingChart extends StatefulWidget {
  final MomentHours momentHours;

  const MomentRingChart({super.key, required this.momentHours});

  @override
  State<MomentRingChart> createState() => _MomentRingChartState();
}

class _MomentRingChartState extends State<MomentRingChart> {
  final isar = IsarService();
  Map<Id, String> names = {};

  @override
  void initState() {
    super.initState();
    _calculateNames();
  }

  @override
  void didUpdateWidget(covariant MomentRingChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _calculateNames();
  }

  void _calculateNames() {
    for (var element in widget.momentHours.taskHours.entries) {
      isar.getTaskById(element.key).then((value) {
        setState(() {
          names[element.key] = value?.name ?? 'dsf';
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      palette: const [
        Colors.orange,
        Colors.red,
        Colors.brown,
        Colors.green,
        Colors.indigo,
        Colors.purple,
        Colors.teal
      ],
      series: [
        DoughnutSeries(
          animationDuration: 500,
          radius: '60%',
          innerRadius: '90%',
          dataSource: widget.momentHours.taskHours.entries.toList(),
          xValueMapper: (var data, _) => data.key,
          yValueMapper: (var data, _) => data.value,
          dataLabelMapper: (var data, _) => names[data.key] ?? '',
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(color: Colors.white),
            alignment: ChartAlignment.far,
            labelAlignment: ChartDataLabelAlignment.outer,
            labelPosition: ChartDataLabelPosition.outside,
            connectorLineSettings: ConnectorLineSettings(),
          ),
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
                        tags: task.tags.toList(),
                        link: task.link,
                      ),
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
  final int? selectedMoment;
  const BarChart({
    super.key,
    this.selectedMoment,
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
                      '${(maxHours * ((4 - index) / 4)).toStringAsFixed(1)}h',
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
