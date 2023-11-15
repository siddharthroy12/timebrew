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
        name: 'timebrew',
      );
    }

    return Future.value(Isar.getInstance('timebrew'));
  }

  Future<Timelog?> getTimelogById(Id timelogId) async {
    final isar = await db;
    return await isar.timelogs.get(timelogId);
  }

  Future<Timelog?> addTimelog(
    Id taskId,
    String description,
    int startTime,
    int endTime,
    bool running,
  ) async {
    final isar = await db;
    final Task? task = await isar.tasks.get(taskId);

    if (task != null) {
      final Timelog timelog = Timelog()
        ..task.value = task
        ..description = description
        ..running = running
        ..startTime = startTime
        ..endTime = endTime;

      await isar.writeTxn(() async {
        await isar.timelogs.put(timelog);
        await timelog.task.save();
      });

      return timelog;
    }
    return null;
  }

  Stream<List<Timelog>> getTimelogStream() async* {
    final isar = await db;
    yield* isar.timelogs.where().watch(fireImmediately: true);
  }

  Stream<List<Timelog>> getTaskTimelogStream(Id id) async* {
    final isar = await db;
    var query = isar.timelogs.filter().task((q) => q.idEqualTo(id)).build();
    yield* query.watch(fireImmediately: true);
  }

  Stream<List<Timelog>> getTagTimelogStream(Id id) async* {
    final isar = await db;
    var query = isar.timelogs
        .filter()
        .task((q) => q.tags((q) => q.idEqualTo(id)))
        .build();
    yield* query.watch(fireImmediately: true);
  }

  Future<void> updateTimelog(Timelog timelog) async {
    final isar = await db;

    await isar.writeTxn(() async {
      await isar.timelogs.put(timelog);
      await timelog.task.save();
    });
  }

  Future<Timelog?> getRunningTimelog() async {
    final isar = await db;
    return isar.timelogs.filter().runningEqualTo(true).findFirst();
  }

  Future unPauseAllTimelogs() async {
    final isar = await db;
    final timelogs = await getPausedTimelogs();
    await isar.writeTxn(() async {
      for (var timelog in timelogs) {
        timelog.paused = false;
        await isar.timelogs.put(timelog);
      }
    });

    return;
  }

  Future<List<Timelog>> getPausedTimelogs() async {
    final isar = await db;
    return isar.timelogs.filter().pausedEqualTo(true).findAll();
  }

  Future<void> deleteTimelog(Id id) async {
    final isar = await db;

    await isar.writeTxn(() async {
      await isar.timelogs.delete(id);
    });
  }

  Future<Task?> getTaskById(Id id) async {
    final isar = await db;
    return await isar.tasks.get(id);
  }

  Stream<List<Task>> getTaskStream() async* {
    final isar = await db;
    yield* isar.tasks.where().watch(fireImmediately: true);
  }

  Future<void> addTask(String name, String link, List<Id> tagIds) async {
    final isar = await db;
    final Task task = Task()
      ..name = name.trim()
      ..link = link;

    for (Id tagId in tagIds) {
      Tag? tag = await isar.tags.get(tagId);
      if (tag != null) {
        task.tags.add(tag);
      }
    }

    await isar.writeTxn(() async {
      await isar.tasks.put(task);
      await task.tags.save();
    });
  }

  Future<void> updateTask(
    Id id,
    String name,
    String link,
    List<Id> tags,
  ) async {
    final isar = await db;
    var task = await isar.tasks.get(id);

    if (task != null) {
      task.name = name.trim();
      task.link = link;
      task.tags.removeWhere((element) => !tags.contains(element.id));

      for (var tag in tags) {
        var t = await isar.tags.get(tag);
        if (t != null) {
          task.tags.add(t);
        }
      }

      await isar.writeTxn(() async {
        await isar.tasks.put(task);
        await task.tags.save();
      });
    }
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

  Future<List<Tag>> getTagList() async {
    final isar = await db;

    return await isar.tags.where().findAll();
  }

  Future<Tag?> getTagById(Id id) async {
    final isar = await db;
    return await isar.tags.get(id);
  }

  Future<void> addTag(String name, String color) async {
    final isar = await db;
    final Tag tag = Tag()
      ..name = name.trim()
      ..color = color;

    await isar.writeTxn(() async {
      await isar.tags.put(tag);
    });
  }

  Future<void> updateTag(Tag tag) async {
    final isar = await db;

    await isar.writeTxn(() async {
      tag.name = tag.name.trim();
      await isar.tags.put(tag);
    });
  }

  Future<List<Task>> getTasksWithOnlyOneTag(Id tagId) async {
    final isar = await db;
    return isar.tasks
        .filter()
        .tagsLengthEqualTo(1)
        .tags((q) => q.idEqualTo(tagId))
        .findAll();
  }

  Future<void> deleteTag(
    Id id,
  ) async {
    final isar = await db;

    await isar.writeTxn(() async {
      await isar.tags.delete(id);
    });

    // Delete tasks that only has this tag
    var tasksToDelete = await getTasksWithOnlyOneTag(id);

    for (var task in tasksToDelete) {
      await deleteTask(task.id, true);
    }
  }
}
