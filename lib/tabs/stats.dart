import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:timebrew/extensions/hex_color.dart';
import 'package:timebrew/models/tag.dart';
import 'package:timebrew/models/task.dart';
import 'package:timebrew/models/timelog.dart';
import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/utils.dart';

enum Calendar { day, week, month }

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> with AutomaticKeepAliveClientMixin {
  final isar = IsarService();
  Calendar calendarView = Calendar.day;
  ScrollController scrollController = ScrollController();
  List<Id> selectedTags = [];

  @override
  bool get wantKeepAlive => true; //Set to true

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
      child: StreamBuilder<List<Task>>(
        initialData: const [],
        stream: isar.getTaskStream(),
        builder: (context, tasks) {
          return StreamBuilder<List<Tag>>(
            initialData: const [],
            stream: isar.getTagStream(),
            builder: (context, tags) {
              return StreamBuilder<List<Timelog>>(
                initialData: const [],
                stream: isar.getTimelogStream(),
                builder: (context, timelogs) {
                  List<Pair<String, double>> hours = [];
                  int maxHours = 0;
                  switch (calendarView) {
                    case Calendar.day:
                      hours = getDailyHours(timelogs.data!);
                      maxHours = 24;
                      break;
                    case Calendar.month:
                      hours = getMonthlyHours(timelogs.data!);
                      maxHours = 730;
                      break;
                    case Calendar.week:
                      hours = getWeeklyHours(timelogs.data!);
                      maxHours = 24 * 7;
                      break;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SegmentedButton<Calendar>(
                        segments: const <ButtonSegment<Calendar>>[
                          ButtonSegment<Calendar>(
                              value: Calendar.day,
                              label: Text('Day'),
                              icon: Icon(Icons.calendar_view_day)),
                          ButtonSegment<Calendar>(
                              value: Calendar.week,
                              label: Text('Week'),
                              icon: Icon(Icons.calendar_view_week)),
                          ButtonSegment<Calendar>(
                              value: Calendar.month,
                              label: Text('Month'),
                              icon: Icon(Icons.calendar_view_month)),
                        ],
                        selected: <Calendar>{calendarView},
                        onSelectionChanged: (Set<Calendar> newSelection) {
                          setState(() {
                            calendarView = newSelection.first;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: Scrollbar(
                          controller: scrollController,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: ListView.separated(
                              reverse: true,
                              controller: scrollController,
                              itemCount: hours.length,
                              scrollDirection: Axis.horizontal,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                width: 10,
                              ),
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  width: 53,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Tooltip(
                                          message:
                                              formatHours(hours[index].last),
                                          child: Stack(
                                            alignment: AlignmentDirectional
                                                .bottomStart,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .inversePrimary,
                                                ),
                                              ),
                                              FractionallySizedBox(
                                                heightFactor:
                                                    hours[index].last /
                                                        maxHours,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                  ),
                                                ),
                                              ),
                                              FractionallySizedBox(
                                                heightFactor:
                                                    (hours[index].last /
                                                        maxHours),
                                                widthFactor: 1,
                                                child: Container(
                                                  transform:
                                                      Matrix4.translationValues(
                                                    0.0,
                                                    -20.0,
                                                    0.0,
                                                  ),
                                                  child: Text(
                                                    '${hours[index].last.toStringAsFixed(1)}h',
                                                    textAlign: TextAlign.center,
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
                                        hours[index].first.split(',')[0],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Builder(builder: (context) {
                        final rows = tags.data!.map((tag) {
                          bool selected = selectedTags.contains(tag.id);

                          return FilterChip(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),
                            color: MaterialStateProperty.resolveWith((states) {
                              return HexColor.fromHex(tag.color);
                            }),
                            side: const BorderSide(
                                width: 0, color: Colors.transparent),
                            selected: selected,
                            onSelected: (newSelected) {
                              setState(() {
                                if (selected) {
                                  selectedTags.remove(tag.id);
                                } else {
                                  selectedTags.add(tag.id);
                                }
                              });
                            },
                            label: Text(
                              '#${tag.name}',
                              style: TextStyle(
                                color: HexColor.fromHex(tag.color)
                                            .computeLuminance() >=
                                        0.5
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                          );
                        }).toList();
                        return Wrap(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.center,
                          runSpacing: 5,
                          spacing: 5,
                          children: rows,
                        );
                      })
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
