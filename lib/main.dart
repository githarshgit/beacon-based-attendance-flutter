import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smartattendancebeacon/add_student_excel.dart';
import 'package:smartattendancebeacon/admin_dashboard.dart';
import 'package:smartattendancebeacon/bluetooth_scan.dart';
import 'package:smartattendancebeacon/get_attendance.dart';
import 'add_student.dart';
import 'package:smartattendancebeacon/faculty_dashboard.dart';
import 'package:smartattendancebeacon/firebase_options.dart';
import 'package:smartattendancebeacon/login_page.dart';
import 'test.dart';

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
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        'admin_dashboard': (context) => AdminDashboardPage(),
        'faculty_dashboard': (context) => FacultyDashboardPage(),
        'bluetooth_page': (context) => BluetoothScanPage(),
        'student_form': (context) => AddStudent(),
        'test': (context) => FetchAttendance(),
        'addstudent': (context) => AddStudent(),
        "get_attendance": (context) => AddStudentExcel(),
      },
      title: const String.fromEnvironment('Beacon Attendance System'),
    ));
  }
}
