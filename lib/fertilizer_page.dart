import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class FertilizerPage extends StatefulWidget {
  @override
  _FertilizerPageState createState() => _FertilizerPageState();
}

class _FertilizerPageState extends State<FertilizerPage> {
  final TextEditingController _fertilizerNameController = TextEditingController();
  final TextEditingController _ratePerKgController = TextEditingController();
  final TextEditingController _minKgController = TextEditingController();
  final TextEditingController _totalKgController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _selectedImage;
  String _imageStatus = "No Image Uploaded";
  bool _isLoading = false;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _imageStatus = "Image Uploaded ✅";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  Future<void> _addFertilizer() async {
    if (_fertilizerNameController.text.isEmpty ||
        _ratePerKgController.text.isEmpty ||
        _minKgController.text.isEmpty ||
        _totalKgController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Display success message without saving to SQLite
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fertilizer details saved successfully (not stored in DB)')),
    );

    // Clear the form after submission
    _fertilizerNameController.clear();
    _ratePerKgController.clear();
    _minKgController.clear();
    _totalKgController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedImage = null;
      _imageStatus = "No Image Uploaded";
      _isLoading = false;
    });
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          prefixIcon: Icon(icon, color: Colors.white),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Fertilizer Details'), backgroundColor: Colors.green[700]),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/fertilizer_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white),
                        ),
                        child: _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.cover)
                            : Container(
                          color: Colors.transparent,
                          child: const Icon(Icons.image, size: 50, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _imageStatus,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _selectedImage != null ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(_fertilizerNameController, 'Fertilizer Name', Icons.eco),
                    _buildTextField(_ratePerKgController, 'Rate per Kg', Icons.attach_money, isNumeric: true),
                    _buildTextField(_minKgController, 'Min Kg Purchase', Icons.scale, isNumeric: true),
                    _buildTextField(_totalKgController, 'Total Kg Available', Icons.shopping_cart, isNumeric: true),
                    _buildTextField(_descriptionController, 'Fertilizer Description', Icons.description),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _addFertilizer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Text("Create Fertilizer", style: TextStyle(fontSize: 18, color: Colors.white)),
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
}
