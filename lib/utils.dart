import 'package:timebrew/models/timelog.dart';
import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/extensions/date_time.dart';

/// A pair of values.
class Pair<E, F> {
  E first;
  F last;
  Pair({required this.first, required this.last});
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
    result += "$days day ";
  }
  if (hours > 0) {
    result += "$hours hour ";
  }
  if (minutes > 0) {
    result += "$minutes minute ";
  }
  if (seconds > 0 && minutes == 0) {
    result += "$seconds second";
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

List<Pair<String, double>> getDailyHours(List<Timelog> timelogs) {
  List<Pair<String, double>> result = [];
  Map<String, double> groupByDay = {};

  for (var timelog in timelogs) {
    final dateString =
        DateTime.fromMillisecondsSinceEpoch(timelog.startTime).toDateString();

    final hours = getTimelogHours(timelog);

    if (groupByDay.containsKey(dateString)) {
      groupByDay[dateString] = groupByDay[dateString]! + hours;
    } else {
      groupByDay[dateString] = hours;
    }
  }

  for (var i = 0; i < 365; i++) {
    final dateString =
        DateTime.now().subtract(Duration(days: i)).toDateString();
    double hours = 0;
    if (groupByDay.containsKey(dateString)) {
      hours = groupByDay[dateString]!;
    } else {
      hours = 0;
    }
    result.add(Pair(first: dateString, last: hours));
  }

  return result;
}

List<Pair<String, double>> getWeeklyHours(List<Timelog> timelogs) {
  List<Pair<String, double>> result = [];
  Map<String, double> groupByDay = {};

  for (var timelog in timelogs) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timelog.startTime);

    String month = dateTime.toDateString().split(' ')[0];
    String year = dateTime.year.toString().substring(2, 4);
    int week = dateTime.weekOfMonth;
    var key = "${week}w $month, '$year";

    final hours = getTimelogHours(timelog);

    if (groupByDay.containsKey(key)) {
      groupByDay[key] = groupByDay[key]! + hours;
    } else {
      groupByDay[key] = hours;
    }
  }

  for (var i = 0; i < 365; i++) {
    final dateTime = DateTime.now().subtract(Duration(days: i));

    String month = dateTime.toDateString().split(' ')[0];
    String year = dateTime.year.toString().substring(2, 4);
    int week = dateTime.weekOfMonth;

    var key = "${week}w $month, '$year";
    double hours = 0;
    if (groupByDay.containsKey(key)) {
      hours = groupByDay[key]!;
    } else {
      hours = 0;
    }
    if (result.isEmpty || result.last.first != key) {
      result.add(Pair(first: key, last: hours));
    }
  }

  return result;
}

List<Pair<String, double>> getMonthlyHours(List<Timelog> timelogs) {
  List<Pair<String, double>> result = [];
  Map<String, double> groupByDay = {};

  for (var timelog in timelogs) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timelog.startTime);

    String month = dateTime.toDateString().split(' ')[0];
    String year = dateTime.year.toString().substring(2, 4);

    var key = "$month '$year";

    final hours = getTimelogHours(timelog);

    if (groupByDay.containsKey(key)) {
      groupByDay[key] = groupByDay[key]! + hours;
    } else {
      groupByDay[key] = hours;
    }
  }

  for (var i = 0; i < 12 * 3; i++) {
    final dateTime = DateTime.now().subtract(Duration(days: i * 30));

    String month = dateTime.toDateString().split(' ')[0];
    String year = dateTime.year.toString().substring(2, 4);

    var key = "$month '$year";
    double hours = 0;
    if (groupByDay.containsKey(key)) {
      hours = groupByDay[key]!;
    } else {
      hours = 0;
    }
    if (result.isEmpty || result.last.first != key) {
      result.add(Pair(first: key, last: hours));
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
