import 'package:flutter/material.dart';

class RequestPage extends StatefulWidget {
  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  List<Map<String, dynamic>> requests = [];

  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void addRequest() {
    if (titleController.text.isNotEmpty &&
        locationController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty) {
      setState(() {
        requests.add({
          'title': titleController.text,
          'location': locationController.text,
          'description': descriptionController.text,
          'status': 'Pending',
          'image': 'https://via.placeholder.com/150', // Placeholder image
        });
      });
      titleController.clear();
      locationController.clear();
      descriptionController.clear();
      Navigator.pop(context);
    }
  }

  void editRequest(int index) {
    titleController.text = requests[index]['title'];
    locationController.text = requests[index]['location'];
    descriptionController.text = requests[index]['description'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
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
        return AlertDialog(
          title: Text('Add Farming Job Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: addRequest,
              child: Text('Add'),
            ),
          ],
        );
      },
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
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Image.network(
                requests[index]['image'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(requests[index]['title']),
              subtitle: Text(
                '${requests[index]['location']}\n'
                    '${requests[index]['description']}\n'
                    'Status: ${requests[index]['status']}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => editRequest(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteRequest(index),
                  ),
                  Switch(
                    value: requests[index]['status'] == 'Completed',
                    onChanged: (value) => toggleStatus(index),
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddRequestDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
