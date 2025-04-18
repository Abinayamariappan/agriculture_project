import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class PlantDiseasePage extends StatefulWidget {
  @override
  _PlantDiseasePageState createState() => _PlantDiseasePageState();
}

class _PlantDiseasePageState extends State<PlantDiseasePage> {
  File? _image;
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  final String apiKey = 'bIYxKxD7VwY0EUV6aAD8fva3TZgd0U9IRvJP8RGIxiMRx3ZpIq';

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = null;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = await _image!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://api.plant.id/v2/identify'),
        headers: {
          'Content-Type': 'application/json',
          'Api-Key': apiKey,
        },
        body: jsonEncode({
          "images": [base64Image],
          "modifiers": ["crops_fast", "similar_images"],
          "plant_language": "en",
          "disease_details": ["common_names", "description", "treatment", "url"]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _result = data;
        });
      } else {
        throw Exception('Failed to analyze plant. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildResultCard() {
    if (_result == null) return SizedBox();

    final suggestions = _result!['suggestions'] ?? [];

    if (suggestions.isEmpty) {
      return const Text('No diseases found.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: suggestions.map<Widget>((item) {
        final plantName = item['plant_name'];
        final probability = (item['probability'] * 100).toStringAsFixed(2);
        final diseases = item['diseases'] as List<dynamic>?;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plant: $plantName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Confidence: $probability%'),
                if (diseases != null && diseases.isNotEmpty)
                  ...diseases.map((disease) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Disease: ${disease['name']}', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Description: ${disease['description'] ?? "N/A"}'),
                        Text('Treatment: ${disease['treatment'] ?? "N/A"}'),
                      ],
                    ),
                  )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plant Disease Identifier'), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_image!, height: 220, fit: BoxFit.cover),
              )
            else
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Center(
                    child: Text('Tap to Upload Plant Image', style: TextStyle(color: Colors.green)),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (_image != null && !_isLoading)
              ElevatedButton.icon(
                onPressed: _analyzeImage,
                icon: const Icon(Icons.search),
                label: const Text('Analyze Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
              ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            const SizedBox(height: 20),
            if (_result != null) _buildResultCard(),
          ],
        ),
      ),
    );
  }
}
