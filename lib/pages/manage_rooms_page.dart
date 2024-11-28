import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../ipv.dart'; // Import the base URL for API endpoints

class ManageRoomsPage extends StatefulWidget {
  @override
  _ManageRoomsPageState createState() => _ManageRoomsPageState();
}

class _ManageRoomsPageState extends State<ManageRoomsPage> {
  List<Map<String, dynamic>> _rooms = [];

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  // Fetch rooms from the API
  Future<void> _fetchRooms() async {
    final response = await http.get(Uri.parse('${ApiEndpoints.baseUrl}/rooms'));
    if (response.statusCode == 200) {
      final decodedRooms = jsonDecode(response.body) as List;
      setState(() {
        _rooms = decodedRooms.map((e) {
          return {
            "id": e['id'],
            "room_name": e['room_name'],
            "capacity": e['capacity'],
            "building": e['building'],
            "floor": e['floor'],
          };
        }).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load rooms')),
      );
    }
  }

  // Add room functionality
  Future<void> _addRoom() async {
    final TextEditingController roomNameController = TextEditingController();
    final TextEditingController capacityController = TextEditingController();
    final TextEditingController buildingController = TextEditingController();
    final TextEditingController floorController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Add Room',
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
                _buildTextField(roomNameController, 'Room Name'),
                const SizedBox(height: 20),
                _buildTextField(capacityController, 'Capacity'),
                const SizedBox(height: 20),
                _buildTextField(buildingController, 'Building'),
                const SizedBox(height: 20),
                _buildTextField(floorController, 'Floor'),
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
                final newRoomData = {
                  "room_name": roomNameController.text,
                  "capacity": int.parse(capacityController.text),
                  "building": buildingController.text,
                  "floor": int.parse(floorController.text),
                  "id": "r${DateTime.now().millisecondsSinceEpoch}",
                };

                final response = await http.post(
                  Uri.parse('${ApiEndpoints.baseUrl}/rooms'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(newRoomData),
                );

                if (response.statusCode == 201) {
                  Navigator.of(context).pop();
                  _fetchRooms();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to add room')),
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

  // Edit room functionality
  Future<void> _editRoom(String roomId) async {
    final room = _rooms.firstWhere((room) => room["id"] == roomId);

    final TextEditingController roomNameController =
        TextEditingController(text: room["room_name"]);
    final TextEditingController capacityController =
        TextEditingController(text: room["capacity"].toString());
    final TextEditingController buildingController =
        TextEditingController(text: room["building"]);
    final TextEditingController floorController =
        TextEditingController(text: room["floor"].toString());

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Edit Room',
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
                _buildTextField(roomNameController, 'Room Name'),
                const SizedBox(height: 20),
                _buildTextField(capacityController, 'Capacity'),
                const SizedBox(height: 20),
                _buildTextField(buildingController, 'Building'),
                const SizedBox(height: 20),
                _buildTextField(floorController, 'Floor'),
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
                final updatedRoomData = {
                  "room_name": roomNameController.text,
                  "capacity": int.parse(capacityController.text),
                  "building": buildingController.text,
                  "floor": int.parse(floorController.text),
                  "id": room["id"], // Keep the same ID
                };

                final response = await http.put(
                  Uri.parse('${ApiEndpoints.baseUrl}/rooms/$roomId'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode(updatedRoomData),
                );

                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                  _fetchRooms();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update room')),
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

  // Delete room functionality
  Future<void> _deleteRoom(String roomId) async {
    final response = await http.delete(
      Uri.parse('${ApiEndpoints.baseUrl}/rooms/$roomId'),
    );
    if (response.statusCode == 200) {
      setState(() {
        _rooms.removeWhere((room) => room["id"] == roomId);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete room')),
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
          // Manage Rooms
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  const Text(
                    "Manage Rooms",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Add Room Button
                  ElevatedButton.icon(
                    onPressed: _addRoom,
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: const Text(
                      'Add Room',
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
                  // Rooms List
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _rooms.length,
                    itemBuilder: (context, index) {
                      final room = _rooms[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        elevation: 4,
                        child: ListTile(
                          title: Text(room['room_name'],
                              style: const TextStyle(fontSize: 18)),
                          subtitle: Text(
                            'Capacity: ${room['capacity']}\nBuilding: ${room['building']}\nFloor: ${room['floor']}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete,
                                color: Color.fromARGB(255, 95, 4, 45)),
                            onPressed: () => _deleteRoom(room["id"]),
                          ),
                          onTap: () => _editRoom(room["id"]),
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
