import 'package:flutter/material.dart';

class Tag {
  String? id;
  String name;
  String color;
  Tag(this.name, this.color);
}

class TagProvider extends ChangeNotifier {
  final List<Tag> _tags = [];

  get tags {
    return _tags;
  }

  addTag(Tag tag) {
    _tags.add(tag);
    notifyListeners();
  }

  updateTag(String id, Tag tag) {
    int index = _tags.indexWhere((element) => element.id == id);
    _tags[index] = tag;
    notifyListeners();
  }

  deleteTag(String id) {
    int index = _tags.indexWhere((element) => element.id == id);
    _tags.removeAt(index);
    notifyListeners();
  }
}
