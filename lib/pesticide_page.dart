import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart'; // ✅ Import SQLite Database Helper

// ✅ Global Variable to Store Logged-in Farmer ID
int? loggedInFarmerId;

class PesticidePage extends StatefulWidget {
  @override
  _PesticidePageState createState() => _PesticidePageState();
}

class _PesticidePageState extends State<PesticidePage> {
  final TextEditingController _pesticideTypeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _sprayingAreaController = TextEditingController();
  File? _selectedImage;
  String _imageStatus = "No Image Uploaded";

  // ✅ Pick Image from Gallery
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _imageStatus = "Image Uploaded ✅";
      });
    }
  }

  // ✅ Show Success Alert
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Success ✅"),
          content: const Text("Pesticide spraying request added successfully!"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
          ],
        );
      },
    );
  }

  // ✅ Submit Pesticide Spraying Request
  void _submitRequest() async {
    if (loggedInFarmerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No farmer logged in! Please login first.')),
      );
      return;
    }

    if (_pesticideTypeController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _sprayingAreaController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all fields and select an image')),
      );
      return;
    }

    // ✅ Save to Database
    await DatabaseHelper.instance.insertPesticide(
      farmerId: loggedInFarmerId!, // Use the logged-in farmer ID
      type: _pesticideTypeController.text,
      location: _locationController.text,
      sprayingArea: double.parse(_sprayingAreaController.text),
      description: _descriptionController.text,
      image: _selectedImage!.path,
      status: 'Worker Requested',
    );

    // ✅ Show Success Alert
    _showSuccessDialog();

    // ✅ Clear Fields
    _pesticideTypeController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _sprayingAreaController.clear();
    setState(() {
      _selectedImage = null;
      _imageStatus = "No Image Uploaded";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Pesticide Spraying Worker'), backgroundColor: Colors.green),
      body: Stack(
        children: [
          // ✅ Background Image
          Positioned.fill(
            child: Image.asset('assets/pesticide_bg.jpg', fit: BoxFit.cover),
          ),

          // ✅ Blurred Overlay for Readability
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                  boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 15, spreadRadius: 3)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ Image Upload
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.8)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _selectedImage != null
                              ? Image.file(_selectedImage!, fit: BoxFit.cover)
                              : const Icon(Icons.image, size: 50, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ✅ Image Upload Status
                    Text(
                      _imageStatus,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _selectedImage != null ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ✅ Input Fields
                    _buildTextField(_pesticideTypeController, 'Pesticide Type', Icons.bug_report),
                    _buildTextField(_locationController, 'Location', Icons.location_on),
                    _buildTextField(_sprayingAreaController, 'Spraying Area (in acres)', Icons.landscape, isNumeric: true),
                    _buildTextField(_descriptionController, 'Description', Icons.description),

                    const SizedBox(height: 15),

                    // ✅ Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Request Worker", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Reusable Text Field Widget with High Contrast
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white), // ✅ White placeholder text
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(icon, color: Colors.white),
          filled: true,
          fillColor: Colors.black.withOpacity(0.4),
        ),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
