import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';
import 'package:image_picker/image_picker.dart';

class RecipeOcrScreen extends StatefulWidget {
  const RecipeOcrScreen({super.key});

  @override
  State<RecipeOcrScreen> createState() => _RecipeOcrScreenState();
}

class _RecipeOcrScreenState extends State<RecipeOcrScreen> {
  // For receiving the scanned text from the camera
  final StreamController<String> _scannedTextController = StreamController<String>();

  // Basic camera toggles
  bool _torchOn = false;
  int _cameraSelection = 0;
  bool _lockCamera = true;
  bool _loading = false;

  // Holds the file from gallery, if user loads one
  File? _loadedImage;

  // Keys
  final GlobalKey<ScalableOCRState> _cameraKey = GlobalKey<ScalableOCRState>();

  @override
  void dispose() {
    _scannedTextController.close();
    super.dispose();
  }

  /// Called whenever `ScalableOCR` returns new text.
  void _onTextScanned(String text) {
    _scannedTextController.add(text);
  }

  /// Called when user picks an image from gallery
  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _loadedImage = File(pickedFile.path);
      });
      // If you want to do OCR on the loaded image, you'd need to see if
      // flutter_scalable_ocr can process a static file directly, or use another library.
      // For demonstration, we'll do a placeholder:
      _scannedTextController.add("Loaded image: ${pickedFile.path}\n(You could OCR this offline.)");
    }
  }

  void _switchCamera() {
    setState(() {
      _loading = true;
      _cameraSelection = (_cameraSelection == 0) ? 1 : 0;
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {
        _loading = false;
      });
    });
  }

  void _toggleTorch() {
    setState(() {
      _loading = true;
      _torchOn = !_torchOn;
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {
        _loading = false;
      });
    });
  }

  void _toggleLockCamera() {
    setState(() {
      _loading = true;
      _lockCamera = !_lockCamera;
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan a Recipe'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // If we haven't loaded an image, show the camera widget
            if (_loadedImage == null) ...[
              if (!_loading)
                ScalableOCR(
                  key: _cameraKey,
                  torchOn: _torchOn,
                  cameraSelection: _cameraSelection,
                  lockCamera: _lockCamera,
                  paintboxCustom: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 4.0
                    ..color = const Color.fromARGB(153, 102, 160, 241),
                  boxLeftOff: 5,
                  boxBottomOff: 2.5,
                  boxRightOff: 5,
                  boxTopOff: 2.5,
                  boxHeight: MediaQuery.of(context).size.height / 3,
                  getRawData: (value) {
                    inspect(value);
                  },
                  getScannedText: (value) {
                    _onTextScanned(value);
                  },
                )
              else
                // placeholder loading container
                Padding(
                  padding: const EdgeInsets.all(17.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: MediaQuery.of(context).size.height / 3,
                    width: MediaQuery.of(context).size.width,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ] else ...[
              // If an image is loaded, show the image
              Image.file(
                _loadedImage!,
                height: MediaQuery.of(context).size.height / 3,
                fit: BoxFit.contain,
              ),
            ],

            // Show scanned or loaded text
            StreamBuilder<String>(
              stream: _scannedTextController.stream,
              builder: (context, snapshot) {
                final text = snapshot.data ?? '';
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Detected text: $text"),
                );
              },
            ),

            // Buttons row
            Wrap(
              spacing: 16,
              children: [
                ElevatedButton(
                  onPressed: _switchCamera,
                  child: const Text("Switch Camera"),
                ),
                ElevatedButton(
                  onPressed: _toggleTorch,
                  child: const Text("Toggle Torch"),
                ),
                ElevatedButton(
                  onPressed: _toggleLockCamera,
                  child: const Text("Toggle Lock Camera"),
                ),
                ElevatedButton(
                  onPressed: _pickImageFromGallery,
                  child: const Text("Load Image from Gallery"),
                ),
                if (_loadedImage != null)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadedImage = null; // Clear
                      });
                      _scannedTextController.add("");
                    },
                    child: const Text("Clear Loaded Image"),
                  )
              ],
            )
          ],
        ),
      ),
    );
  }
}
