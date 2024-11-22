import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../functionality_widget/enum.dart';


class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  User? get user => _user;
  String? get errorMessage => _errorMessage;
  LoadingState _loadingState = LoadingState.initial;
  LoadingState get loadingState => _loadingState;

  // Login function
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    _loadingState = LoadingState.loading;
    notifyListeners();

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      log("message {$_user");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', _user!.uid);

      // hapus "@" from email ==> name
      String userName = email.split('@')[0];
      await prefs.setString('userName', userName);

      _loadingState = LoadingState.success;

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      _loadingState = LoadingState.error;
    } finally {
      // _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> logout() async {
    // Sign out the user from Firebase
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('userId');
    await prefs.remove('userName');
    _user = null;

    notifyListeners();
  }
}
