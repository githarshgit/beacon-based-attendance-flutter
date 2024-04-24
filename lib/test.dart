import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class AddMultipleStudents extends StatefulWidget {
  const AddMultipleStudents({Key? key}) : super(key: key);

  @override
  State<AddMultipleStudents> createState() => _AddMultipleStudentsState();
}

class _AddMultipleStudentsState extends State<AddMultipleStudents> {
  File? _selectedFile;

  void _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'], // Allow only Excel files
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    } else {
      // User canceled the file picker
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No file selected.'),
        ),
      );
    }
  }

  void _uploadStudents() async {
    if (_selectedFile == null) {
      // No file selected, show error message
      return;
    }

    try {
      // Read data from Excel sheet
      List<Student> students = await _readExcelData(_selectedFile!);

      // Upload students to Firestore
      await _uploadStudentsToFirestore(students);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Students added successfully.'),
        ),
      );
    } catch (error) {
      print('Error uploading students: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload students.'),
        ),
      );
    }
  }

  Future<List<Student>> _readExcelData(File file) async {
    List<Student> students = [];

    // Open the Excel file
    var bytes = await file.readAsBytes();
    var excel = Excel.decodeBytes(bytes);

    // Get the first sheet
    var sheet = excel.tables.keys.first;

    // Iterate over rows starting from the second row (skipping header)
    for (var row in excel.tables[sheet]!.rows.skip(1)) {
      // Assuming your Excel sheet has columns in the following order: Name, Email, Password, Class
      String name = row[0]?.toString() ?? '';
      String email = row[1]?.toString() ?? '';
      String password = row[2]?.toString() ?? '';
      String selectedClass = row[3]?.toString() ?? '';

      // Create a new Student object and add it to the list
      students.add(Student(
        name: name,
        email: email,
        password: password,
        selectedClass: selectedClass,
      ));
    }

    return students;
  }

  Future<void> _uploadStudentsToFirestore(List<Student> students) async {
    // Iterate over the list of students and upload each student to Firestore
    for (var student in students) {
      await FirebaseFirestore.instance.collection('students').add({
        'name': student.name,
        'email': student.email,
        'password': student.password,
        'class': student.selectedClass,
        // Add other student details as needed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Multiple Students'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _selectFile,
              child: Text('Select Excel Sheet'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadStudents,
              child: Text('Upload Students'),
            ),
          ],
        ),
      ),
    );
  }
}

class Student {
  final String name;
  final String email;
  final String password;
  final String selectedClass;

  Student({
    required this.name,
    required this.email,
    required this.password,
    required this.selectedClass,
  });
}
