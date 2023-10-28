import 'package:flutter/material.dart';
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

  @override
  bool get wantKeepAlive => true; //Set to true

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
      child: StreamBuilder<List<Timelog>>(
        initialData: const [],
        stream: isar.getTimelogStream(),
        builder: (context, snapshot) {
          List<Pair<String, double>> hours = [];
          int maxHours = 0;
          switch (calendarView) {
            case Calendar.day:
              hours = getDailyHours(snapshot.data!);
              maxHours = 24;
              break;
            case Calendar.month:
              hours = getMonthlyHours(snapshot.data!);
              maxHours = 730;
              break;
            case Calendar.week:
              hours = getWeeklyHours(snapshot.data!);
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
                      separatorBuilder: (context, index) => const SizedBox(
                        width: 10,
                      ),
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 53,
                          child: Column(
                            children: [
                              Expanded(
                                child: Tooltip(
                                  message: formatHours(hours[index].last),
                                  child: Stack(
                                    alignment: AlignmentDirectional.bottomStart,
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
                                            hours[index].last / maxHours,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                        ),
                                      ),
                                      FractionallySizedBox(
                                        heightFactor:
                                            (hours[index].last / maxHours) +
                                                0.05,
                                        widthFactor: 1,
                                        child: Text(
                                          '${hours[index].last.toStringAsFixed(1)}h',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(hours[index].first.split(',')[0]),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
