import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'farmer_sales_page.dart';
import 'database_helper.dart';

class CropDetailsPage extends StatefulWidget {
  @override
  _CropDetailsPageState createState() => _CropDetailsPageState();
}

class _CropDetailsPageState extends State<CropDetailsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _minOrderController = TextEditingController();
  final TextEditingController _availableQtyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _image;
  String _imageStatus = "No Image Uploaded";
  int? _farmerId;

  @override
  void initState() {
    super.initState();
    _loadFarmerId();
  }

  Future<void> _loadFarmerId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _farmerId = prefs.getInt('farmerId');
    });
  }

  Future<File?> _compressImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final img.Image? image = img.decodeImage(bytes);
    if (image == null) return null;

    final compressedImage = img.encodeJpg(image, quality: 70);
    final newFile = File(imageFile.path)..writeAsBytesSync(compressedImage);
    return newFile;
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        File? compressedImage = await _compressImage(File(pickedFile.path));
        setState(() {
          _image = compressedImage;
          _imageStatus = "Image Uploaded ✅";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

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
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FarmerSalesPage(farmerId: _farmerId)),
                );
              },
              child: const Text("Go to Sales"),
            ),
          ],
        );
      },
    );
  }

  void _clearFields() {
    _nameController.clear();
    _priceController.clear();
    _minOrderController.clear();
    _availableQtyController.clear();
    _descriptionController.clear();
    setState(() {
      _image = null;
      _imageStatus = "No Image Uploaded";
    });
  }

  Future<int?> getLoggedInFarmerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('farmerId');
  }

  void _addCrop() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _minOrderController.text.isEmpty ||
        _availableQtyController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all fields and select an image')),
      );
      return;
    }

    try {
      final bytes = await _image!.readAsBytes();
      final double price = double.parse(_priceController.text);
      final double minKg = double.parse(_minOrderController.text);
      final double totalKg = double.parse(_availableQtyController.text);

      final farmerId = await getLoggedInFarmerId();
      if (farmerId == null) {
        throw Exception("Farmer ID not found");
      }

      await DatabaseHelper().insertCrop(
        name: _nameController.text,
        price: price,
        minKg: minKg,
        totalKg: totalKg,
        description: _descriptionController.text,
        image: bytes,
        status: "Available",
        farmerId: farmerId,
      );

      _clearFields();
      _showSuccessDialog(); // 👉 This will show dialog and navigate to FarmerSalesPage

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to insert crop: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Crop Details'), backgroundColor: Colors.green),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/farm_bg.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
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
                              child: _image != null
                                  ? Image.file(_image!, fit: BoxFit.cover)
                                  : const Icon(Icons.image, size: 50, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _imageStatus,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _image != null ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildTextField(_nameController, 'Crop Name', Icons.eco),
                        _buildTextField(_priceController, 'Rate per Kg', Icons.attach_money, isNumeric: true),
                        _buildTextField(_minOrderController, 'Min Kg Purchase', Icons.scale, isNumeric: true),
                        _buildTextField(_availableQtyController, 'Total Kg Available', Icons.shopping_cart, isNumeric: true),
                        _buildTextField(_descriptionController, 'Crop Description', Icons.description),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addCrop,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Submit Crop", style: TextStyle(fontSize: 18, color: Colors.white)),
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
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
          prefixIcon: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
