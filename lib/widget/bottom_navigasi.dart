import 'package:flutter/material.dart';
import 'package:my_reminder_app/screen/dashboard.dart';
import 'package:my_reminder_app/screen/jadwal.dart';

class BottomX extends StatefulWidget {
  @override
  _BottomXState createState() => _BottomXState();
}

class _BottomXState extends State<BottomX> {
  int _currentIndex = 0;

  // List halaman
  final List<Widget> _pages = [
    Dashboard(),
   JadwalPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: _pages[_currentIndex], // Menampilkan halaman sesuai index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Index aktif
        onTap: (int index) {
          setState(() {
            _currentIndex = index; // Mengubah halaman
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
         
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
