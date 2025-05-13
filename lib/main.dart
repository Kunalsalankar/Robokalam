import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Check login status
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String userName = prefs.getString('userName') ?? '';

  // Run the app with the initial route information
  runApp(MyApp(isLoggedIn: isLoggedIn, userName: userName));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String userName;

  const MyApp({Key? key, required this.isLoggedIn, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Robokalam App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      // This is the key change: we decide the initial screen based on login status
      // For first launch or not logged in users, show splash screen
      // For logged in users, go directly to home screen
      home: isLoggedIn
          ? HomeScreen(userName: userName)  // Skip splash screen if logged in
          : SplashScreen(),  // Show splash screen only for first launch/not logged in
    );
  }
}