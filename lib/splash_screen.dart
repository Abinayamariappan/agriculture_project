import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart'; // Change to your actual home page

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ Full-Screen Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/splash_bg.jpg', // Ensure this image is in your assets folder
              fit: BoxFit.cover,
            ),
          ),

          // ✅ Blurred Overlay for Readability
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)), // Soft dark overlay
          ),

          // ✅ Centered Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // **🚀 Animated Logo with Zoom Effect**
                ZoomIn(
                  duration: const Duration(seconds: 1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      'assets/C.png',
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // **🌟 Animated App Name with Bounce Effect**
                BounceInDown(
                  child: Text(
                    "Fresh Harvest",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [Shadow(blurRadius: 3.0, color: Colors.black38, offset: Offset(2, 2))],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // **💡 Animated Tagline for Extra Style**
                FadeInDown(
                  delay: const Duration(milliseconds: 500),
                  child: Text(
                    "Connecting Farmers to the Market",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // **⚡ Smooth Spinning Loading Animation**
                Spin(
                  duration: const Duration(seconds: 2),
                  child: const SpinKitFadingCircle(color: Colors.white, size: 50),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
