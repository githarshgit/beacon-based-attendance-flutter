import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStudent extends StatefulWidget {
  @override
  _AddStudentState createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedclass;
  String? _selectedMacAddress; // Add this line

  void _addStudent() async {
    // Modify to not take any parameters
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String selectedClass = _selectedclass!;
    String selectedMacAddress =
        _selectedMacAddress!; // Get the selected MAC address

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'class': selectedClass,
        'role': 'student',
        'macAddress': selectedMacAddress, // Include the selected MAC address
      });

      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
      setState(() {
        _selectedclass = null;
        _selectedMacAddress = null; // Reset the selected MAC address
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Student account created successfully!'),
        ),
      );
    } catch (error) {
      print('Error creating student account: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create student account'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Student Name',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 20),
            classDropdown(
              onChanged: (String? className, String? macAddress) {
                setState(() {
                  _selectedclass = className;
                  _selectedMacAddress =
                      macAddress; // Set the selected MAC address
                  print(_selectedMacAddress);
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addStudent,
              child: Text('Add Student'),
            ),
          ],
        ),
      ),
    );
  }
}

class classDropdown extends StatefulWidget {
  final Function(String?, String?) onChanged; // Add a parameter for MAC address

  classDropdown({required this.onChanged});

  @override
  _classDropdownState createState() => _classDropdownState();
}

class _classDropdownState extends State<classDropdown> {
  String? _selectedClass;
  String? _selectedMacAddress; // Add this line

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('class').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        var classDocs = snapshot.data!.docs;

        return DropdownButton<String>(
          value: _selectedClass,
          hint: Text('Select Class'),
          onChanged: (String? value) {
            setState(() {
              _selectedClass = value;
              var selectedClassDoc = classDocs.firstWhere(
                (doc) => doc['name'] == value,
              );
              var selectedMacAddress =
                  selectedClassDoc['macAddress']; // Get the MAC address
              widget.onChanged(value,
                  selectedMacAddress); // Pass both class name and MAC address
            });
          },
          items: classDocs.map<DropdownMenuItem<String>>((classDoc) {
            String className = classDoc['name'];
            return DropdownMenuItem<String>(
              value: className,
              child: Text(className),
            );
          }).toList(),
        );
      },
    );
  }
}
