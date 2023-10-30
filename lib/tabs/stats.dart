import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:timebrew/extensions/hex_color.dart';
import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/utils.dart';

// To select between differnt grouping mode
enum Calendar { day, week, month }

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> with AutomaticKeepAliveClientMixin {
  final isar = IsarService();
  Calendar calendarView = Calendar.day;
  // Just to show the horizontal scrollbar
  ScrollController scrollController = ScrollController();
  List<Id> selectedTags = [];
  List<SizedBox> bars = [];

  @override
  bool get wantKeepAlive => true;

  Future<List<SizedBox>> _buildBars() async {
    List<SizedBox> newBars = [];
    final timelogs = await isar.getTimelogStream().first;
    final tags = await isar.getTagStream().first;

    List<MomentHours> hours = [];
    int maxHours = 0;
    switch (calendarView) {
      case Calendar.day:
        hours = getDailyHours(timelogs);
        maxHours = 24;
        break;
      case Calendar.month:
        hours = getMonthlyHours(timelogs);
        maxHours = 730;
        break;
      case Calendar.week:
        hours = getWeeklyHours(timelogs);
        maxHours = 24 * 7;
        break;
    }
    for (var hour in hours) {
      newBars.add(
        SizedBox(
          width: 53,
          child: Column(
            children: [
              Expanded(
                child: Tooltip(
                  message: formatHours(hour.totalHours),
                  child: Builder(builder: (context) {
                    // Build FractionallySizedBoxes for tags
                    List<FractionallySizedBox> tagBoxes = [];
                    List<Pair<Id, double>> portions = [];

                    var totalTagHours = 0.0;

                    for (var tag in hour.tagHours.keys) {
                      totalTagHours += hour.tagHours[tag]!;
                    }
                    for (var tag in hour.tagHours.keys) {
                      double portion = hour.tagHours[tag]! / totalTagHours;

                      if (selectedTags.contains(tag)) {
                        portions.add(
                          Pair<Id, double>(
                            first: tag,
                            last: portion,
                          ),
                        );
                      }
                    }
                    portions.sort(
                      (a, b) => a.last.compareTo(b.last),
                    );

                    double portionAdded = 0;

                    for (var portion in portions) {
                      final color = tags
                          .firstWhere((element) => element.id == portion.first)
                          .color;
                      var finalPortion = portion.last + portionAdded;
                      finalPortion =
                          ((finalPortion) * (hour.totalHours / maxHours));

                      portionAdded += portion.last;

                      tagBoxes.add(
                        FractionallySizedBox(
                          heightFactor: finalPortion,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: HexColor.fromHex(
                                color,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return Stack(
                      alignment: AlignmentDirectional.bottomStart,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Theme.of(context).colorScheme.surfaceVariant,
                          ),
                        ),
                        FractionallySizedBox(
                          heightFactor: hour.totalHours / maxHours,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Theme.of(context).colorScheme.surfaceTint,
                            ),
                          ),
                        ),
                        ...tagBoxes.reversed,
                        FractionallySizedBox(
                          heightFactor: (hour.totalHours / maxHours),
                          widthFactor: 1,
                          child: Container(
                            transform: Matrix4.translationValues(
                              0.0,
                              -22.0,
                              0.0,
                            ),
                            child: Text(
                              '${hour.totalHours.toStringAsFixed(1)}h',
                              style: const TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                hour.moment.split(',')[0],
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }
    return Future.value(newBars);
  }

  @override
  void initState() {
    super.initState();
    _buildBars();

    isar.getTagStream().listen((event) {
      setState(() {});
      selectedTags = event.map((e) => e.id).toList();
    });
    isar.getTaskStream().listen((event) {
      setState(() {});
    });
    isar.getTimelogStream().listen((event) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20),
      child: Column(
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
          FutureBuilder(
            initialData: const [],
            future: _buildBars(),
            builder: (context, snapshot) {
              final bars = snapshot.data!;
              return Expanded(
                child: Listener(
                  onPointerSignal: (event) {
                    if (event is PointerScrollEvent) {
                      final offset = event.scrollDelta.dy;
                      scrollController.jumpTo(scrollController.offset + offset);
                    }
                  },
                  child: Scrollbar(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: ListView.separated(
                        reverse: true,
                        controller: scrollController,
                        itemCount: bars.length,
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (context, index) => const SizedBox(
                          width: 10,
                        ),
                        itemBuilder: (context, index) {
                          return bars[index];
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          StreamBuilder(
            initialData: const [],
            stream: isar.getTagStream(),
            builder: (context, tags) {
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
                  side: const BorderSide(width: 0, color: Colors.transparent),
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
                      color:
                          HexColor.fromHex(tag.color).computeLuminance() >= 0.5
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
            },
          )
        ],
      ),
    );
  }
}
