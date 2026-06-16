DateTime epochSecondsToDateTime(int epochSeconds) =>
    DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);

int dateTimeToEpochSeconds(DateTime dt) =>
    dt.millisecondsSinceEpoch ~/ 1000;

String formatEpochDate(int epochSeconds) {
  final dt = epochSecondsToDateTime(epochSeconds);
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

int currentEpochSeconds() => DateTime.now().millisecondsSinceEpoch ~/ 1000;

DateTime datePickerMinDate() => DateTime(2000);

DateTime datePickerMaxDate() => DateTime.now().add(const Duration(days: 365));
