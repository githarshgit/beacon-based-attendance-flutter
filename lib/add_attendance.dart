import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddAttendance extends StatefulWidget {
  const AddAttendance({Key? key}) : super(key: key);

  @override
  State<AddAttendance> createState() => _AddAttendanceState();
}

class _AddAttendanceState extends State<AddAttendance> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool isBluetoothEnabled = false;
  String? loggedInStudentMacAddress;
  String? loggedInStudentClass;

  @override
  void initState() {
    super.initState();

    checkBluetoothEnabled();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Attendance'),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          onPressed: () {
            if (isBluetoothEnabled) {
              // Start Bluetooth scanning
              startBluetoothScan();
            } else {
              // Bluetooth is not enabled
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Bluetooth is not enabled.'),
                ),
              );
            }
          },
          child: Text(
            '+ Attendance',
            style: TextStyle(fontSize: 30.0),
          ),
        ),
      ),
    );
  }

  void checkBluetoothEnabled() async {
    // Check if Bluetooth is enabled
    bool isEnabled = await flutterBlue.isOn;
    setState(() {
      isBluetoothEnabled = isEnabled;
      enableBluetoothAndRetrieveStudentInfo();
    });
  }

  void enableBluetoothAndRetrieveStudentInfo() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Retrieve the user document from Firestore
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        String macAddress = userSnapshot['macAddress'];
        String studentClass = userSnapshot['class'];

        setState(() {
          loggedInStudentMacAddress = macAddress;
          loggedInStudentClass = studentClass;
        });
      } else {}
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  void startBluetoothScan() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text('Scanning for beacon...'),
            ],
          ),
        );
      },
    );

    flutterBlue.startScan(timeout: Duration(seconds: 10)).then((results) {
      Navigator.pop(context);
      for (ScanResult result in results) {
        print((result.device.id.id));

        if (result.device.id.id == loggedInStudentMacAddress) {
          // result.advertisementData.localName == loggedInStudentClass

          markAttendanceAsPresent();
          return;
        }
      }
      // Student is not in the class
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No Beacon found nearby!'),
        ),
      );
    }).catchError((error) {
      print('Error scanning for Bluetooth devices: $error');

      Navigator.pop(context);
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error scanning for Bluetooth devices.'),
        ),
      );
    });
  }

  void markAttendanceAsPresent() {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;
    int day = now.day;

    String dateString =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

    String hour = now.hour.toString().padLeft(2, '0');
    String minute = now.minute.toString().padLeft(2, '0');

    String timeAsString = '$hour:$minute';

    // Add attendance record to Firestore
    FirebaseFirestore.instance
        .collection('attendance')
        .doc("$uid _ $dateString")
        .set({
      'uid': uid,
      'class': loggedInStudentClass,
      'macAddress': loggedInStudentMacAddress,
      'status': 'present',
      'date': dateString,
      'time': timeAsString
    }).then((value) {
      // Attendance marked successfully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 5),
          content:
              Text('Attendance Done for $dateString of $loggedInStudentClass'),
        ),
      );
    }).catchError((error) {
      print('Error marking attendance: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark attendance.'),
        ),
      );
    });
  }
}
