import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:my_reminder_app/models/teacher_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../functionality_widget/enum.dart';


class FirebaseProvider with ChangeNotifier {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  TeacherData? teacherData;
  String? errorMessage;
  LoadingState loadingState = LoadingState.initial;

  /// Fetch teacher data using key from SharedPreferences
  Future<void> fetchTeacherData({required String teacherName}) async {
    log("ok");
    loadingState = LoadingState.loading;
    errorMessage = null;
    notifyListeners();

    try {
      // Get the teacher key from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      // final email =  prefs.getString('email');
      // String userName = email.split('@')[0];
      // final teacherKey = prefs.getString(userName);

      // if (teacherKey == null || teacherKey.isEmpty) {
      //   errorMessage = "Teacher key not found in preferences.";
      //   loadingState = LoadingState.error;
      //   notifyListeners();
      //   return;
      // }

      // Fetch data from Firebase
      final snapshot = await _databaseReference.child('guru/$teacherName').get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        teacherData = TeacherData.fromJson(data);
        loadingState = LoadingState.success;
        log('Fetched data for $teacherName: $teacherData');
      } else {
        errorMessage = "Teacher data not found for key: $teacherName";
        loadingState = LoadingState.error;
      }
    } catch (e) {
      errorMessage = "Error fetching data: $e";
      loadingState = LoadingState.error;
      log(errorMessage!);
    } finally {
      notifyListeners();
    }
  }
}
