import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDuration(String duration) {
    if (duration.isEmpty) return '0h 0min';

    final parts = duration.split(':');
    if (parts.length < 2) return '0h 0min';

    return '${parts[0]}h ${parts[1]}min';
  }

  static DateTime parseDateTime(String dateTimeStr) {
    try {
      final parts = dateTimeStr.split(' ');
      if (parts.length < 2) return DateTime.now();

      final dateParts = parts[0].split('/');
      if (dateParts.length < 3) return DateTime.now();

      final formattedDate =
          '${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}';
      return DateTime.parse('$formattedDate ${parts[1]}:00');
    } catch (e) {
      return DateTime.now();
    }
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  static int parseDurationToMinutes(String duration) {
    if (duration.isEmpty) return 0;

    try {
      final parts = duration.split(':');
      if (parts.length < 2) return 0;

      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    } catch (e) {
      return 0;
    }
  }

  static String calculateConnectionTime(
    DateTime arrival,
    DateTime? nextDeparture,
  ) {
    if (nextDeparture == null) return '';

    final difference = nextDeparture.difference(arrival);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    return '$hours h $minutes min';
  }
}
