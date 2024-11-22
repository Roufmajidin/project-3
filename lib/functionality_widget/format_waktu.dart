import 'package:intl/intl.dart';



String formatWaktu(String waktu) {
  if (waktu.contains('-')) {
    try {
      List<String> times = waktu.split('-');
      final startTime = DateFormat("HH:mm").parse(times[0]);
      final endTime = DateFormat("HH:mm").parse(times[1]);
      return '${DateFormat("HH:mm").format(startTime)}-${DateFormat("HH:mm").format(endTime)}';
    } catch (e) {
      return 'Invalid time range';
    }
  } else {
    try {
      final singleTime = DateFormat("HH:mm").parse(waktu);
      return '${DateFormat("HH:mm").format(singleTime)}-${DateFormat("HH:mm").format(singleTime)}';
    } catch (e) {
      return 'Invalid time format';
    }
  }
}



