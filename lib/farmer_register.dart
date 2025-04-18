import 'dart:ui';
import 'package:flutter/material.dart';
import 'otp_verification.dart';
import 'database_helper.dart';

class FarmerRegister extends StatefulWidget {
  @override
  _FarmerRegisterState createState() => _FarmerRegisterState();
}

class _FarmerRegisterState extends State<FarmerRegister> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // ✅ Register Farmer with OTP Verification
  Future<void> _registerFarmer() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();

    // ✅ Basic Validations
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name and phone number')),
      );
      return;
    }

    if (name.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name must be at least 3 characters long')),
      );
      return;
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit phone number')),
      );
      return;
    }

    // ✅ Check if Farmer Already Registered
    final existingFarmer = await DatabaseHelper.instance.getFarmerByPhone(phone);
    if (existingFarmer != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number already registered. Please log in.')),
      );
      return;
    }

    // ✅ Navigate to OTP Verification Screen (Pass Name & Phone)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPVerification(
          name: name,
          phone: phone,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/login_background.jpg', // Ensure this file exists in assets
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Blurred Background for Readability
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3), // Increase blur for better blending
              child: Container(color: Colors.black.withOpacity(0.3)), // Darker overlay for contrast
            ),
          ),

          // ✅ Centered Registration Card
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.white.withOpacity(0.85), // More transparent for smooth blending
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ Logo
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/C.png'), // Ensure this file exists
                          backgroundColor: Colors.transparent,
                        ),
                        const SizedBox(height: 20),

                        // ✅ Title
                        const Text(
                          "Farmer Registration",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ✅ Full Name Input
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            prefixIcon: const Icon(Icons.person, color: Colors.green),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // ✅ Phone Number Input
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            prefixIcon: const Icon(Icons.phone, color: Colors.green),
                          ),
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _registerFarmer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10), // spacing between buttons

                    // ✅ "Already registered? Log in" Button
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/farmer_login'); // Change this route as needed
                          },
                          child: const Text(
                            'Already registered? Log in',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                          ),
                        ),

                      ],
                    ),
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