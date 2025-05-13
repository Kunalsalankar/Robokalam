import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String userName = prefs.getString('userName') ?? '';

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

      home: isLoggedIn
          ? HomeScreen(userName: userName)
          : SplashScreen(),
    );
  }
}