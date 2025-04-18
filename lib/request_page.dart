import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RequestPage extends StatefulWidget {
  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  List<Map<String, dynamic>> requests = [];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? _selectedImage;
  String imageUploadStatus = "No image selected";

  final ImagePicker _picker = ImagePicker(); // Ensure this is initialized


  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      print("Image picked: ${pickedFile.path}");

      setState(() {
        _selectedImage = File(pickedFile.path);
        imageUploadStatus = "Uploaded";
      });

      print("Image updated in UI");
    } else {
      print("No image selected");
    }
  }

  void addRequest() {
    if (titleController.text.isNotEmpty &&
        locationController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        _selectedImage != null) {
      setState(() {
        requests.add({
          'title': titleController.text,
          'location': locationController.text,
          'description': descriptionController.text,
          'status': 'Pending',
          'image': _selectedImage,
        });
      });

      titleController.clear();
      locationController.clear();
      descriptionController.clear();
      _selectedImage = null;
      imageUploadStatus = "Upload Image";
      Navigator.pop(context);
    }
  }

  void editRequest(int index) {
    titleController.text = requests[index]['title'];
    locationController.text = requests[index]['location'];
    descriptionController.text = requests[index]['description'];
    _selectedImage = requests[index]['image'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Request'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(titleController, 'Title', Icons.title),
                _buildTextField(locationController, 'Location', Icons.location_on),
                _buildTextField(descriptionController, 'Description', Icons.description),
                SizedBox(height: 10),
                _selectedImage != null
                    ? Image.file(_selectedImage!, height: 100, width: 100, fit: BoxFit.cover)
                    : SizedBox(),
                TextButton(
                  onPressed: pickImage,
                  child: Text("Change Image"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  requests[index]['title'] = titleController.text;
                  requests[index]['location'] = locationController.text;
                  requests[index]['description'] = descriptionController.text;
                  requests[index]['image'] = _selectedImage;
                });
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void toggleStatus(int index) {
    setState(() {
      requests[index]['status'] =
      requests[index]['status'] == 'Pending' ? 'Completed' : 'Pending';
    });
  }

  void deleteRequest(int index) {
    setState(() {
      requests.removeAt(index);
    });
  }

  void showAddRequestDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black26),
                          ),
                          child: _selectedImage != null
                              ? Image.file(_selectedImage!, fit: BoxFit.cover)
                              : Icon(Icons.image, size: 50, color: Colors.black54),
                        ),
                        SizedBox(height: 5),
                        Text(imageUploadStatus, style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildTextField(titleController, 'Title', Icons.title),
                  _buildTextField(locationController, 'Location', Icons.location_on),
                  _buildTextField(descriptionController, 'Description', Icons.description),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: addRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.all(15),
                    ),
                    child: const Text("Create Request", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Request Farming Jobs')),
      body: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: Colors.white, // **Removed gradient, now simple white**
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: requests[index]['image'] != null
                            ? Image.file(
                          requests[index]['image'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        )
                            : Icon(Icons.image, size: 70, color: Colors.grey),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(requests[index]['title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.green),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    requests[index]['location'],
                                    style: TextStyle(fontSize: 14, color: Colors.black54),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(requests[index]['description'], style: TextStyle(fontSize: 14, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(requests[index]['status'], style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orange)),
                      Row(
                        children: [
                          IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => editRequest(index)),
                          IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => deleteRequest(index)),
                          Switch(value: requests[index]['status'] == 'Completed', onChanged: (value) => toggleStatus(index), activeColor: Colors.green),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: showAddRequestDialog, child: Icon(Icons.add)),
    );
  }
}
