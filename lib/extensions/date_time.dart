const months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];

extension DateTimeFormatting on DateTime {
  String toDateString() {
    final day = this.day.toString();
    final month = months[this.month - 1];
    final year = this.year.toString();

    return '$month $day, $year';
  }

  static DateTime fromDateString(String dateString) {
    final splits = dateString.split(' ');
    final month = months.indexOf(splits[0]) + 1;
    final day = int.parse(splits[1].replaceAll(',', ''));
    final year = int.parse(splits[2]);

    return DateTime(year, month, day);
  }
}

extension DateTimeExtension on DateTime {
  int get weekOfMonth {
    var date = this;
    final firstDayOfTheMonth = DateTime(date.year, date.month, 1);
    int sum = firstDayOfTheMonth.weekday - 1 + date.day;
    if (sum % 7 == 0) {
      return sum ~/ 7;
    } else {
      return sum ~/ 7 + 1;
    }
  }

  DateTime get lastDayOfMonth =>
      month < 12 ? DateTime(year, month + 1, 0) : DateTime(year + 1, 1, 0);
  DateTime get firstDayOfMonth => DateTime(year, month, 1);

  DateTime get getDate => DateTime(year, month, day);

  DateTime get getStartOfTheWeek =>
      subtract(Duration(days: weekday - 2)).getDate;

  DateTime get getEndOfTheWeek =>
      add(Duration(days: DateTime.daysPerWeek - weekday - 1)).getDate;
}
