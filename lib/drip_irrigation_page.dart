import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'farming_jobs_page.dart';

class DripIrrigationPage extends StatefulWidget {
  @override
  _DripIrrigationPageState createState() => _DripIrrigationPageState();
}

class _DripIrrigationPageState extends State<DripIrrigationPage> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _waterSourceController = TextEditingController();
  final TextEditingController _landAreaController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _wagesController = TextEditingController();
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FarmingJobsPage(farmerId: _farmerId)),
                );
              },
              child: const Text("Go to Jobs"),
            ),
          ],
        );
      },
    );
  }

  void _submitRequest() async {
    // Validate all required fields and ensure the image is selected
    if (_typeController.text.trim().isEmpty ||
        _waterSourceController.text.trim().isEmpty ||
        _landAreaController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _wagesController.text.trim().isEmpty ||
        _image == null ||
        _farmerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and upload an image')),
      );
      return;
    }

    try {
      // Convert land area and wages to numbers
      double? landArea = double.tryParse(_landAreaController.text.trim());
      double? wages = double.tryParse(_wagesController.text.trim());

      // Check if land area and wages are valid numbers
      if (landArea == null || wages == null) {
        throw FormatException("Invalid number format");
      }

      // Validate that land area and wages are positive numbers
      if (landArea <= 0 || wages <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Land area and wages must be positive numbers')),
        );
        return;
      }

      // Convert the selected image to bytes
      final imageBytes = await _image!.readAsBytes();

      // Save the data to the database
      await DatabaseHelper.instance.insertDripIrrigation(
        farmerId: _farmerId!,
        type: _typeController.text.trim(),
        waterSource: _waterSourceController.text.trim(),
        landArea: landArea,
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        image: imageBytes, // Store the image as bytes
        wages: wages,
        status: 'Worker Requested',
      );

      // Show success dialog after submission
      _showSuccessDialog();

      // Clear all fields and reset the image status
      _typeController.clear();
      _waterSourceController.clear();
      _landAreaController.clear();
      _locationController.clear();
      _descriptionController.clear();
      _wagesController.clear();
      setState(() {
        _image = null;
        _imageStatus = "No Image Uploaded";
      });
    } catch (e) {
      // Handle any errors that may occur during the submission process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
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
                          child: _image != null
                              ? Image.file(_image!, fit: BoxFit.cover)
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
                        color: _image != null ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ✅ Input Fields
                    _buildTextField(_typeController, 'Irrigation Type', Icons.water),
                    _buildTextField(_waterSourceController, 'Water Source', Icons.waves),
                    _buildTextField(_landAreaController, 'Land Area (in acres)', Icons.landscape, isNumeric: true),
                    _buildTextField(_locationController, 'Location', Icons.location_on),
                    _buildTextField(_wagesController, 'Wages (per day)', Icons.money, isNumeric: true),
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
