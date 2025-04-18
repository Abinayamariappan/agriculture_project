import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'database_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class JobsPage extends StatefulWidget {
  @override
  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> allJobs = [];
  String selectedStatus = 'All';
  String searchQuery = '';
  late TabController _tabController;

  final List<String> jobTypes = [
    'All',
    'Farmland',
    'Drip Irrigation',
    'Pesticide Spraying'
  ];

  final String defaultPhoneNumber = '+918838778182'; // ✅ Predefined fallback number

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: jobTypes.length, vsync: this);
    _tabController.addListener(loadAllJobs);
    loadAllJobs();
  }

  Future<void> loadAllJobs() async {
    final farmlands = await DatabaseHelper.instance.getFarmlandRequests();
    final irrigation = await DatabaseHelper.instance.getDripIrrigationRequests();
    final pesticides = await DatabaseHelper.instance.getPesticideRequests();

    setState(() {
      allJobs = [
        ...farmlands.map((e) => {...e, 'jobType': 'Farmland'}),
        ...irrigation.map((e) => {...e, 'jobType': 'Drip Irrigation'}),
        ...pesticides.map((e) => {...e, 'jobType': 'Pesticide Spraying'}),
      ];
    });
  }

  List<Map<String, dynamic>> get filteredJobs {
    final currentType = jobTypes[_tabController.index];
    return allJobs.where((job) {
      final matchesStatus = selectedStatus == 'All' || job['status'] == selectedStatus;
      final matchesType = currentType == 'All' || job['jobType'] == currentType;
      final matchesSearch = searchQuery.isEmpty ||
          (job['name']?.toLowerCase() ?? job['type']?.toLowerCase() ?? '').contains(searchQuery.toLowerCase()) ||
          (job['location']?.toLowerCase() ?? '').contains(searchQuery.toLowerCase());
      return matchesStatus && matchesType && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final jobsToShow = filteredJobs;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Farming Jobs"),
        backgroundColor: Colors.green,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => selectedStatus = value),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'All', child: Text('All')),
              PopupMenuItem(value: 'Pending', child: Text('Pending')),
              PopupMenuItem(value: 'Requested', child: Text('Requested')),
              PopupMenuItem(value: 'Completed', child: Text('Completed')),
            ],
            icon: Icon(Icons.filter_alt),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search jobs...',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => searchQuery = value),
              ),
            ),

            // ✅ Tabs
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.green[800],
              indicatorColor: Colors.green,
              tabs: jobTypes.map((type) => Tab(text: type)).toList(),
            ),

            // ✅ Job List
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: jobTypes.map((type) {
                  final jobs = filteredJobs;
                  return jobs.isEmpty
                      ? Center(child: Text('No jobs found'))
                      : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      children: jobs.map((job) => buildJobCard(job)).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildJobCard(Map<String, dynamic> job) {
    final Uint8List? imageBytes = job['image'];
    final jobName = job['name'] ?? job['type'] ?? 'Unnamed Job';
    final location = job['location'] ?? 'Unknown';
    final wages = job['wages']?.toString() ?? 'N/A';
    final status = job['status'] ?? 'Pending';
    final jobType = job['jobType'] ?? 'Job';

    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageBytes != null
                      ? Image.memory(imageBytes, width: 60, height: 60, fit: BoxFit.cover)
                      : Icon(Icons.agriculture, size: 60, color: Colors.green),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(jobName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("📍 $location"),
                      Text("💰 ₹$wages / day"),
                      Text("📌 $jobType | $status"),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.share, color: Colors.green),
                      onPressed: () async {
                        final phone = defaultPhoneNumber;
                        final message = '''
🌾 *Farming Job Opportunity* 🌾
📌 *Job:* $jobName
📍 *Location:* $location
💰 *Wages:* ₹$wages/day
📞 *Contact:* $phone
                        ''';
                        await Share.share(message);
                      },
                    ),
                    Icon(
                      status == 'Pending'
                          ? Icons.schedule
                          : status == 'Requested'
                          ? Icons.hourglass_top
                          : Icons.check_circle,
                      color: status == 'Pending'
                          ? Colors.orange
                          : status == 'Requested'
                          ? Colors.blue
                          : Colors.green,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () async {
                final Uri phoneUri = Uri(scheme: 'tel', path: defaultPhoneNumber);
                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Cannot launch dialer'),
                  ));
                }
              },
              icon: Icon(Icons.phone),
              label: Text("Contact"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
