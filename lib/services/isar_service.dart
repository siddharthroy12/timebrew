import 'package:isar/isar.dart';
import 'package:timebrew/models/tag.dart';
import 'package:timebrew/models/task.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timebrew/models/timelog.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();

    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [TimelogSchema, TaskSchema, TagSchema],
        directory: dir.path,
        inspector: false,
      );
    }

    return Future.value(Isar.getInstance());
  }

  Future<void> addTimelog(Id taskId, String description) async {
    final isar = await db;
    final Task? task = await isar.tasks.get(taskId);
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;

    if (task != null) {
      final Timelog timelog = Timelog()
        ..task.value = task
        ..description = description
        ..running = true
        ..startTime = currentTimestamp
        ..endTime = currentTimestamp;

      await isar.writeTxn(() async {
        await timelog.task.save();
        await isar.timelogs.put(timelog);
      });
    }
  }

  Future<void> updateTimelog(Timelog timelog) async {
    final isar = await db;

    await isar.writeTxn(() async {
      await timelog.task.save();
      await isar.timelogs.put(timelog);
    });
  }

  Future<void> deleteTimelog(Id id) async {
    final isar = await db;

    await isar.writeTxn(() async {
      await isar.timelogs.delete(id);
    });
  }

  Future<void> addTask(String name, List<Id> tagIds) async {
    final isar = await db;
    final Task task = Task()..name = name;

    for (Id tagId in tagIds) {
      Tag? tag = await isar.tags.get(tagId);
      if (tag != null) {
        task.tags.add(tag);
      }
    }

    await isar.writeTxn(() async {
      await task.tags.save();
      await isar.tasks.put(task);
    });
  }

  Future<void> updateTask(Task task) async {
    final isar = await db;

    await isar.writeTxn(() async {
      await task.tags.save();
      await isar.tasks.put(task);
    });
  }

  Future<void> deleteTask(Id id, bool deleteTimelogs) async {
    final isar = await db;

    await isar.writeTxn(() async {
      await isar.tasks.delete(id);

      if (deleteTimelogs) {
        await isar.timelogs.filter().task((q) => q.idEqualTo(id)).deleteAll();
      }
    });
  }

  Stream<List<Tag>> getTagStream() async* {
    final isar = await db;
    yield* isar.tags.where().watch(fireImmediately: true);
  }

  Future<Tag?> getTagById(Id id) async {
    final isar = await db;
    return await isar.tags.get(id);
  }

  Future<void> addTag(String name, String color) async {
    final isar = await db;
    final Tag tag = Tag()
      ..name = name
      ..color = color;

    await isar.writeTxn(() async {
      await isar.tags.put(tag);
    });
  }

  Future<void> updateTag(Tag tag) async {
    final isar = await db;

    await isar.writeTxn(() async {
      await isar.tags.put(tag);
    });
  }

  Future<void> deleteTag(
    Id id,
  ) async {
    final isar = await db;

    await isar.writeTxn(() async {
      await isar.tags.delete(id);
    });
  }
}
