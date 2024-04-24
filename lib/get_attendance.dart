import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartattendancebeacon/class_dropdown.dart';

class FetchAttendance extends StatefulWidget {
  @override
  _FetchAttendanceState createState() => _FetchAttendanceState();
}

class _FetchAttendanceState extends State<FetchAttendance> {
  String? selectedClass;
  String? selectedMacAddress;
  TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Class:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            classDropdown(
              onChanged: (String? selectedValue, String? macAddress) {
                setState(() {
                  selectedClass = selectedValue;
                  selectedMacAddress = macAddress;
                  print(macAddress);
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Select Date:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != _selectedDate) {
                  setState(() {
                    _selectedDate = pickedDate;
                    _dateController.text =
                        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (selectedClass != null) {
                  // Fetch attendance data for the selected class and date
                  fetchAttendance(selectedClass!, _selectedDate);
                } else {
                  // Class not selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select a class.'),
                    ),
                  );
                }
              },
              child: Text('Fetch Attendance'),
            ),
            SizedBox(height: 20),
            Text(
              'Attendance List:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: attendanceData.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      title: Text(
                        attendanceData[index]['name'],
                        style: TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(attendanceData[index]['email']),
                      trailing: Text(
                        attendanceData[index]['present'] ? 'Present' : 'Absent',
                        style: TextStyle(
                          color: attendanceData[index]['present']
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> attendanceData = [];

  Future<void> fetchAttendance(
      String selectedClass, DateTime selectedDate) async {
    // Form the date string in YYYY-MM-DD format
    String dateString =
        '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    print(dateString);
    try {
      // Fetch all users of the selected class
      QuerySnapshot<Map<String, dynamic>> usersSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('macAddress', isEqualTo: selectedClass)
              .get();

      // Extract all the student UIDs and initialize a map to store attendance status
      List<String> studentUIDs = [];
      Map<String, bool> attendanceMap = {};

      usersSnapshot.docs.forEach((userDoc) {
        String uid = userDoc.id;
        String name = userDoc.data()['name'];
        String email = userDoc.data()['email'];

        // Add student UID to the list
        studentUIDs.add(uid);
        // print(studentUIDs);
        // Initialize attendance status for each student as false (not present)
        attendanceMap[uid] = false;

        // Print student name and email (you can remove this if not needed)
        print('Student Name: $name, Email: $email');
      });

      // Fetch attendance records for the selected date and mark present students
      QuerySnapshot<Map<String, dynamic>> attendanceQuerySnapshot =
          await FirebaseFirestore.instance
              .collection('attendance')
              .where('date', isEqualTo: dateString)
              .where('status', isEqualTo: 'present')
              .get();

      attendanceQuerySnapshot.docs.forEach((attendanceDoc) {
        String uid = attendanceDoc.id; // Assuming UID is used as document ID

        // Mark student as present
        attendanceMap[uid] = true;
      });

      // List students who are not present or have no attendance data
      List<String> absentStudents = [];
      studentUIDs.forEach((uid) {
        if (!attendanceMap.containsKey(uid) || attendanceMap[uid] == false) {
          absentStudents.add(uid);
        }
      });

      // Display the attendance status
      int totalStudentsCount = studentUIDs.length;
      int presentStudentsCount = totalStudentsCount - absentStudents.length;
      print('Total Students: $totalStudentsCount');
      print('Present Students: $presentStudentsCount');
      print('Absent Students: ${absentStudents.length}');
      print('List of absent students: $absentStudents');

      // Populate attendance data list for displaying in the UI
      attendanceData.clear();
      await Future.forEach(studentUIDs, (uid) async {
        DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (userSnapshot.exists) {
          Map<String, dynamic>? userData = userSnapshot.data()
              as Map<String, dynamic>?; // Cast to Map<String, dynamic>
          if (userData != null) {
            String name =
                userData['name'] ?? ''; // Fetch student name from Firestore
            String email =
                userData['email'] ?? ''; // Fetch student email from Firestore
            print('Name: $name, Email: $email'); // Debugging
            if (attendanceMap.containsKey(uid)) {
              // Student present
              attendanceData.add({
                'name': name,
                'email': email,
                'present': attendanceMap[uid],
              });
            } else {
              // No attendance data for the student
              attendanceData.add({
                'name': name,
                'email': email,
                'present': false,
              });
            }
          }
        } else {
          print('User not found for UID: $uid'); // Debugging
        }
      });

      setState(() {}); // Refresh UI with attendance data
    } catch (error) {
      print('Error fetching attendance data: $error');
      // Handle error appropriately, such as displaying an error message
      // For example:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching attendance data.'),
        ),
      );
    }
  }
}