extension DateTimeFormatting on DateTime {
  String toDateString() {
    final months = [
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
    final day = this.day.toString();
    final month = months[this.month - 1];
    final year = this.year.toString();

    return '$month $day, $year';
  }
}
