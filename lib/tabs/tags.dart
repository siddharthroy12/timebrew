import 'package:flutter/material.dart';

class Tags extends StatefulWidget {
  const Tags({super.key});

  @override
  State<Tags> createState() => _TagsState();
}

class _TagsState extends State<Tags> {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [TagEntry(), TagEntry(), TagEntry()],
          ),
        ),
      ],
    );
  }
}

class TagEntry extends StatelessWidget {
  const TagEntry({
    super.key,
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
                  'Hello',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text('1h 3m', style: Theme.of(context).textTheme.bodySmall),
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
