// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
// import 'package:image_picker/image_picker.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Cat vs Dog',
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late Interpreter _interpreter;
//   bool _loading = true;
//   final ImagePicker _picker = ImagePicker();
//   File? _image;
//   String? _output;

//   @override
//   void initState() {
//     super.initState();
//     _loadModel();
//   }

//   Future<void> _loadModel() async {
//     try {
//       _interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite');
//       print('Model loaded successfully!');
//       setState(() {
//         _loading = false;
//       });
//     } catch (e) {
//       print('Failed to load model: $e');
//       setState(() {
//         _loading = false;
//       });
//     }
//   }

//   Future<void> chooseImage() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         _image = File(image.path);
//       });
//       classifyImage(_image!);
//     }
//   }

//   // Future<void> captureImage() async {
//   //   final XFile? image = await _picker.pickImage(source: ImageSource.camera);
//   //   if (image != null) {
//   //     setState(() {
//   //       _image = File(image.path);
//   //     });
//   //     classifyImage(_image!);
//   //   }
//   // }
//   Future<void> captureImage() async {
//   try {
//     final XFile? image = await _picker.pickImage(source: ImageSource.camera);
//     if (image != null) {
//       setState(() {
//         _image = File(image.path);
//       });
//       classifyImage(_image!);
//     } else {
//       print("No image was captured.");
//     }
//   } catch (e) {
//     print("Error while capturing image: $e");
//   }
// }


// Future<void> classifyImage(File image) async {
//   try {
//     if (_interpreter == null) {
//       throw Exception("Model not loaded");
//     }

//     // Preprocess the image
//     final input = _preprocessImage(image);

//     // Prepare output tensor
//     final output = List.filled(2, 0.0).reshape([1, 2]);

//     // Run the model
//     _interpreter.run(input, output);

//     // Process the output
//     print('Output tensor: $output');
//     final List probabilities = output[0];
//     String predictionLabel = probabilities[0] > probabilities[1] ? 'Cat' : 'Dog';

//     setState(() {
//       _output = predictionLabel;
//     });
//   } catch (e) {
//     print('Error during classification: $e');
//   }
// }


// List<List<List<List<double>>>> _preprocessImage(File image) {
//   // Decode image
//   final bytes = image.readAsBytesSync();
//   final img.Image? imageRaw = img.decodeImage(Uint8List.fromList(bytes));
//   if (imageRaw == null) throw Exception("Failed to decode image");

//   // Resize image
//   final img.Image resizedImage = img.copyResize(imageRaw, width: 224, height: 224);

//   // Normalize and create tensor
//   final input = List.generate(
//     1,
//     (_) => List.generate(
//       224,
//       (y) => List.generate(
//         224,
//         (x) {
//           final pixel = resizedImage.getPixel(x, y);
//           final r = img.getRed(pixel) / 255.0;
//           final g = img.getGreen(pixel) / 255.0;
//           final b = img.getBlue(pixel) / 255.0;
//           return [r, g, b];
//         },
//       ),
//     ),
//   );
//   return input;
// }


//   @override
//   void dispose() {
//     _interpreter.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0XFF101010),
//       body: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             const SizedBox(height: 85),
//             // const Text(
//             //   'CNN Project',
//             //   style: TextStyle(color: Color(0XFFEEDA28), fontSize: 18),
//             // ),
//             const SizedBox(height: 6),
//             const Text(
//               'Detect Dogs and Cats',
//               style: TextStyle(
//                 color: Color(0XFFE99600),
//                 fontSize: 28,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 100),
//             Center(
//               child: _loading
//                   ? const CircularProgressIndicator()
//                   : Column(
//                       children: [
//                         _image != null
//                             ? SizedBox(
//                                 height: 250,
//                                 child: Image.file(_image!),
//                               )
//                             : const Text(
//                                 'No image selected',
//                                 style: TextStyle(color: Colors.white, fontSize: 18),
//                               ),
//                         const SizedBox(height: 20),
//                         _output != null
//                             ? Text(
//                                 'Prediction: $_output',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 20,
//                                 ),
//                               )
//                             : Container(),
//                         const SizedBox(height: 50),
//                       ],
//                     ),
//             ),
//             SizedBox(
//               width: MediaQuery.of(context).size.width,
//               child: Column(
//                 children: [
//                   GestureDetector(
//                     onTap: captureImage,
//                     child: Container(
//                       width: MediaQuery.of(context).size.width - 150,
//                       alignment: Alignment.center,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 17,
//                       ),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFE99600),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: const Text(
//                         'Take a photo',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   GestureDetector(
//                     onTap: chooseImage,
//                     child: Container(
//                       width: MediaQuery.of(context).size.width - 150,
//                       alignment: Alignment.center,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 24,
//                         vertical: 17,
//                       ),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFE99600),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: const Text(
//                         'Camera roll',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_dog_cateclassification/real_time_classification.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cat vs Dog',
      home: RealTimeDogCatClassification(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Interpreter _interpreter;
  bool _loading = true;
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _output;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  // Load the TFLite model
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite');
      print('Model loaded successfully!');
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

  // Request camera and storage permissions
  Future<void> requestPermissions() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      print("Camera permission granted");
    } else {
      print("Camera permission denied");
    }
    status = await Permission.storage.request();
    if (status.isGranted) {
      print("Storage permission granted");
    } else {
      print("Storage permission denied");
    }
  }

  // Choose image from gallery
  Future<void> chooseImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
      classifyImage(_image!);
    }
  }

  // Capture image using camera
  // Future<void> captureImage() async {
  //   try {
  //     await requestPermissions(); // Request necessary permissions
  //     final XFile? image = await _picker.pickImage(source: ImageSource.camera);
  //     if (image != null) {
  //       setState(() {
  //         _image = File(image.path);
  //       });
  //       classifyImage(_image!);
  //     } else {
  //       print("No image was captured.");
  //     }
  //   } catch (e) {
  //     print("Error while capturing image: $e");
  //   }
  // }

  // Classify image using the model
  Future<void> classifyImage(File image) async {
    try {
      if (_interpreter == null) {
        throw Exception("Model not loaded");
      }

      // Preprocess the image
      final input = _preprocessImage(image);

      // Prepare output tensor
      final output = List.filled(2, 0.0).reshape([1, 2]);

      // Run the model
      _interpreter.run(input, output);

      // Process the output
      print('Output tensor: $output');
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
    // Decode image
    final bytes = image.readAsBytesSync();
    final img.Image? imageRaw = img.decodeImage(Uint8List.fromList(bytes));
    if (imageRaw == null) throw Exception("Failed to decode image");

    // Resize image
    final img.Image resizedImage = img.copyResize(imageRaw, width: 224, height: 224);

    // Normalize and create tensor
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
                        _image != null
                            ? SizedBox(
                                height: 250,
                                child: Image.file(_image!),
                              )
                            : const Text(
                                'No image selected',
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
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
                        const SizedBox(height: 50),
                      ],
                    ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  // GestureDetector(
                  //   onTap: captureImage,
                  //   child: Container(
                  //     width: MediaQuery.of(context).size.width - 150,
                  //     alignment: Alignment.center,
                  //     padding: const EdgeInsets.symmetric(
                  //       horizontal: 24,
                  //       vertical: 17,
                  //     ),
                  //     decoration: BoxDecoration(
                  //       color: const Color(0xFFE99600),
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     child: const Text(
                  //       'Take a photo',
                  //       style: TextStyle(color: Colors.white),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: chooseImage,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 150,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 17,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE99600),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Camera roll',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
