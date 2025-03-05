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
  final StreamController<String> _scannedTextController =
      StreamController<String>();

  // Basic camera toggles
  bool _torchOn = false;
  int _cameraSelection = 0;
  bool _lockCamera = true;
  bool _loading = false;

  // Holds the file from gallery, if user loads one
  File? _loadedImage;

  // Keys
  final GlobalKey<ScalableOCRState> _cameraKey = GlobalKey<ScalableOCRState>();

  // Local variable to store the latest recognized text
  String _latestScannedText = '';

  // Recipe fields (very basic example)
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();
  final TextEditingController _prepTimeController = TextEditingController();
  final TextEditingController _cookTimeController = TextEditingController();
  final TextEditingController _servingsController = TextEditingController();

  @override
  void dispose() {
    _scannedTextController.close();
    super.dispose();
  }

  /// Called whenever `ScalableOCR` returns new text.
  void _onTextScanned(String text) {
    // Update the stream
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
      // For demonstration, add a placeholder text:
      _scannedTextController.add(
          "Loaded image: ${pickedFile.path}\n(You could OCR this offline.)");
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

  /// Very naive parsing that looks for lines beginning with "Title:",
  /// "Ingredients:", "Steps:", etc., and puts them into controllers.
  /// Adapt as needed!
  void _autoFillFieldsFromText(String rawText) {
    final lines =
        rawText.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty);

    for (String line in lines) {
      if (line.toLowerCase().startsWith("title:")) {
        _titleController.text =
            line.replaceFirst(RegExp(r'(?i)title:'), '').trim();
      } else if (line.toLowerCase().startsWith("ingredients:")) {
        _ingredientsController.text =
            line.replaceFirst(RegExp(r'(?i)ingredients:'), '').trim();
      } else if (line.toLowerCase().startsWith("steps:") ||
          line.toLowerCase().startsWith("directions:")) {
        _stepsController.text =
            line.replaceFirst(RegExp(r'(?i)steps:|directions:'), '').trim();
      } else if (line.toLowerCase().startsWith("prep time:")) {
        _prepTimeController.text =
            line.replaceFirst(RegExp(r'(?i)prep time:'), '').trim();
      } else if (line.toLowerCase().startsWith("cook time:")) {
        _cookTimeController.text =
            line.replaceFirst(RegExp(r'(?i)cook time:'), '').trim();
      } else if (line.toLowerCase().startsWith("servings:")) {
        _servingsController.text =
            line.replaceFirst(RegExp(r'(?i)servings:'), '').trim();
      }
    }
  }

  void _showRecipeSummary() {
    final summary = '''
Title: ${_titleController.text}
Ingredients: ${_ingredientsController.text}
Steps: ${_stepsController.text}
Prep Time: ${_prepTimeController.text}
Cook Time: ${_cookTimeController.text}
Servings: ${_servingsController.text}
''';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Recipe Summary'),
        content: SingleChildScrollView(
          child: Text(summary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
                    // This returns the raw MLKit blocks, lines, etc. for debugging
                    inspect(value);
                  },
                  getScannedText: (value) {
                    _onTextScanned(value);
                  },
                )
              else
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
              Image.file(
                _loadedImage!,
                height: MediaQuery.of(context).size.height / 3,
                fit: BoxFit.contain,
              ),
            ],

            // Listen to the OCR stream and keep the latest text in memory.
            StreamBuilder<String>(
              stream: _scannedTextController.stream,
              builder: (context, snapshot) {
                // If there is new text, update _latestScannedText
                final text = snapshot.data ?? '';
                _latestScannedText = text;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Detected text:\n$text"),
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
            ),

            // A button to parse the recognized text into the fields
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  // Use the last scanned text
                  _autoFillFieldsFromText(_latestScannedText);
                },
                child: const Text("Auto-Fill Fields from Detected Text"),
              ),
            ),

            // A simple "recipe fields" form so user can refine
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildTextField("Title", _titleController),
                  _buildTextField("Ingredients", _ingredientsController,
                      maxLines: 3),
                  _buildTextField("Steps / Instructions", _stepsController,
                      maxLines: 5),
                  Row(
                    children: [
                      Expanded(
                        child:
                            _buildTextField("Prep Time", _prepTimeController),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child:
                            _buildTextField("Cook Time", _cookTimeController),
                      ),
                    ],
                  ),
                  _buildTextField("Servings", _servingsController),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _showRecipeSummary,
                    child: const Text("Show Summary"),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Helper to build a standard text field
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
    );
  }
}
