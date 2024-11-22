import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  CustomAppBar({required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
          "Jadwal Page",
          style: TextStyle(fontFamily: "Poppins", fontSize: 18),
        ),
      centerTitle: true,
      // backgroundColor: Appp,
      actions: actions,
      elevation: 4, // Bayangan di bawah AppBar
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16), // Radius untuk bagian bawah
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0); // Tinggi standar AppBar
}