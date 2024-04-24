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
  bool isBluetoothEnabled = false; // Flag to check if Bluetooth is enabled
  String? loggedInStudentMacAddress; // Logged-in student's MAC address
  String? loggedInStudentClass; // Logged-in student's class

  @override
  void initState() {
    super.initState();
    // Check if Bluetooth is enabled on app start
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
              borderRadius:
                  BorderRadius.circular(30.0), // Making the button round
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
    // Assuming you have access to the authenticated user's UID
    String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Retrieve the user document from Firestore
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userSnapshot.exists) {
        // Get the data from the user document
        String macAddress = userSnapshot['macAddress'];
        String studentClass = userSnapshot['class'];
        // Set the logged-in student's information in the state
        setState(() {
          loggedInStudentMacAddress = macAddress;
          loggedInStudentClass = studentClass;
        });
      } else {
        // User document does not exist
        // Handle this case accordingly
      }
    } catch (error) {
      // Error occurred while fetching user document
      // Handle the error
      print('Error fetching user data: $error');
    }
  }

  void startBluetoothScan() {
    // Show progress indicator while scanning
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(), // Progress indicator
              SizedBox(height: 10),
              Text('Scanning for beacon...'), // Message
            ],
          ),
        );
      },
    );

    flutterBlue.startScan(timeout: Duration(seconds: 10)).then((results) {
      Navigator.pop(context); // Dismiss the dialog when scanning is complete
      for (ScanResult result in results) {
        print((result.device.id.id));
        // Check if the scanned device MAC address and class match with the logged-in student's information
        if (result.device.id.id == loggedInStudentMacAddress) {
          // result.advertisementData.localName == loggedInStudentClass
          // Mark attendance as present with current date and time
          markAttendanceAsPresent();
          return;
        }
      }
      // Student is not in the class
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are out of range from Beacon.'),
        ),
      );
    }).catchError((error) {
      print('Error scanning for Bluetooth devices: $error');
      // Dismiss the dialog in case of error
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
    // Get the current date and time
    DateTime now = DateTime.now();
    int year = now.year;
    int month = now.month;
    int day = now.day;

    // Form the date string in YYYY-MM-DD format
    String dateString =
        '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

    String hour =
        now.hour.toString().padLeft(2, '0'); // Ensure two digits for hour
    String minute =
        now.minute.toString().padLeft(2, '0'); // Ensure two digits for minute

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
          content: Text('Attendance marked as present.'),
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
