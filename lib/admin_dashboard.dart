import 'package:flutter/material.dart';
import 'govt_schemes_admin.dart'; // Ensure this file exists
import 'admin_login.dart'; // Ensure Admin Login Page exists

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
                MaterialPageRoute(builder: (context) => const AdminLoginPage()), // ✅ Fixed Class Name
              );
            },
          ),
        ],
      ),
      body: Center(
        child: _buildDashboardButton(
          context,
          "Manage Govt Schemes",
          Colors.purple,
          Icons.account_balance,
          const GovtSchemesAdminPage(),
        ),
      ),
    );
  }

  // ✅ Fixed .withOpacity() Issue by Using Color.fromARGB()
  Widget _buildDashboardButton(BuildContext context, String title, Color color, IconData icon, Widget page) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color.fromARGB((0.8 * 255).toInt(), color.red, color.green, color.blue), // ✅ Fixed
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
