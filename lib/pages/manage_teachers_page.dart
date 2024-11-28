import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../ipv.dart'; // Import the base URL for API endpoints

class ManageTeachersPage extends StatefulWidget {
  @override
  _ManageTeachersPageState createState() => _ManageTeachersPageState();
}

class _ManageTeachersPageState extends State<ManageTeachersPage> {
  List<Map<String, dynamic>> _teachers = [];

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  // Fetch teachers from the API
  Future<void> _fetchTeachers() async {
    final response =
        await http.get(Uri.parse('${ApiEndpoints.baseUrl}/teachers'));
    if (response.statusCode == 200) {
      final decodedTeachers = jsonDecode(response.body) as List;
      setState(() {
        _teachers = decodedTeachers.map((e) {
          return {
            "id": e['id'],
            "name": (e['first_name'] ?? '') + ' ' + (e['last_name'] ?? ''),
            "first_name": e['first_name'],
            "last_name": e['last_name'],
            "email": e['email'],
            "department": e['department'],
            "phone": e['phone'],
          };
        }).toList();
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load teachers')),
      );
    }
  }

  // Add teacher functionality
  Future<void> _addTeacher() async {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController departmentController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Teacher',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(firstNameController, 'First Name'),
                const SizedBox(height: 20),
                _buildTextField(lastNameController, 'Last Name'),
                const SizedBox(height: 20),
                _buildTextField(emailController, 'Email'),
                const SizedBox(height: 20),
                _buildTextField(departmentController, 'Department'),
                const SizedBox(height: 20),
                _buildTextField(phoneController, 'Phone'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final newTeacherData = {
                  "teacher_id":
                      "T${DateTime.now().millisecondsSinceEpoch}", // Unique ID
                  "first_name": firstNameController.text,
                  "last_name": lastNameController.text,
                  "email": emailController.text,
                  "department": departmentController.text,
                  "phone": phoneController.text,
                  "id": "a${DateTime.now().millisecondsSinceEpoch}",
                };

                final response = await http.post(
                  Uri.parse('${ApiEndpoints.baseUrl}/teachers'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(newTeacherData),
                );

                if (response.statusCode == 201) {
                  Navigator.of(context).pop();
                  _fetchTeachers();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to add teacher')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                minimumSize: const Size(100, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Edit teacher functionality
  Future<void> _editTeacher(String teacherId) async {
    final teacher =
        _teachers.firstWhere((teacher) => teacher["id"] == teacherId);

    final TextEditingController firstNameController =
        TextEditingController(text: teacher["first_name"]);
    final TextEditingController lastNameController =
        TextEditingController(text: teacher["last_name"]);
    final TextEditingController emailController =
        TextEditingController(text: teacher["email"]);
    final TextEditingController departmentController =
        TextEditingController(text: teacher["department"]);
    final TextEditingController phoneController =
        TextEditingController(text: teacher["phone"]);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Edit Teacher',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(firstNameController, 'First Name'),
                const SizedBox(height: 20),
                _buildTextField(lastNameController, 'Last Name'),
                const SizedBox(height: 20),
                _buildTextField(emailController, 'Email'),
                const SizedBox(height: 20),
                _buildTextField(departmentController, 'Department'),
                const SizedBox(height: 20),
                _buildTextField(phoneController, 'Phone'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedTeacherData = {
                  "teacher_id": teacherId,
                  "first_name": firstNameController.text,
                  "last_name": lastNameController.text,
                  "email": emailController.text,
                  "department": departmentController.text,
                  "phone": phoneController.text,
                  "id": teacher["id"], // Keep the same ID
                };

                final response = await http.put(
                  Uri.parse('${ApiEndpoints.baseUrl}/teachers/$teacherId'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(updatedTeacherData),
                );

                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                  _fetchTeachers();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update teacher')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                minimumSize: const Size(100, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Delete teacher functionality
  Future<void> _deleteTeacher(String teacherId) async {
    final response = await http.delete(
      Uri.parse('${ApiEndpoints.baseUrl}/teachers/$teacherId'),
    );
    if (response.statusCode == 200) {
      setState(() {
        _teachers.removeWhere((teacher) => teacher["id"] == teacherId);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete teacher')),
      );
    }
  }

  // Custom method for TextFields
  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.pink),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent overlay
          Container(
            color: Colors.pink.withOpacity(0.3),
          ),
          // Manage Teachers
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  const Text(
                    "Manage Teachers",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Add Teacher Button
                  ElevatedButton.icon(
                    onPressed: _addTeacher,
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text(
                      'Add Teacher',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Teachers List
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _teachers.length,
                    itemBuilder: (context, index) {
                      final teacher = _teachers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        elevation: 4,
                        child: ListTile(
                          title: Text(teacher['name'],
                              style: const TextStyle(fontSize: 18)),
                          subtitle: Text(
                            'Department: ${teacher['department']}\nPhone: ${teacher['phone']}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Color.fromARGB(255, 95, 4, 45)),
                            onPressed: () => _deleteTeacher(teacher["id"]),
                          ),
                          onTap: () => _editTeacher(teacher["id"]),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
