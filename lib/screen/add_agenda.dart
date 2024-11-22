import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_reminder_app/controllers/data_provider.dart';
import 'package:my_reminder_app/functionality_widget/enum.dart';
import 'package:my_reminder_app/screen/jadwal.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AddAgenda extends StatefulWidget {
  const AddAgenda({super.key});

  @override
  State<AddAgenda> createState() => _AddAgendaState();
}

DateTime? selectedDate;
TimeOfDay? selectedTime;

final keterangan = TextEditingController();
final tanggal = TextEditingController();
final jam = TextEditingController();
final type = TextEditingController();
String _choosenValue = 'Non-KBM';
String? userName;

class _AddAgendaState extends State<AddAgenda> {
  @override
  void initState() {
    super.initState();

    _loadUserName();

    Intl.defaultLocale = 'id_ID';
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

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000), // Earliest date selectable
      lastDate: DateTime(2100), // Latest date selectable
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        tanggal.text = _formatDateTime().toString();
        _pickTime();
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        int hour = pickedTime.hour;
        int minute = pickedTime.minute;
        selectedTime = pickedTime;
        String formattedTime =
            "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";

        // tanggal.text = _formatDateTime().toString();
        jam.text = formattedTime.toString();
        // log(formattedTime.toString());
      });
    }
  }

  String _formatDateTime() {
    if (selectedDate == null && selectedTime == null) {
      return "No date and time selected";
    }

    String formattedDate = selectedDate != null
        ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
        : "No date selected";

    return "$formattedDate";
  }

  //save data
  final DatabaseReference _agendaRef =
      FirebaseDatabase.instance.reference().child('guru');
  String getDayOfWeek(String dateString) {
    // Parse the input date string into a DateTime object
    DateTime date = DateFormat('dd/MM/yyyy').parse(dateString);

    // Define a list of days in Indonesian
    List<String> daysInIndonesian = [
      'minggu',
      'senin',
      'selasa',
      'rabu',
      'kamis',
      'jumat',
      'sabtu'
    ];

    int dayIndex = date.weekday;

    return daysInIndonesian[dayIndex];
  }

  Future<void> saveAgenda() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance
          .reference()
          .child('guru/$userName/mengajar');
      DatabaseEvent event = await ref.once();
      DataSnapshot snapshot = event.snapshot;

      // Convert snapshot data to a Map
      Map<dynamic, dynamic> currentData = {};
      if (snapshot.value is Map) {
        currentData = Map<dynamic, dynamic>.from(snapshot.value as Map);
      }

      // Calculate the next key
      int nextKey = currentData.isEmpty
          ? 0
          : currentData.keys
                  .map((key) => int.tryParse(key.toString()) ?? 0)
                  .reduce((a, b) => a > b ? a : b) +
              1;

      final uuid = Uuid();
      String uniqueKey = uuid.v4();
      DatabaseReference reff =
          FirebaseDatabase.instance.reference().child('guru/$userName');

      Map<String, dynamic> newMengajarData = {
        'hari': getDayOfWeek(tanggal.text),
        'kelas': '-',
        'waktu': jam.text,
        'keterangan': keterangan.text,
        'jenis': _choosenValue,
        'tanggal': selectedDate.toString(),
      };

      await reff
          .child("mengajar")
          .child(uniqueKey) // Use a custom key
          .set(newMengajarData);
      // log('next ${nextKey+1}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const JadwalPage()),
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Agenda Saved')));
    } catch (e) {
      print('Error saving agenda: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save agenda')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Padding(
              padding:
                  EdgeInsets.only(left: 16.0, right: 16, top: 50, bottom: 10),
              child: Center(
                child: Text(
                  "Tambah Agenda",
                  style: TextStyle(fontFamily: "Poppins", fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Keterangan",
                      style: TextStyle(fontFamily: "Poppins", fontSize: 14),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xff7EB8BF).withOpacity(.3)),
                    child: TextFormField(
                      style: const TextStyle(fontFamily: "Poppins"),
                      controller: keterangan,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "keterangan is required";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        border: InputBorder.none,
                        hintText: "Keterangan",
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Tanggal",
                      style: TextStyle(fontFamily: "Poppins", fontSize: 14),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xff7EB8BF).withOpacity(.3)),
                    child: GestureDetector(
                      onTap: () {
                        // log("hallo");
                        _pickDate();
                      },
                      child: TextFormField(
                        enabled: false,
                        style: const TextStyle(fontFamily: "Poppins"),
                        controller: tanggal,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "tanggal is required";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person),
                          border: InputBorder.none,
                          hintText: "Tanggal",
                        ),
                      ),
                    ),
                  ),
                  // waktu

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Waktu",
                      style: TextStyle(fontFamily: "Poppins", fontSize: 14),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xff7EB8BF).withOpacity(.3)),
                    child: GestureDetector(
                      onTap: () {
                        // log("hallo");
                        _pickTime();
                      },
                      child: TextFormField(
                        enabled: false,
                        style: const TextStyle(fontFamily: "Poppins"),
                        controller: jam,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "jam is required";
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person),
                          border: InputBorder.none,
                          hintText: "waktu",
                        ),
                      ),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "Jenis Agenda",
                      style: TextStyle(fontFamily: "Poppins", fontSize: 14),
                    ),
                  ),
                  Container(
                    // width: Media,
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xff7EB8BF).withOpacity(.3)),
                    child: DropdownButton(
                      isExpanded: true,
                      underline: const Text(''),

                      focusColor: Colors.white,
                      value: _choosenValue,
                      //elevation: 5,

                      style: const TextStyle(
                          color: Colors.white, fontFamily: 'Poppins'),
                      iconEnabledColor: Colors.black,
                      items: <String>['Non-KBM', 'KBM']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                                color: Colors.black, fontFamily: 'Poppins'),
                          ),
                        );
                      }).toList(),
                      hint: const Text(
                        "-",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _choosenValue = value!;
                        });
                      },
                    ),
                  ),

                  // button
                  const SizedBox(height: 20),
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * .9,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xff7EB8BF)),
                    child: TextButton(
                        onPressed: () async {
                          Map<String, dynamic> newMengajarData = {
                            'hari': getDayOfWeek(tanggal.text),
                            'kelas': '-',
                            'waktu': jam.text,
                            'keterangan': keterangan.text,
                            'jenis': _choosenValue,
                            'tanggal': selectedDate,
                          };
                          saveAgenda();
                        },
                        child: const Text(
                          "Simpan",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w700),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
