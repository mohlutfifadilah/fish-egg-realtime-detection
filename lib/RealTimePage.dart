import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'onnx_runtime.dart'; // Import file onnx_runtime.dart

class RealTimePage extends StatefulWidget {
  const RealTimePage({super.key});

  @override
  _RealTimePageState createState() => _RealTimePageState();
}

class _RealTimePageState extends State<RealTimePage> {
  final ImagePicker _picker = ImagePicker();
  String _detectionResult = '';

  Future<void> _openCamera(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gambar dari kamera diambil: ${image.path}')),
        );
        // Panggil metode inferensi setelah mengambil gambar
        await _runInference(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _runInference(String imagePath) async {
    try {
      List<double> result = await OnnxRuntime.runInference(imagePath);
      setState(() {
        _detectionResult = 'Jumlah telur ikan: ${result.length}'; // Sesuaikan berdasarkan hasil model Anda
      });
    } catch (e) {
      setState(() {
        _detectionResult = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deteksi Objek Langsung'),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _openCamera(context),
              child: const Text('Buka Kamera'),
            ),
            const SizedBox(height: 20),
            Text(_detectionResult),
          ],
        ),
      ),
    );
  }
}
