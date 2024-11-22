import 'package:intl/intl.dart';

String formatWaktu(String waktu) {
  if (waktu.contains('-')) {
    // If it's a time range, split it into start and end times
    try {
      List<String> times = waktu.split('-');
      final startTime = DateFormat("HH").parse(times[0]);
      final endTime = DateFormat("HH").parse(times[1]);
      return '${DateFormat("HH:mm").format(startTime)}-${DateFormat("HH:mm").format(endTime)}';
    } catch (e) {
      return 'Invalid time range';
    }
  } else {
    // If it's a single time, use it for both start and end times
    try {
      final singleTime = DateFormat("HH").parse(waktu);
      return '${DateFormat("HH:mm").format(singleTime)}-${DateFormat("HH:mm").format(singleTime)}';
    } catch (e) {
      return 'Invalid time format';
    }
  }
}

String getJamAwal(String waktu) {
  // Memisahkan waktu mulai dan waktu selesai
  List<String> waktuParts = waktu.split('-');

  if (waktuParts.length == 1) {
    // Jika hanya ada satu waktu (misalnya "10:02"), gunakan waktu yang sama sebagai waktu selesai
    try {
      final startTime = DateFormat("HH").parse(waktuParts[0].trim());
      String endTimeFormatted = DateFormat("HH")
          .format(startTime); // Waktu selesai adalah waktu yang sama
      return '$endTimeFormatted'; // Mengembalikan waktu yang sama
    } catch (e) {
      return 'Waktu tidak valid';
    }
  } else if (waktuParts.length == 2) {
    // Jika ada rentang waktu (misalnya "08:00-08:45"), kembalikan waktu selesai
    try {
      final endTime = DateFormat("HH").parse(waktuParts[1].trim());
      String endTimeFormatted = DateFormat("HH").format(endTime);
      return '$endTimeFormatted'; // Mengembalikan waktu selesai dari rentang waktu
    } catch (e) {
      return 'Waktu tidak valid';
    }
  } else {
    return 'Waktu tidak valid'; // Jika format tidak sesuai
  }
}

String getJamAkhir(String waktu) {
  // Memisahkan waktu mulai dan waktu selesai
  List<String> waktuParts = waktu.split('-');

  if (waktuParts.length == 1) {
    // Jika hanya ada satu waktu (misalnya "10:02"), gunakan waktu yang sama sebagai waktu selesai
    try {
      final startTime = DateFormat("HH").parse(waktuParts[0].trim());
      String endTimeFormatted = DateFormat("HH")
          .format(startTime); // Waktu selesai adalah waktu yang sama
      return '$endTimeFormatted'; // Mengembalikan waktu yang sama
    } catch (e) {
      return 'Waktu tidak valid';
    }
  } else if (waktuParts.length == 2) {
    // Jika ada rentang waktu (misalnya "08:00-08:45"), kembalikan waktu selesai
    try {
      final endTime = DateFormat("HH").parse(waktuParts[1].trim());
      String endTimeFormatted = DateFormat("HH").format(endTime);
      return '$endTimeFormatted'; // Mengembalikan waktu selesai dari rentang waktu
    } catch (e) {
      return 'Waktu tidak valid';
    }
  } else {
    return 'Waktu tidak valid'; // Jika format tidak sesuai
  }
}

String getJamDanMenitTerkahir(String waktu) {
  if (waktu.contains('-')) {
    // Memisahkan waktu mulai dan waktu selesai jika ada tanda "-"
    List<String> waktuParts = waktu.split('-');
    
    // Parsing waktu selesai
    final endTime = DateFormat("HH:mm").parse(waktuParts[1].trim());
    int jamSelesai = endTime.hour;
    int menitSelesai = endTime.minute;

    // Memastikan format menit memiliki dua digit
    String menitSelesaiFormatted = menitSelesai.toString().padLeft(2, '0');

    // Mengembalikan waktu selesai dengan format jam:menit
    return "$jamSelesai:$menitSelesaiFormatted";
  } else {
    // Jika hanya waktu tunggal, formatnya adalah "jam:menit-(sampai) jam:menit"
    final startTime = DateFormat("HH:mm").parse(waktu.trim());
    int jamMulai = startTime.hour;
    int menitMulai = startTime.minute;

    // Memastikan format menit memiliki dua digit
    String menitMulaiFormatted = menitMulai.toString().padLeft(2, '0');

    // Mengembalikan string dengan format "jam:menit-(sampai) jam:menit"
    return "$jamMulai:$menitMulaiFormatted-(sampai) $jamMulai:$menitMulaiFormatted";
  }
}
