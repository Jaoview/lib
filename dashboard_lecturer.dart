import 'package:booking/Lecturer/menu_lecturer.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:booking/config.dart'; // Ensure this is the correct path to your config.dart file

class DashboardLecturer extends StatefulWidget {
  const DashboardLecturer({super.key});

  @override
  State<DashboardLecturer> createState() => _DashboardLecturerState();
}

class _DashboardLecturerState extends State<DashboardLecturer> {
  List<Map<String, dynamic>> slotData = [];
  bool isLoading = true; // Loading state

  // Function to fetch slot counts from API
  Future<void> fetchSlotCounts() async {
    try {
      // Use baseURL from config.dart
      final response = await http.get(
        Uri.parse('$baseURL/countStatuses'),
        headers: {
          'Authorization':
              'Bearer <your-jwt-token>', // Replace with actual JWT token
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Decode the response
        final data = json.decode(response.body)['data'];
        print('API Response Data: $data'); // Debugging the API response

        // Ensure all fields are integers and handle null or invalid values
        final free = int.tryParse(data['free'].toString()) ?? 0;
        final pending = int.tryParse(data['pending'].toString()) ?? 0;
        final disabled = int.tryParse(data['disabled'].toString()) ?? 0;
        final approve = int.tryParse(data['approve'].toString()) ?? 0;

        // Calculate total slots
        final totalSlots = free + pending + disabled + approve;
        print('Calculated Total Slots: $totalSlots'); // Debugging total slots

        setState(() {
          slotData = [
            {
              'label': 'Total Slots',
              'count': totalSlots,
              'color': Colors.brown[300],
            },
            {
              'label': 'Free Slots',
              'count': free,
              'color': Colors.lightGreenAccent,
            },
            {
              'label': 'Pending Slots',
              'count': pending,
              'color': Colors.yellowAccent,
            },
            {
              'label': 'Disabled Slots',
              'count': disabled,
              'color': Colors.grey,
            },
            {
              'label': 'Approved Slots',
              'count': approve,
              'color': Colors.lightBlueAccent,
            },
          ];
          isLoading = false; // Data successfully loaded
        });
      } else {
        print('Failed to fetch slot counts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during fetchSlotCounts: $e');
      setState(() {
        isLoading = false; // Stop loading in case of error
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSlotCounts(); // Fetch data on widget load
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: const MenuLecturerPage(), // Drawer with "Logout"
      body: RefreshIndicator(
        onRefresh: fetchSlotCounts, // Pull-to-refresh handler
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
                    // Loading spinner or slot data display
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Container(
                            alignment: Alignment.topCenter,
                            padding: const EdgeInsets.only(top: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Wrap(
                                spacing: 16.0,
                                runSpacing: 16.0,
                                alignment:
                                    WrapAlignment.center, // Center the items
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
                                            borderRadius:
                                                BorderRadius.circular(22),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                spreadRadius: 2,
                                                blurRadius: 7,
                                                offset: const Offset(4, 4),
                                              ),
                                            ],
                                          ),
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                right: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(22),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    slot['label'],
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${slot['count']} Slots',
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
