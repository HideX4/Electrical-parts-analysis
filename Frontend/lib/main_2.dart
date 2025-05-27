import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'prediction_screen.dart';
import 'gallery.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from Camera or Gallery
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      File imageFile = File(image.path);
      _sendImageToServer(imageFile);
    }
  }

  // Function to upload image to the server
  Future<void> _sendImageToServer(File imageFile) async {
    String serverUrl = "http://194.171.191.226:2583/predict";
    //String serverUrl = "http://10.0.2.2:8000/predict";

    var request = http.MultipartRequest("POST", Uri.parse(serverUrl));
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);

        String prediction = jsonResponse['prediction'];
        double confidence = jsonResponse['confidence'];

        // Extract other confidence scores
        Map<String, double> otherConfidences = {};
        if (jsonResponse.containsKey('other_confidences')) {
          otherConfidences = Map<String, double>.from(
            jsonResponse['other_confidences'].map(
              (key, value) => MapEntry(key, value.toDouble()),
            ),
          );
        }

        // Navigate to Prediction Screen with other confidence scores
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => PredictionScreen(
                  imagePath: imageFile.path,
                  prediction: prediction,
                  confidence: confidence,
                  otherConfidences: otherConfidences,
                ),
          ),
        );
      } else {
        _showError("Failed to get response from server.");
      }
    } catch (e) {
      _showError("Error: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.black),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
        ),
        title: const Text(
          "Welcome back",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [Icon(Icons.settings, color: Colors.black)],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.grey[300],
          child: Column(
            children: [
              const SizedBox(height: 50), // Space at the top
              _buildDrawerButton("Gallery"),
              _buildDrawerButton("Components list"),
              _buildDrawerButton("About"),
              _buildDrawerButton("Projects"),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.camera), // Take picture
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border.all(color: Colors.black26),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.black,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Take a Picture",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap:
                        () => _pickImage(
                          ImageSource.gallery,
                        ), // Pick from gallery
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border.all(color: Colors.black26),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library,
                              size: 40,
                              color: Colors.black,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Choose from Gallery",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.black87,
            width: double.infinity,
            child: const Text(
              "CompanyName @ 202X. All rights reserved.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (text == "Gallery") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GalleryScreen()),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.black),
            ),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
