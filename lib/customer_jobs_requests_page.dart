import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database_helper.dart'; // Replace with your actual database helper

class CustomerJobsRequestsPage extends StatefulWidget {
  final VoidCallback updatePendingJobCount;

  const CustomerJobsRequestsPage({
    Key? key,
    required this.updatePendingJobCount,
  }) : super(key: key);

  @override
  _CustomerJobsRequestsPageState createState() =>
      _CustomerJobsRequestsPageState();
}

class _CustomerJobsRequestsPageState extends State<CustomerJobsRequestsPage> {
  List<Map<String, dynamic>> jobRequests = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchJobRequests();
  }

  Future<void> _fetchJobRequests() async {
    final jobs = await DatabaseHelper.instance.getPendingCustomerJobs();
    setState(() {
      jobRequests = jobs;
    });
  }


  List<Map<String, dynamic>> get filteredJobs {
    return jobRequests.where((job) {
      final query = searchQuery.toLowerCase();
      return job['title'].toLowerCase().contains(query) ||
          job['location'].toLowerCase().contains(query) ||
          job['description'].toLowerCase().contains(query);
    }).toList();
  }

  void _showContactDialog(String phone) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Contact Customer"),
        content: Text("Phone: $phone"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Call"),
            onPressed: () async {
              final Uri phoneUri = Uri(scheme: 'tel', path: phone);
              Navigator.pop(context);
              if (await canLaunchUrl(phoneUri)) {
                await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not launch phone dialer')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _shareJob(Map<String, dynamic> job) {
    final message = '''
📢 *Farming Job Request* 📢
🔹 *Title:* ${job['title']}
📍 *Location:* ${job['location']}
📝 *Description:* ${job['description']}
📞 *Contact:* ${job['customer_phone']}
''';
    Share.share(message);
  }

  Widget buildJobCard(Map<String, dynamic> job) {
    final imageBytes =
    job['image'] != null ? base64Decode(job['image']) : null;
    final status = job['status'] ?? 'Pending';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                imageBytes != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(imageBytes,
                      width: 60, height: 60, fit: BoxFit.cover),
                )
                    : Icon(Icons.agriculture,
                    size: 60, color: Colors.grey.shade400),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job['title'] ?? 'No Title',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("📍 ${job['location']}",
                          style: TextStyle(color: Colors.grey[700])),
                      Text("📞 ${job['customer_phone']}",
                          style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(job['description'] ?? 'No Description'),
            const SizedBox(height: 10),
            Row(
              children: [
                Text("Status: ",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(status, style: TextStyle(color: Colors.orange)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.phone, color: Colors.green),
                  onPressed: () => _showContactDialog(job['customer_phone']),
                ),
                IconButton(
                  icon: Icon(Icons.share, color: Colors.blue),
                  onPressed: () => _shareJob(job),
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
    final jobsToShow = filteredJobs;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: TextField(
          onChanged: (value) => setState(() => searchQuery = value),
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search job requests...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.white),
          ),
        ),
      ),
      body: jobsToShow.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "No pending job requests found.",
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ),
      )
          : ListView.builder(
        itemCount: jobsToShow.length,
        itemBuilder: (context, index) =>
            buildJobCard(jobsToShow[index]),
      ),
    );
  }
}
