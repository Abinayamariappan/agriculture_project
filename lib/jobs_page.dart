import 'package:flutter/material.dart';

class JobsPage extends StatefulWidget {
  @override
  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  List<Map<String, String>> jobs = [
    {'title': 'Harvesting Assistant', 'status': 'Pending', 'location': 'Tamil Nadu'},
    {'title': 'Irrigation Setup', 'status': 'Completed', 'location': 'Kerala'},
    {'title': 'Soil Testing', 'status': 'Pending', 'location': 'Karnataka'},
  ];

  String selectedFilter = 'All';

  void requestJob(int index) {
    setState(() {
      jobs[index]['status'] = 'Requested';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Farming Jobs'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'All', child: Text('All')),
              PopupMenuItem(value: 'Pending', child: Text('Pending')),
              PopupMenuItem(value: 'Completed', child: Text('Completed')),
            ],
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: ListView(
        children: jobs.where((job) => selectedFilter == 'All' || job['status'] == selectedFilter).map((job) {
          int index = jobs.indexOf(job);
          return Card(
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                ListTile(
                  title: Text(job['title']!),
                  subtitle: Text('Status: ${job['status']}\nLocation: ${job['location']}'),
                  trailing: job['status'] == 'Pending'
                      ? Icon(Icons.schedule, color: Colors.orange)
                      : job['status'] == 'Requested'
                      ? Icon(Icons.hourglass_top, color: Colors.blue)
                      : Icon(Icons.check_circle, color: Colors.green),
                ),
                if (job['status'] == 'Pending')
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () => requestJob(index),
                      child: Text('Request Job'),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
