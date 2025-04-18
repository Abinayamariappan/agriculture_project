import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // Required for BackdropFilter
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'farmer_dashboard.dart';
import 'farmer_register.dart';

class FarmerLogin extends StatefulWidget {
  const FarmerLogin({super.key});

  @override
  _FarmerLoginState createState() => _FarmerLoginState();
}

class _FarmerLoginState extends State<FarmerLogin> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoggedInFarmer(); // 👈 This will check shared prefs instead
  }

  Future<void> _checkLoggedInFarmer() async {
    final prefs = await SharedPreferences.getInstance();
    final farmerId = prefs.getInt('farmerId');

    if (farmerId != null) {
      final farmer = await DatabaseHelper.instance.getFarmerById(farmerId); // You'll need to add this if missing

      if (farmer != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FarmerDashboard(
              farmerId: farmerId.toString(),
              name: farmer['name'] ?? "Unknown",
              phone: farmer['phone'] ?? "Not Available",
            ),
          ),
        );
      }
    }
  }



  // ✅ Login Function

  Future<void> _login() async {
    String phoneInput = _phoneController.text.trim();

    if (phoneInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    print("📌 Login Attempted with Phone: $phoneInput");

    final farmer = await DatabaseHelper.instance.getFarmerByPhone(phoneInput);
    print("📌 Farmer Found: $farmer");

    if (farmer != null) {
      String farmerId = farmer['id'].toString();  // Ensure it's a string for navigation
      String name = farmer['name'] ?? "Unknown";
      String phone = farmer['phone'] ?? "Not Available";

      final prefs = await SharedPreferences.getInstance();

      // ✅ Save farmerId as int and phone as String to SharedPreferences
      await prefs.setInt('farmerId', farmer['id']);
      await prefs.setString('loggedInFarmerPhone', phone);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FarmerDashboard(
              farmerId: farmerId,
              name: name,
              phone: phone,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid phone number or not registered')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/login_background.jpg', // Your selected background image
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Blurred Overlay for Better Readability
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(color: Colors.black.withOpacity(0.2)), // Subtle dark overlay
            ),
          ),

          // ✅ Centered Login Card
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white.withOpacity(0.7), // ✅ Semi-transparent card
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ Logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          'assets/C.png',
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ✅ Title
                      const Text(
                        "Farmer Login",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // ✅ Input Field
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Enter Phone Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.phone, color: Colors.green),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ✅ Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('Login', style: TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ✅ Register Link
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FarmerRegister()),
                          );
                        },
                        child: const Text(
                          "New Farmer? Register Here",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}