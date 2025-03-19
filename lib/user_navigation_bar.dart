import 'package:flutter/material.dart';
import 'user_homepage.dart';
import 'jobs_page.dart';
import 'request_page.dart';
import 'disease_identification_page.dart';
import 'dashboard_page.dart';

class UserNavigationBar extends StatefulWidget {
  @override
  _UserNavigationBarState createState() => _UserNavigationBarState();
}

class _UserNavigationBarState extends State<UserNavigationBar> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    UserHomePage(),
    JobsPage(),
    RequestPage(),
    DiseaseIdentificationPage(),
    DashboardPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Display selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update index
          });
        },
        backgroundColor: Colors.green, // ✅ Change background color for visibility
        selectedItemColor: Colors.white, // ✅ Highlight selected item
        unselectedItemColor: Colors.black54, // ✅ Change unselected item color
        showUnselectedLabels: true, // ✅ Ensure all labels are visible
        type: BottomNavigationBarType.fixed, // ✅ Prevents shifting effect
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Jobs"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 30), label: "Request"),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Disease"),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
        ],
      ),
    );
  }
}
