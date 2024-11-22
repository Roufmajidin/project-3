import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // final DatabaseReference ref = FirebaseDatabase.instance.ref('guru/majid');
  SharedPreferences? prefs;

  // Default path in case the prefName is not set
  DatabaseReference? ref;
  NotificationProvider() {
    _initializeNotifications();
    _loadPrefs(); // Load SharedPreferences when the provider is initialized
    _listenForChanges();
  }
  Future<void> _loadPrefs() async {
    prefs = await SharedPreferences.getInstance();
    String? prefName = prefs?.getString('userName'); // Retrieve prefName

    // If prefName is available, update the DatabaseReference path
    if (prefName != null) {
      // ref = FirebaseDatabase.instance.ref('guru/$prefName'); // Update path dynamically
      // log("ini budi $prefName");
      notifyListeners();
    }

    notifyListeners(); // Notify listeners that the path has changed
  }

  // Initialize notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _listenForChanges() async {
    prefs = await SharedPreferences.getInstance();

    String? storedName = prefs?.getString('userName');
    log(storedName.toString());

    final DatabaseReference scheduleRef =
        FirebaseDatabase.instance.ref().child("guru/$storedName");

    scheduleRef.onValue.listen((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;

      var idawatiData = snapshot.value;
      if (idawatiData is Map) {
        Map<String, dynamic> dataMap = idawatiData.cast<String, dynamic>();
        final mengajarData = dataMap['mengajar'];
        DateTime now = DateTime.now();

        if (mengajarData is Map) {
          // Handling if mengajarData is a Map
          mengajarData.forEach((key, jadwal) {
            String waktu = jadwal['waktu'];
            if (waktu != null && waktu.isNotEmpty) {
              List<String> timeRange = waktu.split('-');
              if (timeRange.isNotEmpty) {
                List<String> startTime = timeRange[0].split(':');
                if (startTime.length == 2) {
                  try {
                    int startHour = int.parse(startTime[0]);
                    int startMinute = int.parse(startTime[1]);

                    DateTime scheduledTime = DateTime(
                        now.year, now.month, now.day, startHour, startMinute);

                    log('Jadwal: ${jadwal['kelas']} - ${jadwal['waktu']}');
                    log('Waktu Terjadwal: $scheduledTime');
                    log('Waktu Sekarang: $now');

                    if (scheduledTime.isBefore(now)) {
                      log('Jadwal sudah lewat: Tidak mengirim notifikasi...');
                    } else {
                      // Schedule notification for future
                      Duration difference = scheduledTime.difference(now);
                      log('Jadwal belum lewat: Menunggu...');

                      Future.delayed(difference, () {
                        log('Menjalankan notifikasi untuk: ${jadwal['kelas']}');
                        _sendNotification(
                            dataMap['nama'], jadwal['kelas'], jadwal['waktu']);
                      });
                    }
                  } catch (e) {
                    log('Error parsing waktu: $waktu');
                  }
                }
              }
            } else {
              log('Waktu tidak valid: $waktu');
            }
          });
        } else if (mengajarData is List) {
          // Handling if mengajarData is a List
          for (var jadwal in mengajarData) {
            String waktu = jadwal['waktu'];
            if (waktu != null && waktu.isNotEmpty) {
              List<String> timeRange = waktu.split('-');
              if (timeRange.isNotEmpty) {
                List<String> startTime = timeRange[0].split(':');
                if (startTime.length == 2) {
                  try {
                    int startHour = int.parse(startTime[0]);
                    int startMinute = int.parse(startTime[1]);

                    DateTime scheduledTime = DateTime(
                        now.year, now.month, now.day, startHour, startMinute);

                    log('Jadwal: ${jadwal['kelas']} - ${jadwal['waktu']}');
                    log('Waktu Terjadwal: $scheduledTime');
                    log('Waktu Sekarang: $now');

                    if (scheduledTime.isBefore(now)) {
                      log('Jadwal sudah lewat: Tidak mengirim notifikasi...');
                    } else {
                      // Schedule notification for future
                      Duration difference = scheduledTime.difference(now);
                      log('Jadwal belum lewat: Menunggu...');

                      Future.delayed(difference, () {
                        log('Menjalankan notifikasi untuk: ${jadwal['kelas']}');
                        _sendNotification(
                            dataMap['nama'], jadwal['kelas'], jadwal['waktu']);
                      });
                    }
                  } catch (e) {
                    log('Error parsing waktu: $waktu');
                  }
                }
              }
            } else {
              log('Waktu tidak valid: $waktu');
            }
          }
        }
      } else {
        log("Data untuk guru idawati tidak valid.");
      }
    });
  }

  // Send notification
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
      'Hallo, $nama ${kelas == "-" ? "Jangan lupa rapat ya pada jam" : "jangan lupa mengajar $kelas"} waktu $waktu.',
      platformDetails,
    );
  }
}
