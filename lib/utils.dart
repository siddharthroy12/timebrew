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
  Map<Id, double> taskHours;
  MomentHours({
    required this.moment,
    required this.totalHours,
    required this.taskHours,
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
    result += "$days day ";
  }
  if (hours > 0) {
    result += "$hours hr ";
  }
  if (minutes > 0) {
    result += "$minutes min ";
  }
  if (seconds > 0 && minutes == 0) {
    result += "$seconds sec";
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

int hoursToMilliseconds(double hours) {
  return (hours * Duration.millisecondsPerHour).round();
}

(
  List<List<MomentHours>>,
  List<List<MomentHours>>,
) getStatsHours(
  List<Timelog> timelogs,
) {
  List<List<MomentHours>> daysInWeeks = [];
  List<List<MomentHours>> monthsInQuaters = [];
  Map<String, MomentHours> groupByDay = {};
  Map<String, MomentHours> groupByMonth = {};

  // Loop over the timelogs and group MomentHours in day and months and get the latest and oldest timelogs timestamp
  var oldestTimelogTimestamp = DateTime.now().millisecondsSinceEpoch;
  var latestTimelogTimestamp = DateTime.now().millisecondsSinceEpoch;

  for (var timelog in timelogs) {
    final dateTimeString =
        DateTime.fromMillisecondsSinceEpoch(timelog.endTime).toDateString();
    final dayKey = dateTimeString;
    final month = dateTimeString.split(' ')[0];
    final year = dateTimeString.split(' ')[2];
    final monthKey = '$month, $year';
    final hours = getTimelogHours(timelog);

    // Find oldest and latest timelog timestamp
    if (timelog.startTime < oldestTimelogTimestamp) {
      oldestTimelogTimestamp = timelog.startTime;
    }
    if (timelog.endTime > latestTimelogTimestamp) {
      latestTimelogTimestamp = timelog.endTime;
    }

    // Group by day
    if (!groupByDay.containsKey(dayKey)) {
      groupByDay[dayKey] =
          MomentHours(moment: dayKey, totalHours: 0, taskHours: {});
    }
    groupByDay[dayKey]!.totalHours += hours;
    if (timelog.task.value != null) {
      if (!groupByDay[dayKey]!.taskHours.containsKey(timelog.task.value!.id)) {
        groupByDay[dayKey]!.taskHours[timelog.task.value!.id] = 0;
      }
      groupByDay[dayKey]!.taskHours[timelog.task.value!.id] =
          groupByDay[dayKey]!.taskHours[timelog.task.value!.id]! + hours;
    }

    // Group by month
    if (!groupByMonth.containsKey(monthKey)) {
      groupByMonth[monthKey] =
          MomentHours(moment: monthKey, totalHours: 0, taskHours: {});
    }
    groupByMonth[monthKey]!.totalHours += hours;
    if (timelog.task.value != null) {
      if (!groupByMonth[monthKey]!
          .taskHours
          .containsKey(timelog.task.value!.id)) {
        groupByMonth[monthKey]!.taskHours[timelog.task.value!.id] = 0;
      }
      groupByMonth[monthKey]!.taskHours[timelog.task.value!.id] =
          groupByMonth[monthKey]!.taskHours[timelog.task.value!.id]! + hours;
    }
  }

  // Get the start and end date to loop between
  DateTime startDate =
      DateTime.fromMillisecondsSinceEpoch(oldestTimelogTimestamp)
          .getDate
          .getStartOfTheWeek;

  DateTime endDate = DateTime.fromMillisecondsSinceEpoch(latestTimelogTimestamp)
      .getDate
      .getEndOfTheWeek;

  // Days in week
  List<MomentHours> week = [];

  for (var currentDate = endDate;
      currentDate.millisecondsSinceEpoch >= startDate.millisecondsSinceEpoch;
      currentDate = currentDate.subtract(const Duration(days: 1))) {
    if (week.length == 7) {
      daysInWeeks.add(week.reversed.toList());
      week = [];
    }
    final dateTimeString = currentDate.toDateString();
    if (groupByDay.containsKey(dateTimeString)) {
      week.add(groupByDay[dateTimeString]!);
    } else {
      week.add(
          MomentHours(moment: dateTimeString, totalHours: 0, taskHours: {}));
    }
  }

  // Months in Quater
  List<MomentHours> quater = [];

  // Go over each day form latest and oldest month and store MomentHours in monthsInQuaters

  return (daysInWeeks.reversed.toList(), monthsInQuaters);
}

int roundToNearestMultipleOf5(int number) {
  // Calculate the remainder when divided by 5
  int remainder = number % 5;

  // If the remainder is less than 3, round down; otherwise, round up.
  return number + (5 - remainder);
}
