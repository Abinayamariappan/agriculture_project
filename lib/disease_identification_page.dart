import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DiseaseIdentificationPage extends StatefulWidget {
  @override
  _DiseaseIdentificationPageState createState() => _DiseaseIdentificationPageState();
}

class _DiseaseIdentificationPageState extends State<DiseaseIdentificationPage> {
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForAnalysis() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an image first!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final bytes = await _selectedImage!.readAsBytes();
    final base64Image = base64Encode(bytes);

    final url = Uri.parse("https://api.plant.id/v2/health_assessment");
    const apiKey = "bIYxKxD7VwY0EUV6aAD8fva3TZgd0U9IRvJP8RGIxiMRx3ZpIq"; // 🔐 Replace with your actual API key

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Api-Key': apiKey,
      },
      body: jsonEncode({
        "images": [base64Image],
        "modifiers": ["crops_fast", "similar_images"],
        "plant_language": "en",
        "disease_details": ["description", "treatment"],
      }),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final assessment = data['health_assessment'];

      if (assessment != null && assessment.isNotEmpty && assessment[0]['diseases'].isNotEmpty) {
        final disease = assessment[0]['diseases'][0];
        final name = disease['name'] ?? "Unknown";
        final description = disease['description'] ?? "No description.";
        final treatment = disease['treatment']['biological'] ?? "No treatment information.";

        _showResultDialog(name, description, treatment);
      } else {
        _showResultDialog("No disease found", "The plant looks healthy!", "");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to analyze the image.")),
      );
    }
  }

  void _showResultDialog(String name, String description, String treatment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📝 Description:\n$description\n"),
              Text("🛠️ Treatment:\n$treatment"),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
        ],
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Disease Identification', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCustomButton(Icons.camera_alt, "Capture", Colors.blue, () => _pickImage(ImageSource.camera)),
                _buildCustomButton(Icons.photo_library, "Gallery", Colors.green, () => _pickImage(ImageSource.gallery)),
              ],
            ),
            const SizedBox(height: 30),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
              onPressed: _submitForAnalysis,
              icon: Icon(Icons.search, color: Colors.white),
              label: Text("Submit for Analysis", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                elevation: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
