import 'package:flutter/material.dart';
import 'menu_staff.dart';

class AddEditStaff extends StatefulWidget {
  const AddEditStaff({super.key});

  @override
  _AddEditStaffState createState() => _AddEditStaffState();
}

class _AddEditStaffState extends State<AddEditStaff> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<String, List<Map<String, dynamic>>> rooms = {
    'Room 1': [
      {'timeslot': '08:00 - 10:00', 'status': 'Free', 'color': Colors.green},
      {'timeslot': '10:00 - 12:00', 'status': 'Pending', 'color': Colors.yellow},
      {'timeslot': '13:00 - 15:00', 'status': 'Disable', 'color': Colors.grey},
      {'timeslot': '15:00 - 17:00', 'status': 'Reserved', 'color': Colors.red},
    ],
    'Room 2': [
      {'timeslot': '08:00 - 10:00', 'status': 'Reserved', 'color': Colors.red},
      {'timeslot': '10:00 - 12:00', 'status': 'Free', 'color': Colors.green},
      {'timeslot': '13:00 - 15:00', 'status': 'Pending', 'color': Colors.yellow},
      {'timeslot': '15:00 - 17:00', 'status': 'Disable', 'color': Colors.grey},
    ],
  };
  Map<String, List<Map<String, dynamic>>>? _deletedRoomBackup;

   @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        title: const Text('Add/Edit'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: const MenuStaff(),
      drawerEnableOpenDragGesture: false,
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 110),
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
                    'Add/Edit',
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: _showAddDialog,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: Colors.black,
                        ),
                      ),
                    ),
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
      height: 300,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            height: 300,
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
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => confirmDeleteRoom(context, roomName),
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
                                  onTap: () => toggleStatus(roomName, index),
                                  child: Container(
                                    width: 80,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
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

  void toggleStatus(String roomName, int index) {
    setState(() {
      final slot = rooms[roomName]![index];
      if (slot['status'] == 'Free') {
        slot['status'] = 'Disable';
        slot['color'] = Colors.grey;
      } else if (slot['status'] == 'Disable') {
        slot['status'] = 'Free';
        slot['color'] = Colors.green;
      }
    });
  }

  void _showAddDialog() {
    final TextEditingController roomNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Room'),
        content: TextField(
          controller: roomNameController,
          decoration: const InputDecoration(
            labelText: 'Room Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final roomName = roomNameController.text.trim();
              if (roomName.isNotEmpty) {
                addRoom(roomName);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void addRoom(String roomName) {
    setState(() {
      rooms[roomName] = [
        {'timeslot': '08:00 - 10:00', 'status': 'Free', 'color': Colors.green},
        {'timeslot': '10:00 - 12:00', 'status': 'Free', 'color': Colors.green},
        {'timeslot': '13:00 - 15:00', 'status': 'Free', 'color': Colors.green},
        {'timeslot': '15:00 - 17:00', 'status': 'Free', 'color': Colors.green},
      ];
    });
  }

  void confirmDeleteRoom(BuildContext context, String roomName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $roomName'),
        content: const Text('Are you sure you want to delete this room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deleteRoom(roomName);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void deleteRoom(String roomName) {
    setState(() {
      // Backup the room's data before deletion
      _deletedRoomBackup = {roomName: rooms[roomName]!};
      rooms.remove(roomName);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$roomName has been deleted.'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Restore the room data from backup if it exists
            if (_deletedRoomBackup != null) {
              setState(() {
                rooms[roomName] = _deletedRoomBackup![roomName]!;
                _deletedRoomBackup = null; // Clear backup after undo
              });
            }
          },
        ),
      ),
    );
  }
}
