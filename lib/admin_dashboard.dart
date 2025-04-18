import 'package:flutter/material.dart';
import 'govt_schemes_admin.dart';
import 'admin_login.dart';
import 'generate_report.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AdminLoginPage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDashboardTile(
            context,
            "Manage Govt Schemes",
            Icons.account_balance,
            Colors.purple,
                () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GovtSchemesAdminPage()),
                ),
          ),
          const SizedBox(height: 20), // Adds spacing
          _buildDashboardTile(
            context,
            "Manage Reports",
            Icons.bar_chart,
            Colors.orange,
                () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GenerateReportPage()),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTile(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 12), // Increased spacing
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 70, // Increased button height
          padding: const EdgeInsets.symmetric(horizontal: 16), // Added padding
          child: Row(
            children: [
              Icon(icon, size: 35, color: Colors.white), // Slightly larger icon
              const SizedBox(width: 16), // Space between icon and text
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const Icon(
                  Icons.arrow_forward_ios, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}