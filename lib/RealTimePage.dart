import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class RealTimePage extends StatefulWidget {
  const RealTimePage({super.key});

  @override
  _RealTimePageState createState() => _RealTimePageState();
}

class _RealTimePageState extends State<RealTimePage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  static const platform = MethodChannel('onnx_runtime');
  String _detectionResult = '';
  List<Rect> _boundingBoxes = [];
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
      );

      _initializeControllerFuture = _cameraController.initialize();
      await _initializeControllerFuture;

      // Jalankan inferensi setelah kamera diinisialisasi
      _cameraController.startImageStream((CameraImage image) {
        if (!_isDetecting) {
          _isDetecting = true;
          _runInference(image);
        }
      });

      setState(
          () {}); // Panggil setState untuk memperbarui UI setelah inisialisasi
    } catch (e) {
      setState(() {
        _detectionResult = 'Error initializing camera: $e';
      });
    }
  }

  Future<void> _runInference(CameraImage image) async {
    try {
      // Proses frame kamera dan konversi ke format yang dapat diterima oleh model
      final List<dynamic> result = await platform.invokeMethod('runInference', {
        'planes': image.planes.map((plane) => plane.bytes).toList(),
        'width': image.width,
        'height': image.height,
      });

      List<Rect> boxes = [];
      for (int i = 0; i < result.length; i += 4) {
        double x1 = result[i];
        double y1 = result[i + 1];
        double x2 = result[i + 2];
        double y2 = result[i + 3];
        boxes.add(Rect.fromLTRB(x1, y1, x2, y2));
      }

      setState(() {
        _boundingBoxes = boxes;
        _detectionResult = 'Jumlah telur ikan: ${boxes.length}';
      });

      _isDetecting = false;
    } catch (e) {
      setState(() {
        _detectionResult = 'Error: $e';
      });

      _isDetecting = false;
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deteksi Objek Langsung'),
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: CameraPreview(_cameraController),
                ),
                if (_boundingBoxes.isNotEmpty)
                  Stack(
                    children: _boundingBoxes.map((box) {
                      return Positioned(
                        left: box.left,
                        top: box.top,
                        width: box.width,
                        height: box.height,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                Positioned(
                  top: 30,
                  left: 10,
                  child: Text(
                    _detectionResult,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
