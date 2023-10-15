import 'package:isar/isar.dart';
import 'package:timebrew/models/task.dart';

part 'tag.g.dart';

@collection
class Tag {
  Id id = Isar.autoIncrement;
  late String name;
  late String color;
  @Backlink(to: 'tags')
  final tasks = IsarLinks<Task>();
}
