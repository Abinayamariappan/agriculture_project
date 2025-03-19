import 'package:flutter/material.dart';

class GovtSchemesAdminPage extends StatefulWidget {
  const GovtSchemesAdminPage({super.key});

  @override
  _GovtSchemesAdminPageState createState() => _GovtSchemesAdminPageState();
}

class _GovtSchemesAdminPageState extends State<GovtSchemesAdminPage> {
  final List<Map<String, String>> _schemes = [
    {"title": "PM-KISAN", "description": "Direct income support to farmers"},
    {"title": "Soil Health Card", "description": "Testing soil quality for better productivity"},
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int? _editingIndex;

  // ✅ Open Dialog for Adding or Editing
  void _showSchemeDialog({String? title, String? description, int? index}) {
    _titleController.text = title ?? "";
    _descriptionController.text = description ?? "";
    _editingIndex = index;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? "Add Scheme" : "Edit Scheme"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Scheme Name')),
              TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                _saveScheme();
                Navigator.pop(context);
              },
              child: Text(index == null ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }

  // ✅ Save or Update Scheme
  void _saveScheme() {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) return;

    setState(() {
      if (_editingIndex == null) {
        _schemes.add({"title": _titleController.text, "description": _descriptionController.text});
      } else {
        _schemes[_editingIndex!] = {"title": _titleController.text, "description": _descriptionController.text};
      }
    });
  }

  // ✅ Delete Scheme
  void _deleteScheme(int index) {
    setState(() {
      _schemes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Govt Schemes'), backgroundColor: Colors.purple),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _schemes.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(_schemes[index]["title"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(_schemes[index]["description"]!),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showSchemeDialog(title: _schemes[index]["title"], description: _schemes[index]["description"], index: index)),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteScheme(index)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () => _showSchemeDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
