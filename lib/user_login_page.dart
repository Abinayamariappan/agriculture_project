import 'package:flutter/material.dart';
import 'user_homepage.dart';
import 'user_registration_page.dart';

class UserLoginPage extends StatefulWidget {
  @override
  _UserLoginPageState createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _login() {
    if (_formKey.currentState!.validate()) {
      String name = nameController.text.trim();
      String phone = phoneController.text.trim();
      String password = passwordController.text.trim();

      if (name == "Abinaya" && phone == "8838778182" && password == "password123") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserHomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid credentials!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/User_bg.jpg', // Ensure this image exists in assets
            fit: BoxFit.cover,
          ),

          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Centered Logo
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/C.png'),
                    ),
                    SizedBox(height: 20),

                    // Transparent Card for Login Form
                    Card(
                      color: Colors.white.withOpacity(0.8), // Semi-transparent background
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // "User Login" Title
                            Text(
                              "User Login",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20),

                            // Login Form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      labelText: "Name",
                                      prefixIcon: Icon(Icons.person),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) return "Enter your name";
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  TextFormField(
                                    controller: phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      labelText: "Phone Number",
                                      prefixIcon: Icon(Icons.phone),
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) return "Enter your phone number";
                                      if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return "Enter a valid 10-digit phone number";
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 10),
                                  TextFormField(
                                    controller: passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: "Password",
                                      prefixIcon: Icon(Icons.lock),
                                      border: OutlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) return "Enter your password";
                                      if (value.length < 6) return "Password must be at least 6 characters";
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),

                            // Login Button
                            ElevatedButton(
                              onPressed: _login,
                              child: Text("Login"),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            SizedBox(height: 10),

                            // Forgot Password
                            TextButton(
                              onPressed: () {},
                              child: Text("Forgot Password?"),
                            ),

                            // Register Link
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => UserRegistrationPage()),
                                );
                              },
                              child: Text("Don't have an account? Register"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
