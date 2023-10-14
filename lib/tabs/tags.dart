import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timebrew/extensions/hex_color.dart';
import '../providers/tag_provider.dart';

class Tags extends StatefulWidget {
  const Tags({super.key});

  @override
  State<Tags> createState() => _TagsState();
}

class _TagsState extends State<Tags> {
  @override
  Widget build(BuildContext context) {
    List<Tag> tags = context.watch<TagProvider>().tags;

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tags.length,
      itemBuilder: (BuildContext context, int index) {
        Tag tag = tags[index];
        return TagEntry(
          name: tag.name,
          id: tag.id ?? '',
          milliseconds: 0,
          color: HexColor.fromHex(tag.color),
        );
      },
    );
  }
}

class TagEntry extends StatelessWidget {
  final String name;
  final String id;
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(milliseconds.toString(),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            PopupMenuButton(
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                const PopupMenuItem(
                  value: 'Hello',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'Hello',
                  child: Text('Delete'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
