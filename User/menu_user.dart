import 'package:flutter/material.dart';
import 'package:project/User/room_list_user.dart';
import 'package:project/User/status_user.dart';
import 'package:project/User/history_user.dart';
import 'package:project/Login/login.dart';

class MenuUser extends StatelessWidget {
  const MenuUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DrawerHeader(
            child: Row(
              children: [
                Text('Menu User'),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RoomListUser()),
            ),
            icon: const Icon(Icons.meeting_room),
            label: const Text('Room list'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Status(bookingData: []), // Pass empty list if no data
              ),
            ),
            icon: const Icon(Icons.edit),
            label: const Text('Check Status'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HistoryUser()),
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
