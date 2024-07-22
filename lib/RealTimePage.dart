import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RealTimePage extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  Future<void> _openCamera(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gambar dari kamera diambil: ${image.path}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deteksi Objek Langsung'),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _openCamera(context),
              child: Text('Buka Kamera'),
            ),
            SizedBox(height: 20), // Jarak antara dua tombol
          ],
        ),
      ),
    );
  }
}
