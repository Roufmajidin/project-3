import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_reminder_app/functionality_widget/c.dart';
import 'package:my_reminder_app/functionality_widget/enum.dart';
import 'package:my_reminder_app/functionality_widget/get_jam_terkahir.dart';

class JadwalScreen extends StatefulWidget {
  String userName;

  String hari;
  bool isShort;
  // String? hari;
  late TabController _tabController;

  JadwalScreen(
      {super.key,
      required this.userName,
      required this.hari,
      required this.isShort});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  @override
  Widget build(BuildContext context) {
    // log(widget.hari);
    final DatabaseReference scheduleRef =
        FirebaseDatabase.instance.reference().child("guru/${widget.userName}");
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: StreamBuilder<DatabaseEvent>(
                stream: scheduleRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading data'));
                  }
                  final data = snapshot.data!.snapshot.value;
                  if (data is! Map) {
                    return const Center(child: Text('Invalid data format'));
                  }

                  Map<String, dynamic> teacherData =
                      Map<String, dynamic>.from(data);

                  final mengajarData = teacherData['mengajar'];

                  if (mengajarData is Map) {
                  } else if (mengajarData is List) {}
                  final daysOfWeek = {
                    'senin': 0,
                    'selasa': 1,
                    'rabu': 2,
                    'kamis': 3,
                    'jumat': 4,
                    'sabtu': 5,
                    // 'minggu': 6,
                  };
// filter by widget.hari
                  final filteredData = mengajarData.entries
                      .where((entry) =>
                          entry.value['hari'] != null &&
                          entry.value['hari'].toLowerCase() ==
                              widget.hari.toLowerCase())
                      .toList();
                  final now = DateTime.now();
                  final today = now.weekday - 1;
                  return ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final key = filteredData[index].key;
                        final mengajarDetails = filteredData[index].value;

                        final scheduleTimeTerkahir = DateFormat("HH:mm").parse(
                            getJamDanMenitTerkahir(mengajarDetails['waktu']));
                        final scheduleTime =
                            DateFormat("HH:mm").parse(mengajarDetails['waktu']);

                        int jamTerkahir = scheduleTimeTerkahir.hour;
                        int menitTerahir = scheduleTimeTerkahir.minute;
                        int jam = scheduleTime.hour;
                        int menit = scheduleTime.minute;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            // height: 140,
                            decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 223, 223, 223)
                                    .withOpacity(0.3),
                                borderRadius: const BorderRadius.only(
                                    bottomRight: Radius.circular(12),
                                    bottomLeft: Radius.circular(12))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      print('true $key');
                                      final _scheduleRef = FirebaseDatabase
                                          .instance
                                          .ref('guru/idawati/mengajar');

                                      if (widget.isShort == false) {
                                        _scheduleRef
                                            .child(key)
                                            .remove()
                                            .then((_) {
                                          // print("Data berhasil dihapus");
                                        }).catchError((error) {
                                          // print("Error menghapus data: $error");
                                        });
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: widget.isShort == false
                                                  ? Colors.green
                                                      .withOpacity(0.4)
                                                  : Colors.transparent),
                                          child: Text(
                                            // "j",
                                            mengajarDetails['hari'],
                                            style: const TextStyle(
                                                fontFamily: "Poppins",
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              color:
                                                  Colors.blue.withOpacity(0.2)),
                                          child: Column(
                                            children: [
                                              Text(
                                                // "j",
                                                mengajarDetails['kelas'] == '-'
                                                    ? "Agenda Rapat"
                                                    : '',
                                                style: const TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Text(
                                                // "j",
                                                mengajarDetails['kelas'] == '-'
                                                    ? formatDate(
                                                        mengajarDetails[
                                                            'tanggal'])
                                                    : '',
                                                style: const TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: TimeCountdown(
                                      teacherId: widget.userName.toString(),
                                      tanggalMulai: mengajarDetails['hari'],
                                      // status: mengajarDetails['kelas'] == '-'
                                      //     ? "non-kbm"
                                      //     : '-',
                                      targetHour: jam,
                                      targetMinute: menit,
                                      targetEndMinute: menitTerahir,
                                      targetEndHour: jamTerkahir,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      detailList(mengajarDetails['kelas'],
                                          Icons.view_timeline),
                                      detailList(mengajarDetails['waktu'],
                                          Icons.access_time_outlined),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                })));
  }

  // List<dynamic> filterByCurrentDay(dynamic teacherData) {
  //   final mengajarData = teacherData['mengajar'];
  //   final now = DateTime.now();

  //   // Map weekday numbers to day names in Indonesian
  //   final daysOfWeek = [
  //     'senin',
  //     'selasa',
  //     'rabu',
  //     'kamis',
  //     'jumat',
  //     'sabtu',
  //   ];

  //   // Get the current day name in Indonesian (e.g., "Senin")
  //   final today = daysOfWeek[now.weekday - 1];

  //   if (mengajarData is Map) {
  //     final filteredData = mengajarData[today];
  //     return filteredData != null ? [filteredData] : [];
  //   } else if (mengajarData is List) {
  //     // Handle List case
  //     final filteredData = mengajarData.where((item) {
  //       return item['day'] == today;
  //     }).toList();
  //     return filteredData;
  //   }

  //   return []; // Return an empty list if no valid data format
  // }

  SizedBox detailList(String txt, IconData icon) {
    return SizedBox(
        child: Row(
      children: [
        Icon(
          icon,
          size: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 12),
          child: Text(
            txt,
            style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ));
  }
}
