import 'package:flutter/material.dart';
import 'package:timebrew/extensions/hex_color.dart';
import 'package:timebrew/models/tag.dart';
import 'package:timebrew/models/timelog.dart';
import 'package:timebrew/popups/confirm_delete.dart';
import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/popups/create_tag.dart';
import 'package:timebrew/utils.dart';

class Tags extends StatefulWidget {
  const Tags({super.key});

  @override
  State<Tags> createState() => _TagsState();
}

class _TagsState extends State<Tags> with AutomaticKeepAliveClientMixin {
  final isar = IsarService();

  @override
  bool get wantKeepAlive => true; //Set to true

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StreamBuilder(
      stream: isar.getTaskStream(),
      builder: (context, snapshot) {
        return StreamBuilder(
          stream: isar.getTimelogStream(),
          builder: (context, snapshot) {
            return StreamBuilder<List<Tag>>(
              initialData: const [],
              stream: isar.getTagStream(),
              builder: (context, snapshot) {
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    Tag tag = snapshot.data![index];
                    return StreamBuilder<List<Timelog>>(
                        initialData: const [],
                        stream: isar.getTagTimelogStream(tag.id),
                        builder: (context, snapshot) {
                          int milliseconds = 0;
                          if (snapshot.data!.isNotEmpty) {
                            milliseconds = snapshot.data!
                                .map((timelog) =>
                                    timelog.endTime - timelog.startTime)
                                .reduce((value, element) => value + element);
                          }
                          return TagEntry(
                            name: tag.name,
                            id: tag.id,
                            milliseconds: milliseconds,
                            color: HexColor.fromHex(tag.color),
                          );
                        });
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class TagEntry extends StatelessWidget {
  final String name;
  final int id;
  final int milliseconds;
  final Color color;
  final isar = IsarService();

  TagEntry({
    super.key,
    required this.name,
    required this.id,
    required this.milliseconds,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#$name',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color.computeLuminance() >= 0.5
                            ? Colors.black
                            : Colors.white,
                      ),
                ),
                Text(
                  millisecondsToReadable(milliseconds),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color.computeLuminance() >= 0.5
                            ? Colors.black
                            : Colors.white,
                      ),
                ),
              ],
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
                        return CreateTagDialog(
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
                          description: 'Are you sure you want to delete $name',
                          onConfirm: () {
                            isar.deleteTag(id);

                            final snackBar = SnackBar(
                              content: Text('Tag $name deleted'),
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
    );
  }
}
