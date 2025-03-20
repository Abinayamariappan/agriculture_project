import 'package:flutter/material.dart';
import 'farmer_login.dart';
import 'admin_login.dart';
import 'footer.dart'; // Import the footer widget
import 'user_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage("assets/agriculture_background.jpg"), context).then((_) {
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/agriculture_background.jpg",
                fit: BoxFit.cover,
              ),
            ),

            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),

            Positioned(
              top: 20,
              left: 20,
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: const AssetImage("assets/C.png"),
              ),
            ),

            Positioned(
              top: 25,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.admin_panel_settings, size: 30, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminLoginPage()),
                  );
                },
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Welcome to",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "AgriConnect",
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [Shadow(blurRadius: 5.0, color: Colors.black45, offset: Offset(2, 2))],
                    ),
                  ),
                  const SizedBox(height: 50),
                  AnimatedOpacity(
                    opacity: _isLoaded ? 1.0 : 0.0,
                    duration: const Duration(seconds: 1),
                    child: Column(
                      children: [
                        CustomButton(
                          text: 'Farmer',
                          icon: Icons.agriculture,
                          backgroundColor: Colors.green,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FarmerLogin()),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: 'User',
                          icon: Icons.person,
                          backgroundColor: Colors.brown,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserNavigationBar()), // ✅ Corrected
                            );
                          },

                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FooterWidget(), // ✅ Placed correctly at the bottom
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 60,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 26, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 10,
          shadowColor: Colors.black54,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
