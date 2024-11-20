import 'package:flutter/material.dart';
// import 'package:project/Lecturer/booking_request_lecturer.dart';
// import 'package:project/Lecturer/history_lecturer.dart';
import 'package:project/Lecturer/menu_lecturer.dart'; // Ensure this includes "Logout" in MenuLecturerPage

class DashboardLecturer extends StatefulWidget {
  const DashboardLecturer({super.key});

  @override
  State<DashboardLecturer> createState() => _DashboardLecturerState();
}

class _DashboardLecturerState extends State<DashboardLecturer> {
  final List<Map<String, dynamic>> slotData = [
    {'label': 'Total Slots', 'count': 8, 'color': Colors.brown[300]},
    {'label': 'Free Slots', 'count': 2, 'color': Colors.lightGreenAccent},
    {'label': 'Reserved Slots', 'count': 2, 'color': Colors.lightBlueAccent},
    {'label': 'Pending', 'count': 2, 'color': Colors.yellowAccent},
    {'label': 'Disabled', 'count': 2, 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),

      drawer: const MenuLecturerPage(), // Drawer with "Logout"
      body: Center(
        // Use Center to align everything in the center
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
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

                  Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(top: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        spacing: 16.0,
                        runSpacing: 16.0,
                        alignment: WrapAlignment.center, // Center the items
                        children: slotData.map((slot) {
                          return SizedBox(
                            width: 150,
                            height: 80,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  height: 70,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: slot['color'],
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 7,
                                        offset: const Offset(4, 4),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            slot['label'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${slot['count']} Slot',
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawerEnableOpenDragGesture: false, // Disables swipe to open drawer
    );
  }
}
