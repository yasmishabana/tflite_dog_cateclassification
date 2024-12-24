import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

class RealTimeDogCatClassification extends StatefulWidget {
  const RealTimeDogCatClassification({super.key});

  @override
  State<RealTimeDogCatClassification> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<RealTimeDogCatClassification> {
  late Interpreter _interpreter;
  bool _loading = true;
  String? _output;
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _initializeCamera();
  }

  // Load the TFLite model
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite');
      setState(() {
        _loading = false;
      });
    } catch (e) {
      print('Failed to load model: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  // Initialize the back camera
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      final camera = _cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back); // Use back camera

      _cameraController = CameraController(camera, ResolutionPreset.high);
      await _cameraController!.initialize();
      setState(() {
        _isCameraReady = true;
      });
      _cameraController!.startImageStream((image) {
        _processCameraImage(image);
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  // Process camera image frames for classification
  Future<void> _processCameraImage(CameraImage image) async {
    if (!_loading && _cameraController != null) {
      final bytes = await _cameraController!.takePicture();
      classifyImage(File(bytes.path)); // Classify the captured image
    }
  }

  // Classify image using the model
  Future<void> classifyImage(File image) async {
    try {
      if (_interpreter == null) {
        throw Exception("Model not loaded");
      }

      final input = _preprocessImage(image);
      final output = List.filled(2, 0.0).reshape([1, 2]);

      _interpreter.run(input, output);

      final List probabilities = output[0];
      String predictionLabel = probabilities[0] > probabilities[1] ? 'Cat' : 'Dog';

      setState(() {
        _output = predictionLabel;
      });
    } catch (e) {
      print('Error during classification: $e');
    }
  }

  // Preprocess image: resize and normalize
  List<List<List<List<double>>>> _preprocessImage(File image) {
    final bytes = image.readAsBytesSync();
    final img.Image? imageRaw = img.decodeImage(Uint8List.fromList(bytes));
    if (imageRaw == null) throw Exception("Failed to decode image");

    final resizedImage = img.copyResize(imageRaw, width: 224, height: 224);

    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            final r = img.getRed(pixel) / 255.0;
            final g = img.getGreen(pixel) / 255.0;
            final b = img.getBlue(pixel) / 255.0;
            return [r, g, b];
          },
        ),
      ),
    );
    return input;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _interpreter.close();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0XFF101010),
    body: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 85),
          const SizedBox(height: 6),
          const Text(
            'Detect Dogs and Cats',
            style: TextStyle(
              color: Color(0XFFE99600),
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 100),
          Center(
            child: _loading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      _isCameraReady
                          ? SizedBox(
                              height: 500,  // Adjust this value as needed
                              width: double.infinity,  // Fill the screen width
                              child: CameraPreview(_cameraController!),
                            )
                          : const Text('Camera is loading...'),
                      const SizedBox(height: 20),
                      _output != null
                          ? Text(
                              'Prediction: $_output',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            )
                          : Container(),
                    ],
                  ),
          ),
        ],
      ),
    ),
  );
}

}
