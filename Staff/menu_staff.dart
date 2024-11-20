import 'package:flutter/material.dart';
import 'add_edit_staff.dart';
import 'history_staff.dart';
import 'dashboard_staff.dart';
import 'package:project/Staff/room_list_staff.dart';
import 'package:project/Login/login.dart';

class MenuStaff extends StatelessWidget {
  const MenuStaff({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DrawerHeader(
            child: Row(
              children: [
                Text('Menu Staff'),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardStaff()),
            ),
            icon: const Icon(Icons.dashboard),
            label: const Text('Dashboard'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RoomListStaff()),
            ),
            icon: const Icon(Icons.meeting_room),
            label: const Text('Room list'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AddEditStaff()),
            ),
            icon: const Icon(Icons.edit),
            label: const Text('Add/Edit'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HistoryStaff()),
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
