import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'database_helper.dart';
import 'farming_jobs_page.dart';

class ManageFarmlandPage extends StatefulWidget {
  @override
  _ManageFarmlandPageState createState() => _ManageFarmlandPageState();
}

class _ManageFarmlandPageState extends State<ManageFarmlandPage> {
  final TextEditingController _farmNameController = TextEditingController();
  final TextEditingController _farmSizeController = TextEditingController();
  final TextEditingController _farmLocationController = TextEditingController();
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
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

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Success ✅"),
        content: Text("Farmland request added successfully!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FarmingJobsPage(farmerId: _farmerId)),
              );
            },
            child: Text("Go to Jobs"),
          ),
        ],
      ),
    );
  }

  void _submitRequest() async {
    if (_farmNameController.text.trim().isEmpty ||
        _farmSizeController.text.trim().isEmpty ||
        _farmLocationController.text.trim().isEmpty ||
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
      double? farmSize = double.tryParse(_farmSizeController.text.trim());
      double? wages = double.tryParse(_wagesController.text.trim());

      if (farmSize == null || wages == null || farmSize <= 0 || wages <= 0) {
        throw FormatException("Invalid number format");
      }

      final imageBytes = await _image!.readAsBytes();

      await DatabaseHelper.instance.insertFarmland(
        farmerId: _farmerId!,
        name: _farmNameController.text.trim(),
        size: farmSize,
        location: _farmLocationController.text.trim(),
        description: _descriptionController.text.trim(),
        wages: wages,
        image: imageBytes,
        status: 'Worker Requested',
      );

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with blur
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/farm_bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4), // More transparent
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      const Text(
                        "Request Farmland Workers",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _showImagePickerModal,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: _image != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          )
                              : Icon(Icons.add_a_photo, size: 50),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _imageStatus,
                        style: TextStyle(
                          color: _image != null ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(_farmNameController, 'Farmland Name'),
                      _buildTextField(_farmSizeController, 'Size (acres)', isNumeric: true),
                      _buildTextField(_farmLocationController, 'Location'),
                      _buildTextField(_wagesController, 'Wages (per day)', isNumeric: true),
                      _buildTextField(_descriptionController, 'Description'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Submit Request"),
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

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.6), // Slightly transparent fill
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
