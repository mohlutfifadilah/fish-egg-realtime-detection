import 'package:fish_egg_realtime_detection/CameraPage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class InputPage extends StatefulWidget {
  const InputPage({Key? key}) : super(key: key);

  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  List<CameraDescription>? cameras;
  List<dynamic> _detections = [];
  int _totalObjects = 0;

  @override
  void initState() {
    super.initState();
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    cameras = await availableCameras();
  }

  Future<List<dynamic>> _runModel(String imagePath) async {
    try {
      Uri uri = Uri.parse('http://127.0.0.1:5000/run_model');
      var request = http.MultipartRequest('POST', uri);

      if (kIsWeb) {
        // Web-specific file upload code
        final file = File(imagePath);
        final bytes = await file.readAsBytes();
        request.files.add(
            http.MultipartFile.fromBytes('file', bytes, filename: 'image.jpg'));
      } else {
        // Mobile-specific file upload code
        request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var result = json.decode(responseData);
        return result['detections'] ?? [];
      } else {
        print('Failed to run model');
        return [];
      }
    } catch (e) {
      print("Failed to run model: $e");
      return [];
    }
  }

  Future<void> _openCamera(BuildContext context) async {
    if (cameras != null && cameras!.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraPage(
              cameras: cameras!,
              onPictureTaken: (path) {
                setState(() {
                  _imagePath = path;
                });
                _processImage(path);
              }),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada kamera yang tersedia')),
      );
    }
  }

  Future<void> _inputGambar(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gambar dari galeri diambil: ${image.path}')),
        );
        _processImage(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _processImage(String imagePath) async {
    final results = await _runModel(imagePath);
    setState(() {
      _detections = results;
      _totalObjects = results.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambil atau Input Gambar'),
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
            ElevatedButton(
              onPressed: () => _inputGambar(context),
              child: const Text('Input Gambar dari Galeri'),
            ),
            const SizedBox(height: 20),
            _imagePath != null
                ? kIsWeb
                    ? Image.network(
                        _imagePath!,
                        width: 300,
                        height: 300,
                      )
                    : Stack(
                        children: [
                          Image.file(
                            File(_imagePath!),
                            width: 300,
                            height: 300,
                          ),
                          ..._detections.map((detection) {
                            final x = detection['x'];
                            final y = detection['y'];
                            final width = detection['width'];
                            final height = detection['height'];
                            return Positioned(
                              left: x,
                              top: y,
                              child: Container(
                                width: width,
                                height: height,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      )
                : const Text('Tidak ada gambar yang dipilih.'),
            const SizedBox(height: 20),
            _imagePath != null
                ? Text('Total objek terdeteksi: $_totalObjects')
                : Container(),
          ],
        ),
      ),
    );
  }
}
