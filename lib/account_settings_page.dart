import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AccountSettingsPage extends StatefulWidget {
  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Static user data
  String name = "Abinaya"; // Static name
  String phone = "8838778182"; // Static phone number
  String address = "               "; // Initially empty address
  TextEditingController addressController = TextEditingController();

  // Function to pick an image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take a Photo'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Choose from Gallery'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _editAddress() {
    setState(() {
      address = addressController.text; // Save the entered address
    });
    Navigator.pop(context); // Close the bottom sheet or dialog
  }

  void _showEditAddressDialog() {
    addressController.text = address; // Prefill existing address
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Address'),
          content: TextField(
            controller: addressController,
            decoration: InputDecoration(labelText: 'Enter new address'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _editAddress,
              child: Text('Save Address'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Settings'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _showEditAddressDialog, // Open the dialog to enter address
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85, // Set card width
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Prevent extra space
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                      child: _imageFile == null
                          ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(phone, style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                  SizedBox(height: 16),
                  Text(
                    'Address: $address',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _showEditAddressDialog,
                    icon: Icon(Icons.edit),
                    label: Text('Edit Address'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
