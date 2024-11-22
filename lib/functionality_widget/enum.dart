import 'package:intl/intl.dart';

enum LoadingState { initial, loading, error, success }

String formatDate(String inputDate) {
  try {
    // Parse the input date as the full timestamp format (yyyy-MM-dd HH:mm:ss.SSS)
    DateTime parsedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss.SSS').parse(inputDate);

    // Format the parsed date to the desired output format (e.g., 22 November 2024)
    return DateFormat('d MMMM yyyy', 'id_ID').format(parsedDate);
  } catch (e) {
    print('Error formatting date: $e');
    return inputDate; // Return original input if an error occurs
  }
}

String formatTime(String timeRange) {
  // Split the time range string into start and end times
  List<String> times = timeRange.split('-');
  if (times.length != 2) {
    return 'Invalid time format';
  }

  // Parse start and end time
  DateTime startTime = _parseTime(times[0]);
  DateTime endTime = _parseTime(times[1]);

  // Get the formatted time in desired format
  String formattedStartTime = DateFormat('HH:mm').format(startTime);
  String formattedEndTime = DateFormat('HH:mm').format(endTime);

  // Calculate the time difference
  Duration difference = endTime.difference(startTime);

  // Format the output string as "xx jam menit menuju jadwal ini"
  return "${difference.inHours} jam ${difference.inMinutes % 60} menit menuju jadwal ini";
}

DateTime _parseTime(String time) {
  // Parsing the time string to DateTime
  List<String> timeParts = time.split(':');
  int hour = int.parse(timeParts[0]);
  int minute = int.parse(timeParts[1]);
  return DateTime(0, 0, 0, hour,
      minute); // Return a DateTime object with year, month, day as default
}
