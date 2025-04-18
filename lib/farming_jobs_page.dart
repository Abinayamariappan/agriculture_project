import 'package:flutter/material.dart';
import 'dart:async';
import 'database_helper.dart';

class FarmingJobsPage extends StatefulWidget {
  final int? farmerId;
  const FarmingJobsPage({super.key, this.farmerId});

  @override
  _FarmingJobsPageState createState() => _FarmingJobsPageState();
}

class _FarmingJobsPageState extends State<FarmingJobsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _jobs = [];
  String searchQuery = "";
  String filterBy = "All";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    try {
      final farmerId = widget.farmerId;
      final farmlandJobs = await DatabaseHelper.instance.getFarmlandRequests(farmerId: farmerId);
      final irrigationJobs = await DatabaseHelper.instance.getDripIrrigationRequests(farmerId: farmerId);
      final pesticideJobs = await DatabaseHelper.instance.getPesticideRequests(farmerId: farmerId);


      // Debug logs to check for wages values
      print("Sample farmland job: ${farmlandJobs.isNotEmpty ? farmlandJobs.first : 'No farmland jobs'}");
      print("Sample irrigation job: ${irrigationJobs.isNotEmpty ? irrigationJobs.first : 'No irrigation jobs'}");
      print("Sample pesticide job: ${pesticideJobs.isNotEmpty ? pesticideJobs.first : 'No pesticide jobs'}");

      final allJobs = [
        ...farmlandJobs.map((f) => {
          'id': f['id'],
          'name': f['name'],
          'location': f['location'],
          // Convert wages to String to ensure consistent handling regardless of original type
          'wages': f['wages']?.toString() ?? 'N/A',
          'status': f['status'],
          'category': 'Farmland',
        }),
        ...irrigationJobs.map((i) => {
          'id': i['id'],
          'name': i['name'],
          'location': i['location'],
          'wages': i['wages']?.toString() ?? 'N/A',
          'status': i['status'],
          'category': 'Irrigation',
        }),
        ...pesticideJobs.map((p) => {
          'id': p['id'],
          'name': p['name'],
          'location': p['location'],
          'wages': p['wages']?.toString() ?? 'N/A',
          'status': p['status'],
          'category': 'Pesticide',
        }),
      ];

      setState(() {
        _jobs = allJobs.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading jobs: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> updateJobStatus(String category, int jobId, String newStatus) async {
    final db = await DatabaseHelper.instance.database;

    String table = category == "Farmland"
        ? 'farmlands'
        : category == "Irrigation"
        ? 'drip_irrigation'
        : 'pesticides';

    await db.update(table, {'status': newStatus}, where: 'id = ?', whereArgs: [jobId]);
  }

  Future<void> deleteJob(String category, int jobId) async {
    final db = await DatabaseHelper.instance.database;

    String table = category == "Farmland"
        ? 'farmlands'
        : category == "Irrigation"
        ? 'drip_irrigation'
        : 'pesticides';

    await db.delete(table, where: 'id = ?', whereArgs: [jobId]);
  }

  void _toggleJobStatus(int jobId) async {
    final job = _jobs.firstWhere((j) => j['id'] == jobId);
    final newStatus = job['status'] == "Pending" ? "Completed" : "Pending";
    await updateJobStatus(job['category'], jobId, newStatus);
    await _loadJobs();
  }

  Widget _buildSearchAndFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: "Search jobs...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.green),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ["All", "Pending", "Completed"].map(_buildFilterOption).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterOption(String value) {
    return RadioListTile(
      value: value,
      groupValue: filterBy,
      title: Text(value),
      onChanged: (val) {
        setState(() => filterBy = val.toString());
        Navigator.pop(context);
      },
    );
  }

  Widget _buildJobList(String category) {
    final filtered = _jobs.where((job) {
      final matchCategory = category == "All" || job['category'] == category;
      final matchSearch = searchQuery.isEmpty || job['name'].toLowerCase().contains(searchQuery.toLowerCase());
      final matchStatus = filterBy == "All" || job['status'] == filterBy;
      return matchCategory && matchSearch && matchStatus;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("No jobs found", style: TextStyle(fontSize: 16)));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildJobCard(filtered[index]),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    // Debug log to check individual job wage values
    print("Building job card for: ${job['name']}, wages: ${job['wages']}");

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(job['location'], style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                // Display wages with proper handling of different types
                Text(
                  job['wages'] != null && job['wages'] != 'N/A' ? "₹${job['wages']}" : "₹N/A",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(job['status']),
                  backgroundColor: job['status'] == "Pending" ? Colors.orange.shade100 : Colors.green.shade100,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: job['status'] == "Pending" ? Colors.orange : Colors.green,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        job['status'] == "Pending" ? Icons.check_circle : Icons.replay,
                        color: job['status'] == "Pending" ? Colors.green : Colors.orange,
                      ),
                      onPressed: () => _toggleJobStatus(job['id']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Job"),
                            content: const Text("Are you sure you want to delete this job?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await deleteJob(job['category'], job['id']);
                          await _loadJobs();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Farming Jobs", style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "Farmland"),
            Tab(text: "Irrigation"),
            Tab(text: "Pesticide"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          _buildSearchAndFilterRow(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildJobList("All"),
                _buildJobList("Farmland"),
                _buildJobList("Irrigation"),
                _buildJobList("Pesticide"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}