import 'package:timebrew/services/isar_service.dart';
import 'package:timebrew/extensions/date_time.dart';

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
