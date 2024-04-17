import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartattendancebeacon/bluetooth_scan.dart';
import 'package:smartattendancebeacon/login_page.dart';

class FacultyDashboardPage extends StatefulWidget {
  @override
  _FacultyDashboardPageState createState() => _FacultyDashboardPageState();
}

class _FacultyDashboardPageState extends State<FacultyDashboardPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _classController = TextEditingController();

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      switch (index) {
        case 0:
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListClassesPage()),
          );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BeaconScannerPage()),
          );
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var scaffold = Scaffold(
      appBar: AppBar(
        title: Text('Add Student'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
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
            TextField(
              controller: _classController,
              decoration: InputDecoration(
                labelText: 'Assign Class',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String name = _nameController.text;
                String email = _emailController.text;
                String password = _passwordController.text;
                String lecture = _classController.text;

                print('Name: $name');
                print('Email: $email');
                print('Password: $password');
                print('Class: $lecture');

                _nameController.clear();
                _emailController.clear();
                _passwordController.clear();
                _classController.clear();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Student added successfully!'),
                  ),
                );
              },
              child: Text('Add Student'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Add Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'List Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
    return scaffold;
  }
}

///////////////////////////////LIST CLASSES/////////////////////////////////////
class ListClassesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Classes'),
      ),
      body: Center(
        child: Text('List of Classes'),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth List'),
      ),
      body: Center(
        child: Text('BLuetooth'),
      ),
    );
  }
}
