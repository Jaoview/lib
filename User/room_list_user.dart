import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import for token storage/retrieval
import 'menu_user.dart';
import 'status_user.dart';

class RoomListUser extends StatefulWidget {
  const RoomListUser({super.key});

  @override
  _RoomListUserState createState() => _RoomListUserState();
}

class _RoomListUserState extends State<RoomListUser> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // URL to fetch data from the server
  final String apiUrl = "http://192.168.56.1:3000/rooms";

  // Rooms data
  Map<String, List<Map<String, dynamic>>> rooms = {};

  @override
  void initState() {
    super.initState();
    fetchRooms(); // Fetch data from the server when the app starts
  }

  // Fetch rooms data from the server
  Future<void> fetchRooms() async {
    try {
      // Retrieve the token
      String? token = await getToken();
      if (token == null) {
        print("No token found");
        return; // Exit if no token is found
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token", // Include the token here
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          rooms = {
            for (var room in data)
              room['roomName']: List<Map<String, dynamic>>.from(
                (room['timeslots'] as List<dynamic>).asMap().entries.map((entry) {
                  String status = entry.value;
                  return {
                    'timeslot': _getTimeslot(entry.key),
                    'status': status,
                    'color': _getStatusColor(status),
                  };
                }),
              ),
          };
        });
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Failed to fetch rooms: $e');
    }
  }

 Future<void> bookRoomSlot(String roomName, String timeslot) async {
  final String bookUrl = "http://192.168.56.1:3000/book";
  try {
    String? token = await getToken();
    if (token == null) return;

    final response = await http.post(
      Uri.parse(bookUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "roomName": roomName,
        "timeslot": timeslot,
      }),
    );

    if (response.statusCode == 200) {
      print("Booking successful");
      await fetchRooms(); // Refresh the room list to reflect the updated status
    } else {
      print("Failed to book slot: ${response.body}");
    }
  } catch (e) {
    print("Error booking slot: $e");
  }
}


  // Token storage and retrieval
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Map time slot index to readable time ranges
  String _getTimeslot(int index) {
    const timeslotMap = {
      0: '08:00 - 10:00',
      1: '10:00 - 12:00',
      2: '13:00 - 15:00',
      3: '15:00 - 17:00',
    };
    return timeslotMap[index] ?? 'Unknown';
  }

  // Map room statuses to colors
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Free':
        return Colors.green;
      case 'Pending':
        return Colors.yellow;
      case 'Reserved':
        return Colors.red;
      case 'Disable':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        title: const Text('Room List'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: const MenuUser(),
      drawerEnableOpenDragGesture: false,
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 150),
            decoration: const BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Text(
                    'Booking',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    '20 October 2024',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ...rooms.entries.map((entry) {
                    return buildRoomCard(context, entry.key, entry.value);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRoomCard(
    BuildContext context,
    String roomName,
    List<Map<String, dynamic>> timeSlots,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      height: 270,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            height: 270,
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
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          roomName,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: timeSlots.length,
                        itemBuilder: (context, index) {
                          final slot = timeSlots[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  slot['timeslot'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (slot['status'] == 'Free') {
                                      showBookingDialog(
                                          context, roomName, index);
                                    }
                                  },
                                  child: Container(
                                    width: 80,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: slot['color'],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      slot['status'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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
  }

 void showBookingDialog(BuildContext context, String roomName, int slotIndex) async {
  String? token = await getToken();
  if (token == null) {
    print("No token found");
    return;
  }

  // Check if there's an existing pending booking
  bool hasPendingBooking = await checkPendingBooking(token);
  if (hasPendingBooking) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You already have a pending booking.')),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Booking Confirmation'),
        content: Text('Do you want to book this slot in $roomName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
              String timeslot = _getTimeslot(slotIndex);

              // Update slot status locally to "Pending"
              setState(() {
                rooms[roomName]![slotIndex]['status'] = 'Pending';
                rooms[roomName]![slotIndex]['color'] = Colors.yellow;
              });

              // Call the booking function and update the server
              await bookRoomSlot(roomName, timeslot);

              // After booking, navigate to the Status page
              final bookingData = {
                'status': 'Pending',
                'room': roomName,
                'timeSlot': timeslot,
              };

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Status(
                    bookingData: [bookingData],
                  ),
                ),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}

// Check if there's a pending booking for the user
Future<bool> checkPendingBooking(String token) async {
  final String statusUrl = "http://192.168.56.1:3000/check_pending";
  final response = await http.get(
    Uri.parse(statusUrl),
    headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    },
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['hasPending'];
  }
  return false;
}


}
