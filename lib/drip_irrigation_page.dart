import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class DripIrrigationPage extends StatefulWidget {
  @override
  _DripIrrigationPageState createState() => _DripIrrigationPageState();
}

class _DripIrrigationPageState extends State<DripIrrigationPage> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _waterSourceController = TextEditingController();
  final TextEditingController _landAreaController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _selectedImage;
  String _imageStatus = "No Image Uploaded";
  int? _loggedInFarmerId;

  @override
  void initState() {
    super.initState();
    _getFarmerId();
  }

  // ✅ Get Farmer ID from SharedPreferences
  Future<void> _getFarmerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedInFarmerId = prefs.getInt('farmerId');
    });
  }

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
          content: const Text("Irrigation request added successfully!"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
          ],
        );
      },
    );
  }

  // ✅ Submit Irrigation Request
  void _submitRequest() async {
    if (_loggedInFarmerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Farmer ID not found!')),
      );
      return;
    }

    if (_typeController.text.isEmpty ||
        _waterSourceController.text.isEmpty ||
        _landAreaController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all fields and select an image')),
      );
      return;
    }

    // ✅ Save to Database
    await DatabaseHelper.instance.insertDripIrrigation(
      farmerId: _loggedInFarmerId!,
      type: _typeController.text,
      waterSource: _waterSourceController.text,
      landArea: double.parse(_landAreaController.text),
      location: _locationController.text,
      description: _descriptionController.text,
      image: _selectedImage!.path,
      status: 'Worker Requested',
    );

    // ✅ Show Success Alert
    _showSuccessDialog();

    // ✅ Clear Fields
    _typeController.clear();
    _waterSourceController.clear();
    _landAreaController.clear();
    _locationController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedImage = null;
      _imageStatus = "No Image Uploaded";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Irrigation Worker'), backgroundColor: Colors.teal),
      body: Stack(
        children: [
          // ✅ Background Image
          Positioned.fill(
            child: Image.asset('assets/drip_irrigation_bg.jpg', fit: BoxFit.cover),
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
                    _buildTextField(_typeController, 'Irrigation Type', Icons.water),
                    _buildTextField(_waterSourceController, 'Water Source', Icons.waves),
                    _buildTextField(_landAreaController, 'Land Area (in acres)', Icons.landscape, isNumeric: true),
                    _buildTextField(_locationController, 'Location', Icons.location_on),
                    _buildTextField(_descriptionController, 'Description', Icons.description),

                    const SizedBox(height: 15),

                    // ✅ Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
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
          labelStyle: const TextStyle(color: Colors.white),
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
