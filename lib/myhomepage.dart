import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:helpify/camera_screen.dart'; // import your camera screen

class myhomepage extends StatelessWidget {
  final List<CameraDescription> cameras;
  const myhomepage({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Helpy', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Helpy!',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              tooltip: 'Open Camera',
              iconSize: 100,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CameraScreen(cameras: cameras),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
