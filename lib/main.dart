import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smartattendancebeacon/admin_dashboard.dart';
import 'package:smartattendancebeacon/bluetooth_scan.dart';
import 'package:smartattendancebeacon/faculty_dashboard.dart';
import 'package:smartattendancebeacon/firebase_options.dart';
import 'package:smartattendancebeacon/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void _onItemTapped(int index) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        'admin_dashboard': (context) => AdminDashboardPage(),
        'faculty_dashboard': (context) => FacultyDashboardPage(),
      },
      title: const String.fromEnvironment('Beacon Attendance Syste'),
    ));
  }
}
