import 'package:intl/intl.dart';
import 'package:get/get.dart';

class AppDateUtils {
  static String todayKey() {
    final now = DateTime.now();
    return formatDateKey(now);
  }

  static String formatDateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  static DateTime parseDateKey(String dateKey) {
    return DateTime.parse(dateKey);
  }

  static String weekRange(DateTime date) {
    final start = date.subtract(Duration(days: date.weekday - 1));
    final end = start.add(const Duration(days: 6));
    final loc = Get.locale?.languageCode;
    final fmt = DateFormat('d MMM', loc);
    return '${fmt.format(start)} – ${fmt.format(end)}, ${end.year}';
  }

  static String monthLabel(DateTime date) {
    final loc = Get.locale?.languageCode;
    return DateFormat('MMMM, y', loc).format(date);
  }

  static DateTime startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static DateTime endOfWeek(DateTime date) {
    return startOfWeek(date).add(const Duration(days: 6));
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  static DateTime startOfYear(DateTime date) => DateTime(date.year, 1, 1);
  static DateTime endOfYear(DateTime date) => DateTime(date.year, 12, 31);
  static String yearLabel(DateTime date) => date.year.toString();

  static String viDayName(DateTime date) {
    const days = [
      'Thứ hai',
      'Thứ ba',
      'Thứ tư',
      'Thứ năm',
      'Thứ sáu',
      'Thứ bảy',
      'Chủ nhật',
    ];
    return days[date.weekday - 1];
  }

  static String formatViDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} Thg ${date.month}, ${date.year}';
  }
}
