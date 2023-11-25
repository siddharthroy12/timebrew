import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:timebrew/models/tag.dart';
import 'package:timebrew/services/isar_service.dart';

class TagFilter extends StatefulWidget {
  final Id? initialSelectedTag;
  final Function(Id?) onSelectedTagChange;
  const TagFilter({
    super.key,
    required this.initialSelectedTag,
    required this.onSelectedTagChange,
  });

  @override
  State<TagFilter> createState() => _TagFilterState();
}

class _TagFilterState extends State<TagFilter> {
  List<Tag> _tags = [];
  final _isar = IsarService();
  late StreamSubscription _tagStreamSubscription;
  // Null means all
  Id? _selectedTag;

  @override
  void initState() {
    super.initState();
    _selectedTag = widget.initialSelectedTag;
    _tagStreamSubscription = _isar.getTagStream().listen((tags) {
      setState(() {
        _tags = tags;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tagStreamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        ChoiceChip(
          selected: _selectedTag == null,
          label: const Text('All'),
          onSelected: (selected) {
            setState(() {
              _selectedTag = null;
              widget.onSelectedTagChange(null);
            });
          },
        ),
        const SizedBox(
          width: 10,
        ),
        ..._tags.map(
          (e) => Row(
            children: [
              ChoiceChip(
                label: Text(e.name),
                selected: _selectedTag == e.id,
                onSelected: (selected) {
                  setState(() {
                    _selectedTag = e.id;
                    widget.onSelectedTagChange(e.id);
                  });
                },
              ),
              const SizedBox(
                width: 10,
              )
            ],
          ),
        )
      ],
    );
  }
}
