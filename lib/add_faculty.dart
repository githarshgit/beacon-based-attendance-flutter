import 'package:cloud_firestore/cloud_firestore.dart';

void addFacultyMember(String name, String subject) async {
  try {
    await FirebaseFirestore.instance
        .collection('faculty_members')
        .add({'name': name, 'role': 'faculty', 'subject': subject});
    print('Faculty member added successfully!');
  } catch (e) {
    print('Error adding faculty member: $e');
  }
}
