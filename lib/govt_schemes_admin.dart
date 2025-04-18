import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class GovtSchemesAdminPage extends StatefulWidget {
  const GovtSchemesAdminPage({super.key});

  @override
  _GovtSchemesAdminPageState createState() => _GovtSchemesAdminPageState();
}

class _GovtSchemesAdminPageState extends State<GovtSchemesAdminPage> {
  late Database _database;
  List<Map<String, dynamic>> _schemes = [];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _applyLinkController = TextEditingController();
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'schemes.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE schemes(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, apply TEXT)",
        );
      },
    );
    await _insertInitialSchemes(); // 🔥 Insert only if empty
    await _loadSchemes();
  }

  Future<void> _insertInitialSchemes() async {
    final existing = await _database.query('schemes');
    if (existing.isEmpty) {
      final initialSchemes = [
        {
          "title": "PM-KISAN",
          "description": "Income support of ₹6,000 per year to farmers.",
          "apply": "https://pmkisan.gov.in/"
        },
        {
          "title": "PMFBY",
          "description": "Crop insurance for farmers against natural calamities.",
          "apply": "https://pmfby.gov.in/"
        },
        {
          "title": "Kisan Credit Card (KCC)",
          "description": "Provides short-term credit to farmers for crops and allied activities.",
          "apply": "https://www.pmkisan.gov.in/KisanCreditCard.aspx"
        },
        {
          "title": "e-NAM",
          "description": "Online trading platform for agricultural commodities.",
          "apply": "https://enam.gov.in/"
        },
        {
          "title": "Soil Health Card Scheme",
          "description": "Provides soil health reports to farmers for better crop decisions.",
          "apply": "https://soilhealth.dac.gov.in/"
        },
        {
          "title": "Pradhan Mantri Krishi Sinchai Yojana",
          "description": "Promotes irrigation and water use efficiency.",
          "apply": "https://pmksy.gov.in/"
        },
        {
          "title": "National Agriculture Market (NAM)",
          "description": "A pan-India trading portal for farmers to get better prices.",
          "apply": "https://enam.gov.in/"
        },
        {
          "title": "Rashtriya Krishi Vikas Yojana (RKVY)",
          "description": "Supports development in agriculture and allied sectors.",
          "apply": "https://rkvy.nic.in/"
        },
        {
          "title": "Agri Infrastructure Fund",
          "description": "Provides financing for post-harvest management infrastructure.",
          "apply": "https://agriinfra.dac.gov.in/"
        },
        {
          "title": "Sub-Mission on Agriculture Mechanization (SMAM)",
          "description": "Helps farmers buy machinery at subsidized rates.",
          "apply": "https://agrimachinery.nic.in/"
        },
        {
          "title": "National Horticulture Mission",
          "description": "Supports development of horticulture crops.",
          "apply": "https://nhm.gov.in/"
        },
        {
          "title": "National Mission on Sustainable Agriculture (NMSA)",
          "description": "Promotes climate-resilient farming practices.",
          "apply": "https://nmsa.dac.gov.in/"
        },
        {
          "title": "MIDH – Mission for Integrated Development of Horticulture",
          "description": "Supports holistic growth of horticulture.",
          "apply": "https://midh.gov.in/"
        },
        {
          "title": "Paramparagat Krishi Vikas Yojana (PKVY)",
          "description": "Encourages organic farming in clusters.",
          "apply": "https://pkvy.nic.in/"
        },
        {
          "title": "National Project on Organic Farming",
          "description": "Promotes organic farming and certification.",
          "apply": "https://ncof.dacnet.nic.in/"
        },
        {
          "title": "Fasal Bima Yojana",
          "description": "Comprehensive crop insurance for all stages.",
          "apply": "https://pmfby.gov.in/"
        },
        {
          "title": "MKSP – Mahila Kisan Sashaktikaran Pariyojana",
          "description": "Empowers women farmers through training and support.",
          "apply": "https://nrlm.gov.in/"
        },
        {
          "title": "Operation Greens",
          "description": "Supports farmers growing tomato, onion, and potato.",
          "apply": "https://mofpi.nic.in/"
        },
        {
          "title": "Agri-Clinics and Agri-Business Centres Scheme",
          "description": "Promotes agripreneurship among agriculture graduates.",
          "apply": "https://www.agriclinics.net/"
        },
        {
          "title": "Farmers Producer Organizations (FPOs)",
          "description": "Support for farmer-owned business entities.",
          "apply": "https://sfacindia.com/"
        },
      ];

      for (var scheme in initialSchemes) {
        await _database.insert('schemes', scheme, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
  }

  Future<void> _loadSchemes() async {
    final List<Map<String, dynamic>> schemes = await _database.query('schemes');
    setState(() {
      _schemes = schemes;
    });
  }

  Future<void> _saveScheme() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) return;

    final data = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'apply': _applyLinkController.text,
    };

    if (_editingId == null) {
      await _database.insert('schemes', data, conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await _database.update('schemes', data, where: 'id = ?', whereArgs: [_editingId]);
    }

    _titleController.clear();
    _descriptionController.clear();
    _applyLinkController.clear();
    _editingId = null;
    _loadSchemes();
  }

  Future<void> _deleteScheme(int id) async {
    await _database.delete('schemes', where: 'id = ?', whereArgs: [id]);
    _loadSchemes();
  }

  void _showSchemeDialog(BuildContext context, {int? id, String? title, String? description, String? apply}) {
    _titleController.text = title ?? "";
    _descriptionController.text = description ?? "";
    _applyLinkController.text = apply ?? "";
    _editingId = id;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(id == null ? "Add Scheme" : "Edit Scheme"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Scheme Name')),
                TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description')),
                TextField(controller: _applyLinkController, decoration: const InputDecoration(labelText: 'Apply Link')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                _saveScheme();
                Navigator.pop(dialogContext);
              },
              child: Text(id == null ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Govt Schemes'), backgroundColor: Colors.purple),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: _schemes.length,
        itemBuilder: (context, index) {
          final scheme = _schemes[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(scheme["title"], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(scheme["description"]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showSchemeDialog(
                      context,
                      id: scheme["id"],
                      title: scheme["title"],
                      description: scheme["description"],
                      apply: scheme["apply"],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteScheme(scheme["id"]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () => _showSchemeDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
