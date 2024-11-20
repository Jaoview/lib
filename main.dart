import 'package:flutter/material.dart';
import 'package:project/Login/login.dart';
//import 'package:project/User/room_list_user.dart';

// ThemeData myTheme = ThemeData(
//   // material 3 is default, you can neglect this line
//   useMaterial3: true,
//   // color theme
//   colorScheme: ColorScheme.fromSeed(
//     seedColor: Colors.blueAccent,
//     brightness: Brightness.light,
//   ),
// );

//   floatingActionButtonTheme: const FloatingActionButtonThemeData(
//     backgroundColor: Colors.black,
//   ),
//   elevatedButtonTheme: ElevatedButtonThemeData(
//     style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
//   ),
// );

// ThemeData myThem = ThemeData(
//   textTheme: const TextTheme(
//     displayLarge: TextStyle(
//       color: Colors.red,
//       fontSize: 80,
//       //fontFamily: 'PlaywriteCU',
//       ),
//   ),
//   fontFamily: 'PlaywriteCU'
// );

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: Login(),
      //theme: myTheme,
      debugShowCheckedModeBanner: false,
    ),
  );
}


