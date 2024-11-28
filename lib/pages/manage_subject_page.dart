import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../ipv.dart'; // Import the base URL for API endpoints

class ManageSubjectsPage extends StatefulWidget {
  @override
  _ManageSubjectsPageState createState() => _ManageSubjectsPageState();
}

class _ManageSubjectsPageState extends State<ManageSubjectsPage> {
  List<Map<String, dynamic>> _subjects = [];

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  // Fetch subjects from the API
  Future<void> _fetchSubjects() async {
    final response =
        await http.get(Uri.parse('${ApiEndpoints.baseUrl}/subjects'));
    if (response.statusCode == 200) {
      final decodedSubjects = jsonDecode(response.body) as List;
      setState(() {
        _subjects = decodedSubjects.map((e) {
          return {
            "id": e['id'],
            "subject_name": e['subject_name'],
            "subject_code": e['subject_code'],
            "department": e['department'],
            "description": e['description'],
            "subject_id": e['subject_id'], // hidden field
          };
        }).toList();
      });
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load subjects')),
      );
    }
  }

  // Add subject functionality
  Future<void> _addSubject() async {
    final TextEditingController subjectNameController = TextEditingController();
    final TextEditingController subjectCodeController = TextEditingController();
    final TextEditingController departmentController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Subject',
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
                _buildTextField(subjectNameController, 'Subject Name'),
                const SizedBox(height: 20),
                _buildTextField(subjectCodeController, 'Subject Code'),
                const SizedBox(height: 20),
                _buildTextField(departmentController, 'Department'),
                const SizedBox(height: 20),
                _buildTextField(descriptionController, 'Description'),
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
                final newSubjectData = {
                  "subject_id":
                      "S${DateTime.now().millisecondsSinceEpoch}", // Unique ID
                  "subject_name": subjectNameController.text,
                  "subject_code": subjectCodeController.text,
                  "department": departmentController.text,
                  "description": descriptionController.text,
                  "id": "a${DateTime.now().millisecondsSinceEpoch}",
                };

                final response = await http.post(
                  Uri.parse('${ApiEndpoints.baseUrl}/subjects'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(newSubjectData),
                );

                if (response.statusCode == 201) {
                  Navigator.of(context).pop();
                  _fetchSubjects();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to add subject')),
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

  // Edit subject functionality
  Future<void> _editSubject(String subjectId) async {
    final subject =
        _subjects.firstWhere((subject) => subject["id"] == subjectId);

    final TextEditingController subjectNameController =
        TextEditingController(text: subject["subject_name"]);
    final TextEditingController subjectCodeController =
        TextEditingController(text: subject["subject_code"]);
    final TextEditingController departmentController =
        TextEditingController(text: subject["department"]);
    final TextEditingController descriptionController =
        TextEditingController(text: subject["description"]);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Edit Subject',
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
                _buildTextField(subjectNameController, 'Subject Name'),
                const SizedBox(height: 20),
                _buildTextField(subjectCodeController, 'Subject Code'),
                const SizedBox(height: 20),
                _buildTextField(departmentController, 'Department'),
                const SizedBox(height: 20),
                _buildTextField(descriptionController, 'Description'),
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
                final updatedSubjectData = {
                  "subject_id": subjectId,
                  "subject_name": subjectNameController.text,
                  "subject_code": subjectCodeController.text,
                  "department": departmentController.text,
                  "description": descriptionController.text,
                  "id": subject["id"], // Keep the same ID
                };

                final response = await http.put(
                  Uri.parse('${ApiEndpoints.baseUrl}/subjects/$subjectId'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(updatedSubjectData),
                );

                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                  _fetchSubjects();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update subject')),
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

  // Delete subject functionality
  Future<void> _deleteSubject(String subjectId) async {
    final response = await http.delete(
      Uri.parse('${ApiEndpoints.baseUrl}/subjects/$subjectId'),
    );
    if (response.statusCode == 200) {
      setState(() {
        _subjects.removeWhere((subject) => subject["subject_id"] == subjectId);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete subject')),
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
          // Manage Subjects
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  const Text(
                    "Manage Subjects",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Add Subject Button
                  ElevatedButton.icon(
                    onPressed: _addSubject,
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text(
                      'Add Subject',
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
                  // Subjects List
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _subjects.length,
                    itemBuilder: (context, index) {
                      final subject = _subjects[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        elevation: 4,
                        child: ListTile(
                          title: Text(subject['subject_name'],
                              style: const TextStyle(fontSize: 18)),
                          subtitle: Text(
                            'Code: ${subject['subject_code']}\nDepartment: ${subject['department']}\nDescription: ${subject['description']}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Color.fromARGB(255, 95, 4, 45)),
                            onPressed: () => _deleteSubject(subject["id"]),
                          ),
                          onTap: () => _editSubject(subject["id"]),
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
