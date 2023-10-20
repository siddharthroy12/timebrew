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
  if (seconds > 0) {
    result += "$seconds seconds";
  }

  final trim = result.trim();

  return trim.isNotEmpty ? trim : "No time spent";
}
