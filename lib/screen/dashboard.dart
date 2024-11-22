import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_reminder_app/controllers/data_provider.dart';
import 'package:my_reminder_app/controllers/general_controller.dart';
import 'package:my_reminder_app/controllers/notifi_fire.dart';
import 'package:my_reminder_app/login.dart';
import 'package:my_reminder_app/screen/add_agenda.dart';
import 'package:my_reminder_app/screen/jadwal.dart';
import 'package:my_reminder_app/widget/list_jadwal.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String? userName;

  @override
  void initState() {
    super.initState();

    _loadUserName();

    Intl.defaultLocale = 'id_ID';
  }

  bool isShort = true;

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

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          return Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, _) => const Dashboard(),
              transitionsBuilder: (context, animation, _, child) {
                // Disable animation by returning the child directly
                return child;
              },
            ),
          );
        },
        child: SingleChildScrollView(
          child: Consumer(
              builder: (context, FirebaseProvider firebaseProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(
                      left: 16.0, right: 16, top: 50, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Hallo, Welcome brack",
                            style:
                                TextStyle(fontFamily: "Poppins", fontSize: 18),
                          ),
                          userName == null
                              ? const CircularProgressIndicator()
                              : Container(
                                  padding: EdgeInsets.only(left: 5, right: 60),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.2),
                                  ),
                                  child: Text(
                                    userName!,
                                    style: const TextStyle(
                                        fontFamily: "Poppins",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                        ],
                      ),
                      InkWell(
                        onTap: () async {
                          await Provider.of<AuthProvider>(context,
                                  listen: false)
                              .logout();
                          // ignore: use_build_context_synchronously
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          );
                        },
                        child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(
                              Icons.person_2_rounded,
                              color: Colors.white,
                            )),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(12),
                            bottomLeft: Radius.circular(12))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 100,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isShort = !isShort;
                            });
                          },
                          child: Row(
                            children: [
                              const Text(
                                "Agenda",
                                style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                              Icon(Icons.sort)
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          //  Navigator.push(
                          //   context,
                          //   PageRouteBuilder(
                          //     pageBuilder: (context, animation1, animation2) =>
                          //         const AddAgenda(),
                          //     transitionDuration: Duration.zero,
                          //     reverseTransitionDuration: Duration.zero,
                          //   ),
                          // );
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  const JadwalPage(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                        child: const Text(
                          "Semua",
                          style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                // data
                DataJadwal(
                  userName: userName.toString(),
                  isShort: isShort,
                  hari: "",
                )
              ],
            );
          }),
        ),
      ),
    );
  }
}
