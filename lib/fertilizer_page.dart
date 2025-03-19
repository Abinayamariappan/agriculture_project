import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart';

class FertilizerPage extends StatefulWidget {
  @override
  _FertilizerPageState createState() => _FertilizerPageState();
}

class _FertilizerPageState extends State<FertilizerPage> {
  final TextEditingController _fertilizerNameController = TextEditingController();
  final TextEditingController _ratePerKgController = TextEditingController();
  final TextEditingController _minKgController = TextEditingController();
  final TextEditingController _totalKgController = TextEditingController();
  final TextEditingController _farmerIdController = TextEditingController();
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
        _farmerIdController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all fields and select an image')),
      );
      return;
    }

    int farmerId;
    double ratePerKg, minKg, totalKg;

    try {
      farmerId = int.parse(_farmerIdController.text);
      ratePerKg = double.parse(_ratePerKgController.text);
      minKg = double.parse(_minKgController.text);
      totalKg = double.parse(_totalKgController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numeric values')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseHelper.instance.insertProduct(
        farmerId: farmerId,
        name: _fertilizerNameController.text,
        category: 'Fertilizer',
        price: ratePerKg,
        minKg: minKg,
        totalKg: totalKg,
        status: 'Available',
        image: _selectedImage?.path ?? '',
      );

      _showSuccessDialog();

      _fertilizerNameController.clear();
      _ratePerKgController.clear();
      _minKgController.clear();
      _totalKgController.clear();
      _farmerIdController.clear();
      setState(() {
        _selectedImage = null;
        _imageStatus = "No Image Uploaded";
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database error: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Fertilizer added successfully!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
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
          // Background Image with Blur Effect
          Positioned.fill(
            child: Image.asset(
              'assets/fertilizer_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          // Centered Card for Form
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
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
                            border: Border.all(color: Colors.white.withOpacity(0.8)),
                          ),
                          child: _selectedImage != null
                              ? Image.file(_selectedImage!, fit: BoxFit.cover)
                              : const Icon(Icons.image, size: 50, color: Colors.white),
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
                      _buildTextField(_farmerIdController, 'Farmer ID', Icons.person, isNumeric: true),
                      const SizedBox(height: 15),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addFertilizer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: const EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Create Fertilizer", style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
