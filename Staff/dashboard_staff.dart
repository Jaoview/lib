import 'package:flutter/material.dart';
import 'menu_staff.dart';

class DashboardStaff extends StatefulWidget {
  const DashboardStaff({super.key});

  @override
  State<DashboardStaff> createState() => _DashboardStaffState();
}

class _DashboardStaffState extends State<DashboardStaff> {
  final List<Map<String, dynamic>> slotData = [
    {'label': 'Total Slots', 'count': 8, 'color': Colors.brown[300]},
    {'label': 'Free Slots', 'count': 2, 'color': Colors.lightGreenAccent},
    {'label': 'Reserved Slots', 'count': 2, 'color': Colors.lightBlueAccent},
    {'label': 'Pending', 'count': 2, 'color': Colors.yellowAccent},
    {'label': 'Disabled', 'count': 2, 'color': Colors.grey},
  ];

  Future<void> refresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      // This is where you can refresh your data
      // For now, it just simulates a delay
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: const MenuStaff(),
      body: RefreshIndicator(
        onRefresh: refresh, // Call the refresh function on swipe down
        child: Align(
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
      ),
      drawerEnableOpenDragGesture: false, // Disables swipe to open drawer
    );
  }
}
