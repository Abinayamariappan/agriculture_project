import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PlantDiseasePage extends StatefulWidget {
  @override
  _PlantDiseasePageState createState() => _PlantDiseasePageState();
}

class _PlantDiseasePageState extends State<PlantDiseasePage> {
  File? _selectedImage;
  String? _diseaseType;
  String? _solution;

  // ✅ Pick Image from Gallery or Camera
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _diseaseType = null; // Reset previous result
        _solution = null;
      });
    }
  }

  // ✅ Simulate Disease Detection
  void _submitForDetection() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image first')),
      );
      return;
    }

    // Simulating AI model response (Replace this with real AI integration)
    setState(() {
      _diseaseType = "Leaf Spot Disease"; // Example disease
      _solution = "Apply a copper-based fungicide and ensure proper air circulation.";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Analysis complete! Check results below.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Identification', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Image Display Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 8,
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.image_outlined, size: 60, color: Colors.grey),
                      SizedBox(height: 10),
                      Text("No Image Selected", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Button Row for Image Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCustomButton(Icons.camera_alt, "Capture", Colors.blue, () => _pickImage(ImageSource.camera)),
                _buildCustomButton(Icons.photo_library, "Gallery", Colors.green, () => _pickImage(ImageSource.gallery)),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ Submit Button
            ElevatedButton(
              onPressed: _submitForDetection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
              ),
              child: const Text("Submit for Analysis", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),

            const SizedBox(height: 20),

            // ✅ Display Disease Type and Solution
            if (_diseaseType != null && _solution != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("🔍 Disease Detected:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(_diseaseType!, style: TextStyle(fontSize: 16, color: Colors.red)),

                  const SizedBox(height: 10),

                  Text("💡 Solution:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(_solution!, style: TextStyle(fontSize: 16, color: Colors.green)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ✅ Custom Button Widget
  Widget _buildCustomButton(IconData icon, String label, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        elevation: 5,
      ),
    );
  }
}
