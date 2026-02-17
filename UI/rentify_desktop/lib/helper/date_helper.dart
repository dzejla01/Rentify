import 'package:intl/intl.dart';

class DateHelper {
  static final _uiFormat = DateFormat('dd.MM.yyyy');

  static String format(DateTime date) => _uiFormat.format(date.toLocal());

  static String toIsoFromUi(String value) {
    final parts = value.split('.');
    if (parts.length < 3) {
      throw FormatException('Neispravan format datuma (dd.MM.yyyy)');
    }
    final day = parts[0].trim().padLeft(2, '0');
    final month = parts[1].trim().padLeft(2, '0');
    final year = parts[2].trim();
    return '${year}-${month}-${day}T00:00:00.000Z';
  }

  static String? formatNullable(DateTime? date) {
    if (date == null) return null;
    return format(date);
  }

  static DateTime toUtcDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  static String toUtcIso(DateTime date) => toUtcDate(date).toIso8601String();

  static String? toUtcIsoNullable(DateTime? date) {
    if (date == null) return null;
    return toUtcIso(date);
  }

  static DateTime safeDayInMonth(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    final safeDay = day > lastDay ? lastDay : day;
    return DateTime(year, month, safeDay);
  }
}
