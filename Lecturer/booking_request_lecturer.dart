import 'package:flutter/material.dart';
import 'menu_lecturer.dart';

class BookingRequestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Request"),
      ),
      backgroundColor: colorScheme.primary,
      drawer: const MenuLecturerPage(),
      body: Stack(
        children: [
          // White background container with rounded corners at the top
          Container(
            margin: const EdgeInsets.only(top: 50),
            decoration: const BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                bookingCard(
                  context,
                  room: "Room 1",
                  timeRange: "08:00 - 10:00",
                  requestBy: "6531501170",
                  date: "20/10/2024",
                  bookingTime: "07:30:33 AM",
                ),
                const SizedBox(height: 16),
                bookingCard(
                  context,
                  room: "Room 2",
                  timeRange: "13:00 - 15:00",
                  requestBy: "6531501150",
                  date: "20/10/2024",
                  bookingTime: "10:35:59 AM",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget bookingCard(
    BuildContext context, {
    required String room,
    required String timeRange,
    required String requestBy,
    required String date,
    required String bookingTime,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      height: 250,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Background of the card with blue shadow and rounded corners
          Container(
            height: 250,
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
            // Inner white card with rounded corners
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      room,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Time: $timeRange",
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Request by: $requestBy",
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Date: $date",
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Booking Time: $bookingTime",
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Action for Yes button
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            minimumSize: const Size(100, 40),
                          ),
                          child: const Text(
                            "Yes",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Action for No button
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            minimumSize: const Size(100, 40),
                          ),
                          child: const Text(
                            "No",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
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
}
