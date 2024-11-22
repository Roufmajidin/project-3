import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_reminder_app/functionality_widget/c.dart';
import 'package:my_reminder_app/functionality_widget/enum.dart';
import 'package:my_reminder_app/functionality_widget/get_jam_terkahir.dart';

class DataJadwal extends StatefulWidget {
  String userName;

  String hari;
  bool isShort;
  // String? hari;
  late TabController _tabController;

  DataJadwal(
      {super.key,
      required this.userName,
      required this.hari,
      required this.isShort});

  @override
  State<DataJadwal> createState() => _DataJadwalState();
}

class _DataJadwalState extends State<DataJadwal> {
  Future<void> deleteSchedule(String scheduleKey) async {
    try {
      log("apakah ini $scheduleKey");
      await FirebaseDatabase.instance
          .reference()
          .child("guru/${widget.userName}/mengajar/$scheduleKey")
          .remove();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Schedule deleted successfully')),
      );
    } catch (e) {
      print('Error deleting schedule: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete schedule')),
      );
    }
  }

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

                  // Menentukan hari sekarang
                  final now = DateTime.now();
                  final today =
                      now.weekday - 1; // Mengubah weekday (1-7) menjadi (0-6)

                  // Menyaring data dan memisahkan data yang sesuai hari ini
                  List<MapEntry<String, dynamic>> todaySchedules = [];
                  List<MapEntry<String, dynamic>> otherSchedules = [];

                  log("hari w ${widget.hari}");
                  mengajarData.forEach((key, value) {
                    if (value['hari'] != null) {
                      final hariValue = value['hari'].toLowerCase();
                      final hariDariWidget = widget.hari.isNotEmpty
                          ? widget.hari.toLowerCase()
                          : null;

                      // Kondisi untuk menambahkan ke todaySchedules
                      if (hariDariWidget != null &&
                          daysOfWeek[hariValue] == daysOfWeek[hariDariWidget]) {
                        todaySchedules.add(MapEntry(key, value));
                      } else if (hariDariWidget == null &&
                          daysOfWeek[hariValue] == today) {
                        todaySchedules.add(MapEntry(key, value));
                      } else {
                        // Tambahkan ke otherSchedules jika tidak masuk kondisi di atas
                        otherSchedules.add(MapEntry(key, value));
                      }
                    }
                  });

                  // Menggabungkan data dengan data hari ini di bagian atas
                  List<MapEntry<String, dynamic>> sortedData = [
                    ...todaySchedules,
                    ...otherSchedules
                  ];

                  log("sore ${sortedData.toList()}");

                  return ListView.builder(
                      itemCount: widget.isShort == false
                          ? mengajarData.length
                          : sortedData.length,
                      itemBuilder: (context, index) {
                        final sorted = sortedData[index].value;

                        // varr
                        String key = mengajarData.keys.elementAt(index);
                        var mengajarDetails = mengajarData[key];

                        //  String jamAwal = getjamAwal(mengajarDetails['waktu']);
                        //  String jamAAhir = getJamAKhir(mengajarDetails['waktu']);
                        //  String jamAwal = getJamDanMenitTerkahir(mengajarDetails['waktu']);
                        final scheduleTime = DateFormat("HH:mm").parse(
                            widget.isShort == true
                                ? mengajarDetails['waktu']
                                : sorted['waktu']);
                        // var
                        String a = getJamDanMenitTerkahir(widget.isShort == false
                            ? mengajarDetails['waktu']
                            : sorted['waktu']);
                        final scheduleTimeTerkahir =
                            DateFormat("HH:mm").parse(a); // Parse waktu

                        int jamTerkahir = scheduleTimeTerkahir.hour;
                        int menitTerahir = scheduleTimeTerkahir.minute;
                        // Memecah menjadi jam dan menit
                        int jam = scheduleTime.hour;
                        int menit = scheduleTime.minute;

                        // final aa = true;
                        log("ini waktu ${jam} ${menit} sampai ${jamTerkahir} ${menitTerahir})");
                        if (widget.isShort == false) {
                          // mengajard data/delete
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              // height: 140,
                              decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 223, 223, 223)
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
                                        // deleteSchedule(mengajarData[index]);
                                        final _scheduleRef = FirebaseDatabase
                                            .instance
                                            .ref('guru/idawati/mengajar');

                                        if (widget.isShort == false) {
                                          _scheduleRef
                                              .child(key)
                                              .remove()
                                              .then((_) {
                                            print("Data berhasil dihapus");
                                          }).catchError((error) {
                                            print(
                                                "Error menghapus data: $error");
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
                                                color: Colors.blue
                                                    .withOpacity(0.2)),
                                            child: Column(
                                              children: [
                                                Text(
                                                  // "j",
                                                  mengajarDetails['kelas'] ==
                                                          '-'
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
                                                  mengajarDetails['kelas'] ==
                                                          '-'
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
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              // height: 140,
                              decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 223, 223, 223)
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
                                        // print('igg $index');
                                        // deleteSchedule(mengajarData[index]);
                                        // final _scheduleRef = FirebaseDatabase
                                        //     .instance
                                        //     .ref('guru/idawati/mengajar');

                                        // if (widget.isShort == false) {
                                        //   _scheduleRef
                                        //       .child(index.toString())
                                        //       .remove()
                                        //       .then((_) {
                                        //     print("Data berhasil dihapus");
                                        //   }).catchError((error) {
                                        //     print(
                                        //         "Error menghapus data: $error");
                                        //   });
                                        // }
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
                                              sorted['hari'],
                                              style: const TextStyle(
                                                  fontFamily: "Poppins",
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Colors.blue
                                                    .withOpacity(0.2)),
                                            child: Column(
                                              children: [
                                                Text(
                                                  // "j",
                                                  sorted['kelas'] == '-'
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
                                                  sorted['kelas'] == '-'
                                                      ? formatDate(
                                                          sorted['tanggal'])
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
                                        tanggalMulai: sorted['hari'],
                                        // status: sorted['kelas'] == '-'
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
                                        detailList(sorted['kelas'],
                                            Icons.view_timeline),
                                        detailList(sorted['waktu'],
                                            Icons.access_time_outlined),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      });
                })));
  }

  List<dynamic> filterByCurrentDay(dynamic teacherData) {
    final mengajarData = teacherData['mengajar'];
    final now = DateTime.now();

    // Map weekday numbers to day names in Indonesian
    final daysOfWeek = [
      'senin',
      'selasa',
      'rabu',
      'kamis',
      'jumat',
      'sabtu',
    ];

    // Get the current day name in Indonesian (e.g., "Senin")
    final today = daysOfWeek[now.weekday - 1];

    if (mengajarData is Map) {
      final filteredData = mengajarData[today];
      return filteredData != null ? [filteredData] : [];
    } else if (mengajarData is List) {
      // Handle List case
      final filteredData = mengajarData.where((item) {
        return item['day'] == today;
      }).toList();
      return filteredData;
    }

    return []; // Return an empty list if no valid data format
  }

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
