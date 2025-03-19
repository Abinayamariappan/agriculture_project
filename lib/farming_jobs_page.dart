import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'database_helper.dart';

class FarmingJobsPage extends StatefulWidget {
  @override
  _FarmingJobsPageState createState() => _FarmingJobsPageState();
}

class _FarmingJobsPageState extends State<FarmingJobsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _allJobs = [];
  List<Map<String, dynamic>> _farmlandJobs = [];
  List<Map<String, dynamic>> _irrigationJobs = [];
  List<Map<String, dynamic>> _pesticideJobs = [];
  String searchQuery = "";
  String filterBy = "All";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadJobs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    final jobs = await DatabaseHelper.instance.getProducts();
    setState(() {
      _allJobs = jobs.where((j) => j['category'] == 'Farmland' || j['category'] == 'Drip Irrigation' || j['category'] == 'Pesticide Spraying').toList();
      _farmlandJobs = jobs.where((j) => j['category'] == 'Farmland').toList();
      _irrigationJobs = jobs.where((j) => j['category'] == 'Drip Irrigation').toList();
      _pesticideJobs = jobs.where((j) => j['category'] == 'Pesticide Spraying').toList();
    });
  }

  Future<void> _deleteJob(int id) async {
    await DatabaseHelper.instance.deleteProduct(id);
    _loadJobs();
  }

  void _toggleStatus(int index, List<Map<String, dynamic>> jobs) async {
    setState(() {
      jobs[index]['status'] = jobs[index]['status'] == "Pending" ? "Completed" : "Pending";
    });
    await DatabaseHelper.instance.updateProductStatus(jobs[index]['id'], jobs[index]['status']);
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => searchQuery = value);
    });
  }

  List<Map<String, dynamic>> _filteredJobs(List<Map<String, dynamic>> jobs) {
    return jobs.where((job) =>
    (filterBy == "All" || job['status'] == filterBy) &&
        job['name'].toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farming Jobs', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Farmland'),
            Tab(text: 'Irrigation'),
            Tab(text: 'Pesticide'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterRow(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildJobList(_filteredJobs(_allJobs), "No job requests yet!"),
                _buildJobList(_filteredJobs(_farmlandJobs), "No farmland jobs available!"),
                _buildJobList(_filteredJobs(_irrigationJobs), "No irrigation jobs available!"),
                _buildJobList(_filteredJobs(_pesticideJobs), "No pesticide spraying jobs available!"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                labelText: "Search Jobs",
                hintText: "Search by name...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded search bar
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200], // Light background
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.green, size: 28),
            onPressed: () {
              _showFilterMenu();
            },
          ),
        ],
      ),
    );
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Filter Jobs",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildFilterOption("All"),
              _buildFilterOption("Pending"),
              _buildFilterOption("Completed"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String option) {
    return ListTile(
      title: Text(option, style: const TextStyle(fontSize: 16)),
      trailing: filterBy == option
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      onTap: () {
        setState(() => filterBy = option);
        Navigator.pop(context);
      },
    );
  }



  Widget _buildJobList(List<Map<String, dynamic>> jobs, String emptyMessage) {
    return jobs.isEmpty
        ? Center(
      child: Text(
        emptyMessage,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              leading: ElevatedButton(
                onPressed: () => _toggleStatus(index, jobs),
                child: const Text("Change Status"),
              ),
              title: Text(job['name'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Status: ${job['status']}", style: TextStyle(color: job['status'] == 'Pending' ? Colors.orange : Colors.green)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteJob(job['id'])),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
