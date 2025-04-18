import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'farming_jobs_page.dart';

class PesticidePage extends StatefulWidget {
  @override
  _PesticidePageState createState() => _PesticidePageState();
}

class _PesticidePageState extends State<PesticidePage> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sprayingAreaController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _wagesController = TextEditingController();

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
          content: const Text(" Pesticide Spraying request added successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
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


  Future<int?> getLoggedInFarmerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('farmerId');
  }


  void _submitRequest() async {
    if (_farmerId == null ||
        _typeController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _sprayingAreaController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _wagesController.text.trim().isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and upload an image')),
      );
      return;
    }

    try {
      double? sprayingArea = double.tryParse(_sprayingAreaController.text.trim());
      double? wages = double.tryParse(_wagesController.text.trim());

      if (sprayingArea == null || wages == null) {
        throw FormatException("Invalid number format");
      }

      if (sprayingArea <= 0 || wages <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Spraying area and wages must be positive numbers')),
        );
        return;
      }

      // Convert image to bytes for BLOB storage
      final imageBytes = await _image!.readAsBytes();

      await DatabaseHelper.instance.insertPesticide(
        farmerId: _farmerId!,
        type: _typeController.text.trim(),
        location: _locationController.text.trim(),
        sprayingArea: sprayingArea,
        description: _descriptionController.text.trim(),
        image: imageBytes, // Store as BLOB
        wages: wages,
        status: 'pending',
      );

      _showSuccessDialog();

      _typeController.clear();
      _locationController.clear();
      _sprayingAreaController.clear();
      _descriptionController.clear();
      _wagesController.clear();
      setState(() {
        _image = null;
        _imageStatus = "No Image Uploaded";
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Pesticide Spraying Worker'), backgroundColor: Colors.green),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/pesticide_bg.jpg', fit: BoxFit.cover),
          ),
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
                    _buildTextField(_typeController, 'Pesticide Type', Icons.bug_report),
                    _buildTextField(_locationController, 'Location', Icons.location_on),
                    _buildTextField(_sprayingAreaController, 'Spraying Area (in acres)', Icons.landscape, isNumeric: true),
                    _buildTextField(_descriptionController, 'Description', Icons.description),
                     _buildTextField(_wagesController, 'Wages (in INR)', Icons.money, isNumeric: true),

                    const SizedBox(height: 15),
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
