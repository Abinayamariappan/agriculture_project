import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import 'database_helper.dart';

class SeedsPage extends StatefulWidget {
  @override
  _SeedsPageState createState() => _SeedsPageState();
}

class _SeedsPageState extends State<SeedsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _minOrderController = TextEditingController();
  final TextEditingController _availableQtyController = TextEditingController();
  final TextEditingController _farmerIdController = TextEditingController();
  File? _image;
  String _imageStatus = "No Image Uploaded";

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageStatus = "Image Uploaded ✅";
      });
    }
  }

  void _addSeed() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _minOrderController.text.isEmpty ||
        _availableQtyController.text.isEmpty ||
        _farmerIdController.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and upload an image')),
      );
      return;
    }

    try {
      int farmerId = int.parse(_farmerIdController.text);
      double price = double.parse(_priceController.text);
      double minOrder = double.parse(_minOrderController.text);
      double availableQty = double.parse(_availableQtyController.text);

      await DatabaseHelper.instance.insertProduct(
        farmerId: farmerId,
        name: _nameController.text,
        category: 'Seeds',
        price: price,
        minKg: minOrder,
        totalKg: availableQty,
        status: 'Available',
        image: _image?.path ?? '',
      );

      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numeric values')),
      );
    }
  }

  void _clearFields() {
    _nameController.clear();
    _priceController.clear();
    _minOrderController.clear();
    _availableQtyController.clear();
    _farmerIdController.clear();
    setState(() {
      _image = null;
      _imageStatus = "No Image Uploaded";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Seed Details'), backgroundColor: Colors.green),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/seeds_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
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
                              border: Border.all(color: Colors.grey),
                            ),
                            child: _image != null
                                ? Image.file(_image!, fit: BoxFit.cover)
                                : const Icon(Icons.image, size: 50, color: Colors.grey),
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
                        _buildTextField(_nameController, 'Seed Name', Icons.eco),
                        _buildTextField(_priceController, 'Price per Kg', Icons.attach_money, isNumeric: true),
                        _buildTextField(_minOrderController, 'Min Kg Purchase', Icons.scale, isNumeric: true),
                        _buildTextField(_availableQtyController, 'Total Kg Available', Icons.shopping_cart, isNumeric: true),
                        _buildTextField(_farmerIdController, 'Farmer ID', Icons.person, isNumeric: true),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: _addSeed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.all(15),
                          ),
                          child: const Text("Create Seed", style: TextStyle(fontSize: 18, color: Colors.white)),
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
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}
