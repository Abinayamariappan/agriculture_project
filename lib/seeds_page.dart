import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
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
  final TextEditingController _descriptionController = TextEditingController();

  File? _image;
  String _imageStatus = "No Image Uploaded";
  int? _farmerId; // To store fetched farmer ID

  @override
  void initState() {
    super.initState();
    _fetchFarmerId(); // Fetch farmer ID when page loads
  }

  Future<void> _fetchFarmerId() async {
    String? phoneNumber = await DatabaseHelper.instance.getLoggedInUserPhone();
    if (phoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No logged-in user found!')),
      );
      return;
    }

    Map<String, dynamic>? farmerData = await DatabaseHelper.instance.getFarmerByPhone(phoneNumber);
    if (farmerData != null && farmerData.containsKey('id')) {
      setState(() {
        _farmerId = farmerData['id'] as int;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farmer ID not found!')),
      );
    }
  }

  void _addSeed() async {
    if (_farmerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farmer ID not available!')),
      );
      return;
    }

    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _minOrderController.text.isEmpty ||
        _availableQtyController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and upload an image')),
      );
      return;
    }

    try {
      double price = double.parse(_priceController.text);
      double minOrder = double.parse(_minOrderController.text);
      double availableQty = double.parse(_availableQtyController.text);

      await DatabaseHelper.instance.insertProduct(
        farmerId: _farmerId!,
        name: _nameController.text,
        category: 'Seeds',
        price: price,
        minKg: minOrder,
        totalKg: availableQty,
        status: 'Available',
        image: _image?.path ?? '',
        description: _descriptionController.text,
      );

      _clearFields();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Seed added successfully!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid numeric values')),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _imageStatus = "Image Uploaded";
      });
    } else {
      setState(() {
        _imageStatus = "No Image Selected";
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Seed Details'), backgroundColor: Colors.green),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/seeds_bg.jpg'),
                fit: BoxFit.cover,
              ),
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
                        child: _image != null
                            ? Image.file(_image!, fit: BoxFit.cover)
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
                        color: _image != null ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(_nameController, 'Seed Name', Icons.eco),
                    _buildTextField(_priceController, 'Price per Kg', Icons.attach_money, isNumeric: true),
                    _buildTextField(_minOrderController, 'Min Kg Purchase', Icons.scale, isNumeric: true),
                    _buildTextField(_availableQtyController, 'Total Kg Available', Icons.shopping_cart, isNumeric: true),
                    _buildTextField(_descriptionController, 'Seed Description', Icons.description),
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
          prefixIcon: Icon(icon, color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
        ),
      ),
    );
  }
}
