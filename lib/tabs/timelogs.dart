import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:timebrew/extensions/date_time.dart';
import 'package:timebrew/models/timelog.dart';
import 'package:timebrew/popups/confirm_delete.dart';
import 'package:timebrew/popups/create_timelog.dart';
import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/widgets/app_bar_menu_button.dart';
import 'package:timebrew/widgets/conditional.dart';
import 'package:timebrew/widgets/no_data_emoji.dart';
import 'package:timebrew/utils.dart';
import 'package:timebrew/widgets/tag_filter.dart';

class Timelogs extends StatefulWidget {
  final Id? selectedTask;

  const Timelogs({
    super.key,
    this.selectedTask,
  });

  @override
  State<Timelogs> createState() => _TimelogsState();
}

class _TimelogsState extends State<Timelogs>
    with AutomaticKeepAliveClientMixin {
  Id? _selectedTag;
  final _isar = IsarService();
  Map<String, List<Timelog>> _groupedTimelogs = {};
  final ScrollController _dateScrollController = ScrollController();
  List<String> _dates = [];
  String selectedDate = 'Logs';
  bool _isLoading = true;
  int _minDateTimestamp = 0;
  int _maxDateTimestamp = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTimelogs();
  }

  void _loadTimelogs() {
    _isar.getTimelogStream().listen((timelogs) {
      if (timelogs.isNotEmpty) {
        final Map<String, List<Timelog>> groupedTimelogs = {};
        final List<String> dates = [];

        // Group timelogs and Calculate minimum and maximum date
        if (timelogs.isNotEmpty) {
          _minDateTimestamp = timelogs.first.endTime;
          _maxDateTimestamp = timelogs.first.endTime;
        }
        for (var timelog in timelogs) {
          if (timelog.endTime < _minDateTimestamp) {
            _minDateTimestamp = timelog.endTime;
          }

          if (timelog.endTime > _maxDateTimestamp) {
            _maxDateTimestamp = timelog.endTime;
          }

          final dateTimeString =
              DateTime.fromMillisecondsSinceEpoch(timelog.endTime)
                  .toDateString();
          if (groupedTimelogs.containsKey(dateTimeString)) {
            groupedTimelogs[dateTimeString]!.add(timelog);
          } else {
            groupedTimelogs[dateTimeString] = [timelog];
          }
        }

        _minDateTimestamp -= Duration.millisecondsPerDay * 30;

        for (var currentDate =
                DateTime.fromMillisecondsSinceEpoch(_maxDateTimestamp);
            currentDate.millisecondsSinceEpoch >= _minDateTimestamp;
            currentDate = currentDate.subtract(const Duration(days: 1))) {
          final dateTimeString = currentDate.toDateString();
          dates.add(dateTimeString);
        }

        selectedDate = DateTime.fromMillisecondsSinceEpoch(_maxDateTimestamp)
            .toDateString();
        setState(() {
          _groupedTimelogs = groupedTimelogs;
          _dates = dates;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    bool hasData = _groupedTimelogs.isNotEmpty;

    PreferredSize? bottomWidget;

    if (hasData) {
      bottomWidget = PreferredSize(
        preferredSize: const Size.fromHeight(114),
        child: SizedBox(
          height: 114,
          child: Column(
            children: [
              SizedBox(
                height: 60,
                child: Listener(
                  onPointerSignal: (event) {
                    if (event is PointerScrollEvent) {
                      final offset = event.scrollDelta.dy;
                      _dateScrollController
                          .jumpTo(_dateScrollController.offset + offset);
                    }
                  },
                  child: ListView.separated(
                    controller: _dateScrollController,
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    itemCount: _dates.length,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    separatorBuilder: (c, i) => const SizedBox(
                      width: 10,
                    ),
                    itemBuilder: (context, index) {
                      final [month, date] =
                          _dates[index].split(',').first.split(' ');
                      return SizedBox(
                        width: 35,
                        child: Material(
                          color: _dates[index] != selectedDate
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.inversePrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              setState(() {
                                selectedDate = _dates[index];
                              });
                            },
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    color: Colors.black.withAlpha(20),
                                    child: Center(
                                      child: Text(
                                        month,
                                        style: TextStyle(
                                          color: _dates[index] != selectedDate
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                          fontWeight:
                                              _dates[index] != selectedDate
                                                  ? FontWeight.w500
                                                  : FontWeight.w400,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      date,
                                      style: TextStyle(
                                        color: _dates[index] != selectedDate
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                        fontWeight:
                                            _dates[index] != selectedDate
                                                ? FontWeight.w500
                                                : FontWeight.w400,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: TagFilter(
                  initialSelectedTag: null,
                  onSelectedTagChange: (tag) {
                    setState(() {
                      _selectedTag = tag;
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                height: 0,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(selectedDate),
        actions: [
          IconButton(
            onPressed: () {
              final initialDate =
                  DateTimeFormatting.fromDateString(selectedDate);
              final firstDate =
                  DateTime.fromMillisecondsSinceEpoch(_minDateTimestamp);
              final lastDate =
                  DateTime.fromMillisecondsSinceEpoch(_maxDateTimestamp);
              showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: firstDate,
                lastDate: lastDate,
              ).then(
                (value) {
                  setState(
                    () {
                      if (value != null) {
                        selectedDate = value.toDateString();
                      }
                    },
                  );
                },
              );
            },
            icon: const Icon(
              Icons.calendar_month_rounded,
            ),
          ),
          const AppBarMenuButton()
        ],
        bottom: bottomWidget,
      ),
      body: Conditional(
        condition: _isLoading,
        ifTrue: const Center(
          child: CircularProgressIndicator(),
        ),
        ifFalse: Conditional(
          condition: hasData,
          ifTrue: Column(
            children: [
              Expanded(
                child: Builder(
                  builder: (context) {
                    List<Timelog> items = [];
                    if (_groupedTimelogs.containsKey(selectedDate)) {
                      items = _groupedTimelogs[selectedDate]!.toList();

                      if (_selectedTag != null) {
                        items.removeWhere((element) {
                          bool result = true;
                          if (element.task.value != null) {
                            for (var tag in element.task.value!.tags) {
                              if (tag.id == _selectedTag) {
                                result = false;
                              }
                            }
                          }
                          return result;
                        });
                      }

                      if (widget.selectedTask != null) {
                        items.removeWhere((element) {
                          bool result = true;
                          if (element.task.value != null) {
                            if (element.task.value!.id == widget.selectedTask) {
                              result = false;
                            }
                          }
                          return result;
                        });
                      }

                      items.sort((a, b) => a.startTime.compareTo(b.startTime));
                    }
                    if (items.isEmpty) {
                      return Center(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.hourglass_disabled_rounded,
                            size: 80,
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Text('No logs in $selectedDate'),
                        ],
                      ));
                    }
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (c, i) => const Divider(
                        height: 0,
                      ),
                      itemBuilder: (context, index) {
                        Timelog timelog = items[index];
                        return TimelogEntry(
                          id: timelog.id,
                          running: timelog.running,
                          task: timelog.task.value?.name ?? '',
                          description: timelog.description,
                          startTime: timelog.startTime,
                          endTime: timelog.endTime,
                          milliseconds: timelog.endTime - timelog.startTime,
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
          ifFalse: const NoDataEmoji(),
        ),
      ),
    );
  }
}

class TimelogEntry extends StatelessWidget {
  final Id id;
  final String task;
  final String description;
  final int startTime;
  final int endTime;
  final int milliseconds;
  final bool running;
  final showOptions;

  const TimelogEntry({
    super.key,
    required this.id,
    required this.running,
    required this.task,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.milliseconds,
    this.showOptions = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${millisecondsToTime(startTime)} - ${millisecondsToTime(endTime)} · ${millisecondsToReadable(milliseconds)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          task,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        Builder(builder: (context) {
                          if (description.isEmpty) {
                            return const Text(
                              'No description',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                              ),
                            );
                          }
                          return Text(description,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ));
                        }),
                      ],
                    ),
                  ),
                  showOptions
                      ? SizedBox(
                          width: 50,
                          child: Center(
                            child: PopupMenuButton(
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry>[
                                PopupMenuItem(
                                  value: 'edit',
                                  enabled: !running,
                                  onTap: () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (context) {
                                        return CreateTimelogDialog(
                                          id: id,
                                        );
                                      },
                                    );
                                  },
                                  child: const Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  enabled: !running,
                                  onTap: () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (context) {
                                        return ConfirmDeleteDialog(
                                          description:
                                              'Are you sure you want to delete this timelog for task "$task"',
                                          onConfirm: () {
                                            final isar = IsarService();

                                            isar.deleteTimelog(id);

                                            const snackBar = SnackBar(
                                              content: Text('Timelog deleted'),
                                            );

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
