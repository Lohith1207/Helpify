import 'package:flutter/material.dart';
import 'package:helpify/myhomepage.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health AI',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        primaryColor: Colors.grey[900],
        cardColor: Colors.grey[850],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: myhomepage(cameras: cameras),
    );
  }
}
