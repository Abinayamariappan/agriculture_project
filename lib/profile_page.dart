import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final String farmerId;
  final String name;
  final String phone;

  const ProfilePage({super.key, required this.farmerId, required this.name, required this.phone});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;
  String _address = "";
  final TextEditingController _addressController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  /// Load Address and Profile Image from SharedPreferences
  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _address = prefs.getString('address_${widget.farmerId}') ?? "";
      _addressController.text = _address; // Load into the controller
      String? imagePath = prefs.getString('profileImage_${widget.farmerId}');
      if (imagePath != null && File(imagePath).existsSync()) {
        _profileImage = File(imagePath);
      }
    });
  }

  /// Save Address in SharedPreferences
  Future<void> _saveAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('address_${widget.farmerId}', _addressController.text);
  }

  /// Pick an Image from Gallery & Save Path
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage_${widget.farmerId}', pickedFile.path);
    }
  }

  /// Build Profile Picture (From File or Default Avatar)
  Widget _buildProfilePicture() {
    if (_profileImage != null) {
      return ClipOval(
        child: Image.file(_profileImage!, width: 100, height: 100, fit: BoxFit.cover),
      );
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.green[700],
        child: Text(
          widget.name.isNotEmpty ? widget.name[0].toUpperCase() : "?",
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }
  }

  /// Build Address Section
  Widget _buildAddressSection() {
    if (_isEditing) {
      return TextField(
        controller: _addressController,
        decoration: const InputDecoration(labelText: "Address"),
        onChanged: (value) => _address = value, // Update address in real-time
        onSubmitted: (value) => _saveAddress(), // Save when done typing
      );
    } else {
      return _buildProfileDetail("Address", _address.isNotEmpty ? _address : "No address provided", Icons.location_on);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farmer Profile"),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  _saveAddress();
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture
            GestureDetector(
              onTap: _pickImage,
              child: _buildProfilePicture(),
            ),
            const SizedBox(height: 10),
            const Text("Tap to change profile picture", style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 20),

            // Farmer ID
            _buildProfileDetail("Farmer ID", widget.farmerId, Icons.badge),

            // Name
            _buildProfileDetail("Name", widget.name, Icons.person),

            // Phone
            _buildProfileDetail("Phone", widget.phone, Icons.phone),

            // Address Section
            _buildAddressSection(),
          ],
        ),
      ),
    );
  }

  /// Helper Widget to Display Profile Details
  Widget _buildProfileDetail(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 10),
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
