import 'dart:ui';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'farmer_dashboard.dart';

class OTPVerification extends StatefulWidget {
  final String name;
  final String phone;

  const OTPVerification({Key? key, required this.name, required this.phone}) : super(key: key);

  @override
  _OTPVerificationState createState() => _OTPVerificationState();
}

class _OTPVerificationState extends State<OTPVerification> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;

  // ✅ Simulate OTP Verification (Replace with real OTP API)
  Future<void> _verifyOTP() async {
    if (otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Simulated OTP Verification (Replace with actual API call)
    await Future.delayed(const Duration(seconds: 2));

    if (otpController.text == "1234") {
      int farmerId = await DatabaseHelper.instance.registerFarmer(
        name: widget.name,
        phone: widget.phone,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FarmerDashboard(
              farmerId: farmerId.toString(),  // ✅ Now defined!
              name: widget.name,
              phone: widget.phone,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP! Please try again.')),
      );
    }


    setState(() {
      isLoading = false;
    });
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
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3), // Increased blur for smooth effect
              child: Container(color: Colors.black.withOpacity(0.3)), // Darker overlay for better contrast
            ),
          ),

          // ✅ Centered OTP Card
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.white.withOpacity(0.85), // Blended effect
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ Logo
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/C.png'),
                          backgroundColor: Colors.transparent,
                        ),
                        const SizedBox(height: 20),

                        // ✅ Title
                        const Text(
                          "OTP Verification",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Enter the OTP sent to ${widget.phone}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 20),

                        // ✅ OTP Input Field
                        TextField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, letterSpacing: 5),
                          decoration: InputDecoration(
                            labelText: 'Enter OTP',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ✅ Verify Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: isLoading ? null : _verifyOTP,
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Verify OTP', style: TextStyle(fontSize: 18, color: Colors.white)),
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