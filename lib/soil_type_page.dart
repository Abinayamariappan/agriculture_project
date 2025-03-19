import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SoilTypePage extends StatefulWidget {
  @override
  _SoilTypePageState createState() => _SoilTypePageState();
}

class _SoilTypePageState extends State<SoilTypePage> {
  File? _selectedImage;
  String? _soilType;
  String? _suggestedCrops;

  // ✅ Image Picker Function
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _soilType = null; // Reset previous result
        _suggestedCrops = null;
      });
    }
  }

  // ✅ Simulating AI Model for Soil Detection
  void _analyzeSoil() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image first')),
      );
      return;
    }

    // 🔍 Simulated AI Model Logic
    setState(() {
      List<String> soilTypes = ["Clay Soil", "Sandy Soil", "Loamy Soil", "Silty Soil", "Peaty Soil"];
      List<String> cropSuggestions = [
        "Rice, Lettuce, Cabbage",
        "Carrots, Radishes, Watermelons",
        "Wheat, Corn, Pulses",
        "Sugarcane, Mango, Banana",
        "Strawberries, Peppers, Tomatoes"
      ];

      int randomIndex = _selectedImage!.path.length % soilTypes.length;
      _soilType = soilTypes[randomIndex];
      _suggestedCrops = cropSuggestions[randomIndex];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Analysis Complete: $_soilType detected")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Type Identification'),
        backgroundColor: Colors.indigo,
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Title
            const Text(
              'Upload an Image to Identify Soil Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // ✅ Image Preview
            _selectedImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_selectedImage!, height: 250, fit: BoxFit.cover),
            )
                : Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text("No image selected", style: TextStyle(color: Colors.black54))),
            ),

            const SizedBox(height: 20),

            // ✅ Buttons for Image Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Capture"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gallery"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ Submit for Analysis
            ElevatedButton(
              onPressed: _analyzeSoil,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text("Analyze Soil", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),

            const SizedBox(height: 30),

            // ✅ Display Soil Type & Suggested Crops
            if (_soilType != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 2)
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Soil Type: $_soilType",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Suggested Crops: $_suggestedCrops",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      backgroundColor: Colors.grey[200], // Light Background
    );
  }
}
