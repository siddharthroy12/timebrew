import 'package:flutter/material.dart';
import 'package:timebrew/extensions/hex_color.dart';
import 'package:timebrew/models/tag.dart';
import 'package:timebrew/popups/confirm_delete.dart';
import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/popups/create_tag.dart';

class Tags extends StatefulWidget {
  const Tags({super.key});

  @override
  State<Tags> createState() => _TagsState();
}

class _TagsState extends State<Tags> {
  final isar = IsarService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Tag>>(
      stream: isar.getTagStream(),
      builder: (context, snapshot) {
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: snapshot.data != null ? snapshot.data!.length : 0,
          itemBuilder: (BuildContext context, int index) {
            Tag tag = snapshot.data![index];
            return TagEntry(
              name: tag.name,
              id: tag.id,
              milliseconds: 0,
              color: HexColor.fromHex(tag.color),
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
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  "No time spent",
                  style: Theme.of(context).textTheme.bodySmall,
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
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
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
