import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class CustomerJobsPage extends StatefulWidget {
  @override
  _CustomerJobsPageState createState() => _CustomerJobsPageState();
}

class _CustomerJobsPageState extends State<CustomerJobsPage> {
  List<Map<String, dynamic>> jobs = [];
  String selectedFilter = 'All';
  String searchQuery = '';
  String? imageBase64;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int customerId = prefs.getInt('currentUserId') ?? 0;

    final jobList = await DatabaseHelper.instance.getCustomerJobsByCustomerId(customerId);
    setState(() {
      jobs = jobList;
    });
  }

  void toggleJobStatus(int jobId, String currentStatus) async {
    final newStatus = currentStatus == 'Pending' ? 'Completed' : 'Pending';
    await DatabaseHelper.instance.updateCustomerJobStatus(jobId, newStatus);
    _loadJobs();
  }

  void deleteJob(int jobId) async {
    await DatabaseHelper.instance.deleteCustomerJob(jobId);
    _loadJobs();
  }

  void _showAddJobDialog(BuildContext context) {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final descriptionController = TextEditingController();
    final phoneController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Job"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Title", prefixIcon: Icon(Icons.title)),
              ),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: "Location", prefixIcon: Icon(Icons.location_on)),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: "Description", prefixIcon: Icon(Icons.description)),
                maxLines: 2,
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Customer Name", prefixIcon: Icon(Icons.person)),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Phone", prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              int customerId = prefs.getInt('currentUserId') ?? 0;

              if (titleController.text.isNotEmpty &&
                  locationController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                await DatabaseHelper.instance.insertCustomerJob(
                  titleController.text.trim(),
                  locationController.text.trim(),
                  descriptionController.text.trim(),
                  phoneController.text.trim(),
                  name: nameController.text.trim(),
                  imageBase64: null,
                  customerId: customerId, // <-- pass it here
                );
                Navigator.pop(context);
                _loadJobs();
              }
            },
            child: Text("Add Job"),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get filteredJobs {
    return jobs.where((job) {
      final matchesStatus = selectedFilter == 'All' || job['status'] == selectedFilter;
      final query = searchQuery.toLowerCase();
      final matchesSearch = job['title'].toLowerCase().contains(query) || job['location'].toLowerCase().contains(query);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customer Job Requests"),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => selectedFilter = value),
            itemBuilder: (context) => ['All', 'Pending', 'Completed']
                .map((status) => PopupMenuItem(value: status, child: Text(status)))
                .toList(),
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: jobs.isEmpty
          ? Center(child: Text("No jobs found."))
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: filteredJobs.length,
          itemBuilder: (context, index) {
            final job = filteredJobs[index];
            final image = job['image'] != null ? base64Decode(job['image']) : null;

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (image != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(image, height: 150, fit: BoxFit.cover),
                      ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(job['title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("📍 ${job['location']}"),
                          Text("📝 ${job['description']}"),
                          if (job['customer_name'] != null) Text("👤 ${job['customer_name']}"),
                          if (job['customer_phone'] != null) Text("📞 ${job['customer_phone']}"),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Chip(
                          label: Text(job['status']),
                          backgroundColor: getStatusColor(job['status']),
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed: () => toggleJobStatus(job['id'], job['status']),
                          child: Text(job['status'] == 'Pending' ? "Mark Completed" : "Mark Pending"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddJobDialog(context),
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }
}
