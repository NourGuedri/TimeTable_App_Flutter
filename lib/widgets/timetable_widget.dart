import 'package:flutter/material.dart';
import '../models/session.dart';
import '../services/api.dart';

class TimetableWidget extends StatefulWidget {
  const TimetableWidget({Key? key}) : super(key: key);

  @override
  State<TimetableWidget> createState() => _TimetableWidgetState();
}

class _TimetableWidgetState extends State<TimetableWidget> {
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

  Map<String, List<Session>> _sessionsByDayAndTime = {};
  Map<String, String> _subjectNames = {}; // Subject ID to name mapping
  Map<String, String> _teacherNames = {}; // Teacher ID to name mapping
  Map<String, String> _roomNames = {}; // Room ID to name mapping

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    try {
      List<Session> sessions = await ApiService.fetchSessions();

      // Récupérer les informations des sujets et des enseignants
      List<String> subjectIds =
          sessions.map((session) => session.subjectId).toSet().toList();
      List<String> teacherIds =
          sessions.map((session) => session.teacherId).toSet().toList();
      List<String> roomIds =
          sessions.map((session) => session.roomId).toSet().toList();

      // Fetch subject names and teacher names
      Map<String, String> subjectNames =
          await ApiService.fetchSubjectsByIds(subjectIds);
      Map<String, String> teacherNames =
          await ApiService.fetchTeachersByIds(teacherIds);
      Map<String, String> roomNames = await ApiService.fetchRoomsByIds(roomIds);

      // Organiser les sessions par jour et par plage horaire
      Map<String, List<Session>> groupedSessions = {
        for (var day in _days) day: []
      };

      for (var session in sessions) {
        if (groupedSessions.containsKey(session.sessionDate)) {
          groupedSessions[session.sessionDate]!.add(session);
        }
      }

      setState(() {
        _sessionsByDayAndTime = groupedSessions;
        _subjectNames = subjectNames;
        _teacherNames = teacherNames;
        _roomNames = roomNames;
      });
    } catch (e) {
      debugPrint('Failed to fetch sessions: $e');
    }
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
          // Timetable
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  const Text(
                    "Timetable",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Timetable Table
                  Table(
                    border: TableBorder.all(color: Colors.grey),
                    children: [
                      TableRow(
                        children: [
                          const TableCell(
                            child: Center(
                              child: Text(
                                'Time / Day',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink,
                                ),
                              ),
                            ),
                          ),
                          ..._timeSlots
                              .map((slot) => Center(
                                    child: Text(
                                      slot,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                      ..._days.map((day) {
                        return TableRow(
                          children: [
                            Center(
                              child: Text(
                                day,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                            ..._timeSlots.map((timeSlot) {
                              // Filtrer les sessions par jour et par plage horaire
                              List<Session> sessions =
                                  _sessionsByDayAndTime[day]!
                                      .where((session) => _isSessionInTimeSlot(
                                          session, timeSlot))
                                      .toList();

                              return Center(
                                child: sessions.isNotEmpty
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Affiche le nom du sujet au centre (récupéré par subjectId)
                                          Text(
                                            _subjectNames[
                                                    sessions.first.subjectId] ??
                                                sessions.first.subjectId,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),

                                          // Affiche le numéro de la salle en haut
                                          Text(
                                            "Room: ${_roomNames[sessions.first.roomId]}",
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          // Affiche le nom du professeur en bas (récupéré par teacherId)
                                          Text(
                                            "Teacher: ${_teacherNames[sessions.first.teacherId] ?? sessions.first.teacherId}",
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        'X',
                                        style: TextStyle(color: Colors.black),
                                      ),
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSessionInTimeSlot(Session session, String timeSlot) {
    List<String> times = timeSlot.split('-');
    String start = times[0];
    String end = times[1];

    return session.startTime == start && session.endTime == end;
  }
}
