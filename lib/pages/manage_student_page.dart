import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../ipv.dart'; // Import the base URL for API endpoints

class ManageStudentsPage extends StatefulWidget {
  @override
  _ManageStudentsPageState createState() => _ManageStudentsPageState();
}

class _ManageStudentsPageState extends State<ManageStudentsPage> {
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  // Fetch students from the API
  Future<void> _fetchStudents() async {
    final response =
        await http.get(Uri.parse('${ApiEndpoints.baseUrl}/students'));
    if (response.statusCode == 200) {
      final decodedStudents = jsonDecode(response.body) as List;
      setState(() {
        _students = decodedStudents.map((e) {
          return {
            "id": e['id'],
            "name": (e['first_name'] ?? '') + ' ' + (e['last_name'] ?? ''),
            "first_name": e['first_name'],
            "last_name": e['last_name'],
            "email": e['email'],
            "class": e['class'],
            "phone": e['phone'],
          };
        }).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load students')),
      );
    }
  }

  // Add student functionality
  Future<void> _addStudent() async {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController classController = TextEditingController();
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
            'Add Student',
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
                _buildTextField(classController, 'Class'),
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
                final newStudentData = {
                  "student_id":
                      "S${DateTime.now().millisecondsSinceEpoch}", // Unique ID
                  "first_name": firstNameController.text,
                  "last_name": lastNameController.text,
                  "email": emailController.text,
                  "class": classController.text,
                  "phone": phoneController.text,
                  "id": "a${DateTime.now().millisecondsSinceEpoch}",
                };

                final response = await http.post(
                  Uri.parse('${ApiEndpoints.baseUrl}/students'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(newStudentData),
                );

                if (response.statusCode == 201) {
                  Navigator.of(context).pop();
                  _fetchStudents();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to add student')),
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

  // Edit student functionality
  Future<void> _editStudent(String studentId) async {
    final student =
        _students.firstWhere((student) => student["id"] == studentId);

    final TextEditingController firstNameController =
        TextEditingController(text: student["first_name"]);
    final TextEditingController lastNameController =
        TextEditingController(text: student["last_name"]);
    final TextEditingController emailController =
        TextEditingController(text: student["email"]);
    final TextEditingController classController =
        TextEditingController(text: student["class"]);
    final TextEditingController phoneController =
        TextEditingController(text: student["phone"]);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Edit Student',
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
                _buildTextField(classController, 'Class'),
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
                final updatedStudentData = {
                  "student_id": studentId,
                  "first_name": firstNameController.text,
                  "last_name": lastNameController.text,
                  "email": emailController.text,
                  "class": classController.text,
                  "phone": phoneController.text,
                  "id": student["id"], // Keep the same ID
                };

                final response = await http.put(
                  Uri.parse('${ApiEndpoints.baseUrl}/students/$studentId'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(updatedStudentData),
                );

                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                  _fetchStudents();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update student')),
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

  // Delete student functionality
  Future<void> _deleteStudent(String studentId) async {
    final response = await http.delete(
      Uri.parse('${ApiEndpoints.baseUrl}/students/$studentId'),
    );
    if (response.statusCode == 200) {
      setState(() {
        _students.removeWhere((student) => student["id"] == studentId);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete student')),
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
          // Manage Students
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  const Text(
                    "Manage Students",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Add Student Button
                  ElevatedButton.icon(
                    onPressed: _addStudent,
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text(
                      'Add Student',
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
                  // Students List
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        elevation: 4,
                        child: ListTile(
                          title: Text(student['name'],
                              style: const TextStyle(fontSize: 18)),
                          subtitle: Text(
                            'Class: ${student['class']}\nPhone: ${student['phone']}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Color.fromARGB(255, 95, 4, 45)),
                            onPressed: () => _deleteStudent(student["id"]),
                          ),
                          onTap: () => _editStudent(student["id"]),
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
