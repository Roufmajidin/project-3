import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_reminder_app/controllers/data_provider.dart';
import 'package:my_reminder_app/controllers/notifi_fire.dart';
import 'package:my_reminder_app/functionality_widget/colors.dart';
import 'package:my_reminder_app/screen/add_agenda.dart';
import 'package:my_reminder_app/screen/dashboard.dart';
import 'package:my_reminder_app/widget/list_jadwal.dart';
import 'package:my_reminder_app/widget/list_jadwal_dua.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage>
    with SingleTickerProviderStateMixin {
  // var
  String? userName;
  String selectedDate = "";
  late TabController _tabController;
  int currentDayIndex = DateTime.now().weekday - 1;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _tabController = TabController(
      length: 6,
      vsync: this,
      initialIndex: currentDayIndex,
    );

    // Set the initial selected date
    selectedDate = uniqueDays[currentDayIndex];
  }

  void changeStatus(int index) {
    setState(() {
      selectedDate =
          uniqueDays[index]; // Update selectedDate based on the index
    });
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? storedName = prefs.getString('userName');
    setState(() {
      userName = storedName;
    });
    // ignore: use_build_context_synchronously
    final provider = Provider.of<FirebaseProvider>(context, listen: false);
    provider.fetchTeacherData(teacherName: userName!);
  }

  // endvar
  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final DatabaseReference scheduleRef =
        FirebaseDatabase.instance.reference().child("guru/$userName");
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Jadwal Page",
          style: TextStyle(fontFamily: "Poppins", fontSize: 18),
        ),
      ),
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () {
          return Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
        },
        child: Consumer(
            builder: (context, FirebaseProvider firebaseProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 80,
                width: MediaQuery.of(context).size.width,
                child:
                    // list 1
                    StreamBuilder(
                  stream: scheduleRef.onValue,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData ||
                        (snapshot.data!).snapshot.value == null) {
                      return const Center(child: Text('No data available'));
                    }

                    List<String> weekOrder = [
                      'senin',
                      'selasa',
                      'rabu',
                      'kamis',
                      'jumat',
                      'sabtu',
                      // 'minggu'
                    ];
                    // Sort the uniqueDays based on the predefined weekOrder

                    return Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: AppColors.surface.withOpacity(0.8)),
                          child: TabBar(
                            
                            indicatorColor: AppColors.primary,
                            labelStyle: const TextStyle(
                                fontFamily: "Poppins",
                                color: AppColors.textPrimary),
                            tabAlignment: TabAlignment.start,
                            controller: _tabController,
                            onTap: (value) {
                              var uniqd = uniqueDays;
                              // selectedDate = day;
                              changeStatus(
                                  value); // Pass the tapped tab's index
                              log(selectedDate.toString());
                            },
                            isScrollable: true,
                            tabs: weekOrder.map((day) {
                              return Tab(

                                text:
                                    day, // Assuming you have a capitalize method for the day names
                              );
                            }).toList(),
                          ),
                        ));
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "List Agenda",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    // Text(
                    //   selectedDate.toString(),
                    //   style: TextStyle(
                    //       fontFamily: "Poppins",
                    //       fontSize: 16,
                    //       fontWeight: FontWeight.w500),
                    // ),
                  ],
                ),
              ),
              // list keudua
              // data
              JadwalScreen(
                hari: selectedDate,
                isShort: false,
                userName: userName.toString(),
              )
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAgenda()),
          );
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('FAB Clicked! Current Day: $selectedDate'),
          //   ),
          // );
        },
        child: const Icon(Icons.add), // Icon for the FAB
      ),
    );
  }

  // Helper method to map day strings to full day names
  String _getDayString(String day) {
    switch (day.toLowerCase()) {
      case 'senin':
        return 'Senin';
      case 'selasa':
        return 'selasa';
      case 'rabu':
        return 'rabu';
      case 'kamis':
        return 'kamis';
      case 'jumat':
        return 'jumat';
      case 'sabtu':
        return 'Sabtu';
      case 'minggu':
        return 'Min';
      default:
        return 'Unknown';
    }
  }
}

final List<String> uniqueDays = [
  'senin',
  'selasa',
  'rabu',
  'kamis',
  'jumat',
  'sabtu',
  'minggu'
];

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
              fontFamily: "Poppins", fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    ],
  ));
}
