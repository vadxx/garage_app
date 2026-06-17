DateTime epochSecondsToDateTime(int epochSeconds) =>
    DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);

int dateTimeToEpochSeconds(DateTime dt) => dt.millisecondsSinceEpoch ~/ 1000;

String formatEpochDate(int epochSeconds) {
  final dt = epochSecondsToDateTime(epochSeconds);
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

int currentEpochSeconds() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

int parseDateString(String dateStr) {
  dateStr = dateStr.trim();
  final parts = dateStr.split('-');
  if (parts.length != 3) throw FormatException('Invalid date: "$dateStr"');

  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) {
    throw FormatException('Invalid date: "$dateStr"');
  }

  // Validate via DateTime — catches Feb 29 non-leap, month > 12, day > 31.
  final dt = DateTime(year, month, day);
  if (dt.year != year || dt.month != month || dt.day != day) {
    throw FormatException('Invalid date: "$dateStr"');
  }

  return dateTimeToEpochSeconds(dt);
}

DateTime datePickerMinDate() => DateTime(2000);

DateTime datePickerMaxDate() => DateTime.now().add(const Duration(days: 365));
