import 'package:isar/isar.dart';
import 'package:timebrew/models/timelog.dart';
import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/extensions/date_time.dart';

/// A pair of values.
class Pair<E, F> {
  E first;
  F last;
  Pair({required this.first, required this.last});
}

class MomentHours {
  String moment;
  double totalHours;
  Map<Id, double> tagHours;
  MomentHours({
    required this.moment,
    required this.totalHours,
    required this.tagHours,
  });
}

/// Convert milliseconds to human readable format
/// [milliseconds] is epoc time
/// and this returns a string like `2 hours 34 minutes`

String millisecondsToReadable(int milliseconds) {
  const millisecondsInSecond = 1000;
  const secondsInMinute = 60;
  const minutesInHour = 60;
  const hoursInDay = 24;

  var seconds = (milliseconds / millisecondsInSecond).floor();
  var minutes = (seconds / secondsInMinute).floor();
  var hours = (minutes / minutesInHour).floor();
  var days = (hours / hoursInDay).floor();

  milliseconds %= millisecondsInSecond;
  seconds %= secondsInMinute;
  minutes %= minutesInHour;
  hours %= hoursInDay;

  var result = "";

  if (days > 0) {
    result += "${days}Day\n";
  }
  if (hours > 0) {
    result += "${hours}Hr\n";
  }
  if (minutes > 0) {
    result += "${minutes}Min\n";
  }
  if (seconds > 0 && minutes == 0) {
    result += "${seconds}Sec\n";
  }

  final trim = result.trim();

  return trim.isNotEmpty ? trim : "No time spent";
}

/// Convert millisecond epoc time to 12-hour string like "4:45 PM"
String millisecondsToTime(int timestamp) {
  final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final hour = dateTime.hour;
  final minute = dateTime.minute;
  final period = hour < 12 ? 'AM' : 'PM';

  // Convert to 12-hour format
  final formattedHour = hour % 12 == 0 ? 12 : hour % 12;

  return '$formattedHour:${minute.toString().padLeft(2, '0')} $period';
}

/// Convert timelogs to CSV string
Future<String> convertTimelogsToCSV() async {
  final isar = IsarService();
  String result = 'Date, Task, Tags, Start time, End Time, Total time';

  var timelogs = await isar.getTimelogStream().first;
  timelogs.sort((a, b) => b.startTime - a.startTime);

  for (var timelog in timelogs) {
    var task = timelog.task.value?.name ?? '';
    var tags = '';
    if (timelog.task.value != null) {
      for (var tag in timelog.task.value!.tags) {
        tags += '#${tag.name} ';
      }
    }
    var date = DateTime.fromMillisecondsSinceEpoch(timelog.endTime)
        .toDateString()
        .replaceAll(', ', '-')
        .replaceAll(' ', '-');
    var startTime = millisecondsToTime(timelog.startTime);
    var endTime = millisecondsToTime(timelog.endTime);
    var totalTime = Duration(milliseconds: timelog.endTime - timelog.startTime)
        .toString()
        .split('.')[0];

    result += '\n$date,$task,$tags,$startTime,$endTime,$totalTime';
  }
  return result;
}

double getTimelogHours(Timelog timelog) {
  return (timelog.endTime - timelog.startTime) / 3.6e+6;
}

List<MomentHours> getDailyHours(List<Timelog> timelogs) {
  List<MomentHours> result = [];
  Map<String, MomentHours> groupByDay = {};

  for (var timelog in timelogs) {
    final dateString =
        DateTime.fromMillisecondsSinceEpoch(timelog.startTime).toDateString();

    final hours = getTimelogHours(timelog);

    Map<Id, double> tagHours = {};
    for (var tag in timelog.task.value!.tags) {
      if (tagHours.containsKey(tag.id)) {
        tagHours[tag.id] = tagHours[tag.id]! + hours;
      } else {
        tagHours[tag.id] = hours;
      }
    }

    if (groupByDay.containsKey(dateString)) {
      groupByDay[dateString]!.totalHours += hours;
      for (var id in tagHours.keys) {
        if (groupByDay[dateString]!.tagHours.containsKey(id)) {
          groupByDay[dateString]!.tagHours[id] =
              groupByDay[dateString]!.tagHours[id]! + tagHours[id]!;
        } else {
          groupByDay[dateString]!.tagHours[id] = tagHours[id]!;
        }
      }
    } else {
      groupByDay[dateString] = MomentHours(
        moment: dateString,
        totalHours: hours,
        tagHours: tagHours,
      );
    }
  }

  for (var i = 0; i < 365; i++) {
    final dateString =
        DateTime.now().subtract(Duration(days: i)).toDateString();
    var moment = MomentHours(moment: dateString, totalHours: 0, tagHours: {});
    if (groupByDay.containsKey(dateString)) {
      moment = groupByDay[dateString]!;
    }
    result.add(moment);
  }

  return result;
}

