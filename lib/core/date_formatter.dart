class DateFormatter {
  const DateFormatter._();

  static const _months = [
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
    'Dec',
  ];

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static String date(DateTime value) =>
      '${value.day} ${_months[value.month - 1]} ${value.year}';

  static String weekday(DateTime value) => _weekdays[value.weekday - 1];

  static String dateTime(DateTime value) => '${date(value)} · ${clock(value)}';

  static String clock(DateTime value) =>
      '${_two(value.hour)}:${_two(value.minute)}';

  static String duration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    final seconds = value.inSeconds.remainder(60);
    if (hours > 0) return '${_two(hours)}:${_two(minutes)}:${_two(seconds)}';
    return '${_two(minutes)}:${_two(seconds)}';
  }

  static String shortDuration(Duration value) {
    if (value.inHours > 0) {
      final minutes = value.inMinutes.remainder(60);
      return '${value.inHours}h ${minutes}m';
    }
    return '${value.inMinutes}m';
  }

  static String thousands(num value) {
    final digits = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
