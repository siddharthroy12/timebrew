import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:timebrew/extensions/date_time.dart';
import 'package:timebrew/models/timelog.dart';
import 'package:timebrew/popups/confirm_delete.dart';
import 'package:timebrew/popups/create_timelog.dart';
import 'package:timebrew/services/isar_service.dart';
import '../widgets/grouped_list.dart';
import 'package:timebrew/utils.dart';

class Timelogs extends StatefulWidget {
  const Timelogs({super.key});

  @override
  State<Timelogs> createState() => _TimelogsState();
}

class _TimelogsState extends State<Timelogs>
    with AutomaticKeepAliveClientMixin {
  final isar = IsarService();

  @override
  bool get wantKeepAlive => true; //Set

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder<List<Timelog>>(
      initialData: const [],
      stream: isar.getTimelogStream(),
      builder: (context, snapshot) {
        return GroupedListView<Timelog, String>(
          padding: const EdgeInsets.all(8),
          elements: snapshot.data ?? [],
          groupBy: (element) =>
              DateTime.fromMillisecondsSinceEpoch(element.startTime)
                  .toDateString(),
          groupHeaderBuilder: (List<Timelog> timelogs) {
            var date =
                DateTime.fromMillisecondsSinceEpoch(timelogs.first.startTime)
                    .toDateString();

            var totalMilliseconds = 0;

            if (timelogs.isNotEmpty) {
              totalMilliseconds = timelogs
                  .map((timelog) => timelog.endTime - timelog.startTime)
                  .reduce((value, element) => value + element);
            }

            var totalTime = millisecondsToReadable(totalMilliseconds);
            return Container(
              color: Theme.of(context).colorScheme.background,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      totalTime,
                    ),
                  ],
                ),
              ),
            );
          },
          itemBuilder: (context, element) => TimelogEntry(
            id: element.id,
            task: (element.task.value?.name ?? ''),
            description: element.description,
            milliseconds: element.endTime - element.startTime,
            startTime: element.startTime,
            endTime: element.endTime,
          ),
          itemComparator: (item1, item2) => item1.startTime.compareTo(
            item2.startTime,
          ), // optional
          useStickyGroupSeparators: true, // optional
          order: GroupedListOrder.DESC, // optional
        );
      },
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
  final isar = IsarService();

  TimelogEntry({
    super.key,
    required this.id,
    required this.task,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.milliseconds,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Column(
            children: [
              Text(millisecondsToTime(endTime)),
              const SizedBox(
                height: 35,
                child: VerticalDivider(),
              ),
              Text(millisecondsToTime(startTime)),
            ],
          ),
        ),
        Expanded(
          child: Card(
            child: SizedBox(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                task,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                millisecondsToReadable(milliseconds),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          Builder(builder: (context) {
                            if (description.isEmpty) {
                              return Container();
                            }
                            return Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  description,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                        PopupMenuItem(
                          value: 'edit',
                          child: const Text('Edit'),
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
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: const Text('Delete'),
                          onTap: () {
                            showDialog<void>(
                              context: context,
                              builder: (context) {
                                return ConfirmDeleteDialog(
                                  description:
                                      'Are you sure you want to delete this timelog for task "$task"',
                                  onConfirm: () {
                                    isar.deleteTimelog(id);

                                    final snackBar = SnackBar(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.error,
                                      content: const Text('Timelog deleted'),
                                    );

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
