import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  // We can make these optional with default values to maintain compatibility
  // with both your original code and our fixed version
  final bool? isLoggedIn;
  final String? userName;

  const SplashScreen({Key? key, this.isLoggedIn, this.userName}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // This function checks login status and navigates accordingly
  Future<void> _checkLoginStatus() async {
    // If isLoggedIn was provided by constructor, use it
    // Otherwise, fetch it from SharedPreferences
    bool isUserLoggedIn;
    String userName = '';

    if (widget.isLoggedIn != null) {
      // Use the value passed in constructor
      isUserLoggedIn = widget.isLoggedIn!;
      userName = widget.userName ?? '';
    } else {
      // No value passed, check SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      isUserLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      userName = prefs.getString('userName') ?? '';
    }

    // Show splash screen for 3 seconds as in your original code
    Timer(Duration(seconds: 3), () {
      if (isUserLoggedIn) {
        // User is already logged in, go to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(userName: userName),
          ),
        );
      } else {
        // User is not logged in, go to login screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using your image asset
            Image.asset(
              'assets/images/img.png',
              height: 150,
            ),
            SizedBox(height: 20),
            Text(
              'Robokalam App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}