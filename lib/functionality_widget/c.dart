import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeCountdown extends StatefulWidget {
  final String teacherId; // Teacher's ID for fetching schedule
  final String tanggalMulai; // Day of the week when class starts
  final int targetHour; // Target hour for the class start
  final int targetMinute; // Target minute for the class start
  final int targetEndHour; // Target hour for the class end
  final int targetEndMinute; // Target minute for the class end
  // final String status; // Target minute for the class end

  TimeCountdown({
    required this.teacherId,
    required this.tanggalMulai,
    required this.targetHour,
    required this.targetMinute,
    required this.targetEndHour,
    required this.targetEndMinute,
    // required this.status,
  });

  @override
  _TimeCountdownState createState() => _TimeCountdownState();
}

// Enum for status
enum ClassStatus { notStarted, waiting, ongoing, finished, dayPassed }

class _TimeCountdownState extends State<TimeCountdown> {
  late Timer _timer;
  Duration _timeLeft = const Duration();
  ClassStatus status = ClassStatus.notStarted;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();

    _startCountdown();
  }

  void _startCountdown() {
    log('ini di ct ${widget.targetHour} ${widget.targetMinute} ${widget.targetEndHour} ${widget.targetEndMinute}');
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _now = DateTime.now(); // Update current time every second

      setState(() {
        int todayIndex = _now.weekday -
            1; // Get index of current day (0 = Monday, 1 = Tuesday, ..., 6 = Sunday)
        int targetIndex = _getDayIndexFromString(
            widget.tanggalMulai); // Get index from the schedule day

        // Check if the schedule day has already passed this week
        if (targetIndex < todayIndex) {
          status = ClassStatus.dayPassed;
        } else if (targetIndex == todayIndex) {
          // If today is the target day, check if the class has started or ended
          DateTime targetStartTime = DateTime(_now.year, _now.month, _now.day,
              widget.targetHour, widget.targetMinute);
          DateTime targetEndTime = DateTime(_now.year, _now.month, _now.day,
              widget.targetEndHour, widget.targetEndMinute);

          if (_now.isBefore(targetStartTime)) {
            status = ClassStatus.notStarted;
            _timeLeft = targetStartTime.difference(_now);
          } else if (_now.isAfter(targetEndTime)) {
            status = ClassStatus.finished;
          } else {
            status = ClassStatus.ongoing;
            _timeLeft = targetEndTime.difference(_now);
          }
        } else {
          // Calculate how many days until the target day and set status as "waiting"
          int daysRemaining = (targetIndex - todayIndex) % 7;
          status = ClassStatus.waiting;
          _timeLeft = Duration(days: daysRemaining);
        }
      });
    });
  }

  // Helper method to get the index of the day (0 = Monday, 1 = Tuesday, ..., 6 = Sunday)
  int _getDayIndexFromString(String dayString) {
    const Map<String, int> dayMap = {
      'senin': 0,
      'selasa': 1,
      'rabu': 2,
      'kamis': 3,
      'jumat': 4,
      'sabtu': 5,
      // 'minggu': 6,
    };

    return dayMap[dayString.toLowerCase()] ??
        0; // Default to Monday if dayString is invalid
  }

  String getStatusText() {
    switch (status) {
      case ClassStatus.dayPassed:
        return "Hari Terlewat";
      case ClassStatus.notStarted:
        return "${_timeLeft.inHours} jam ${_timeLeft.inMinutes % 60} menit ${_timeLeft.inSeconds % 60}d menuju jadwal";
      case ClassStatus.waiting:
        return "${_timeLeft.inDays} Hari Lagi";
      case ClassStatus.ongoing:
        return "Sedang Kelas: ${_timeLeft.inHours} jam ${_timeLeft.inMinutes % 60} menit ${_timeLeft.inSeconds % 60} detik";
      case ClassStatus.finished:
        return "Jam Selesai";
      default:
        return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    String statusText = getStatusText();

    List<TextSpan> textSpans = [];
    if (statusText.contains("menuju jadwal")) {
      textSpans.add(const TextSpan(
        text: "Jadwal dimulai dalam: ",
        style: TextStyle(color: Colors.black), // normal color
      ));
      textSpans.add(TextSpan(
        text: "${_timeLeft.inHours} jam ${_timeLeft.inMinutes % 60} menit ${_timeLeft.inSeconds % 60} detik",
        style: const TextStyle(color: Colors.red), // red color
      ));
    } else {
      textSpans.add(TextSpan(
        text: statusText,
        style: const TextStyle(color: Colors.black), // default black color
      ));
    }

    return RichText(
      text: TextSpan(
        children: textSpans,
        style: DefaultTextStyle.of(context).style,
      ),
    );
  }


  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
