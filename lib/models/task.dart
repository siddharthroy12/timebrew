import 'package:isar/isar.dart';
import 'package:timebrew/models/timelog.dart';
import './tag.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;
  late String name;
  late String link;
  final tags = IsarLinks<Tag>();

  @Backlink(to: 'task')
  final timelogs = IsarLinks<Timelog>();
}
