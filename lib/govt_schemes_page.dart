import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

class GovtSchemesPage extends StatefulWidget {
  const GovtSchemesPage({super.key});

  @override
  _GovtSchemesPageState createState() => _GovtSchemesPageState();
}

class _GovtSchemesPageState extends State<GovtSchemesPage> {
  late Database _database;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    setState(() {
      _isLoading = true;
    });

    _database = await openDatabase(
      join(await getDatabasesPath(), 'schemes.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE schemes(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, apply TEXT)",
        );
      },
    );

    setState(() {
      _isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchSchemes() async {
    return await _database.query('schemes');
  }

  // Improved URL launcher function with proper error handling
  Future<void> _openSchemeWebsite(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No application link available.")),
      );
      return;
    }

    // Make sure URL has a scheme (http:// or https://)
    String processedUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      processedUrl = 'https://$url';
    }

    try {
      final Uri uri = Uri.parse(processedUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not launch: $processedUrl")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error launching URL: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Government Schemes'),
          backgroundColor: Colors.purple
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchSchemes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No government schemes available."));
          }

          final schemes = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: schemes.length,
            itemBuilder: (context, index) {
              final scheme = schemes[index];

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          scheme['title'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "📜 ${scheme['description']}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.open_in_browser, color: Colors.white),
                            label: const Text("Apply Now", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            onPressed: () => _openSchemeWebsite(context, scheme['apply']),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}