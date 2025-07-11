import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool isInitialized = false;
  bool isDetecting = false;
  final FlutterTts flutterTts = FlutterTts();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.low,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        isInitialized = true;
      });
      startImageStream();
    });
  }

  void startImageStream() {
    _controller.startImageStream((CameraImage image) async {
      if (_timer != null && _timer!.isActive) return;

      _timer = Timer(Duration(seconds: 2), () {}); // throttle frame

      Uint8List jpegBytes = await convertYUV420toJpeg(image);
      await sendFrame(jpegBytes);

      isDetecting = false;
    });
  }

  Future<Uint8List> convertYUV420toJpeg(CameraImage image) async {
    try {
      final int width = image.width;
      final int height = image.height;

      final img.Image imgBuffer = img.Image(width: width, height: height);

      final bytes = image.planes[0].bytes; // Y plane (grayscale)

      int pixelIndex = 0;
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final pixel = bytes[pixelIndex++];
          imgBuffer.setPixelRgb(x, y, pixel, pixel, pixel); // grayscale RGB
        }
      }

      return Uint8List.fromList(img.encodeJpg(imgBuffer));
    } catch (e) {
      print("Image conversion error: $e");
      return Uint8List(0); // empty on error
    }
  }

  Future<void> sendFrame(Uint8List imageBytes) async {
    try {
      var uri = Uri.parse('https://yoloassist.onrender.com/detect/');
      var request = http.MultipartRequest('POST', uri)
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageBytes,
            filename: 'frame.jpg',
          ),
        );
      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        print('🔎 API Response: $respStr');

        await speak(respStr);
      } else {
        print('Detection failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Live Object Detection",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: CameraPreview(_controller),
    );
  }
}
