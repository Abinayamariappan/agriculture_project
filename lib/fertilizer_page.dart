import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'farmer_sales_page.dart';

class FertilizerPage extends StatefulWidget {
  @override
  _FertilizerPageState createState() => _FertilizerPageState();
}

class _FertilizerPageState extends State<FertilizerPage> {
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
          content: const Text("Fertilizer added successfully!"),
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
  Future<void> _loadFarmerId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _farmerId = prefs.getInt('farmerId');
    });
  }

  Future<int?> getLoggedInFarmerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('farmerId');
  }

  void _submitFertilizer() async {
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
      final price = double.tryParse(_priceController.text);
      final minOrder = double.tryParse(_minOrderController.text);
      final availableQty = double.tryParse(_availableQtyController.text);

      // Check if the values are valid numbers
      if (price == null || minOrder == null || availableQty == null) {
        throw Exception('Please enter valid numeric values for price, minKg, and totalKg.');
      }

      if (minOrder > availableQty) {
        throw Exception('Minimum KG cannot be greater than Total KG');
      }

      // Convert image to Uint8List (BLOB)
      final fertilizerImage = await _image!.readAsBytes();

      // Get the farmer's ID
      final farmerId = await getLoggedInFarmerId();

      if (farmerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Farmer not logged in')),
        );
        return;
      }

      // Insert the fertilizer details into the database
      await DatabaseHelper.instance.insertFertilizer(
        name: _nameController.text.trim(),
        price: price,
        minKg: minOrder,
        totalKg: availableQty,
        description: _descriptionController.text.trim(),
        image: fertilizerImage,
        status: 'Available',  // You can change this dynamically if needed
        farmerId: farmerId,  // Use the fetched farmer ID
      );

      // Show success dialog and clear the fields
      _showSuccessDialog();
      _clearFields();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid input: $e')),
      );
    }
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
                    _buildTextField(_nameController, 'Fertilizer Name', Icons.eco),
                    _buildTextField(_priceController, 'Rate per Kg', Icons.attach_money, isNumeric: true),
                    _buildTextField(_minOrderController, 'Min Kg Purchase', Icons.scale, isNumeric: true),
                    _buildTextField(_availableQtyController, 'Total Kg Available', Icons.shopping_cart, isNumeric: true),
                    _buildTextField(_descriptionController, 'Fertilizer Description', Icons.description),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _submitFertilizer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.all(15),
                      ),
                      child: const Text("Submit Fertilizer", style: TextStyle(fontSize: 18, color: Colors.white)),

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
