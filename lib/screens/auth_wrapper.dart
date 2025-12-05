import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'caregiver_home_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  String? _userId;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
      _userRole = prefs.getString('userRole');
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_userId != null && _userRole != null) {
      if (_userRole == 'caregiver') {
        return CaregiverHomeScreen(userId: _userId!);
      } else {
        return HomeScreen(
          userName:
              'User', // We can fetch the name later or store it in prefs too
          userId: _userId!,
        );
      }
    }

    return const LoginScreen();
  }
}
