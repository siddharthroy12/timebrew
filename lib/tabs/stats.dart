import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:timebrew/models/task.dart';
import 'package:timebrew/models/timelog.dart';
import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/tabs/tasks.dart';
import 'package:timebrew/utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:timebrew/widgets/app_bar_menu_button.dart';
import 'package:timebrew/widgets/no_data_emoji.dart';
import 'package:timebrew/widgets/tag_filter.dart';

enum GroupBy { daysInMonth, weeksInMonth }

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  final _isar = IsarService();
  List<List<MomentHours>> _daysInWeeks = [];
  bool _isLoading = true;
  int _outerIndex = 0;
  int _innerIndex = 0;
  late Future<List<Timelog>> _timelogsFuture;
  late Future<List<Task>> _tasksFuture;
  Map<Id, Task> _tasks = {};
  PageController _controller = PageController();
  Id? _selectedTag;

  @override
  void initState() {
    super.initState();
    _onLoad();
  }

  @override
  void dispose() {
    super.dispose();
    _timelogsFuture.ignore();
    _tasksFuture.ignore();
  }

  void _onLoad() async {
    _timelogsFuture = _isar.getTimelogStream().first;
    _tasksFuture = _isar.getTaskStream().first;
    _loadTasks(await _tasksFuture);
    _loadDaysInWeeks(await _timelogsFuture);
    setState(() => _isLoading = false);
  }

  void _loadTasks(List<Task> tasks) {
    for (var task in tasks) {
      setState(() {
        _tasks[task.id] = task;
      });
    }
  }

  double _calculateMomentHoursTotal(MomentHours momentHours) {
    double result = 0;
    momentHours.taskHours.forEach((key, value) {
      if (_tasks[key]!.tags.any((element) => element.id == _selectedTag)) {
        result += value;
      }
    });
    return result;
  }

  void _loadDaysInWeeks(List<Timelog> timelogs) {
    if (mounted) {
      var (daysInWeeks, _) = getStatsHours(timelogs);
      setState(() {
        _daysInWeeks = daysInWeeks;
        if (daysInWeeks.isNotEmpty) {
          int finalInnerIndex = 0;
          int finalOuterIndex = 0;

          for (var outerIndex = daysInWeeks.length - 1;
              outerIndex >= 0;
              outerIndex--) {
            bool found = false;
            for (var innerIndex = daysInWeeks[outerIndex].length - 1;
                innerIndex >= 0;
                innerIndex--) {
              if (_calculateMomentHoursTotal(
                      _daysInWeeks[outerIndex][innerIndex]) !=
                  0) {
                finalInnerIndex = innerIndex;
                finalOuterIndex = outerIndex;
                found = true;
                break;
              }
            }
            if (found) {
              break;
            }
          }

          _outerIndex = finalOuterIndex;
          _controller = PageController(initialPage: _outerIndex);

          _innerIndex = finalInnerIndex;
        }
      });
    }
  }

  void _selectNextMoment() {
    setState(() {
      int previousOuterIndex = _outerIndex;
      if (_innerIndex == _daysInWeeks[_outerIndex].length - 1) {
        if (_outerIndex < _daysInWeeks.length - 1) {
          _outerIndex += 1;
        }
      } else {
        if (_innerIndex < _daysInWeeks[_outerIndex].length - 1) {
          int oldIndex = _innerIndex;
          _innerIndex += 1;

          while (_innerIndex < _daysInWeeks[_outerIndex].length - 1 &&
              _calculateMomentHoursTotal(
                      _daysInWeeks[_outerIndex][_innerIndex]) ==
                  0.0) {
            _innerIndex += 1;
          }
          if (_calculateMomentHoursTotal(
                  _daysInWeeks[_outerIndex][_innerIndex]) ==
              0.0) {
            if (_outerIndex < _daysInWeeks.length - 1) {
              _outerIndex += 1;
            } else {
              _innerIndex = oldIndex;
            }
          }
        }
      }
      if (previousOuterIndex < _outerIndex) {
        _innerIndex = 0;
      }

      _controller.animateToPage(
        _outerIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.linear,
      );
    });
  }

  void _selectPreviousMoment() {
    int previousOuterIndex = _outerIndex;
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
              _calculateMomentHoursTotal(
                      _daysInWeeks[_outerIndex][_innerIndex]) ==
                  0.0) {
            _innerIndex -= 1;
          }
          if (_calculateMomentHoursTotal(
                  _daysInWeeks[_outerIndex][_innerIndex]) ==
              0.0) {
            if (_outerIndex > 0) {
              _outerIndex -= 1;
            } else {
              _innerIndex = oldIndex;
            }
          }
        }
      }
      if (previousOuterIndex > _outerIndex) {
        _innerIndex = _daysInWeeks[_outerIndex].length - 1;
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    String moment = '';
    String timeSpent = '';
    Widget? chart;
    if (_daysInWeeks.isNotEmpty && _daysInWeeks[_outerIndex].isNotEmpty) {
      moment = _daysInWeeks[_outerIndex][_innerIndex].moment;
      timeSpent = millisecondsToReadable(hoursToMilliseconds(
          _calculateMomentHoursTotal(_daysInWeeks[_outerIndex][_innerIndex])));
      chart = MomentRingChart(
        momentHours: _daysInWeeks[_outerIndex][_innerIndex],
      );
    }

    if (_daysInWeeks.isEmpty) {
      return const NoDataEmoji();
    }

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('Stats'),
        actions: const [
          AppBarMenuButton(),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(55),
          child: SizedBox(
            height: 55,
            child: Column(
              children: [
                Expanded(
                  child: TagFilter(
                    initialSelectedTag: _selectedTag,
                    onSelectedTagChange: (tag) {
                      setState(() {
                        _selectedTag = tag;
                      });
                    },
                  ),
                ),
                const Divider(
                  height: 0,
                )
              ],
            ),
          ),
        ),
      ),
      body: ListView(
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
              onPageChanged: (newOuterIndex) {
                setState(() {
                  _outerIndex = newOuterIndex;
                  if (_innerIndex == 0) {
                    int finalInnerIndex = 0;
                    for (var i = finalInnerIndex;
                        i < _daysInWeeks[_outerIndex].length;
                        i++) {
                      if (_calculateMomentHoursTotal(
                              _daysInWeeks[_outerIndex][i]) !=
                          0) {
                        finalInnerIndex = i;
                        break;
                      }
                    }
                    _innerIndex = finalInnerIndex;
                  } else if (_outerIndex <
                      _daysInWeeks[_outerIndex].length - 1) {
                    int finalInnerIndex = _daysInWeeks[_outerIndex].length - 1;
                    for (var i = finalInnerIndex; i > 0; i--) {
                      if (_calculateMomentHoursTotal(
                              _daysInWeeks[_outerIndex][i]) !=
                          0) {
                        finalInnerIndex = i;
                        break;
                      }
                    }
                    _innerIndex = finalInnerIndex;
                  }
                });
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
                  selectedTag: _selectedTag,
                  momentHours: _daysInWeeks[_outerIndex][_innerIndex],
                );
              } else {
                return Container();
              }
            },
          )
        ],
      ),
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
  late Future _calculateNamesFuture;

  @override
  void initState() {
    super.initState();
    _calculateNamesFuture = _calculateNames();
  }

  @override
  void didUpdateWidget(covariant MomentRingChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _calculateNamesFuture = _calculateNames();
  }

  Future _calculateNames() async {
    for (var element in widget.momentHours.taskHours.entries) {
      var value = await isar.getTaskById(element.key);
      setState(() {
        names[element.key] = value?.name ?? 'dsf';
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _calculateNamesFuture.ignore();
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
  final Id? selectedTag;
  const MomentTasks({
    super.key,
    required this.momentHours,
    required this.selectedTag,
  });

  @override
  State<MomentTasks> createState() => _MomentTasksState();
}

class _MomentTasksState extends State<MomentTasks> {
  final isar = IsarService();

  @override
  Widget build(BuildContext context) {
    final taskHours = widget.momentHours.taskHours.entries
        .where((element) {
          if (widget.selectedTag == null) {
            return true;
          } else {
            return element.key == widget.selectedTag;
          }
        })
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
                  return TaskEntry(
                    name: task.name,
                    id: task.id,
                    milliseconds: hoursToMilliseconds(e.$1),
                    tags: task.tags.toList(),
                    link: task.link,
                    timelogs: widget.momentHours.taskTimelogs[e.$2]!,
                    showExpansion: true,
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

    return Stack(
      children: [
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
            children: widget.moments.asMap().entries.map(
              (entry) {
                var fractionHeight = (entry.value.totalHours / maxHours);

                if (entry.value.totalHours > 0 && fractionHeight < 0.02) {
                  fractionHeight = 0.02;
                }

                var timeText = millisecondsToReadable(
                    (entry.value.totalHours * Duration.millisecondsPerHour)
                        .toInt(),
                    compact: true);

                return Expanded(
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
                                heightFactor: fractionHeight,
                                widthFactor: 1,
                                child: Container(
                                  transform: Matrix4.translationValues(
                                    0.0,
                                    -22.0,
                                    0.0,
                                  ),
                                  child: Text(
                                    timeText,
                                    style: const TextStyle(fontSize: 9),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ),
                              FractionallySizedBox(
                                heightFactor: fractionHeight,
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
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }
}