List<MomentHours> getWeeklyHours(List<Timelog> timelogs) {
  List<MomentHours> result = [];
  Map<String, MomentHours> groupByDay = {};

  for (var timelog in timelogs) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timelog.startTime);

    String month = dateTime.toDateString().split(' ')[0];
    String year = dateTime.year.toString().substring(2, 4);
    int week = dateTime.weekOfMonth;
    var key = "${week}w $month, '$year";

    final hours = getTimelogHours(timelog);

    Map<Id, double> tagHours = {};
    for (var tag in timelog.task.value!.tags) {
      if (tagHours.containsKey(tag.id)) {
        tagHours[tag.id] = tagHours[tag.id]! + hours;
      } else {
        tagHours[tag.id] = hours;
      }
    }

    if (groupByDay.containsKey(key)) {
      groupByDay[key]!.totalHours += hours;
      for (var id in tagHours.keys) {
        if (groupByDay[key]!.tagHours.containsKey(id)) {
          groupByDay[key]!.tagHours[id] =
              groupByDay[key]!.tagHours[id]! + tagHours[id]!;
        } else {
          groupByDay[key]!.tagHours[id] = tagHours[id]!;
        }
      }
    } else {
      groupByDay[key] = MomentHours(
        moment: key,
        totalHours: hours,
        tagHours: tagHours,
      );
    }
  }

  for (var i = 0; i < 365; i++) {
    final dateTime = DateTime.now().subtract(Duration(days: i));

    String month = dateTime.toDateString().split(' ')[0];
    String year = dateTime.year.toString().substring(2, 4);
    int week = dateTime.weekOfMonth;

    var key = "${week}w $month, '$year";
    var moment = MomentHours(moment: key, totalHours: 0, tagHours: {});
    if (groupByDay.containsKey(key)) {
      moment = groupByDay[key]!;
    }
    if (result.isEmpty || result.last.moment != key) {
      result.add(moment);
    }
  }

  return result;
}

List<MomentHours> getMonthlyHours(List<Timelog> timelogs) {
  List<MomentHours> result = [];
  Map<String, MomentHours> groupByDay = {};

  for (var timelog in timelogs) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timelog.startTime);

    String month = dateTime.toDateString().split(' ')[0];
    String year = dateTime.year.toString().substring(2, 4);

    var key = "$month '$year";

    final hours = getTimelogHours(timelog);

    Map<Id, double> tagHours = {};
    for (var tag in timelog.task.value!.tags) {
      if (tagHours.containsKey(tag.id)) {
        tagHours[tag.id] = tagHours[tag.id]! + hours;
      } else {
        tagHours[tag.id] = hours;
      }
    }

    if (groupByDay.containsKey(key)) {
      groupByDay[key]!.totalHours += hours;
      for (var id in tagHours.keys) {
        if (groupByDay[key]!.tagHours.containsKey(id)) {
          groupByDay[key]!.tagHours[id] =
              groupByDay[key]!.tagHours[id]! + tagHours[id]!;
        } else {
          groupByDay[key]!.tagHours[id] = tagHours[id]!;
        }
      }
    } else {
      groupByDay[key] = MomentHours(
        moment: key,
        totalHours: hours,
        tagHours: tagHours,
      );
    }
  }

  for (var i = 0; i < 12 * 3; i++) {
    final dateTime = DateTime.now().subtract(Duration(days: i * 30));

    String month = dateTime.toDateString().split(' ')[0];
    String year = dateTime.year.toString().substring(2, 4);

    var key = "$month '$year";
    var moment = MomentHours(moment: key, totalHours: 0, tagHours: {});
    if (groupByDay.containsKey(key)) {
      moment = groupByDay[key]!;
    }
    if (result.isEmpty || result.last.moment != key) {
      result.add(moment);
    }
  }

  return result;
}

String formatHours(double hours) {
  int hoursInt = hours.floor();
  int minutes = ((hours - hoursInt) * 60).round();

  String result = '$hoursInt hour';
  if (hoursInt != 1) {
    result += 's';
  }

  if (minutes > 0) {
    result += ' $minutes minute';
    if (minutes != 1) {
      result += 's';
    }
  }

  return result;
}

int weeksBetween(DateTime from, DateTime to) {
  from = DateTime.utc(from.year, from.month, from.day);
  to = DateTime.utc(to.year, to.month, to.day);
  return (to.difference(from).inDays / 7).ceil();
}
