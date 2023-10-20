import 'package:isar/isar.dart';
import 'package:timebrew/models/task.dart';

part 'timelog.g.dart';

@collection
class Timelog {
  Id id = Isar.autoIncrement;
  final task = IsarLink<Task>();
  late String description;
  late int startTime;
  late int endTime;
  late bool running;
}
