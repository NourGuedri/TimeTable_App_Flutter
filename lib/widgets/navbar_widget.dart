import 'package:flutter/material.dart';
import 'package:time_table/pages/manage_student_page.dart';
import 'package:time_table/pages/manage_subject_page.dart';
import '../pages/manage_teachers_page.dart';
import '../pages/manage_rooms_page.dart';

class AdminNavbar extends StatelessWidget {
  const AdminNavbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Text(
              'Admin Navbar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: const Text(
              'Add Teachers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            leading: const Icon(Icons.person, color: Colors.pink),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageTeachersPage()),
              );
            },
          ),
          ListTile(
            title: const Text(
              'Add Rooms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            leading: const Icon(Icons.meeting_room, color: Colors.pink),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageRoomsPage()),
              );
            },
          ),
          ListTile(
            title: const Text(
              'Add Students',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            leading: const Icon(Icons.school, color: Colors.pink),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageStudentsPage()),
              );
            },
          ),
          ListTile(
            title: const Text(
              'Add Subjects',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            leading: const Icon(Icons.book, color: Colors.pink),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageSubjectsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
