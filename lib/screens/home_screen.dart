import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/navbar_widget.dart';
import '../widgets/timetable_widget.dart';
import '../ipv.dart'; // Import des URL centralisées
import 'login_screen.dart'; // Import de l'écran de connexion

class HomeScreen extends StatefulWidget {
  final String role;

  const HomeScreen({Key? key, required this.role}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _timeSlots = [
    '08:30-10:00',
    '10:15-11:45',
    '12:00-13:00',
    '13:00-14:30',
    '14:45-16:15',
    '16:30-18:00',
  ];

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];
  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _teachers = [];
  List<Map<String, dynamic>> _rooms = [];

  String? selectedDay;
  String? selectedTimeSlot;
  String? selectedSubject;
  String? selectedTeacher;
  String? selectedRoom;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final subjectsResponse = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/subjects'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));
      final teachersResponse =
          await http.get(Uri.parse('${ApiEndpoints.baseUrl}/teachers'));
      final roomsResponse =
          await http.get(Uri.parse('${ApiEndpoints.baseUrl}/rooms'));

      if (subjectsResponse.statusCode == 200 &&
          teachersResponse.statusCode == 200 &&
          roomsResponse.statusCode == 200) {
        setState(() {
          try {
            final decodedSubjects = jsonDecode(subjectsResponse.body) as List;
            _subjects = decodedSubjects.map((e) {
              return {
                "id": e['id'] ?? 'N/A',
                "name": e['subject_name'] ?? 'Unknown',
              };
            }).toList();

            final decodedTeachers = jsonDecode(teachersResponse.body) as List;
            _teachers = decodedTeachers.map((e) {
              return {
                "id": e['id'] ?? 'N/A',
                "name": (e['first_name'] ?? 'Unknown') +
                    ' ' +
                    (e['last_name'] ?? 'Unknown'),
              };
            }).toList();

            final decodedRooms = jsonDecode(roomsResponse.body) as List;
            _rooms = decodedRooms.map((e) {
              return {
                "id": e['id'] ?? 'N/A',
                "name": e['room_name'] ?? 'Unknown',
              };
            }).toList();
          } catch (e) {
            print('Error decoding data: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error processing data')),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load data')),
      );
    }
  }

  Future<void> _addSession() async {
    await _fetchData();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Session',
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
                // Day Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Day',
                    labelStyle: TextStyle(color: Colors.pink),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _days.map((day) {
                    return DropdownMenuItem(value: day, child: Text(day));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDay = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Time  Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Time ',
                    labelStyle: TextStyle(color: Colors.pink),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _timeSlots.map((slot) {
                    return DropdownMenuItem(value: slot, child: Text(slot));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTimeSlot = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Subject Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    labelStyle: TextStyle(color: Colors.pink),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _subjects.map<DropdownMenuItem<String>>((subject) {
                    return DropdownMenuItem<String>(
                      value: subject["id"], // Internal value: Subject ID
                      child: Text(
                          subject["name"]!), // Displayed text: Subject Name
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSubject = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Teacher Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Teacher',
                    labelStyle: TextStyle(color: Colors.pink),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _teachers.map<DropdownMenuItem<String>>((teacher) {
                    return DropdownMenuItem<String>(
                      value: teacher["id"], // Internal value: Teacher ID
                      child: Text(
                          teacher["name"]!), // Displayed text: Teacher Name
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTeacher = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                // Room Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Room',
                    labelStyle: TextStyle(color: Colors.pink),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _rooms.map<DropdownMenuItem<String>>((room) {
                    return DropdownMenuItem<String>(
                      value: room["id"], // Internal value: Room ID
                      child: Text(room["name"]!), // Displayed text: Room Name
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRoom = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            // Cancel Button
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
            // Add Button
            ElevatedButton(
              onPressed: () async {
                if (selectedDay != null &&
                    selectedTimeSlot != null &&
                    selectedSubject != null &&
                    selectedTeacher != null &&
                    selectedRoom != null) {
                  List<String> timeSlotParts =
                      selectedTimeSlot?.split('-') ?? [];
                  String startTime =
                      timeSlotParts.isNotEmpty ? timeSlotParts[0] : '';
                  String endTime =
                      timeSlotParts.length > 1 ? timeSlotParts[1] : '';

                  // Create session data
                  final sessionData = {
                    "subject_id": selectedSubject,
                    "teacher_id": selectedTeacher,
                    "room_id": selectedRoom,
                    "session_date": selectedDay,
                    "class_id": "C002",
                    "start_time": startTime,
                    "end_time": endTime,
                    "session_id": "SS${DateTime.now().millisecondsSinceEpoch}"
                  };

                  // Send POST request to add session
                  final response = await http.post(
                    Uri.parse(ApiEndpoints.baseUrl + '/sessions'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode(sessionData),
                  );

                  if (response.statusCode == 201) {
                    // Refresh data after successful addition
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(role: widget.role),
                      ),
                    ); // Close the dialog
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add session')),
                    );
                  }
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

  // Method for logout
  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const LoginScreen()), // Navigate back to login screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home ',
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              minimumSize: const Size(100, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          if (widget.role == 'admin')
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addSession,
              tooltip: 'Add Session',
            ),
        ],
      ),
      drawer: widget.role == 'admin' ? const AdminNavbar() : null,
      body: Column(
        children: [
          Expanded(child: TimetableWidget()),
        ],
      ),
    );
  }
}
