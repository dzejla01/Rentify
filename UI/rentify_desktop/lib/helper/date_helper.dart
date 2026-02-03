import 'package:intl/intl.dart';

class DateHelper {

  static final _uiFormat = DateFormat('dd.MM.yyyy');


  static String format(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  static String? formatNullable(DateTime? date) {
    if (date == null) return null;
    return format(date);
  }

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

}
