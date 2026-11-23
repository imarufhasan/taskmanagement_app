import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _displayFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');

  static String formatDisplay(DateTime? date) {
    if (date == null) return '';
    return _displayFormat.format(date);
  }

  static String formatIso(DateTime? date) {
    if (date == null) return '';
    return _isoFormat.format(date);
  }

  static bool isOverdue(DateTime? dueDate, String status) {
    if (dueDate == null || status == 'completed') return false;
    final now = DateTime.now();
    return dueDate.isBefore(DateTime(now.year, now.month, now.day));
  }
}
