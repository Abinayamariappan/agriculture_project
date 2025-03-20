import 'package:flutter/material.dart';
import 'user_login_page.dart';

class UserRegistrationPage extends StatefulWidget {
  @override
  _UserRegistrationPageState createState() => _UserRegistrationPageState();
}

class _UserRegistrationPageState extends State<UserRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _registerUser() {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text.trim();
      String phone = _phoneController.text.trim();
      String password = _passwordController.text.trim();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Successful! Please Login.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserLoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/User_bg.jpg'), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/C.png'), // Logo
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2), // White border
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Card(
                    color: Colors.transparent, // Transparent background
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "User Registration",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: "Full Name",
                                    labelStyle: TextStyle(color: Colors.white),
                                    prefixIcon: Icon(Icons.person, color: Colors.white),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  validator: (value) =>
                                  value!.isEmpty ? "Please enter your name" : null,
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  controller: _phoneController,
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: "Phone Number",
                                    labelStyle: TextStyle(color: Colors.white),
                                    prefixIcon: Icon(Icons.phone, color: Colors.white),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value!.isEmpty) return "Enter your phone number";
                                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                                      return "Enter a valid 10-digit phone number";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  controller: _passwordController,
                                  style: TextStyle(color: Colors.white),
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    labelStyle: TextStyle(color: Colors.white),
                                    prefixIcon: Icon(Icons.lock, color: Colors.white),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) return "Enter your password";
                                    if (value.length < 6) {
                                      return "Password must be at least 6 characters";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white, // Button color
                                      foregroundColor: Colors.black, // Text color
                                    ),
                                    onPressed: _registerUser,
                                    child: Text("Register"),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => UserLoginPage()),
                                      );
                                    },
                                    child: Text("Already have an account? Login",
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
