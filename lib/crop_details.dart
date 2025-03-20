import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart'; // ✅ Import SQLite Database Helper
import 'package:shared_preferences/shared_preferences.dart';

class CropDetailsPage extends StatefulWidget {
  @override
  _CropDetailsPageState createState() => _CropDetailsPageState();
}

class _CropDetailsPageState extends State<CropDetailsPage> {
  final TextEditingController _cropNameController = TextEditingController();
  final TextEditingController _ratePerKgController = TextEditingController();
  final TextEditingController _minKgController = TextEditingController();
  final TextEditingController _totalKgController = TextEditingController(); // ✅ Added Total KG Field
  final TextEditingController _descriptionController = TextEditingController(); // ✅ Add Crop Description Field

  File? _selectedImage;
  String _imageStatus = "No Image Uploaded"; // ✅ Track Image Upload Status

  // ✅ Pick Image from Gallery
  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _imageStatus = "Image Uploaded ✅"; // ✅ Show success message
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  // ✅ Show Success Alert Box
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Success ✅"),
          content: const Text("Crop added successfully!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // ✅ Get Farmer ID from Database
  Future<int?> _getFarmerId() async {
    // Retrieve the logged-in farmer's phone number from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String? farmerPhone = prefs.getString('loggedInFarmerPhone'); // Ensure this key is stored at login

    if (farmerPhone == null) return null; // Ensure the phone number is available

    final farmer = await DatabaseHelper.instance.getFarmerByPhone(farmerPhone);
    return farmer?['id'];
  }


  // ✅ Add Crop to Database
  void _addCrop() async {
    if (_cropNameController.text.isEmpty ||
        _ratePerKgController.text.isEmpty ||
        _minKgController.text.isEmpty ||
        _totalKgController.text.isEmpty || // ✅ Validate Total KG
        _descriptionController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all fields and select an image')),
      );
      return;
    }

    double ratePerKg, minKg, totalKg;
    try {
      ratePerKg = double.parse(_ratePerKgController.text);
      minKg = double.parse(_minKgController.text);
      totalKg = double.parse(_totalKgController.text); // ✅ Parse Total KG
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numeric values for rate, min kg, and total kg')),
      );
      return;
    }

    // ✅ Get farmerId dynamically
    int? farmerId = await _getFarmerId();
    if (farmerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farmer not found! Please log in again.')),
      );
      return;
    }

    // ✅ Save Crop Data to SQLite Database
    await DatabaseHelper.instance.insertProduct(
      farmerId: farmerId, // ✅ Pass farmerId
      name: _cropNameController.text,
      category: 'Crop',
      price: ratePerKg,
      minKg: minKg,
      totalKg: totalKg, // ✅ Pass totalKg
      description: _descriptionController.text,
      status: 'Available',
      image: _selectedImage?.path ?? '', // ✅ Ensure image is handled properly
    );

    // ✅ Show Success Alert Box
    _showSuccessDialog();

    // ✅ Clear Fields After Adding
    _cropNameController.clear();
    _ratePerKgController.clear();
    _minKgController.clear();
    _totalKgController.clear(); // ✅ Clear Total KG
    _descriptionController.clear();
    setState(() {
      _selectedImage = null;
      _imageStatus = "No Image Uploaded";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Crop Details'), backgroundColor: Colors.green),
      body: Stack(
        children: [
          // ✅ Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/farm_bg.jpg', // 🔹 Make sure this image exists in your assets folder
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Darkened Overlay for Readability
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9, // ✅ Adjusted for better centering
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ Image Upload Section
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

                        // ✅ Image Upload Status Message
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
                        _buildTextField(_cropNameController, 'Crop Name', Icons.eco),
                        _buildTextField(_ratePerKgController, 'Rate per Kg', Icons.attach_money, isNumeric: true),
                        _buildTextField(_minKgController, 'Min Kg Purchase', Icons.scale, isNumeric: true),
                        _buildTextField(_totalKgController, 'Total Kg Available', Icons.shopping_cart, isNumeric: true),
                        _buildTextField(_descriptionController, 'Crop Description', Icons.description),

                        const SizedBox(height: 15),

                        // ✅ Create Crop Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addCrop,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Create Crop", style: TextStyle(fontSize: 18, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white), // ✅ Text color set to white
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white), // ✅ Placeholder color set to white
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white), // ✅ Border color set to white
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white), // ✅ Keeps border white even when not focused
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white), // ✅ Keeps border white when focused
          ),
          prefixIcon: Icon(icon, color: Colors.white), // ✅ Icon color set to white
        ),
      ),
    );
  }
}
