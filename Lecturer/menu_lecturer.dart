import 'package:flutter/material.dart';
import 'package:project/Lecturer/booking_request_lecturer.dart';
import 'package:project/Lecturer/dashboard_lecturer.dart';
import 'package:project/Lecturer/history_lecturer.dart';
import 'package:project/Lecturer/room_list_lecturer.dart';
import 'package:project/Login/login.dart';

class MenuLecturerPage extends StatelessWidget {
  const MenuLecturerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DrawerHeader(
            child: Row(
              children: [
                Text('Menu Lecturer'),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardLecturer()),
            ),
            icon: const Icon(Icons.dashboard),
            label: const Text('Dashboard'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RoomListLecturer()),
            ),
            icon: const Icon(Icons.meeting_room),
            label: const Text('Room list'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BookingRequestPage()),
            ),
            icon: const Icon(Icons.edit),
            label: const Text('Booking Request'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HistoryLecturerPage()),
            ),
            icon: const Icon(Icons.history),
            label: const Text('History'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
