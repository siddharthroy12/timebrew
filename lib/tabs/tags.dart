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
                return ListView.separated(
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (context, index) {
                    return Container();
                  },
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
                      },
                    );
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

  const TagEntry({
    super.key,
    required this.name,
    required this.id,
    required this.milliseconds,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      leading: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: color,
        ),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Text(
              "#",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color.computeLuminance() >= 0.5
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            millisecondsToReadable(milliseconds),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      trailing: PopupMenuButton(
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
                      final isar = IsarService();

                      isar.deleteTag(id);

                      final snackBar = SnackBar(
                        content: Text('Tag $name deleted'),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
