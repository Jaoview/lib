import 'package:flutter/material.dart';
import 'menu_staff.dart';

class HistoryStaff extends StatefulWidget {
  const HistoryStaff({super.key});

  @override
  State<HistoryStaff> createState() => _HistoryStaffState();
}

class _HistoryStaffState extends State<HistoryStaff> {
  final List<Map<String, dynamic>> room = [
    {
      'rooms': 'Room 1',
      'timeslot': '08:00 - 10:00',
      'date': DateTime(2024, 10, 20, 7, 30, 33),
      'status': 'Approve',
      'requestBy': '6531501170',
      'Lecture': 'Aj.1'
    },
    {
      'rooms': 'Room 2',
      'timeslot': '13:00 - 15:00',
      'date': DateTime(2024, 10, 24, 10, 15, 23),
      'status': 'Reject',
      'requestBy': '6531501150',
      'Lecture': 'Aj.2'
    },
  ];

  String formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return '$day/$month/$year';
  }

  String formatTime(DateTime date) {
    return TimeOfDay.fromDateTime(date).format(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        title: const Text('History Staff'),
      ),
      drawer: const MenuStaff(),
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Background container
                  Container(
                    margin: const EdgeInsets.only(top: 70),
                    decoration: const BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: room.length,
                    itemBuilder: (context, index) {
                      final entry = room[index];
                      final formattedDate = formatDate(entry['date']);
                      final formattedTime = formatTime(entry['date']);
                      final statusColor = entry['status'] == 'Approve'
                          ? Colors.green
                          : Colors.red;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        height: 210,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Card background
                            Container(
                              height: 210,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                color: Colors.lightBlue,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 6,
                                    offset: const Offset(6, 6),
                                  ),
                                ],
                              ),
                              // Inner card with white background
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                       Text(
                                        '${entry['rooms']}',
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        'Time slot: ${entry['timeslot']}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'Date: $formattedDate',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'Time: $formattedTime',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            'Status: ',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            entry['status'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: statusColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                       Text(
                                        'Request by: ${entry['requestBy']}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'By: ${entry['Lecture']}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawerEnableOpenDragGesture: false, // Disable opening drawer with swipe
    );
  }
}
