import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final DatabaseReference _database = FirebaseDatabase.instance.ref(); // Referensi database
  DatabaseReference ref = FirebaseDatabase.instance.ref('guru/idawati');

  // Fungsi untuk mengambil data dari node 'idawati'
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Inisialisasi timezones untuk notifikasi
    _initializeNotifications();
    _listenForChanges();
  }

 void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  
 // Fungsi untuk mendengarkan perubahan data pada Firebase
  void _listenForChanges() {
    DatabaseReference ref = FirebaseDatabase.instance.ref('guru/idawati');
    ref.onValue.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;

      // Cast data secara aman
      var idawatiData = snapshot.value;
      if (idawatiData is Map) {
        Map<String, dynamic> dataMap = idawatiData.cast<String, dynamic>();

        var mengajarData = dataMap['mengajar'] as List<dynamic>;
        DateTime now = DateTime.now();

        // Loop untuk setiap jadwal
        for (var jadwal in mengajarData) {
          String waktu = jadwal['waktu'];
          List<String> timeRange = waktu.split('-');
          List<String> startTime = timeRange[0].split(':');

          // Ambil jam dan menit dari waktu mulai
          int startHour = int.parse(startTime[0]);
          int startMinute = int.parse(startTime[1]);

          // Buat objek DateTime dari waktu mulai
          DateTime scheduledTime =
              DateTime(now.year, now.month, now.day, startHour, startMinute);

          // Log jadwal yang diproses
          log('Jadwal: ${jadwal['kelas']} - ${jadwal['waktu']}');
          log('Waktu Terjadwal: $scheduledTime');
          log('Waktu Sekarang: $now');

          if (scheduledTime.isBefore(now)) {
            log('Jadwal sudah lewat: Mengirim notifikasi...');
            // _sendNotification(dataMap['nama'], jadwal['kelas'], jadwal['waktu']);
          } else {
            // Jadwalkan notifikasi di masa depan
            Duration difference = scheduledTime.difference(now);
            log('Jadwal belum lewat: Menunggu...');
            Future.delayed(difference, () {
              log('Menjalankan notifikasi untuk: ${jadwal['kelas']}');
              _sendNotification(dataMap['nama'], jadwal['kelas'], jadwal['waktu']);
            });
          }
        }
      } else {
        log("Data untuk guru idawati tidak valid.");
      }
    });
  }

  

  void _sendNotification(String nama, String kelas, String waktu) async {
  var androidDetails = const AndroidNotificationDetails(
    'your_channel_id', 
    'your_channel_name', 
    importance: Importance.max, 
    priority: Priority.high,
  );

  var platformDetails = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0, 
    'Notifikasi Pengajaran', 
    'Guru $nama kelas $kelas waktu $waktu.', 
    platformDetails,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Firebase Schedule Notification")),
      body: Center(child: Text("Cek Jadwal dan Kirim Notifikasi")),
    );
  }
}
