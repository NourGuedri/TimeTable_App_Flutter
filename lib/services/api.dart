import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:time_table/ipv.dart';
import '../models/session.dart';

class ApiService {
  static Future<List<Session>> fetchSessions() async {
    final response =
        await http.get(Uri.parse("${ApiEndpoints.baseUrl}/sessions"));

    if (response.statusCode == 200) {
      List sessionsJson = json.decode(response.body);
      //afficher les body in console

      return sessionsJson.map((json) => Session.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sessions');
    }
  }

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final response = await http.get(Uri.parse("${ApiEndpoints.baseUrl}/users"));
    if (response.statusCode == 200) {
      List users = json.decode(response.body);
      final user = users.firstWhere(
          (u) => u['username'] == username && u['password'] == password,
          orElse: () => null);
      if (user != null) {
        return {'token': 'mocked.jwt.token', 'role': user['role']};
      } else {
        throw Exception('Invalid credentials');
      }
    } else {
      throw Exception('Failed to fetch users');
    }
  }

  static Future<Map<String, String>> fetchRoomsByIds(
      List<String> roomIds) async {
    final Map<String, String> roomNames = {};

    try {
      // Create the request URL with the room IDs
      final uri =
          Uri.parse('${ApiEndpoints.baseUrl}/rooms?ids=${roomIds.join(',')}');

      // Perform the GET request
      final response = await http.get(uri);

      // Check if the response is valid (status 200)
      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> data = json.decode(response.body);

        // Fill the roomNames dictionary with the data
        for (var room in data) {
          roomNames[room['id']] = room['room_name'];
        }
      } else {
        throw Exception('Failed to load room names');
      }
    } catch (e) {
      throw Exception('Failed to fetch rooms: $e');
    }

    return roomNames;
  }

  // Récupérer les noms des sujets par leurs identifiants
  static Future<Map<String, String>> fetchSubjectsByIds(
      List<String> subjectIds) async {
    final Map<String, String> subjectNames = {};

    try {
      // Créez l'URL de la requête avec les identifiants des sujets
      final uri = Uri.parse(
          '${ApiEndpoints.baseUrl}/subjects?ids=${subjectIds.join(',')}');

      // Effectuez la requête GET
      final response = await http.get(uri);

      // Vérifiez si la réponse est valide (status 200)
      if (response.statusCode == 200) {
        // Analysez la réponse JSON
        final List<dynamic> data = json.decode(response.body);

        // Remplissez le dictionnaire subjectNames avec les données
        for (var subject in data) {
          subjectNames[subject['id']] = subject['subject_name'];
        }
      } else {
        throw Exception('Failed to load subjects');
      }
    } catch (e) {
      print('Error fetching subjects: $e');
    }

    return subjectNames;
  }

  // Récupérer les noms des enseignants par leurs identifiants
  static Future<Map<String, String>> fetchTeachersByIds(
      List<String> teacherIds) async {
    final Map<String, String> teacherNames = {};

    try {
      // Créez l'URL de la requête avec les identifiants des enseignants
      final uri = Uri.parse(
          '${ApiEndpoints.baseUrl}/teachers?ids=${teacherIds.join(',')}');

      // Effectuez la requête GET
      final response = await http.get(uri);

      // Vérifiez si la réponse est valide (status 200)
      if (response.statusCode == 200) {
        // Analysez la réponse JSON
        final List<dynamic> data = json.decode(response.body);

        // Remplissez le dictionnaire teacherNames avec les données
        for (var teacher in data) {
          teacherNames[teacher['id']] = teacher['last_name'];
        }
      } else {
        throw Exception('Failed to load teachers');
      }
    } catch (e) {
      print('Error fetching teachers: $e');
    }

    return teacherNames;
  }
}
